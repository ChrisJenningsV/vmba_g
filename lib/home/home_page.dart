import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/menu/menu.dart';
import 'package:package_info/package_info.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:open_appstore/open_appstore.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/data/globals.dart';



class HomePage extends StatefulWidget {
  HomePage({this.ads});

  final bool ads;

  @override
  State<StatefulWidget> createState() => new _HomeState();
}

class _HomeState extends State<HomePage> {
  Image appBarImage;
  Image appBarImageLeft;
  AssetImage mainBackGroundImage;
  AssetImage logoImage;
  bool _displayProcessingIndicator;
  Image alternativeBackgroundImage;
  bool gotBG = false;

  @override
  void initState() {
    super.initState();
    initLang(gblLanguage);
    _displayProcessingIndicator = true;
    waitAndThenHideProcessingIndicator();
  }

  waitAndThenHideProcessingIndicator() {
    Timer(const Duration(milliseconds: 400), () {
      setState(() {
        _displayProcessingIndicator = false;
      });
      checkForLatestVersion();
    });
  }

   initLang(String lang) async {
    //Future<Countrylist> getCountrylist() async {
    if( gblLanguage != 'en') {
      String jsonString = await rootBundle.loadString(
          'lib/assets/lang/$gblLanguage.json');
      gblLangMap = json.decode(jsonString);
    }
  }

  checkForLatestVersion() {
   // Version currentVersion;
   // Version latestVersion;
    String latestVersion;

    if( gblAction == 'UPDATEAVAILABLE') {
      _updateAppDialog();
      return;
    }

    PackageInfo.fromPlatform()
        .then((PackageInfo packageInfo) =>
            packageInfo.version + '.' + packageInfo.buildNumber)
        .then((String version) {

      latestVersion = Platform.isIOS
          ? gblSettings.latestBuildiOS
          : gblSettings.latestBuildAndroid;

      if( latestVersion == null ){
        // no new version
        return;
      }
      int cMajor = int.parse(version.split('.')[0]);
      int cMinor= int.parse(version.split('.')[1]);
      int cPatch= int.parse(version.split('.')[2]);
      int cBuild= int.parse(version.split('.')[3]);
      int lMajor= int.parse(latestVersion.split('.')[0]);
      int lMinor= int.parse(latestVersion.split('.')[1]);
      int lPatch= int.parse(latestVersion.split('.')[2]);
      int lBuild= int.parse(latestVersion.split('.')[3]);


      /*
      currentVersion = Version.parse(version);
      latestVersion = Version.parse(Platform.isIOS
          ? gblSettings.latestBuildiOS
          : gblSettings.latestBuildAndroid);
*/
      gblVersion = version;
      gblIsIos = Platform.isIOS;

      bool bNewBuilsAvailable = false;
      if( lMajor > cMajor ) { bNewBuilsAvailable = true;}
      if( lMajor == cMajor && lMinor > cMinor ) { bNewBuilsAvailable = true;}
      if( lMajor == cMajor && lMinor == cMinor && lPatch > cPatch ) { bNewBuilsAvailable = true;}
      if( lMajor == cMajor && lMinor == cMinor && lPatch == cPatch && lBuild > cBuild ) { bNewBuilsAvailable = true;}

      if( bNewBuilsAvailable == true){
        _updateAppDialog();
      }
    });
  }

  Future<File> file(String filename) async {
    WidgetsFlutterBinding.ensureInitialized();
    Directory dir = await getApplicationDocumentsDirectory();
    String pathName = p.join(dir.path, filename);
    return File(pathName);
  }

  @override
  void didChangeDependencies() {
    try {
      super.didChangeDependencies();
      appBarImage = Image.asset('lib/assets/$gblAppTitle/images/appBar.png',);
      String bgImage = 'lib/assets/$gblAppTitle/images/background.png';
      mainBackGroundImage = AssetImage(bgImage);
      logoImage = AssetImage('lib/assets/$gblAppTitle/images/loader.png');
      precacheImage(appBarImage.image, context);
      precacheImage(mainBackGroundImage, context);
      precacheImage(logoImage, context);
    } catch (e) {
      print(e);
    }
  }

  void _updateAppDialog() {
    var txt = '';
    if( gblSettings.optUpdateMsg != null && gblSettings.optUpdateMsg.isNotEmpty) {
      txt = gblSettings.optUpdateMsg;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text('Update App'),
            content:
                Text('A newer version of the app is available to download' + '\n' + txt),
            actions: <Widget>[
              new TextButton(
                child: new Text(
                  'Close',
                  style: TextStyle(color: Colors.black),
                ),
                style: TextButton.styleFrom(primary: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new TextButton(
                child: new Text(
                  'Update',
                  style: TextStyle(color: Colors.white),
                ),
                style: TextButton.styleFrom(
                    backgroundColor: gblSystemColors.primaryButtonColor ,
                    side: BorderSide(color:  gblSystemColors.textButtonTextColor, width: 1),
                    primary: gblSystemColors.primaryButtonTextColor),
                onPressed: () {
                  OpenAppstore.launch(
                      androidAppId: gblSettings.androidAppId,
                      iOSAppId: gblSettings.iOSAppId);
                },
              ),
            ]);
      },
    );
  }

  //Future<Widget> getImage() async {
    Widget getImage()  {
      return Container(
      //  decoration: BoxDecoration(
      //               image: DecorationImage(
      //                   image: mainBackGroundImage, fit: BoxFit.fitWidth))

      child: SingleChildScrollView(
        // reverse: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          //image: mainBackGroundImage
          children: <Widget>[
            Image(
                image: NetworkImage(gblSettings.backgroundImageUrl),
              fit: BoxFit.fitWidth,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var buttonShape;

    if( gblSettings.backgroundImageUrl != null && gblSettings.backgroundImageUrl.isNotEmpty) {
      try {
        var newImg = Image.network(gblSettings.backgroundImageUrl);
        if (newImg.image != null) {
          gotBG = true;
        }
      } catch(e) {
        gotBG = false;
      }
    }
   // var appLanguage = new AppLanguage();
 //   appLanguage.changeLanguage('fr');

    switch (gblSettings.aircode.toUpperCase()) {
      case 'SI':
        buttonShape = RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60.0),
                topRight: Radius.circular(60.0)));
        break;
      case 'T6':
        buttonShape = RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(60.0),
                bottomLeft: Radius.circular(60.0),
                topLeft: Radius.circular(60.0),
                topRight: Radius.circular(60.0)));
        break;
      default:
        buttonShape = null;
    }

    if (_displayProcessingIndicator) {
      return Scaffold(
          body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('lib/assets/$gblAppTitle/images/loader.png'),
            CircularProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TrText('Loading...'),
            ),
          ],
        ),
      ));
    } else {
      //print(mainBackGroundImage);
      //var bal = (gblFqtvBalance != null && gblFqtvBalance > 0) ?
      //Text('${gblSettings.fqtvName} balance $gblFqtvBalance', style: TextStyle(fontSize: 8.0),):Text(' ');

      return new Scaffold(

        appBar: new AppBar(
            brightness: gblSystemColors.statusBar,
            backgroundColor:
            gblSystemColors.primaryHeaderColor,
            title:
                gblIsLive ? appBarImage : Row( children: <Widget>[appBarImage, Text('Test', style: gblTitleStyle,)]),
            iconTheme: IconThemeData(
                color:
                gblSystemColors.headerTextColor)),
        body: Stack(
          children: <Widget>[
            Container(
                decoration: BoxDecoration(
                    image:  DecorationImage(
                        image: mainBackGroundImage, fit: BoxFit.fitWidth))),
            if (gotBG ) ClipRRect(child: getImage()),
            Container(
              //This container stops the alternative image from scrolling
              child: Text(''),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
            Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  gblNoNetwork ? Text('') : Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                  shape: buttonShape,
                                  backgroundColor: gblSystemColors.primaryButtonColor),
                              onPressed: () => Navigator.of(context)
                                  .pushNamedAndRemoveUntil('/FlightSearchPage',
                                      (Route<dynamic> route) => false),
                              child: Container(
                                height: 60,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(right: 5),
                                      child: Icon(
                                        Icons.flight_takeoff,
                                        color: Colors.white,
                                      ),
                                    ),
                                    TrText(
                                       'Book a flight',
                                       style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                  gblBuildFlavor == 'LM'
                      ? Row(
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                        shape: buttonShape,
                                        backgroundColor: gblSystemColors.primaryButtonColor),
                                    onPressed: () => Navigator.of(context)
                                        .pushNamedAndRemoveUntil('/AdsPage',
                                            (Route<dynamic> route) => false),
                                    child: Container(
                                      height: 60,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Padding(
                                            padding: EdgeInsets.only(right: 5),
                                            child: Icon(
                                              Icons.flight_takeoff,
                                              color: Colors.white,
                                            ),
                                          ),
                                          TrText(
                                            'Book an ADS Flight',
                                               style: TextStyle(color: Colors.white),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      : Row(),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: TextButton(
                              style: TextButton.styleFrom(
                                  shape: buttonShape,
                                  backgroundColor: gblSystemColors
                                      .primaryButtonColor),
                              onPressed: () => Navigator.of(context)
                                  .pushNamedAndRemoveUntil('/MyBookingsPage',
                                      (Route<dynamic> route) => false),
                              child: Container(
                                height: 60,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(right: 5),
                                      child: Icon(
                                        Icons.card_travel,
                                        color: Colors.white,
                                      ),
                                    ),
                                    TrText(
                                      'My Bookings & Check-in',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],

                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                  ),
                  gblNoNetwork ? Row( children: <Widget>[ Expanded( child: new Text( 'No Network Connection',
                        style: TextStyle( backgroundColor: Colors.red, color: Colors.white, fontSize: 18.0, ))) ]): Text(''),
                ],
              ),
            ),
          ],
        ),
        endDrawer: new DrawerMenu(),
      );
    }
  }
}

Widget home() {
  return new Container(
    child: new Center(
      child: new Text(
        'Home',
        style: new TextStyle(fontSize: 32.0),
      ),
    ),
  );
}

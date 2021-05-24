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
import 'package:version/version.dart';
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
    Version currentVersion;
    Version latestVersion;

    PackageInfo.fromPlatform()
        .then((PackageInfo packageInfo) =>
            packageInfo.version + '.' + packageInfo.buildNumber)
        .then((String version) {
      currentVersion = Version.parse(version);
      latestVersion = Version.parse(Platform.isIOS
          ? gblSettings.latestBuildiOS
          : gblSettings.latestBuildAndroid);

      gblVersion = version;
      gblIsIos = Platform.isIOS;
      if (latestVersion > currentVersion) {
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
    super.didChangeDependencies();
    appBarImage = Image.asset(      'lib/assets/$gblAppTitle/images/appBar.png',    );
String bgImage ='lib/assets/$gblAppTitle/images/background.png';
    mainBackGroundImage = AssetImage(bgImage);
    logoImage = AssetImage('lib/assets/$gblAppTitle/images/loader.png');
    precacheImage(appBarImage.image, context);
    precacheImage(mainBackGroundImage, context);
    precacheImage(logoImage, context);
  }

  void _updateAppDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text('Update App'),
            content:
                Text('A newer version of the app is available to download'),
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
                style: TextButton.styleFrom(primary: Colors.black),
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

  Future<Widget> getImage() async {
    return Container(
      //  decoration: BoxDecoration(
      //               image: DecorationImage(
      //                   image: mainBackGroundImage, fit: BoxFit.fitWidth))

      child: SingleChildScrollView(
        // reverse: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Image(
              image: Image.network(
                      gblSettings.backgroundImageUrl)
                  .image,
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
      return new Scaffold(

        appBar: new AppBar(
            brightness: gblSystemColors.statusBar,
            backgroundColor:
            gblSystemColors.primaryHeaderColor,
            title: gblIsLive ? appBarImage : Row( children: <Widget>[appBarImage, Text('Test Mode', style: gblTitleStyle,)]),
            iconTheme: IconThemeData(
                color:
                gblSystemColors.headerTextColor)),
        body: Stack(
          children: <Widget>[
            Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: mainBackGroundImage, fit: BoxFit.fitWidth))),
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

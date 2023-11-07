import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vmba/menu/menu.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/menu/myFqtvPage.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/components/selectLang.dart';

import '../Helpers/pageHelper.dart';
import '../Helpers/settingsHelper.dart';
import '../components/bottomNav.dart';
import '../components/networCheck.dart';
import '../components/showDialog.dart';
import '../components/vidAppBar.dart';
import '../data/repository.dart';
import '../main.dart';
import '../mmb/viewBookingPage.dart';
import '../utilities/messagePages.dart';
import '../utilities/widgets/appBarWidget.dart';


GlobalKey<StatusBarState> statusGlobalKeyOptions = new GlobalKey<StatusBarState>();
GlobalKey<StatusBarState> statusGlobalKeyPax = new GlobalKey<StatusBarState>();
GlobalKey<CheckinBoardingPassesWidgetState> mmbGlobalKeyBooking = new GlobalKey<CheckinBoardingPassesWidgetState>();
GlobalKey<MessagePageState> messageGlobalKeyProgress = new GlobalKey<MessagePageState>();
//GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
//GlobalKey<HomeState> homePageKeyProgress = new GlobalKey<HomeState>();

class HomePage extends StatefulWidget {
  HomePage({this.ads=false, Key key= const Key("home_key")}): super(key: key);

  final bool ads;

  @override
  State<StatefulWidget> createState() => new HomeState();
}

class HomeState extends State<HomePage>  with WidgetsBindingObserver {
  final NetworkCheck _connectivity = NetworkCheck.instance;
  late AssetImage appBarImage;
  Image? appBarImageLeft;
  late AssetImage mainBackGroundImage;
  late AssetImage logoImage;
  bool _displayProcessingIndicator = false;
  Image? alternativeBackgroundImage;
  bool gotBG = false;
  String buildNo = '';
  String updateMsg = '';
  Map _netState = {ConnectivityResult.none: false};


  @override


  @override
  void initState() {
    super.initState();
    commonPageInit('HOME');


    if( gblVerbose) logit('init HomeState');

    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      _netState = source;
      networkStateChange(_netState);
      // check network

      //setState(() => gblNetState = source);
    });

    if( gblLangFileLoaded == false ) {
      //initLang(gblLanguage);
      initLangCached(gblLanguage).then((x){
        setState(() {

        });
      });
    }
    if( gblIsLive == false) {
      PackageInfo.fromPlatform()
          .then((PackageInfo packageInfo) =>
          buildNo = '${packageInfo.buildNumber}'
          );
    }
    getSetting('savedVersion').then((value) {
      if(value == null || value == '' ){
        // if null, old format saved bookings
        if( gblSettings.updateMessage == null || gblSettings.updateMessage.isEmpty) {
          updateMsg =
          'Your app has been updated. The format of a booking has been improved so saved bookings will need reloading.';
        } else {
          updateMsg =gblSettings.updateMessage;
        }
      } else {
        if( value.split('.').length == 4) {
          if (int.parse(gblVersion.split('.')[3]) > int.parse(value.split('.')[3])) {
            if( gblSettings.updateMessage != null && gblSettings.updateMessage.isNotEmpty) {
              updateMsg =gblSettings.updateMessage;
            }

          }
        }
      }
      PackageInfo.fromPlatform()
          .then((PackageInfo packageInfo) =>
      packageInfo.version + '.' + packageInfo.buildNumber)
          .then((String version) {
            if( value != version) {
              saveSetting('savedVersion', version);
            }
        });

    });


    _displayProcessingIndicator = true;
    WidgetsBinding.instance.addObserver(this);
    waitAndThenHideProcessingIndicator();
  }

  void refresh(){
    setState(() {

    });
  }
/*
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        logit("h app in resumed");
        break;
      case AppLifecycleState.inactive:
        logit("h app in inactive");
        break;
      case AppLifecycleState.paused:
        logit("h app in paused");
        break;
      case AppLifecycleState.detached:
        logit("h app in detached");
        break;
    }
  }
*/

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  waitAndThenHideProcessingIndicator() {
    Timer(const Duration(milliseconds: 400), () {
      setState(() {
        _displayProcessingIndicator = false;
      });
      //if (shownUpdate == false) {
      if (gblAction == "UPDATE") {
        checkForLatestVersion();
      }
    });
  }



  checkForLatestVersion() {
    // Version currentVersion;
    // Version latestVersion;
    String latestVersion;
    if (gblAction != "UPDATE") {
      return;
    }

    if (gblAction == 'UPDATE') {
      shownUpdate = true;
      updateAppDialog(context);
      return;
    }

    PackageInfo.fromPlatform()
        .then((PackageInfo packageInfo) =>
    packageInfo.version + '.' + packageInfo.buildNumber)
        .then((String version) {
      latestVersion = Platform.isIOS
          ? gblSettings.latestBuildiOS
          : gblSettings.latestBuildAndroid;

      if (latestVersion == null || latestVersion.contains('.')) {
        // no new version
        return;
      }

      int cBuild = int.parse(version.split('.')[3]);

      gblVersion = version;
      gblIsIos = Platform.isIOS;

      bool bNewBuilsAvailable = false;

      if( int.parse(latestVersion) > cBuild) {
        bNewBuilsAvailable = true;
      }
      if (bNewBuilsAvailable == true) {
        shownUpdate = true;
        updateAppDialog(context);
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
      appBarImage = AssetImage('lib/assets/$gblAppTitle/images/appBar.png');
      logoImage = AssetImage('lib/assets/$gblAppTitle/images/loader.png');

      //     if( gblSettings.aircode == 'LM') {
//        String bgImage = 'lib/assets/$gblAppTitle/images/background.png';
      String bgImage = 'lib/assets/images/bg.png';
      mainBackGroundImage = AssetImage(bgImage);
      precacheImage(mainBackGroundImage, context);
      //   }
      precacheImage(appBarImage, context);
      precacheImage(logoImage, context);
    } catch (e) {
      print(e);
    }
  }

  //Future<Widget> getImage() async {
  Widget getImage() {
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
              fit: BoxFit.fill,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var buttonShape;
    double buttonHeight;
    double? elevation = null;

    Color headerClr = gblSystemColors.primaryHeaderColor;
       bool extendBodyBehindAppBar =  false;

    if( wantPageV2()) {
      headerClr = Colors.transparent;
      elevation = 0;
      extendBodyBehindAppBar =  true;
    }

    if (gblSettings.backgroundImageUrl != null &&
        gblSettings.backgroundImageUrl.isNotEmpty) {
      try {
        var newImg = Image.network(gblSettings.backgroundImageUrl);
        if (newImg.image != null) {
          gotBG = true;
        }
      } catch (e) {
        gotBG = false;
      }
    }
    // var appLanguage = new AppLanguage();
    //   appLanguage.changeLanguage('fr');


    buttonHeight = 60;
    switch (gblSettings.buttonStyle.toUpperCase()){
      case 'OFFSET':
        buttonHeight = 40;
        buttonShape = RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(60.0),
                topRight: Radius.circular(60.0)));
        break;
      case 'RO1':
        buttonShape = RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(60.0),
                bottomLeft: Radius.circular(60.0),
                topLeft: Radius.circular(60.0),
                topRight: Radius.circular(60.0)));
        break;
      case 'RO2':
        buttonHeight = 50;
        buttonShape = RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomRight: Radius.circular(20.0),
                bottomLeft: Radius.circular(20.0),
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0)));
        break;
      case 'RO3':
        buttonHeight = 42;
        buttonShape = RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)));
        break;
    }
    if(gblWarning != ''){
      updateMsg = gblWarning;
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
    } else if (updateMsg != '') {

      return new Scaffold(
          extendBodyBehindAppBar: extendBodyBehindAppBar,
          appBar:  new vidAppBar(
            elevation: elevation,
            centerTitle: gblCentreTitle,

            //brightness: gblSystemColors.statusBar,
            //leading: Image.asset("lib/assets/$gblAppTitle/images/appBar.png",),
            backgroundColor: headerClr,
            title:_getLogo() ,
            iconTheme: IconThemeData(color: gblSystemColors.headerTextColor) ,

            //iconTheme: IconThemeData(color:gblSystemColors.headerTextColor)
          ),
          endDrawer: DrawerMenu(),
          backgroundColor: Colors.grey.shade500,
          body: Center( child: Container(

            //alignment: Alignment.topCenter,

              margin: const EdgeInsets.all(30.0),
              padding: const EdgeInsets.only(top: 20.0, left: 30, right: 30, bottom: 20),
              decoration: BoxDecoration(    border: Border.all(color: Colors.black),
                  color: Colors.white,
                  borderRadius: BorderRadius.all(
                      Radius.circular(3.0))
              ),
              child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [ Column(
                    // crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TrText('Update Message', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),),
                        Padding(padding:  EdgeInsets.only(top: 10.0),),
                        SizedBox(
                          width: 250,
                            child:Text( updateMsg.replaceAll(r'\n', '\n'), maxLines: 20,),

                        ),
                        Padding(padding:  EdgeInsets.only(top: 20.0),),
                        ElevatedButton(
                          onPressed: () {
                            updateMsg = '';
                            gblWarning = '';
                            setState(() {

                            });
                          },
                          style: ElevatedButton.styleFrom(
                              primary: gblSystemColors
                                  .primaryButtonColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(30.0))),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                              TrText(
                                'OK',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ]),])

          ))
        //getAlertDialog( context, 'Payment Error', gblPaymentMsg, onComplete: onComplete ),
      );


    } else {
      //print(mainBackGroundImage);
      //var bal = (gblFqtvBalance != null && gblFqtvBalance > 0) ?
      //Text('${gblSettings.fqtvName} balance $gblFqtvBalance', style: TextStyle(fontSize: 8.0),):Text(' ');

      return new Scaffold(
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        appBar: new vidAppBar(
          elevation: elevation,
            centerTitle: gblCentreTitle,
            //brightness: gblSystemColors.statusBar,
            //leading: Image.asset("lib/assets/$gblAppTitle/images/appBar.png",),
            backgroundColor:headerClr,
            title:_getLogo() ,
            iconTheme: IconThemeData(color: gblSystemColors.headerTextColor) ,

          //iconTheme: IconThemeData(color:gblSystemColors.headerTextColor)
            ),
        body: Stack(
          children: _getBackImage(buttonShape, buttonHeight),
        ),
        bottomNavigationBar: getBottomNav(context),
        endDrawer: new DrawerMenu(),
      );


    }
  }
Widget _getLogo(){
  String txt = '';
  if( gblIsLive == false ) {
    txt = 'Test build $buildNo';
  }

 /* return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset(
        'lib/assets/$gblAppTitle/images/appBar.png',
        fit: BoxFit.contain,
        height: 40,
      ),
       Text(txt)
    ],
  );
*/
  //: Row(children: <Widget>[
  //_getLogo(),
  //Text('Test', style: gblTitleStyle,)
  //])
  double height = 50;
  if(gblSettings.aircode == 'LM' ) {
    height = 70;
  } else if(gblSettings.aircode == 'SI' ) {
    height = 40;
   }
  List<Widget> list = [];
  if ( height > 0 ) {
    if( gblIsLive == true) {
      return Image.asset('lib/assets/$gblAppTitle/images/appBar.png',height: height);
    }
    list.add(Image.asset('lib/assets/$gblAppTitle/images/appBar.png',height: height));
    } else {
    list.add(Image.asset('lib/assets/$gblAppTitle/images/appBar.png'));
  }
  if( gblIsLive == false) {
    TextStyle st = new TextStyle( color: gblTitleStyle!.color  );
    list.add(Text(txt, style: st, textScaleFactor: 0.75,));
  }
  if( gblSettings.wantCentreTitle) {
    return new Row(children: list, mainAxisAlignment: MainAxisAlignment.center,);
  } else {
    return new Row(children: list);

  }
}

  List<Widget> _getBackImage(var buttonShape, var buttonHeight) {
    List<Widget> list = [];

    //   if( gblSettings.aircode == 'LM') {
    list.add(Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: mainBackGroundImage, fit: BoxFit.fill))));
    if (gotBG) {
      list.add(ClipRRect(child: getImage()));
    }
//    } else {
    //    list.add(ClipRRect(child: getImage()));
    //}

    list.add(Container(
      //This container stops the alternative image from scrolling
      child: Text(''),
      width: MediaQuery
          .of(context)
          .size
          .width,
      height: MediaQuery
          .of(context)
          .size
          .height,
    ));

    switch (gblSettings.buttonStyle.toUpperCase()){
      case 'RO3':
        list.add(
          Padding(padding: EdgeInsets.only(left: 20, right: 20),
            child:
            Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: _getButtons(context, buttonShape, buttonHeight),
          ),),
        ));
        break;
      default:
        list.add(Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: _getButtons(context, buttonShape, buttonHeight),
          ),
        ));

        break;
    }
    return list;
  }
}

  List <Widget> _getButtons(BuildContext context, var buttonShape, var buttonHeight) {
    List <Widget> list = [];
    Color b1Clr = gblSystemColors.primaryButtonColor;
    Color b2Clr = gblSystemColors.primaryButtonColor;
    Color b1TextClr =Colors.white;
    Color b2TextClr = Colors.white;
    FontWeight fw = FontWeight.bold;
    double tsf = 1.0;

    if( wantHomePageV2()) {
      b1Clr = gblSystemColors.home1ButtonColor!;
      b2Clr = gblSystemColors.home2ButtonColor!;
      b1TextClr = gblSystemColors.home1ButtonTextColor!;
      b2TextClr = gblSystemColors.home2ButtonTextColor!;
      fw = FontWeight.normal;
      tsf = 1.25;
    }


    if (gblNoNetwork == false && gblSettings.disableBookings == false) {
      list.add(Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: TextButton(
                  style: TextButton.styleFrom(
                      shape: buttonShape,
                      backgroundColor: b1Clr),
                  onPressed: () {
                    if( gblNoNetwork == false) {
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil(
                          '/FlightSearchPage',
                              (Route<dynamic> route) => false);
                    }
                  },
                  child: Container(
                    height: buttonHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                       gblSettings.wantButtonIcons ? Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: Icon(
                            Icons.flight_takeoff,
                            color: Colors.white,
                          ),
                        ) : Container() ,
                        TrText(
                          'Book a flight',
                          textScaleFactor: tsf,
                          style: TextStyle(
                              color: b1TextClr,
                              fontWeight: fw),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ));
    };

    if( gblBuildFlavor == 'LM' && gblNoNetwork == false && gblSettings.disableBookings == false ) {
      list.add(Row(
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
                  onPressed: () =>
                      Navigator.of(context)
                          .pushNamedAndRemoveUntil('/AdsPage',
                              (Route<dynamic> route) => false),
                  child: Container(
                    height: buttonHeight,
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.center,
                      children: <Widget>[
                        gblSettings.wantButtonIcons ? Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: Icon(
                            Icons.flight_takeoff,
                            color: Colors.white,
                          ),
                        ) : Container(),
                        TrText(
                          'Book an ADS / Island Resident ',
                          textScaleFactor: tsf,
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
      ));
    }
  list.add(Row(
    children: <Widget>[
      Expanded(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: TextButton(
              style: TextButton.styleFrom(
                  shape: buttonShape,
                  backgroundColor: b2Clr),
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                  '/MyBookingsPage', (Route<dynamic> route) => false),
              child: Container(
                height: buttonHeight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    gblSettings.wantButtonIcons ? Padding(
                      padding: EdgeInsets.only(right: 5),
                      child: Icon(
                        Icons.card_travel,
                        color: Colors.white,
                      ),
                    ) : Container(),
                    TrText(
                      'My Bookings & Check-in',
                      textScaleFactor: tsf,
                      style: TextStyle(
                      color: b2TextClr,
                      fontWeight: fw),
    ),
    ],
    ),
    ),
    ),
    ),
    ),
    )
    ],

    ));

    if(gblSettings != null && gblSettings.wantFQTV!= null && gblSettings.wantFQTV &&
        gblSettings.wantHomeFQTVButton && gblSettings.fqtvName.isNotEmpty ) {
      print('home FQTV name [${gblSettings.fqtvName}]');

      list.add(Row(
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
                  onPressed: () =>
                      Navigator.push(
                        context, SlideTopRoute(page: MyFqtvPage(
                        isAdsBooking: false,
                        isLeadPassenger: true,))),
                  child: Container(
                    height: buttonHeight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        gblSettings.wantButtonIcons ? Padding(
                          padding: EdgeInsets.only(right: 5),
                          child: Icon(
                            Icons.person_pin,
                            color: Colors.white,
                          ),
                        ) : Container(),
                        TrText(
                          '${gblSettings.fqtvName}       ' ,
                          textScaleFactor: tsf,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: fw),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],

      ));
    }

    list.add(Padding(
    padding: EdgeInsets.all(8),
    ));

    if( gblNoNetwork ) {
/*      list.add(Row(children: <Widget>[
        Expanded(child: new Text('No Network Connection',
            style: TextStyle(backgroundColor: Colors.red,
              color: Colors.white,
              fontSize: 18.0,)))
      ]));*/
      networkOffline();
    }


    return    list;

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

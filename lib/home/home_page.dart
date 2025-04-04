import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vmba/home/travelNotifiation.dart';
import 'package:vmba/menu/menu.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/menu/myFqtvPage.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/components/selectLang.dart';

import '../Helpers/settingsHelper.dart';
import '../components/bottomNav.dart';
import '../components/networCheck.dart';
import '../components/showDialog.dart';
import '../components/vidAppBar.dart';
import '../data/repository.dart';
import '../mmb/myBookingsPage.dart';
import '../mmb/viewBookingPage.dart';
import '../Managers/PaxManager.dart';
import '../utilities/messagePages.dart';
import '../utilities/navigation.dart';
import '../utilities/timeHelper.dart';
import '../utilities/widgets/appBarWidget.dart';
import '../v3pages/smartHomePage.dart';
import '../v3pages/v3Theme.dart';

GlobalKey<StatusBarState> statusGlobalKeyOptions = new GlobalKey<StatusBarState>();
GlobalKey<StatusBarState> statusGlobalKeyPax = new GlobalKey<StatusBarState>();
GlobalKey<ViewBookingBodyState> mmbGlobalKeyBooking = new GlobalKey<ViewBookingBodyState>();
GlobalKey<MessagePageState> messageGlobalKeyProgress = new GlobalKey<MessagePageState>();
GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
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
  Timer? _timer;
  int _currentIndex = 0;
  int homePageMapLen = 0;

  @override
  void initState() {
    super.initState();
    gblIsNewInstall = true;
    commonPageInit('HOME');
    //initGmtTimer();
    setLiveTest();
    if( gblVerbose) logit('init HomeState');
    _connectivity.initialise();
    _connectivity.myStream.listen((source) {
      _netState = source;
      networkStateChange(_netState);
      // check network

      //setState(() => gblNetState = source);
    });
    if( gblSettings.wantLocation){
      initGeolocation(refresh);
    }


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
      try {

        if( gblSettings.wantNewInstallPage && PaxManager.getPaxEmail() == '')
          {
            value = null;
          }

        if (value == null || value == '') {
          // if null, old format saved bookings
          if (gblSettings.updateMessage == null ||
              gblSettings.updateMessage.isEmpty) {
            updateMsg =
            'Your app has been updated.'; // The format of a booking has been improved so saved bookings will need reloading.';
          } else {
            updateMsg = gblSettings.updateMessage;
          }
          if( gblSettings.wantNewInstallPage && !gblContinueAsGuest ){
            gblValidationEmailTries = 0;
            gblValidationPinTries = 0;
            navToNewInstallPage(context);
          }

        } else {
          gblIsNewInstall == false;
          if (value
              .split('.')
              .length == 4 && gblVersion != '' && gblVersion
              .split('.')
              .length == 4) {
            if (int.parse(gblVersion.split('.')[3]) >
                int.parse(value.split('.')[3])) {
              if (gblSettings.updateMessage != null &&
                  gblSettings.updateMessage.isNotEmpty) {
                updateMsg = gblSettings.updateMessage;
              }
            }
          }

        }
      } catch (e) {
        logit('version check ' + e.toString());
      }

      PackageInfo.fromPlatform()
          .then((PackageInfo packageInfo) =>
      packageInfo.version + '.' + packageInfo.buildNumber)
          .then((String version) {
            if( value != version) {
              saveSetting('savedVersion', version);
            }
        });
      // home page image rotation
      if( gblSettings.homepageImageMap != '' && gblSettings.homepageImageDelay > 0 ){
        Map pageMap = json.decode(gblSettings.homepageImageMap.toUpperCase());
        homePageMapLen = pageMap.length;
        gotBG = true;

        _timer = Timer.periodic(Duration(seconds: gblSettings.homepageImageDelay ), (timer) async {
          if (mounted) {
            setState(() {
              if (_currentIndex + 1 >= homePageMapLen) {
                _currentIndex = 0;
              } else {
                _currentIndex = _currentIndex + 1;
              }
            });
          }
        });

      }
    });


    _displayProcessingIndicator = true;
    WidgetsBinding.instance.addObserver(this);
    waitAndThenHideProcessingIndicator();
    if( startTime != null) {
      var difference = DateTime
          .now()
          .difference(startTime!)
          .inMilliseconds;
      logit('Load Time $difference ms');
    }
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
 //   endGmtTimer();
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

    if( gblSettings.homepageImageDelay > 0 ){
      Map pageMap = json.decode(gblSettings.homepageImageMap.toUpperCase());
      String url = pageMap[(_currentIndex+1).toString()] + '.png';
      url = '${gblSettings.gblServerFiles}/$url';

      return Container(
        child: SingleChildScrollView(
          // reverse: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            //image: mainBackGroundImage
            children: <Widget>[
              AnimatedSwitcher(
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(child: child, opacity: animation);
                },
                duration: const Duration(milliseconds: 1500),
                child:
                  Image(
                    key: ValueKey(_currentIndex),
                    image: NetworkImage(url),
                    fit: BoxFit.fill,
                  ),
                ),
            ],
          ),
        ),
      );

    } else {
      return Container(
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
  }

  @override
  Widget build(BuildContext context) {
    initThemes(context);

    if( gblSettings.wantGeoLocationHopePage && gblSettings.darkSiteEnabled == false ) {
      return new SmartHomePage();
    }

/*
    if( (wantHomePageV3() && wantCustomHome()) ||
        (gblSettings.wantFqtvHomepage && gblSettings.wantFqtvAutologin && gblFqtvLoggedIn )){
      return new V3HomePage();
    }
*/


    var buttonShape;
    double buttonHeight;
    double? elevation = null;

    DateTime gmt = getGmtTime();

    Color headerClr = gblSystemColors.primaryHeaderColor;
       bool extendBodyBehindAppBar =  false;

    if( wantPageV2() || gblSettings.wantTransapentHomebar) {
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
          bottomNavigationBar: getBottomNav(context, 'HOME'),
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
      Color background = gblSettings.wantTransapentHomebar ? Colors.transparent : headerClr;
      if( gblSettings.darkSiteEnabled) {
        background = Colors.black;
      }

      return new Scaffold(
          extendBodyBehindAppBar: extendBodyBehindAppBar,
          appBar:  new vidAppBar(
            elevation: elevation,
            automaticallyImplyLeading: false,
            centerTitle: gblCentreTitle,

            backgroundColor: background,
            titleText: _getTitleText(),
            iconTheme: IconThemeData(color: gblSystemColors.headerTextColor) ,

            //iconTheme: IconThemeData(color:gblSystemColors.headerTextColor)
          ),
          endDrawer: DrawerMenu(),
          backgroundColor: Colors.grey.shade500,
          bottomNavigationBar: getBottomNav(context, 'HOME'),
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
                              backgroundColor: gblSystemColors
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
      Color background = gblSettings.wantTransapentHomebar ? Colors.transparent : headerClr;
      if( gblSettings.darkSiteEnabled) {
        background = Colors.black;
      }

      //logit( 'HP ext = $extendBodyBehindAppBar e=$elevation b=${background.toString()}');
      return new Scaffold(
        key: scaffoldKey,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        appBar: new vidAppBar(
          elevation: elevation,
            automaticallyImplyLeading: false,
            centerTitle: gblCentreTitle,
            backgroundColor: background,
            titleText: _getTitleText(),

            //iconTheme: IconThemeData(color: gblSystemColors.headerTextColor) ,
            ),
        body: Stack(
          children: _getBackImage(buttonShape, buttonHeight),
        ),
        bottomNavigationBar: getBottomNav(context, 'HOME'),
        endDrawer: new DrawerMenu(),
      );


    }
  }

 String  _getTitleText() {
   if( gblIsLive == false ) {
     return 'Test build $buildNo';
   }
   return '';
 }
/*Widget _getLogo(){
    //return Text('xxx');
  String txt = '';
  if( gblIsLive == false ) {
    txt = 'Test build $buildNo';
    if (gblBuildFlavor == 'BM')
      txt = 'Test Airline $buildNo';
  }
  double height = 50;
  if(gblSettings.aircode == 'LMx' ) {
    height = 70;
  } else if(gblSettings.aircode == 'SI' ) {
    height = 40;
   }
  List<Widget> list = [];
  if ( height > 0 ) {
   *//* if( gblIsLive == true) {
      return Image.asset('lib/assets/$gblAppTitle/images/appBar.png',height: height);
    }*//*
    list.add(Image.asset('lib/assets/$gblAppTitle/images/appBar.png',height: height, alignment: Alignment.topLeft,));
    } else {
    list.add(Image.asset('lib/assets/$gblAppTitle/images/appBar.png', alignment: Alignment.topLeft));
  }
  //return list[0];
  if( gblIsLive == false) {
    TextStyle st = new TextStyle( color: gblSystemColors.headerTextColor  );
    list.add(Text(txt, style: st, textScaleFactor: 0.75,));
  }
  if( gblSettings.wantCentreTitle) {
    return new Row(children: list, mainAxisAlignment: MainAxisAlignment.center,);
  } else {
    return new Row(children: list,
      //mainAxisAlignment: MainAxisAlignment.start,
      //mainAxisSize: MainAxisSize.max,
    );

  }
}*/

  List<Widget> _getBackImage(var buttonShape, var buttonHeight) {
    List<Widget> list = [];

    //   if( gblSettings.aircode == 'LM') {
    if (!gotBG || gblSettings.darkSiteEnabled == true) {
      list.add(Container(
          decoration: BoxDecoration(
              color: gblSettings.darkSiteEnabled ? Colors.black : null,
              image: DecorationImage(
                  colorFilter: gblSettings.darkSiteEnabled
                      ? new ColorFilter.mode(
                      Colors.black.withOpacity(0.3), BlendMode.dstATop)
                      : null,
                  image: mainBackGroundImage, fit: BoxFit.fill))));
    }
    if (gotBG && gblSettings.darkSiteEnabled == false) {
      list.add(ClipRRect(child: getImage()));
    }
//    } else {
    //    list.add(ClipRRect(child: getImage()));
    //}

    list.add(Container(
      padding: EdgeInsets.only(top: 60),
      //This container stops the alternative image from scrolling
      child: Text('', style: TextStyle(color: Colors.white, fontSize: 30), ), //Text(''),
      width: MediaQuery
          .of(context)
          .size
          .width,
      height: MediaQuery
          .of(context)
          .size
          .height,
    ));

    if( wantHomePageV3()) {
      List<Widget> list2 = [];
      if( gblIsIos) {
        list2.add(Padding(padding: EdgeInsets.only(top: 90)));
      } else {
        list2.add(Padding(padding: EdgeInsets.only(top: 70)));
      }
      list2.add(frontPageNotification(context));
      list2.add( Padding(padding: EdgeInsets.only(top: 10)));
      list2.add(getMiniMyBookingsPage(context, () {
        //doCallback();
      }));

      list.add(Column(
        children: list2)    );
    }

    if( gblSettings.wantHomepageButtons) {
      switch (gblSettings.buttonStyle.toUpperCase()) {
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
    }
    return list;
  }


  List <Widget> _getButtons(BuildContext context, var buttonShape, var buttonHeight) {
    List <Widget> list = [];
    Color b1Clr = gblSystemColors.primaryButtonColor;
    Color b2Clr = gblSystemColors.primaryButtonColor;
    Color b1TextClr =Colors.white;
    Color b2TextClr = Colors.white;
    FontWeight fw = FontWeight.bold;
    double tsf = 1.0;
    Widget b1Text = TrText(
      'Book a flight',
      textScaleFactor: tsf,
      style: TextStyle(
          color: b1TextClr,
          fontWeight: fw),
    );

    if( wantHomePageV3() ) {
      if( gblSystemColors.home1ButtonColor != null )       b1Clr = gblSystemColors.home1ButtonColor!;
      if( gblSystemColors.home2ButtonColor != null ) b2Clr = gblSystemColors.home2ButtonColor!;
      if( gblSystemColors.home1ButtonTextColor != null )  b1TextClr = gblSystemColors.home1ButtonTextColor!;
      if( gblSystemColors.home2ButtonTextColor != null )  b2TextClr = gblSystemColors.home2ButtonTextColor!;
      fw = FontWeight.normal;
      buttonHeight = 35.0;
      tsf = 1.25;
      b1Text = VButtonText('Book a flight', color: b1TextClr,);
    }

    if( gblSettings.darkSiteEnabled) {
      String msg = gblSettings.darkSiteMessage;
      String title = '' + gblSettings.darkSiteTitle;
      list.add( Padding( padding: EdgeInsets.fromLTRB(10, 0, 10, 50),
          child: Card(
            shadowColor: Colors.white,
            color: Colors.black,
              child: Container(
                padding: EdgeInsets.all(10),
                width: 400,
                height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ListTile(
                        //leading: Icon(Icons.arrow_drop_down_circle, color: gblSystemColors.headerTextColor,),
                        title: VTitleText(title,size: TextSize.large, color: gblSystemColors.headerTextColor,),
                      ),
                  VTitleText(msg, color: gblSystemColors.headerTextColor,),
                ]
          )
        )
      ))
      );
      list.add( Padding( padding: EdgeInsets.all(25)));
    } else if(gblSettings.homePageMessage != '' ){
      String msg = gblSettings.homePageMessage;
      if( gblPassengerDetail != null && gblPassengerDetail!.firstName != ''){
        msg = msg.replaceAll('[[firstname]]', gblPassengerDetail!.firstName);
      } else {
        msg = msg.replaceAll('[[firstname]]', gblSettings.defaultTraveller);
      }
      list.add( Padding( padding: EdgeInsets.fromLTRB(10, 0, 10, 10),
          child: VHeadlineText(msg, size: TextSize.medium,color: gblSystemColors.headerTextColor,)));
    }
/*

    if( gblSettings.wantHomeUpcoming && gblTrips != null && gblTrips!.trips != null && gblTrips!.trips!.length> 0) { //
      HomeCard card = new HomeCard();
      String fltDate =  DateFormat('dd MMM yy').format(gblTrips!.trips!.first.fltdate!);
      DateTime dtComp = DateTime.now().add(Duration(days: 1));
      if(gblTrips!.trips!.first.fltdate!.month == DateTime.now().month && gblTrips!.trips!.first.fltdate!.day == DateTime.now().day) {
        fltDate = 'Today';
      } else if(gblTrips!.trips!.first.fltdate!.month == dtComp.month && gblTrips!.trips!.first.fltdate!.day == dtComp.day) {
        fltDate = 'Tomorrow';
      }
        card.title = CardText('', text: translate('Next Trip' + ': ' + fltDate));
        card.icon = Icons.airplanemode_active;
        card.title!.backgroundColor = gblSystemColors.primaryButtonColor;
        card.title!.color = gblSystemColors.primaryButtonTextColor;

        list.add(
            GestureDetector(
                onTap: () {
                  navToMyBookingPage(context, gblTrips!.trips!.first.rloc);
                },
                child:
                v3ExpanderCard(
                    context, card, getUpcoming(context, () {
                  setState(() {});
                }), wantIcon: false
                ))
        );
      }

*/

    if (gblNoNetwork == false && gblSettings.disableBookings == false) {
      list.add(Row(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding:  EdgeInsets.all(8.0),
              child: Center(
                child: TextButton(
                  style: TextButton.styleFrom(
                      shape: buttonShape,
                      backgroundColor: b1Clr),
                  onPressed: () {
                    if( gblNoNetwork == false) {
                      navToFlightSearchPage(context);
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
                        b1Text
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
                      backgroundColor: wantHomePageV3() ? b2Clr : gblSystemColors.primaryButtonColor),
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
                          style: TextStyle(color: wantHomePageV3() ? b2TextClr: Colors.white),
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
    //  print('home FQTV name [${gblSettings.fqtvName}]');

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


  }
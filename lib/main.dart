//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:vmba/completed/ProcessCommandsPage.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/flightSearch/flt_search_page.dart';
import 'package:vmba/completed/completed.dart';
import 'package:vmba/mmb/myBookingsPage.dart';
import 'package:vmba/mmb/myNotificationsPage.dart';
import 'package:vmba/ads/adsPage.dart';
import 'package:vmba/home/home_page.dart';
import 'package:vmba/mmb/viewBookingPage.dart';
import 'package:vmba/root_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vmba/utilities/CustomError.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/v3pages/homePageHelper.dart';

import 'Helpers/settingsHelper.dart';
import 'components/selectLang.dart';
import 'data/globals.dart';
import 'data/SystemColors.dart';
import 'main_aurigny.dart';
import 'main_buraq.dart';
import 'main_caicos.dart';
import 'main_fastjet.dart';
import 'main_fl.dart';
import 'main_hiSky.dart';
import 'main_lm.dart';
import 'main_medSky.dart';
import 'main_si.dart';
import 'main_t6.dart';
import 'main_gotland.dart';
import 'main_halland.dart';
import 'main_skane.dart';
import 'main_keylime.dart';
import 'package:vmba/menu/errorPage.dart';

import 'main_u5.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //AppLanguage appLanguage = AppLanguage();
  //await appLanguage.fetchLocale();

  //  api keys
//  Air North	4N	7d8a80fae6c6424c8d09d4b03098a10d
//  Air Peace	P4	0dc43646b379435695a28688ee5c9468
//  Blue Islands	SI	4d332cf7134f4a43958d954278474b41
//  Air Leap	FL	2edd1519899a4e7fbf9a307a0db4c17a


  gblTitleStyle =  new TextStyle( color: Colors.white) ;


  if (gblAppTitle == null || gblAppTitle ==''){
    switch(gblBuildFlavor){
      case 'AG':
        configAG();
        break;
      case 'AH':
        configAH();
        break;
      case 'AS':
        configAS();
        break;
      case 'T6':
        configT6();
        break;

     case 'LM':
        configLM();
      break;
      case '9Q':
        config9Q();
        break;
      case 'FN':
        configFN();
        break;
      case 'H4':
        configH4();
        break;
      case 'M1':
        configM1();
        break;
      case 'GR':
        configGR();
        break;
      case 'FL':
        configFL();
        break;
      case 'SI':
        configSI();
        break;
      case 'KG':
        configKG();
        break;
      case 'UZ':
        configUZ();
        break;
      case 'U5':
        configU5();
        break;
      default:
        gblAppTitle='Test Title';
/*        gblSystemColors = new SystemColors(primaryButtonColor: Colors.red,
            accentButtonColor: Colors.green,
            primaryColor: Colors.black,
            accentColor: Colors.blue);*/
        break;
    }
  }


  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new App());
  });
}

class App extends StatefulWidget {  //}StatelessWidget {
 // final AppLanguage appLanguage;
  App();

  @override
  State<StatefulWidget> createState() => new AppState();
}

class AppState extends State<App> {
bool bFirstTime = true;
  @override
  void initState() {
    super.initState();
    _initLangs();

    if( gblLangFileLoaded == false ) {
      //initLang(gblLanguage);
      initLangCached(gblLanguage).then((x){
        setState(() {

        });
      });

    }
    if( gblSettings.homePageStyle == 'V3'){
      initHomePage(gblSettings.homePageFilename);
    }
/*
    if( gblSettings.wantPushNoticications) {
       initFirebase(context);
    }
*/
  }

  @override
  Widget build(BuildContext context) {
   // Locale myLocale = Localizations.localeOf(context);
    try {
      gblIs24HoursFormat = MediaQuery.of(context).alwaysUse24HourFormat;
    } catch(e) {
      logit(e.toString());
    }

    bFirstTime = false;
    setLiveTest();

    // check for invalid settings
    if(gblSettings.fQTVpointsName== null || gblSettings.fQTVpointsName.isEmpty){
      gblSettings.fQTVpointsName = 'airmiles';
    }
    final localizationsDelegates = <LocalizationsDelegate>[
      //   AppLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate
    ];

    List<Locale> locales =[
      Locale('fr', ''),
      Locale('en', ''),
      Locale('sv', ''),
      Locale('da', ''),
      Locale('no', ''),
      Locale('fi', ''),
      Locale('ar', ''),
    ];
    if( gblSettings.gblLanguages != null && gblSettings.gblLanguages.isNotEmpty) {
      // sv,Swedish,no,Norwegian,da,Danish,fi,Finnish,en,English,fr,French
      locales = [];
      var langs = gblSettings.gblLanguages.split(',');
      var count = langs.length;
      for( var i = 0 ; i < count; i+=2){
        locales.add(new Locale( langs[i]));
      }


    }
    logit('CREATE APP lang=$gblLanguage');

    return ChangeNotifierProvider(
      create: (_) => new LocaleModel(),
      child: Consumer<LocaleModel>(
          builder: (context, provider, child) =>
              MaterialApp(
                builder: (BuildContext context, Widget? widget) {
                  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                    return CustomError(errorDetails: errorDetails);
                  };
                  return widget!;
                },
            navigatorKey: NavigationService.navigatorKey,
      localizationsDelegates: localizationsDelegates,
      locale: Provider.of<LocaleModel>(context).getLocale(),
      supportedLocales: locales,

       debugShowCheckedModeBanner: false,
      title: gblAppTitle,
      theme: ThemeData(
/*
        useMaterial3: gblSettings.wantMeterial3,
        colorSchemeSeed: gblSettings.wantMeterial3 ? gblSystemColors.primaryButtonColor : null,
*/
        brightness: Brightness.light,
/*
        primaryColor: gblSettings.wantMeterial3 ? null : gblSystemColors.primaryColor,
*/
        primaryColor: gblSystemColors.primaryColor,
        secondaryHeaderColor: gblSystemColors.accentColor,
        useMaterial3: gblSettings.wantMaterial3,
        colorScheme: gblSettings.wantMaterial3 ? null : ColorScheme.light(primary: Colors.black).copyWith(secondary: gblSystemColors.accentColor),
        dividerTheme: DividerThemeData(color: Colors.grey.shade300),
        //buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary,)
      ),
      darkTheme: ThemeData(
        //brightness: Brightness.dark,
        primaryColor: gblSystemColors.primaryColor,
        useMaterial3: gblSettings.wantMaterial3,
        colorScheme: ColorScheme.light(primary: Colors.black).copyWith(secondary: gblSystemColors.accentColor),
        dividerTheme: DividerThemeData(color: Colors.grey.shade300),
      ),
      home: Directionality(
                textDirection: wantRtl() ? TextDirection.rtl : TextDirection.ltr, 
                child: RootPage()
      ),
/*
    onGenerateRoute: (settings) {
      if (settings.name == '/HomePage') {
        return MaterialPageRoute(builder: (_) => HomePage());
      }
    },
*/
      routes: <String, WidgetBuilder>{
        '/HomePage': (BuildContext context) => new HomePage(),
        '/FlightSearchPage': (BuildContext context) => new FlightSearchPage(
              ads: false,
            ),
        '/MyBookingsPage': (BuildContext context) => new MyBookingsPage(),
        '/AddBookingPage': (BuildContext context) => new  MyBookingsPage(), //AddBooking(),
        '/MyNotificationsPage': (BuildContext context) => new MyNotificationsPage(),
        '/AdsFlightSearchPage': (BuildContext context) => new FlightSearchPage(
                       ads: true,
                     ),
        '/AdsPage': (BuildContext context) => new AdsPage(),
        '/ErrorPage': (BuildContext context) => new ErrorPage(),
        '/CompletedPage': (BuildContext context) => new CompletedPage(),
        '/ViewBookingPage': (BuildContext context) => new ViewBookingPage(),
/*        '/ProcessCommandsPage': (BuildContext context) =>
            new ProcessCommandsPage(),*/
      },
       )
      ));
  }
  void _initLangs() async {
    try {
      var prefs = await SharedPreferences.getInstance();
      // reset
      //prefs.setString('language_code', '');
      //String l =  Intl.getCurrentLocale();
      String localeStr = Platform.localeName;
     // var prefs = await SharedPreferences.getInstance();
      if (prefs.getString('language_code') == null || prefs.getString('language_code')!.isEmpty) {
        if( localeStr != null && localeStr.isNotEmpty && _localeSupported(localeStr)) {
          gblLanguage = localeStr.split('_')[0];
          setState(() {
          });
        } else {
          gblLanguage = 'en';
        }
        return ;
      }
      gblLanguage= prefs.getString('language_code') as String;
      setState(() {
        //gblLanguage= prefs.getString('language_code');
      });
    } catch(e){
      print('initLangs error: $e');
    }
  }

  bool _localeSupported(String locale) {
    if( locale == null ) {return false;}
    String language = locale.split('_')[0];
    var langs = gblSettings.gblLanguages.split(',');
    var count = langs.length;
    for( var i = 0 ; i < count; i+=2){
      if( langs[i] == language) {
        return true;
      }
    }
    return false;
  }

  }
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =  GlobalKey<NavigatorState>();
}
class AddBookingPage {}

class LocaleModel with ChangeNotifier {

  Locale getLocale() {
    Locale locale = Locale(gblLanguage);
    return locale;
  }
  void changelocale(Locale l) {
    notifyListeners();
    initializeDateFormatting();
  }
}
/*
Future<void> initFirebase(BuildContext context) async {

  if( gblIsLive == false ) {
    //serverLog('Starting app $gblAppTitle');
  }
  logit('InitFirebase');
  NotificationService().init(context);
}
*/



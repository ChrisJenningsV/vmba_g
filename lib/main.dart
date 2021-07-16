import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:vmba/completed/ProcessCommandsPage.dart';
import 'package:vmba/flightSearch/flt_search_page.dart';
import 'package:vmba/completed/completed.dart';
import 'package:vmba/mmb/addBookingPage.dart';
import 'package:vmba/mmb/myBookingsPage.dart';
import 'package:vmba/ads/adsPage.dart';
import 'package:vmba/home/home_page.dart';
import 'package:vmba/root_page.dart';
import 'data/globals.dart';
import 'data/SystemColors.dart';
import 'main_fl.dart';
import 'main_lm.dart';
import 'main_qi.dart';
import 'main_si.dart';
import 'main_t6.dart';
import 'main_z4.dart';
import 'main_gotland.dart';

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

  if (gblAppTitle == null){
    switch(gblBuildFlavor){
      case 'AG':
        configAG();
        break;
      case 'T6':
        configT6();
        break;
      case 'Z4':
        configZ4();
        break;

        case 'LM':
        configLM();
      break;
      case 'FL':
        configFL();
        break;
      case 'QI':
        configQI();
        break;
      case 'SI':
        configSI();
        break;
      default:
        gblAppTitle='Test Title';
        gblSystemColors = new SystemColors(primaryButtonColor: Colors.red,
            accentButtonColor: Colors.green,
            primaryColor: Colors.black,
            accentColor: Colors.blue);
        break;
    }
  }

/*  if(gblIsLive == true) {
    gblSettings.xmlUrl = gblSettings.live_xmlUrl;
    gblSettings.apisUrl = gblSettings.live_apisUrl;
    gblSettings.apiUrl = gblSettings.live_apiUrl;
    gblSettings.creditCardProvider  = gblSettings.live_creditCardProvider;
  } else {
    gblSettings.xmlUrl = gblSettings.test_xmlUrl;
    gblSettings.apisUrl = gblSettings.test_apisUrl;
    gblSettings.apiUrl = gblSettings.test_apiUrl;
    gblSettings.creditCardProvider  = gblSettings.test_creditCardProvider;
  }

 */

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(new App());
  });
}

class App extends StatelessWidget {
 // final AppLanguage appLanguage;

  App();
  @override
  Widget build(BuildContext context) {
    if(gblIsLive == true) {
      gblSettings.xmlUrl = gblSettings.liveXmlUrl;
      gblSettings.apisUrl = gblSettings.liveApisUrl;
      gblSettings.apiUrl = gblSettings.liveApiUrl;
      gblSettings.creditCardProvider  = gblSettings.liveCreditCardProvider;
    } else {
      gblSettings.xmlUrl = gblSettings.testXmlUrl;
      gblSettings.apisUrl = gblSettings.testApisUrl;
      gblSettings.apiUrl = gblSettings.testApiUrl;
      gblSettings.creditCardProvider  = gblSettings.testCreditCardProvider;
    }
    // check for invalid settings
    if(gblSettings.fQTVpointsName== null || gblSettings.fQTVpointsName.isEmpty){
      gblSettings.fQTVpointsName = 'airmiles';
    }
    final localizationsDelegates = <LocalizationsDelegate>[
      //   AppLocalizationsDelegate(),
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
//      CupertinoLocalizationsDelegate()
    ];

    List<Locale> locales =[
      Locale('fr', ''),
      Locale('en', ''),
      Locale('sv', ''),
      Locale('da', ''),
      Locale('no', ''),
    ];

    return ChangeNotifierProvider(
      create: (_) => new LocaleModel(),
      child: Consumer<LocaleModel>(
          builder: (context, provider, child) => MaterialApp(
      localizationsDelegates: localizationsDelegates,
      //locale: Locale('fr', ''), // locale: Locale(gblLanguage, ''),
      locale: Provider.of<LocaleModel>(context).locale,
      supportedLocales: locales,

       debugShowCheckedModeBanner: false,
      title: gblAppTitle, //'Loganair',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: gblSystemColors.primaryColor,
        accentColor: gblSystemColors.accentColor,
        colorScheme: ColorScheme.light(primary: Colors.black),
        //buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary,)
      ),
      home: new RootPage(),
      routes: <String, WidgetBuilder>{
        /* '/UserProfile': (BuildContext context) => new ProfileWidget(),*/
        '/HomePage': (BuildContext context) => new HomePage(),
        '/FlightSearchPage': (BuildContext context) => new FlightSearchPage(
              ads: false,
            ),
        '/MyBookingsPage': (BuildContext context) => new MyBookingsPage(),
        '/AddBookingPage': (BuildContext context) => new AddBooking(),
        '/AdsFlightSearchPage': (BuildContext context) => new FlightSearchPage(
                       ads: true,
                     ),
        '/AdsPage': (BuildContext context) => new AdsPage(),
        '/CompletedPage': (BuildContext context) => new CompletedPage(),
        '/ProcessCommandsPage': (BuildContext context) =>
            new ProcessCommandsPage(),
      },
       )
      ));
  }

  }

class AddBookingPage {}

class LocaleModel with ChangeNotifier {
  Locale locale = Locale('fr');
  Locale get getlocale => locale;
  void changelocale(Locale l) {
    locale = l;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:vmba/completed/CompletedPageV2.dart';
import 'package:vmba/completed/ProcessCommandsPage.dart';
import 'package:vmba/flightSearch/flt_search_page.dart';
import 'package:vmba/completed/completed.dart';
import 'package:vmba/mmb/addBookingPage.dart';
import 'package:vmba/mmb/myBookingsPage.dart';
import 'package:vmba/ads/adsPage.dart';
import 'package:vmba/resources/app_config.dart';
import 'package:vmba/home/home_page.dart';
import 'package:vmba/root_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:vmba/data/AppLanguage.dart';
import 'package:vmba/data/app_localizations.dart';
import 'data/globals.dart';
import 'data/SystemColors.dart';
import 'main_fl.dart';
import 'main_lm.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //AppLanguage appLanguage = AppLanguage();
  //await appLanguage.fetchLocale();

  gbl_titleStyle =  new TextStyle( color: Colors.white) ;

  if (gblAppTitle == null){
    switch(gblBuildFlavor){
      case 'LM':
        config_lm();
      break;
      case 'FL':
        config_fl();
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
    return MaterialApp(
//      locale: model.appLocal,
       debugShowCheckedModeBanner: false,
      title: gblAppTitle, //'Loganair',
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: gblSystemColors.primaryColor,
        accentColor: gblSystemColors.accentColor,
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
        /*   '/AdsFlightSearchPage': (BuildContext context) => new FlightSearchPage(
                       ads: true,
                     ),*/
        '/AdsPage': (BuildContext context) => new AdsPage(),
        '/CompletedPage': (BuildContext context) => new CompletedPage(),
        '/ProcessCommandsPage': (BuildContext context) =>
            new ProcessCommandsPage(),
      },
          );
  }

  }

class AddBookingPage {}

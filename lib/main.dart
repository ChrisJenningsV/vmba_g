import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:vmba/completed/ProcessCommandsPage.dart';
import 'package:vmba/flightSearch/flt_search_page.dart';
import 'package:vmba/completed/completed.dart';
import 'package:vmba/mmb/addBookingPage.dart';
import 'package:vmba/mmb/myBookingsPage.dart';
import 'package:vmba/ads/adsPage.dart';
import 'package:vmba/home/home_page.dart';
import 'package:vmba/root_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:vmba/utilities/widgets/Messaging.dart';

import 'Services/PushNotificationService.dart';
import 'data/globals.dart';
import 'data/SystemColors.dart';
import 'main_fl.dart';
import 'main_lm.dart';
import 'main_qi.dart';
import 'main_si.dart';
import 'main_t6.dart';
import 'main_z4.dart';
import 'main_gotland.dart';
import 'main_halland.dart';
import 'main_skane.dart';
import 'main_keylime.dart';
import 'package:vmba/menu/errorPage.dart';

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
      case 'AH':
        configAH();
        break;
      case 'AS':
        configAS();
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
      case 'KG':
        configKG();
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

    if( gblSettings.wantPushNoticications) {
       initFirebase(context);
    }
  }

  @override
  Widget build(BuildContext context) {
   // Locale myLocale = Localizations.localeOf(context);
    bFirstTime = false;
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
      GlobalCupertinoLocalizations.delegate
    ];

    List<Locale> locales =[
      Locale('fr', ''),
      Locale('en', ''),
      Locale('sv', ''),
      Locale('da', ''),
      Locale('no', ''),
      Locale('fi', ''),
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
          builder: (context, provider, child) => MaterialApp(
      localizationsDelegates: localizationsDelegates,
      //locale: Locale('fr', ''), // locale: Locale(gblLanguage, ''),
      locale: Provider.of<LocaleModel>(context).getLocale(),
      supportedLocales: locales,

       debugShowCheckedModeBanner: false,
      title: gblAppTitle,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: gblSystemColors.primaryColor,
        secondaryHeaderColor: gblSystemColors.accentColor,

        colorScheme: ColorScheme.light(primary: Colors.black).copyWith(secondary: gblSystemColors.accentColor),
        //buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary,)
      ),
      darkTheme: ThemeData(
        //brightness: Brightness.dark,
        primaryColor: gblSystemColors.primaryColor,
        colorScheme: ColorScheme.light(primary: Colors.black).copyWith(secondary: gblSystemColors.accentColor),
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
        '/ErrorPage': (BuildContext context) => new ErrorPage(),
        '/CompletedPage': (BuildContext context) => new CompletedPage(),
        '/ProcessCommandsPage': (BuildContext context) =>
            new ProcessCommandsPage(),
        '/message': (context) => MessageView(),
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
      if (prefs.getString('language_code') == null || prefs.getString('language_code').isEmpty) {
        if( localeStr != null && localeStr.isNotEmpty && _localeSupported(localeStr)) {
          gblLanguage = localeStr.split('_')[0];
          setState(() {
          });
        } else {
          gblLanguage = 'en';
        }
        return ;
      }
      gblLanguage= prefs.getString('language_code');
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

class AddBookingPage {}

class LocaleModel with ChangeNotifier {

  Locale getLocale() {
    Locale locale = Locale(gblLanguage);
    return locale;
  }
  void changelocale(Locale l) {
    //locale = l;
    //Locale locale = Locale(gblLanguage);
    notifyListeners();
    initializeDateFormatting();
  }
}
Future<void> initFirebase(BuildContext context) async {
  await Firebase.initializeApp();

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
   FirebaseMessaging.instance.getToken().then((token){
     print('token= ' + token);
     saveToken(token);
   });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {

    RemoteNotification notification = message.notification;
    AndroidNotification android = message.notification?.android;

    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
            //  channel.description,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: 'launch_background',
            ),
          ));
    }
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      Navigator.pushNamed(context, '/message',
          arguments: MessageArguments(message, true));
    });

  });
   /*
  print('FlutterFire Messaging Example: Getting APNs token...');
  String token = await FirebaseMessaging.instance.getAPNSToken();
  print('FlutterFire Messaging Example: Got APNs token: $token');
*/

}
/// Create a [AndroidNotificationChannel] for heads up notifications
AndroidNotificationChannel channel;

/// Initialize the [FlutterLocalNotificationsPlugin] package.
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;


/// To verify things are working, check out the native platform logs.
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');


}
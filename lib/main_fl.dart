import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/data/SystemColors.dart';
import 'package:vmba/data/settings.dart';
import 'package:vmba/data/models/passengerTypesDisplay.dart';
import 'resources/app_config.dart';
import 'main.dart';
import 'data/globals.dart';

void main() {
  config_fl();


  var configuredApp = AppConfig(
      appTitle: 'airleap',
      child: App(),
      buildFlavor: 'FL',
      systemColors: gblSystemColors,
      settings: gbl_settings,);
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(configuredApp);
  });
}
void config_fl() {
  SystemColors _systemColors = SystemColors(
      primaryButtonColor: Color.fromRGBO(0X00, 0x37, 0x55, 1),
      accentButtonColor: Color.fromRGBO(0X00, 0x37, 0x55, 1),
      accentColor: Colors.black,
      primaryColor: Color.fromRGBO(0xF0, 0x81,0,1),
      primaryButtonTextColor: Colors.white,
      textButtonTextColor: Colors.black54  ,
      primaryHeaderColor: Color.fromRGBO(0x1C, 0x37,0x48,1), // orange Color.fromRGBO(0xF0, 0x81,0,1),
      headerTextColor: Colors.white,
      statusBar: Brightness.dark);

  gblSystemColors =_systemColors;
  gbl_titleStyle =  new TextStyle( color: Colors.white) ;


  gblAppTitle = 'airleap';
  gblBuildFlavor = 'FL';
  //gbl_language = 'en';

  gbl_settings = Settings(
    latestBuildiOS: '1.0.5',
    latestBuildAndroid: '1.0.0.98',
    airlineName: "Air Leap",
    xmlToken: "token=tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo%3D",
    xmlTokenPost:  "tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo=",
    aircode:  "FL",

    termsAndConditionsUrl:  "https://www.airleap.se/sv/allt-for-resan/fore-resan/resebestammelser",
    privacyPolicyUrl:  "https://www.airleap.se/sv/om-airleap/integritetspolicy",
   faqUrl: "https://customertest.videcom.com/videcomair/vars/public/test/faq.html", //"https://www.airleap.se/en/travel-information",
    contactUsUrl: "https://customertest.videcom.com/videcomair/vars/public/test/contactus.html", // "https://www.airleap.se/en/about-airleap/contact-us",
    locale:  'en-EN',
    bookingLeadTime:  60,
    webCheckinNoSeatCharge:  false,
    vrsGuid:  '6e294c5f-df72-4eff-b8f3-1806b247340c',
    autoSeatOption:  true,
    backgroundImageUrl:  "",
    hostBaseUrl: 'https://customertest.videcom.com/AirLeap/VARS/public',
    iOSAppId:  '1457545908',
    androidAppId:  'se.airleap.booking',

    eVoucher:  false,
    passengerTypes:  PassengerTypes(
      adult: true,
      child: true,
      infant: true,
      youth: true,
    ),
    fqtvName:  "",
    appFeedbackEmail:  "",
    prohibitedItemsNoticeUrl: null,
    groupsBookingsEmail:  "",
    maxNumberOfPax:  8,
    hideFareRules:  true,
    fqtvEnabled:  false,
//      xmlUrl:      "https://booking.loganair.co.uk/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
//      apisUrl:       'https://booking.loganair.co.uk/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
//      apiUrl: 'https://booking.loganair.co.uk/ANCwebApi/api/',
//      creditCardProviderProduction: 'worldpaydirect',

  apiKey: '2edd1519899a4e7fbf9a307a0db4c17a',
//Staging setttings
    xmlUrl:      "https://customertest.videcom.com/airleap/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    apisUrl:      'https://customertest.videcom.com/airleap/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    apiUrl:      'https://customertest.videcom.com/airleap/VARS/webApi/api/',
    creditCardProvider: 'videcard',
    wantPayStack: false,
    wantLeftLogo: false,
    bpShowFastTrack: true,
    bpShowLoungeAccess: true,

/*  final int maxNumberOfPax = 8;
  final bool hideFareRules = false;
  final bool fqtvEnabled = false;
  final bool bpShowLoungeAccess = true;
  final bool bpShowFastTrack = true;
  final Color seatPlanColorEmergency = Colors.red; //Colors.yellow
  final Color seatPlanColorAvailable = Colors.blue; //Colors.green
  final Color seatPlanColorSelected = Colors.blue.shade900; //Colors.grey.shade600
  final Color seatPlanColorUnavailable =
      Colors.grey.shade300; //Colors.grey.shade300
  final Color seatPlanColorRestricted = Colors.green[200]; //Colors.grey.shade300
*/
  );


}
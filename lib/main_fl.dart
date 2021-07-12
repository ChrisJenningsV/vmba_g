import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/data/SystemColors.dart';
import 'package:vmba/data/settings.dart';
import 'package:vmba/data/models/passengerTypesDisplay.dart';
import 'resources/app_config.dart';
import 'main.dart';
import 'data/globals.dart';

void main() {
  configFL();


  var configuredApp = AppConfig(
      appTitle: 'airleap',
      child: App(),
      buildFlavor: 'FL',
      systemColors: gblSystemColors,
      settings: gblSettings,);
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(configuredApp);
  });
}
void configFL() {
  SystemColors _systemColors = SystemColors(
     primaryButtonColor: Color.fromRGBO(0X00, 0x37, 0x55, 1),
      accentButtonColor: Color.fromRGBO(0X00, 0x37, 0x55, 1),
      accentColor: Colors.black,
/*      primaryColor: Color.fromRGBO(0xF0, 0x81,0,1),
      textButtonTextColor: Colors.black54  , */
      primaryHeaderColor: Color.fromRGBO(0x1C, 0x37,0x48,1), // orange Color.fromRGBO(0xF0, 0x81,0,1),


    primaryColor: Colors.red,
    textButtonTextColor: Colors.black54,
    primaryButtonTextColor: Colors.white,
 //   primaryHeaderColor: Colors.red,
    headerTextColor: Colors.white,
    statusBar: Brightness.dark,



    seatPlanColorEmergency: Colors.red, //Colors.yellow
    seatPlanColorAvailable: Colors.blue, //Colors.green
    seatPlanColorSelected: Colors.blue.shade900, //Colors.grey.shade600
    seatPlanColorUnavailable:      Colors.grey.shade300, //Colors.grey.shade300
    seatPlanColorRestricted: Colors.green[200],
  );
//  _systemColors.setDefaults();

  gblSystemColors =_systemColors;
  gblTitleStyle =  new TextStyle( color: Colors.white) ;


  gblAppTitle = 'airleap';
  gblBuildFlavor = 'FL';
   //gbl_language = 'en';

  gblSettings = Settings(
   // latestBuildiOS: '1.0.8.40',
   // latestBuildAndroid: '1.0.8.40',
    wantRememberMe: false,
    wantHomeFQTVButton: true,
    airlineName: "Air Leap",
    xmlToken: "token=tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo%3D",
    xmlTokenPost:  "tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo=",
    aircode:  "FL",

    termsAndConditionsUrl:  " https://www.airleap.se/sv/allt-for-resan/fore-resan/resebestammelser?app_mode=1",
    privacyPolicyUrl:  "https://www.airleap.se/sv/om-air-leap/integritetspolicy?app_mode=1",
   faqUrl: "https://www.airleap.se/sv/allt-for-resan?app_mode=1", //"https://www.airleap.se/en/travel-information",
    contactUsUrl: "https://www.airleap.se/sv/om-air-leap/kontakta-oss?app_mode=1", // "https://www.airleap.se/en/about-airleap/contact-us",
    locale:  'en-EN',
    bookingLeadTime:  60,
    webCheckinNoSeatCharge:  false,
    vrsGuid:  '6e294c5f-df72-4eff-b8f3-1806b247340c',
    autoSeatOption:  true,
    backgroundImageUrl:  "",
    hostBaseUrl: 'https://customertest.videcom.com/AirLeap/VARS/public',
    iOSAppId:  '1457545908',
    androidAppId:   'se.airleap.booking', //  'se.airleap.booking',

    eVoucher:  true,
    passengerTypes:  PassengerTypes(
      adult: true,
      child: true,
      infant: true,
      youth: true,
      senior: true,
    ),
    fqtvName:  "",
    wantFQTV: true,
    wantFQTVNumber: true,
    appFeedbackEmail:  "",
    prohibitedItemsNoticeUrl: null,
    groupsBookingsEmail:  "",
    maxNumberOfPax:  8,
    hideFareRules:  true,
    fqtvEnabled:  false,
// https://customer3.videcom.com/AirLeap/vars/public/

  apiKey: '2edd1519899a4e7fbf9a307a0db4c17a',
//Staging setttings
    liveXmlUrl:      "https://booking.airleap.se/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    liveApisUrl:       'https://booking.airleap.se/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    liveApiUrl: 'https://booking.airleap.se/VARS/webApiV2/api/',
    liveCreditCardProvider: 'worldpaydirect',

    xmlUrl:      "https://customertest.videcom.com/airleap/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    apisUrl:      'https://customertest.videcom.com/airleap/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    apiUrl:      'https://customertest.videcom.com/airleap/VARS/webApiV2/api/',
    creditCardProvider: 'videcard',

    testXmlUrl:      "https://customertest.videcom.com/airleap/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    testApisUrl:      'https://customertest.videcom.com/airleap/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    testApiUrl:      'https://customertest.videcom.com/airleap/VARS/webApiV2/api/',
    testCreditCardProvider: 'videcard',

    wantPayStack: false,
    wantLeftLogo: false,
    bpShowFastTrack: true,
    bpShowLoungeAccess: true,
    searchDateOut: 1,
    searchDateBack: 6,


  );


}
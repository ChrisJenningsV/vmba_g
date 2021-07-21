import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/data/SystemColors.dart';
import 'package:vmba/data/settings.dart';
import 'package:vmba/data/models/passengerTypesDisplay.dart';
import 'resources/app_config.dart';
import 'main.dart';
import 'data/globals.dart';

void main() {
  configT6();

  var configuredApp = AppConfig(
    appTitle: 'airswift',
    child: App(),
    buildFlavor: 'T6',
    systemColors: gblSystemColors,
    settings: gblSettings,);
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(configuredApp);
  });
}
void configT6() {

  SystemColors _systemColors = SystemColors(
      textButtonTextColor: Colors.black54,
     seatPlanColorEmergency: Colors.red, //Colors.yellow
      seatPlanColorAvailable: Colors.blue, //Colors.green
      seatPlanColorSelected: Colors.blue.shade900, //Colors.grey.shade600
      seatPlanColorUnavailable:      Colors.grey.shade300, //Colors.grey.shade300
      seatPlanColorRestricted: Colors.green[200],
      primaryButtonColor: Color.fromRGBO(83, 40, 99, 1),
      accentButtonColor: Color.fromRGBO(83, 40, 99, 1),
         // Color.fromRGBO(73, 201, 245, 1), 
      accentColor: Color.fromRGBO(83, 40, 99, 1),//Color.fromRGBO( 241, 182, 0, 1), //Color.fromRGBO(0, 83, 55, 1), //Colors.white,
      primaryColor: Colors.white,
      primaryButtonTextColor: Colors.white,
      primaryHeaderColor: Colors.white,//Color.fromRGBO(12, 59, 111, 1),
      headerTextColor: Colors.black,
      statusBar: Brightness.light);

  gblSystemColors =_systemColors;
  gblTitleStyle =  new TextStyle( color: Colors.white) ;
  gblAppTitle = 'airswift';
  gblBuildFlavor = 'T6';


  gblSettings = Settings (
      latestBuildiOS: '1.0.5',
      latestBuildAndroid: '1.0.0.98',
    wantRememberMe: false,
    wantHomeFQTVButton: true,
      airlineName: "Air Swift",
      xmlToken: "token=tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo%3D",
      xmlTokenPost: "tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo=",
      aircode: 'T6',
      termsAndConditionsUrl: 'https://air-swift.com/full-terms-conditions/',
      privacyPolicyUrl:  'https://air-swift.com/privacy-policy/',
     // prohibitedItemsNoticeUrl:  'https://www.loganair.co.uk/prohibited-items-notice/',
      locale: 'en-EN',
      bookingLeadTime: 60,
      webCheckinNoSeatCharge: false,
      vrsGuid: '6e294c5f-df72-4eff-b8f3-1806b247340c',
      autoSeatOption: true,
 //     hostBaseUrl:  'https://customertest.videcom.com/airswift/VARS/public',
      iOSAppId: '1457545908',
      androidAppId: 'com.airswift',
      fqtvName: 'Clan',
      appFeedbackEmail: 'appfeedback@airswift.com',
      groupsBookingsEmail: 'groups@airswift.com',
      bpShowFastTrack: true,
      bpShowLoungeAccess: true,
      buttonStyle: 'RO1',

      passengerTypes: PassengerTypes(
      adult: true,
      child: true,
      infant: true,
      youth: true,
      senior:  true,
  ),

//Production setttings
  liveXmlUrl:      "https://booking.loganair.co.uk/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
  liveApisUrl:      'https://booking.loganair.co.uk/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
  liveApiUrl: 'https://booking.loganair.co.uk/ANCwebApi/api/',
  liveCreditCardProvider: 'worldpaydirect',

  eVoucher: true,

//Staging setttings
  xmlUrl:      "https://customertest.videcom.com/airswift/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
  apisUrl:      'https://customertest.videcom.com/airswift/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
  apiUrl:      'https://customertest.videcom.com/airswift/VARS/webApiv2/api/',  // InHouse
  creditCardProvider: 'videcard',

  testXmlUrl:      "https://customertest.videcom.com/airswift/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
  testApisUrl:      'https://customertest.videcom.com/airswift/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
  testApiUrl:      'https://customertest.videcom.com/airswift/VARS/webApiv2/api/',  // InHouse
  testCreditCardProvider: 'videcard',


  wantPayStack: false,
  wantLeftLogo: false,
  apiKey: '26d5a5deaf774724bb5d315dbb8bfee2',
  maxNumberOfPax: 8,
  hideFareRules: false,
  fqtvEnabled: false,
    searchDateOut: 1,
    searchDateBack: 6,
  );
  gblSettings.setDefaults();
}

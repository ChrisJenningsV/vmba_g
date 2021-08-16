import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/data/SystemColors.dart';
import 'package:vmba/data/settings.dart';
import 'package:vmba/data/models/passengerTypesDisplay.dart';
import 'resources/app_config.dart';
import 'main.dart';
import 'data/globals.dart';

void main() {
  configLM();

  var configuredApp = AppConfig(
      appTitle: 'loganair',
      child: App(),
      buildFlavor: 'LM',
      systemColors: gblSystemColors,
      settings: gblSettings,);
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(configuredApp);
  });
}
void configLM() {
  SystemColors _systemColors = SystemColors(
      primaryButtonColor: Colors.black,
      accentButtonColor: Colors.black,
      accentColor: Colors.black,
      primaryColor: Colors.red,
      textButtonTextColor: Colors.black54,
      primaryButtonTextColor: Colors.white,
      primaryHeaderColor: Colors.red,
      headerTextColor: Colors.white,
      statusBar: Brightness.dark,
    seatPlanColorEmergency: Colors.red, //Colors.yellow
    seatPlanColorAvailable: Colors.blue, //Colors.green
    seatPlanColorSelected: Colors.blue.shade900, //Colors.grey.shade600
    seatPlanColorUnavailable:      Colors.grey.shade300, //Colors.grey.shade300
    seatPlanColorRestricted: Colors.green[200], //Colors.grey.shade300
  );
  _systemColors.setDefaults();
  gblSystemColors =_systemColors;
  gblTitleStyle =  new TextStyle( color: Colors.white) ;

  gblAppTitle = 'loganair';
  gblBuildFlavor = 'LM';

  gblSettings = Settings (
//    latestBuildiOS: '1.0.5',
//    latestBuildAndroid: '1.0.0.98',
    wantRememberMe: false,
    wantHomeFQTVButton: false,
    wantMaterialControls: true,
    wantNewEditPax: true,
    wantBags: true,
    airlineName: "Logan Air",
  gblServerFiles: 'https://customertest.videcom.com/LoganAir/AppFiles/',
  xmlToken: "token=tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo%3D",
    xmlTokenPost: "tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo=",
  aircode: 'LM',
  termsAndConditionsUrl: 'https://loganair.co.uk/terms-m/',
   privacyPolicyUrl:  'https://loganair.co.uk/wp-content/uploads/2018/05/Privacy-policy-2205.pdf',
  prohibitedItemsNoticeUrl:  'https://www.loganair.co.uk/prohibited-items-notice/',
  locale: 'en-EN',
  bookingLeadTime: 60,
  webCheckinNoSeatCharge: false,
  vrsGuid: '6e294c5f-df72-4eff-b8f3-1806b247340c',
  autoSeatOption: true,
//  hostBaseUrl:  'https://customertest.videcom.com/LoganAirInHouse/VARS/public',
  iOSAppId: '1457545908',
  androidAppId: 'uk.co.loganair.reservations',
  fqtvName: 'Clan',
  appFeedbackEmail: 'appfeedback@loganair.co.uk',
  groupsBookingsEmail: 'groups@loganair.co.uk',
    bpShowFastTrack: true,
    bpShowLoungeAccess: true,
    searchDateOut: 1,
    searchDateBack: 6,


    passengerTypes: PassengerTypes(
  adults: true,
  child: true,
  infant: true,
  youths: true,
  ),

//Production setttings

  liveXmlUrl:      "https://booking.loganair.co.uk/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
  liveApisUrl:      'https://booking.loganair.co.uk/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
  liveApiUrl:      'https://booking.loganair.co.uk/VARS/webApiv2/api/',

  liveCreditCardProvider: 'worldpaydirect',

  eVoucher: true,
    xmlUrl:      "https://customertest.videcom.com/LoganAirInHouse/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    apisUrl:      'https://customertest.videcom.com/LoganAirInHouse/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    apiUrl:      'https://customertest.videcom.com/LoganAirInHouse/VARS/webApiv2/api/',  // InHouse

//Staging setttings
  testXmlUrl:      "https://customertest.videcom.com/LoganAirInHouse/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
  testApisUrl:      'https://customertest.videcom.com/LoganAirInHouse/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
  testApiUrl:      'https://customertest.videcom.com/LoganAirInHouse/VARS/webApiv2/api/',  // InHouse

/*
    xmlUrl:      "https://customertest.videcom.com/LoganAir/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    apisUrl:      'https://customertest.videcom.com/LoganAir/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    apiUrl:      'https://customertest.videcom.com/LoganAir/VARS/webApiv2/api/',  // InHouse

 */
  creditCardProvider: 'videcard',
  testCreditCardProvider: 'videcard',

  wantPayStack: false,
  wantLeftLogo: false,
  wantCurrencySymbols: true,
  wantMyAccount: true,
  wantFQTV: true,
  wantFQTVNumber: true,
  apiKey: '93a9626c78514c2baab494f4f6e0c197',
  maxNumberOfPax: 8,
  hideFareRules: false,

/*  bpShowLoungeAccess: true,
  bpShowFastTrack: true,
  seatPlanColorEmergency: Colors.red, //Colors.yellow
  seatPlanColorAvailable: Colors.blue, //Colors.green
  seatPlanColorSelected: Colors.blue.shade900, //Colors.grey.shade600
  seatPlanColorUnavailable:      Colors.grey.shade300, //Colors.grey.shade300
  seatPlanColorRestricted: Colors.green[200], //Colors.grey.shade300
 */
  );
  gblSettings.setDefaults();
}

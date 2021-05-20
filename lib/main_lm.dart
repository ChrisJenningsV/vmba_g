import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/data/SystemColors.dart';
import 'package:vmba/data/settings.dart';
import 'package:vmba/data/models/passengerTypesDisplay.dart';
import 'resources/app_config.dart';
import 'main.dart';
import 'data/globals.dart';

void main() {
  config_lm();

  var configuredApp = AppConfig(
      appTitle: 'loganair',
      child: App(),
      buildFlavor: 'LM',
      systemColors: gbl_SystemColors);
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(configuredApp);
  });
}
void config_lm() {
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

  gbl_SystemColors =_systemColors;
  gbl_titleStyle =  new TextStyle( color: Colors.white) ;

  gbl_appTitle = 'loganair';
  gbl_buildFlavor = 'LM';

  gbl_settings = Settings (
    latestBuildiOS: '1.0.5',
    latestBuildAndroid: '1.0.0.98',
    airlineName: "Logan Air",
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
  backgroundImageUrl:  'https://customertest.videcom.com/LoganAir/VARS/public/CustomerFiles/LoganAir/App/HOGMANAY_SALE1.png',
  hostBaseUrl:  'https://customertest.videcom.com/LoganAir/VARS/public',
  iOSAppId: '1457545908',
  androidAppId: 'uk.co.loganair.booking',
  fqtvName: 'Clan',
  appFeedbackEmail: 'appfeedback@loganair.co.uk',
  groupsBookingsEmail: 'groups@loganair.co.uk',
    bpShowFastTrack: true,
    bpShowLoungeAccess: true,


    passengerTypes: PassengerTypes(
  adult: true,
  child: true,
  infant: true,
  youth: true,
  ),

//Production setttings
/*  xmlUrl:      "https://booking.loganair.co.uk/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
  apisUrl:      'https://booking.loganair.co.uk/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
  apiUrl: 'https://booking.loganair.co.uk/ANCwebApi/api/',
  creditCardProvider: 'worldpaydirect',
 */
  eVoucher: true,

//Staging setttings
  xmlUrl:      "https://customertest.videcom.com/LoganAir/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
  apisUrl:      'https://customertest.videcom.com/LoganAir/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
  apiUrl:      'https://customertest.videcom.com/LoganAir/VARS/webApi/api/',
  creditCardProvider: 'videcard',
  wantPayStack: false,
  wantLeftLogo: false,
  apiKey: '93a9626c78514c2baab494f4f6e0c197',
  maxNumberOfPax: 8,
  hideFareRules: false,
  fqtvEnabled: false,

/*  bpShowLoungeAccess: true,
  bpShowFastTrack: true,
  seatPlanColorEmergency: Colors.red, //Colors.yellow
  seatPlanColorAvailable: Colors.blue, //Colors.green
  seatPlanColorSelected: Colors.blue.shade900, //Colors.grey.shade600
  seatPlanColorUnavailable:      Colors.grey.shade300, //Colors.grey.shade300
  seatPlanColorRestricted: Colors.green[200], //Colors.grey.shade300
 */
  );
}

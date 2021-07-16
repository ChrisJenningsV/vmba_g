import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/data/SystemColors.dart';
import 'package:vmba/data/settings.dart';
import 'package:vmba/data/models/passengerTypesDisplay.dart';
import 'resources/app_config.dart';
import 'main.dart';
import 'data/globals.dart';

// brand id AG

void main() {
  configAG();


  var configuredApp = AppConfig(
    appTitle: 'airgotland',
    child: App(),
    buildFlavor: 'AG',
    systemColors: gblSystemColors,
    settings: gblSettings,);
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(configuredApp);
  });
}
void configAG() {
  SystemColors _systemColors = SystemColors(
    primaryButtonColor: Color.fromRGBO(0Xe5, 0x05, 0x5b, 1),
    accentButtonColor: Color.fromRGBO(0Xe5, 0x05, 0x5b, 1),
    accentColor: Colors.black,
/*      primaryColor: Color.fromRGBO(0xF0, 0x81,0,1),
      textButtonTextColor: Colors.black54  , */
    primaryHeaderColor: Color.fromRGBO(0Xe5, 0x05, 0x5b,1), // orange Color.fromRGBO(0xF0, 0x81,0,1),


    primaryColor: Color.fromRGBO(0Xe5, 0x05, 0x5b,1),
    textButtonTextColor: Colors.black54,
    primaryButtonTextColor: Colors.white,
    //   primaryHeaderColor: Colors.red,
    headerTextColor: Colors.white,
    statusBar: Brightness.dark,


/*
    seatPlanColorEmergency: Colors.red, //Colors.yellow
    seatPlanColorAvailable: Colors.blue, //Colors.green
    seatPlanColorSelected: Colors.blue.shade900, //Colors.grey.shade600
    seatPlanColorUnavailable:      Colors.grey.shade300, //Colors.grey.shade300
    seatPlanColorRestricted: Colors.green[200],
    */

  );
  _systemColors.setDefaults();

  gblSystemColors =_systemColors;
  gblTitleStyle =  new TextStyle( color: Colors.white) ;


  gblAppTitle = 'airgotland';
  gblBuildFlavor = 'AG';
  //gbl_language = 'en';

  gblSettings = Settings(
    wantRememberMe: false,
    wantHomeFQTVButton: true,
    wantCurrencyPicker: true,
    currency: 'NOK',
    airlineName: "Air Gotland",
    xmlToken: "token=tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo%3D",
    xmlTokenPost:  "tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo=",
    aircode:  "FL",
    brandID: "AG",

    termsAndConditionsUrl:  " https://www.airgotland.se/sv/allt-for-resan/fore-resan/resebestammelser?app_mode=1",
    privacyPolicyUrl:  "https://www.airgotland.se/sv/om-air-leap/integritetspolicy?app_mode=1",
    faqUrl: "https://www.airgotland.se/sv/allt-for-resan?app_mode=1", //"https://www.airleap.se/en/travel-information",
    contactUsUrl: "https://www.airgotland.se/sv/om-air-leap/kontakta-oss?app_mode=1", // "https://www.airleap.se/en/about-airleap/contact-us",
//    locale:  'en-EN',
 //   bookingLeadTime:  60,
    webCheckinNoSeatCharge:  false,
    vrsGuid:  '6e294c5f-df72-4eff-b8f3-1806b247340c',
    autoSeatOption:  true,
//    backgroundImageUrl:  "",
//    hostBaseUrl: 'https://customertest.videcom.com/AirLeap/VARS/public',
    iOSAppId:  '1457545908',
    androidAppId:   'se.airhalland.booking', //  'se.airleap.booking',

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
//    maxNumberOfPax:  9,
    hideFareRules:  true,
    fqtvEnabled:  false,
    wantMyAccount: true,
    apiKey: '2edd1519899a4e7fbf9a307a0db4c17a',
//Staging setttings
    liveXmlUrl:      "https://booking.airgotland.se/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    liveApisUrl:       'https://booking.airgotland.se/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    liveApiUrl: 'https://booking.airgotland.se/VARS/webApiV2/api/',
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
//    searchDateOut: 1,
//    searchDateBack: 6,
  );
  gblSettings.setDefaults();


}
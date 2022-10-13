import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/data/SystemColors.dart';
import 'package:vmba/data/settings.dart';
import 'package:vmba/data/models/passengerTypesDisplay.dart';
import 'resources/app_config.dart';
import 'main.dart';
import 'data/globals.dart';

// brand id AH

void main() {
  configAH();


  var configuredApp = AppConfig(
    appTitle: 'airhalland',
    child: App(),
    buildFlavor: 'AH',
    systemColors: gblSystemColors,
    settings: gblSettings,);
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(configuredApp);
  });
}
void configAH() {
  SystemColors _systemColors = SystemColors(
    primaryButtonColor: Color.fromRGBO(0X00, 0x37, 0x55, 1),
//    primaryButtonColor: Color.fromRGBO(0X1d, 0x61, 0xa1, 1),
    accentButtonColor: Color.fromRGBO(0X1d, 0x61, 0xa1, 1),
    accentColor: Colors.grey, // used for calendar selection ends
    primaryHeaderColor: Color.fromRGBO(0X00, 0x37, 0x55, 1),


    primaryColor: Color.fromRGBO(0X1d, 0x61, 0xa1,1),
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


  gblAppTitle = 'airhalland';
  gblBuildFlavor = 'AH';

  gblSettings = Settings(
    wantRememberMe: false,
    wantHomeFQTVButton: false,
    airlineName: "Air Halland",
    xmlToken: "token=tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo%3D",
    xmlTokenPost:  "tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo=",
    aircode:  "FL",
    brandID: "AH",
    buttonStyle: 'RO2',
  	youthIsAdult: true,
	
    termsAndConditionsUrl:  "https://www.airhalland.se/sv/allt-for-resan/fore-resan/resebestammelser?app_mode=1",
    privacyPolicyUrl:  "https://www.airhalland.se/sv/om-air-halland/integritetspolicy?app_mode=1",
    faqUrl: "https://www.airhalland.se/sv/allt-for-resan?app_mode=1", //"https://www.airleap.se/en/travel-information",
    contactUsUrl: "https://www.airhalland.se/sv/om-air-halland/kontakta-oss?app_mode=1", // "https://www.airleap.se/en/about-airleap/contact-us",
    bookingLeadTime:  60,
    webCheckinNoSeatCharge:  false,
    vrsGuid:  '6e294c5f-df72-4eff-b8f3-1806b247340c',
    autoSeatOption:  true,
    backgroundImageUrl:  "",
    iOSAppId:  '1457545908',
    androidAppId:   'se.airhalland.booking', //  'se.airleap.booking',
    gblLanguages: 'sv,Swedish,no,Norwegian,en,English',
    wantEnglishTranslation: true,
    currencies: 'se,SEK,no,NOK,eu,EUR',
    currency: 'SEK',
    wantCurrencyPicker: true,
    wantNewEditPax: true,
    wantProducts: false,
    wantDangerousGoods: true ,
    wantFindBookings: true,
    wantClassBandImages: true,
    //wantMaterialControls: true,
    wantPageImages: true,

    want24HourClock: true,

    eVoucher:  true,
    passengerTypes:  PassengerTypes(
      adults: true,
      child: true,
      infant: true,
      youths: true,
      senior: true,
      student: true,
      wantYouthDOB: true,
      youthMaxAge: 25,
      youthMinAge: 12,

    ),
    wantUmnr: true,
    fqtvName:  "Air Club",
    wantFQTV: true,
    wantFQTVNumber: true,
    appFeedbackEmail:  "",
    prohibitedItemsNoticeUrl: null,
    groupsBookingsEmail:  "",
    maxNumberOfPax:  9,
    hideFareRules:  true,
    wantMyAccount: true,
    apiKey: '2edd1519899a4e7fbf9a307a0db4c17a',
//Staging setttings
    liveXmlUrl:      "https://booking.airhalland.se/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    liveApisUrl:       'https://booking.airhalland.se/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    liveApiUrl: 'https://booking.airhalland.se/VARS/webApiV2/api/',
    liveCreditCardProvider: 'worldpaydirect',

    xmlUrl:      "https://customertest.videcom.com/airleap/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    apisUrl:      'https://customertest.videcom.com/airleap/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    apiUrl:      'https://customertest.videcom.com/airleap/VARS/webApiV2/api/',
    creditCardProvider: 'videcard',

    testXmlUrl:      "https://customertest.videcom.com/airleap/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    testApisUrl:      'https://customertest.videcom.com/airleap/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    testApiUrl:      'https://customertest.videcom.com/airleap/VARS/webApiV2/api/',
    testCreditCardProvider: 'videcard',
    gblServerFiles: 'https://customertest.videcom.com/AirLeap/AppFiles/',
    wantPayStack: false,
    wantLeftLogo: false,
    bpShowFastTrack: true,
    bpShowLoungeAccess: true,
  	bpShowAddPassToWalletButton: false,
//    searchDateOut: 1,
//    searchDateBack: 6,
  );
  gblSettings.setDefaults();


}
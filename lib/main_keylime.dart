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
  configKG();


  var configuredApp = AppConfig(
    appTitle: 'keylimeair',
    child: App(),
    buildFlavor: 'KG',
    systemColors: gblSystemColors,
    settings: gblSettings,);
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(configuredApp);
  });
}

void configKG() {
  SystemColors _systemColors = SystemColors(
    primaryButtonColor: Color.fromRGBO(0X33, 0x77, 0x42,1),
    otherButtonColor: Color.fromRGBO(229, 0, 91, 1),

    accentButtonColor: Color.fromRGBO(0XAD, 0xD1, 0x41, 1),
    accentColor: Colors.black,
    primaryHeaderColor: Color.fromRGBO(0X2A, 0x2A, 0x2A, 1),

    primaryColor: Color.fromRGBO(0X33, 0x77, 0x42,1),// colour for datepicker header
    textButtonTextColor: Colors.black54,
    primaryButtonTextColor: Colors.white,
    //   primaryHeaderColor: Colors.red,
    headerTextColor: Colors.white, //Color.fromRGBO(0XAD, 0xD1, 0x41, 1),
    statusBar: Brightness.dark,
  );
  _systemColors.setDefaults();

  gblSystemColors =_systemColors;
  gblTitleStyle =  new TextStyle( color: Colors.white) ;


  gblAppTitle = 'keylimeair';
  gblBuildFlavor = 'KG';

  gblSettings = Settings(
//    latestBuildAndroid: '120', // for test
    wantRememberMe: false,
    wantHomeFQTVButton: false,
    wantCurrencyPicker: false,
    wantNewEditPax: true,
    wantBags: false,
    wantFindBookings: true,
    wantClassBandImages: true,
    wantMaterialControls: true,
    wantPageImages: true,
    wantTallPageImage: true,

    currency: 'USD',
    airlineName: "Key Lime",
    xmlToken: "token=tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo=",
    xmlTokenPost:  "tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo=",
    aircode:  "KG",
    brandID: "",
    buttonStyle: 'RO2',

    termsAndConditionsUrl:  "https://www.airgotland.se/sv/allt-for-resan/fore-resan/resebestammelser?app_mode=1",
    privacyPolicyUrl:  "https://www.airgotland.se/sv/om-air-gotland/integritetspolicy?app_mode=1",
    faqUrl: "https://www.airgotland.se/sv/allt-for-resan?app_mode=1", //"https://www.airleap.se/en/travel-information",
    contactUsUrl: "https://www.airgotland.se/sv/om-air-gotland/kontakta-oss?app_mode=1", // "https://www.airleap.se/en/about-airleap/contact-us",
//    locale:  'en-EN',
    //   bookingLeadTime:  60,
    webCheckinNoSeatCharge:  false,
    vrsGuid:  '6e294c5f-df72-4eff-b8f3-1806b247340c',
    autoSeatOption:  true,
//    backgroundImageUrl:  "",
//    hostBaseUrl: 'https://customertest.videcom.com/AirLeap/VARS/public',
    iOSAppId:  '1457545908',
    androidAppId:   'com.keylimeair.booking', //  'se.airleap.booking',
    gblLanguages: '',
    wantEnglishTranslation: false,
    want24HourClock: true,
    currencies: '',
    gblServerFiles: 'https://customertest.videcom.com/KeyLimeAir/AppFiles',
    passengerTypes:  PassengerTypes(
      adults: true,
      child: true,
      infant: true,
      youths: false,
      senior: false,
      student: false,
      wantYouthDOB: false,
    ),

    eVoucher:  true,
    wantUmnr: true,
    fqtvName:  "Air Club",
    wantFQTV: true,
    wantFQTVNumber: true,
    appFeedbackEmail:  "",
    prohibitedItemsNoticeUrl: null,
    groupsBookingsEmail:  "",
//    maxNumberOfPax:  9,
    hideFareRules:  true,
    wantMyAccount: true,
    wantApis: true,
    wantGender: true,
    wantMiddleName: true,
    wantRedressNo: true,
    wantKnownTravNo: true,


    apiKey: '75998e0697a04bc0bbb7dd9a38cf0745',
//Staging setttings
    liveXmlUrl:      "https://booking.airgotland.se/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    liveApisUrl:       'https://booking.airgotland.se/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    liveApiUrl: 'https://booking.airgotland.se/VARS/webApiV2/api/',
    liveCreditCardProvider: 'worldpaydirect',

    xmlUrl:      "https://customertest.videcom.com/keylimeAir/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    apisUrl:      'https://customertest.videcom.com/keylimeAir/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    apiUrl:      'https://customertest.videcom.com/keylimeAir/VARS/webApiV2/api/',
    creditCardProvider: 'videcard',

    testXmlUrl:      "https://customertest.videcom.com/keylimeAir/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    testApisUrl:      'https://customertest.videcom.com/keylimeAir/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    testApiUrl:      'https://customertest.videcom.com/keylimeAir/VARS/webApiV2/api/',
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
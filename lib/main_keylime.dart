
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
    accentColor: Colors.grey, // used for calendar selection ends
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


  gblAppTitle = 'keylime';
  gblBuildFlavor = 'KG';

  gblSettings = Settings(
//    latestBuildAndroid: '120', // for test
    wantRememberMe: false,
    wantHomeFQTVButton: false,
    wantCurrencyPicker: false,
    wantNewEditPax: true,
    wantProducts: false,
    wantFindBookings: true,
    wantClassBandImages: true,
    //wantMaterialControls: true,
    wantPageImages: false,
    wantTallPageImage: false,
    bpShowAddPassToWalletButton: true,

    currency: 'USD',
    airlineName: "Key Lime",
    xmlToken: "token=tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo=",
    xmlTokenPost:  "tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo=",
    aircode:  "KG",
    brandID: "",
    buttonStyle: 'RO2',

    termsAndConditionsUrl:  "https://denverairconnection.com/mobile/contract-of-carriage/",
    privacyPolicyUrl:  "https://denverairconnection.com/mobile/privacy/",
    faqUrl: "https://denverairconnection.com/mobile/frequently-asked-questions/",
    contactUsUrl: "https://denverairconnection.com/mobile/contact-us/",
//    locale:  'en-EN',
    //   bookingLeadTime:  60,
    webCheckinNoSeatCharge:  false,
    vrsGuid:  '6e294c5f-df72-4eff-b8f3-1806b247340c',
    autoSeatOption:  true,
//    backgroundImageUrl:  "",
//    hostBaseUrl: 'https://customertest.videcom.com/AirLeap/VARS/public',
    iOSAppId:  '1457545908',
    androidAppId:  'com.denverairconnection.booking', // 'com.keylime.booking',
    gblLanguages: '',
    wantEnglishTranslation: false,
    want24HourClock: true,
    currencies: '',
    gblServerFiles: 'https://booking.denverairconnection.com/AppFiles',
    testServerFiles: 'https://customertest.videcom.com/KeyLimeAir/AppFiles',
    passengerTypes:  PassengerTypes(
      adults: true,
      child: true,
      infant: true,
      youths: false,
      senior: false,
      student: false,
      wantYouthDOB: true,
      wantAdultDOB: true,
      wantSeniorDOB: true,
    ),

    eVoucher:  true,
    wantUmnr: true,
    fqtvName:  "Mile High Elite",
    wantFQTV: true,
    wantFQTVNumber: true,
    appFeedbackEmail:  "mobileapp@denverairconnection.com",
    prohibitedItemsNoticeUrl: 'https://denverairconnection.com/mobile/prohibited-items-notice/',
    groupsBookingsEmail:  "",
//    maxNumberOfPax:  9,
    hideFareRules:  true,
    wantMyAccount: true,
    wantApis: true,
    wantGender: true,
    wantMiddleName: true,
    wantRedressNo: true,
    wantKnownTravNo: true,
    useLogin2: true,
    wantNewCalendar: true,
    wantCalendarBigMonth: true,

    apiKey: '75998e0697a04bc0bbb7dd9a38cf0745',
//Staging setttings
    liveXmlUrl:      "https://booking.denverairconnection.com/VARS/Public/WebServices/VrsApi.asmx/PostVRSCommand?",
    liveApisUrl:      'https://booking.denverairconnection.com/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    liveApiUrl:       'https://booking.denverairconnection.com/VARS/webApiV2/api/',
    liveSmartApiUrl:  "https://booking.denverairconnection.com/VARS/Public/webservices/VrsApi.asmx/MobileSmartApi",
    liveCreditCardProvider: 'worldpaydirect',

    xmlUrl:      "https://customertest.videcom.com/keylimeAir/VARS/Public/WebServices/VrsApi.asmx/PostVRSCommand?",
    apisUrl:      'https://customertest.videcom.com/keylimeAir/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    apiUrl:      'https://customertest.videcom.com/keylimeAir/VARS/webApiV2/api/',
    creditCardProvider: 'videcard',

    testXmlUrl:      "https://customertest.videcom.com/keylimeAir/VARS/Public/WebServices/VrsApi.asmx/PostVRSCommand?",
    testSmartApiUrl:  "https://customertest.videcom.com/keylimeAir/VARS/Public/webservices/VrsApi.asmx/MobileSmartApi",
    testApisUrl:      'https://customertest.videcom.com/keylimeAir/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    testApiUrl:      'https://customertest.videcom.com/keylimeAir/VARS/webApiV2/api/',
 //   testApiUrl:      'http://10.0.2.2:5000/api/',
    testCreditCardProvider: 'videcard',

    wantLeftLogo: false,
    bpShowFastTrack: true,
    bpShowLoungeAccess: true,
//    searchDateOut: 1,
//    searchDateBack: 6,
  );


  gblSettings.setDefaults();


}
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
      accentColor: Colors.grey, // used for calendar selection ends
      primaryColor: Colors.red,
      textButtonTextColor: Colors.black54,
      primaryButtonTextColor: Colors.white,
      primaryHeaderColor: Colors.red,
      borderColor: Colors.red,
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
  gblCurrentRloc = '';

  gblSettings = Settings (
   // paySettings: PaySettings(payImageMap: '{"WORLDPAYHOSTED": "image" }' ),
    wantRememberMe: false,
    wantApis: true,
    wantHomeFQTVButton: false,
    wantMaterial3: false,
    wantPriceCalendar: false ,
    wantPriceCalendarRounding: false,
    canGoBackFromPaxPage: true,
    wantGiftVouchers: false,
    //pageStyle: 'V2',

    airlineName: "Loganair",
  gblServerFiles: 'https://booking.loganair.co.uk/AppFiles/',
  testServerFiles: 'https://customertest.videcom.com/LoganAir/AppFiles/',
  xmlToken: "token=tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo%3D",
    xmlTokenPost: "tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo=",
  aircode: 'LM',
  termsAndConditionsUrl: 'https://loganair.co.uk/terms-m/',
   //trackerUrl: 'https://www.easyjet.com/en/flight-tracker/',
   privacyPolicyUrl:  'https://booking.loganair.co.uk/vars/public/CustomerFiles/LoganAir/mobile/LoganPrivacyPolicy.html',
  prohibitedItemsNoticeUrl:  'https://www.loganair.co.uk/prohibited-items-notice/',
  //ccUrl: 'https://customertest.videcom.com/loganair/vars/public/MobileStartPage.aspx',

  locale: 'en-EN',
  bookingLeadTime: 60,
  webCheckinNoSeatCharge: false,
  vrsGuid: '6e294c5f-df72-4eff-b8f3-1806b247340c',
  autoSeatOption: true,
    //useWebApiforVrs: false,
//  hostBaseUrl:  'https://customertest.videcom.com/LoganAirInHouse/VARS/public',
  iOSAppId: '1457545908',
  androidAppId: 'uk.co.loganair.booking',
  fqtvName: 'Clan',
  appFeedbackEmail: 'appfeedback@loganair.co.uk',
  groupsBookingsEmail: 'groups@loganair.co.uk',
    pageImageMap: '{"flightSummary": "summary", "paymentPage": "paymentPage", "editPax": "editPax", "options": "editPax", "paxDetails": "passengers"}',
    wantClassBandImages: false,
    bpShowFastTrack: true,
    bpShowLoungeAccess: true,
    bpShowAddPassToWalletButton: false,
    searchDateOut: 1,
    searchDateBack: 6,


    adsTermsUrl: 'https://www.loganair.co.uk/travel-help/air-discount-scheme-residents-fare-card-terms-and-conditions/',
    passengerTypes: PassengerTypes(
  adults: true,
  child: true,
  infant: true,
  youths: true,
      wantYouthDOB: true,

  ),

//Production setttings

//  liveXmlUrl:      "https://booking.loganair.co.uk/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    liveXmlUrl:      "https://booking.loganair.co.uk/VARS/Public/WebServices/VrsApi.asmx/PostVRSCommand?",
  liveApisUrl:      'https://booking.loganair.co.uk/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
  liveApiUrl:      'https://booking.loganair.co.uk/VARS/webApiv2/api/',
  livePayPage:      'https://booking.loganair.co.uk/VARS/Public/MobilePaymentStart.aspx',
  liveSmartApiUrl:  "https://booking.loganair.co.uk/VARS/Public/webservices/VrsApi.asmx/MobileSmartApi",

  liveCreditCardProvider: 'worldpaydirect',

  eVoucher: true,
  xmlUrl:      "https://customertest.videcom.com/LoganAirInHouse/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
  apisUrl:      'https://customertest.videcom.com/LoganAirInHouse/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
  apiUrl:      'http://10.0.2.2:5000/api',  // InHouse

//Staging setttings
/*
  testApiUrl:      'https://10.0.2.2:51088/webApiv2/api/',  // InHouse

 */

//    testPayPage: 'http://10.0.2.2:57793/MobilePaymentStart.aspx',
   testPayPage: 'https://customertest.videcom.com/LoganAir/VARS/Public/MobilePaymentStart.aspx',

//    testXmlUrl:      "http://10.0.2.2:61670/VRSXMLwebService3.asmx/PostVRSCommand?",
//    testXmlUrl:      "http://10.0.2.2:50311/webservices/VrsApi.asmx/PostVRSCommand?",
    //   testSmartApiUrl:      "http://10.0.2.2:51088/webservices/VrsApi.asmx/MobileSmartApi",

//    testXmlUrl:      "https://customertest.videcom.com/LoganAir/VARS/Public/WebServices/VrsApi.asmx/PostVRSCommand?",


/*
    testXmlUrl:      "https://customertest.videcom.com/LoganAirinhouse/VARS/Public/WebServices/VrsApi.asmx/PostVRSCommand?",
    testSmartApiUrl:      "https://customertest.videcom.com/LoganAirinhouse/VARS/Public/webservices/VrsApi.asmx/MobileSmartApi",
    testApisUrl:      'https://customertest.videcom.com/LoganAirinhouse/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    testApiUrl:      'https://customertest.videcom.com/LoganAirinhouse/VARS/webApiv2/api/',
*/

  //  testXmlUrl:      "http://10.0.2.2:57793/webservices/VrsApi.asmx/PostVRSCommand?",
    testXmlUrl:      "https://customertest.videcom.com/LoganAir/VARS/Public/WebServices/VrsApi.asmx/PostVRSCommand?",
//////    testXmlUrl:      "https://customertest.videcom.com/LoganAir/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
   testSmartApiUrl:      "https://customertest.videcom.com/LoganAir/VARS/Public/webservices/VrsApi.asmx/MobileSmartApi",
 //   testSmartApiUrl:      "http://10.0.2.2:57793/webservices/VrsApi.asmx/MobileSmartApi",
    testApisUrl:      'https://customertest.videcom.com/LoganAir/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
 //   testApiUrl:      'http://10.0.2.2:5000/api',
    testApiUrl:      'https://customertest.videcom.com/LoganAir/VARS/webApiv2/api/',
//    testApiUrl:      'https://customertest.videcom.com/LoganAirInHouse/VARS/webApiv2/api/',

//    testApiUrl:      'http://10.0.2.2:5000/api',  // local


  creditCardProvider: '3DS_videcard',
  testCreditCardProvider: 'videcard', //'videcard|MX payment,3DS_WorldPay3DS|WorldPay payment',

  wantPageImages: true,
  wantLeftLogo: false,
  wantCurrencySymbols: true,
  wantMyAccount: true,
  wantFQTV: true,
  wantFindBookings: true,
  wantNewEditPax: true,
  //wantMaterialControls: true,
  wantAllColorButtons: false,
  wantCitySwap: true,
    wantBpLogo: false,
  wantPushNoticications: true,
  wantNotificationEdit: false,
  //wantRefund: true,
  wantNewPayment: true,
  wantCountry: false,
//  disableBookings: true,

  wantFQTVNumber: true,
  apiKey: '93a9626c78514c2baab494f4f6e0c197',
  maxNumberOfPax: 8,
  hideFareRules: false,

    useWebApiforVrs: true,
    wantMmbProducts: false,
    wantProducts: false,
    wantStatusLine: true,
    wantSeatsWithProducts: false,

  );
  gblSettings.setDefaults();
}

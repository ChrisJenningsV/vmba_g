import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/data/SystemColors.dart';
import 'package:vmba/data/settings.dart';
import 'package:vmba/data/models/passengerTypesDisplay.dart';
import 'resources/app_config.dart';
import 'main.dart';
import 'data/globals.dart';

void main() {
  configUZ();

  var configuredApp = AppConfig(
      appTitle: 'buraq',
      child: App(),
      buildFlavor: 'UZ',
      systemColors: gblSystemColors,
      settings: gblSettings,);
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(configuredApp);
  });
}
void configUZ() {
  SystemColors _systemColors = SystemColors(
      primaryButtonColor: Color.fromRGBO(0X24, 0x80, 0xB3, 1),
      accentButtonColor: Color.fromRGBO(0X24, 0x80, 0xB3, 1),
      accentColor: Color.fromRGBO(0X24, 0x80, 0xB3, 1),
      primaryColor: Color.fromRGBO(0X24, 0x80, 0xB3, 1),
      textButtonTextColor: Colors.black54,
      primaryButtonTextColor: Colors.white,
      primaryHeaderColor: Color.fromRGBO(0X11, 0x76, 0x2B, 1),
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

  gblAppTitle = 'buraq';
  gblBuildFlavor = 'UZ';
  gblCurrentRloc = '';

  gblSettings = Settings (
    wantRememberMe: false,
    wantHomeFQTVButton: false,

    airlineName: "Buraq",
  gblServerFiles: 'https://customertest.videcom.com/buraq/AppFiles/',
  xmlToken: "token=tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo%3D",
    xmlTokenPost: "tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo=",
  aircode: 'UZ',
  termsAndConditionsUrl: ' https://buraq.aero/terms-and-conditions/',
   privacyPolicyUrl:  'https://buraq.aero/privacy-policy/',
  prohibitedItemsNoticeUrl:  'https://buraq.aero/prohibited-items/',

  //ccUrl: 'https://customertest.videcom.com/loganair/vars/public/MobileStartPage.aspx',

  locale: 'en-EN',
  bookingLeadTime: 60,
  webCheckinNoSeatCharge: false,
  vrsGuid: '6e294c5f-df72-4eff-b8f3-1806b247340c',
  autoSeatOption: true,
  iOSAppId: '1457545908',
  androidAppId: 'com.buraq.booking',
  fqtvName: 'club',
  appFeedbackEmail: 'appfeedback@buraq.com',
  groupsBookingsEmail: 'groups@buraq.com',
    pageImageMap: '{"flightSummary": "summary", "paymentPage": "paymentPage", "editPax": "editPax", "paxDetails": "passengers"}',
    wantClassBandImages: true,
    bpShowFastTrack: true,
    bpShowLoungeAccess: true,
    bpShowAddPassToWalletButton: false,
    searchDateOut: 1,
    searchDateBack: 6,


    passengerTypes: PassengerTypes(
  adults: true,
  child: true,
  infant: true,
  youths: true,
      wantYouthDOB: true,

  ),

//Production setttings

  liveXmlUrl:      "https://booking.buraq.aero/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
  liveApisUrl:      'https://booking.buraq.aero/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
  liveApiUrl:      'https://booking.buraq.aero/VARS/webApiv2/api/',
  livePayPage:      'https://booking.buraq.aero/VARS/Public/MobilePaymentStart.aspx',

  liveCreditCardProvider: 'worldpaydirect',

  eVoucher: true,
    xmlUrl:      "https://customertest.videcom.com/LoganAirInHouse/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    apisUrl:      'https://customertest.videcom.com/LoganAirInHouse/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    apiUrl:      'http://10.0.2.2:5000/api',  // InHouse

//Staging setttings
/*  testXmlUrl:      "https://10.0.2.2:51088/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
  testApisUrl:      'https://10.0.2.2:51088/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
  testApiUrl:      'https://10.0.2.2:51088/webApiv2/api/',  // InHouse

 */

 //   testPayPage: 'http://10.0.2.2:53851/MobilePaymentStart.aspx',
 //   testPayPage: 'http://10.0.2.2/MobilePaymentStart.aspx',
 //   testPayPage: 'https://vars-public-cp2.conveyor.cloud/MobilePaymentStart.aspx',
    testPayPage: 'https://customertest.videcom.com/buraq/VARS/Public/MobilePaymentStart.aspx',


//   testXmlUrl:      "http://10.0.2.2:51088/webservices/VrsApi.asmx/PostVRSCommand?",
//    testXmlUrl:      "http://10.0.2.2/webservices/VrsApi.asmx/PostVRSCommand?",
 //   testXmlUrl:      "https://vars-public-cp2.conveyor.cloud/WebServices/VrsApi.asmx/PostVRSCommand?",
    testXmlUrl:      "https://customertest.videcom.com/buraq/VARS/Public/WebServices/VrsApi.asmx/PostVRSCommand?",



 //   testXmlUrl:      "http://10.0.2.2:51090/VRSXMLwebService3.asmx/PostVRSCommand?",
//    testXmlUrl:      "https://customertest.videcom.com/buraq/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",

//  testSmartApiUrl:      "http://10.0.2.2:53851/webservices/VrsApi.asmx/MobileSmartApi",
//    testSmartApiUrl:      "http://10.0.2.2/webservices/VrsApi.asmx/MobileSmartApi",
 //  testSmartApiUrl:      "https://vars-public-cp2.conveyor.cloud/webservices/VrsApi.asmx/MobileSmartApi",
    testSmartApiUrl:      "https://customertest.videcom.com/buraq/VARS/Public/webservices/VrsApi.asmx/MobileSmartApi",



    testApisUrl:      'https://customertest.videcom.com/buraq/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    testApiUrl:      'https://customertest.videcom.com/buraq/VARS/webApiv2/api/',
//    testApiUrl:      'http://10.0.2.2:5000/api',  // local


  creditCardProvider: '3DS_videcard',
  testCreditCardProvider: 'videcard', //'videcard|MX payment,3DS_WorldPay3DS|WorldPay payment',

  displayErrorPnr: true,    // just for test, to display pnr problems
  wantPayStack: false,
  wantPageImages: true,
  wantLeftLogo: false,
  wantCurrencySymbols: true,
  wantMyAccount: true,
  wantFQTV: false,
  wantFindBookings: true,
  wantNewEditPax: true,
  wantMaterialControls: true,
  wantCitySwap: true,
  wantPushNoticications: false,
  wantNotificationEdit: false,
  wantRefund: true,
  wantNewPayment: true,
  wantCountry: false,
  useWebApiforVrs: true,
//  disableBookings: true,

  wantFQTVNumber: true,
  apiKey: 'c7137da1854e4e3f9e5d58f6e78616ee',
  maxNumberOfPax: 8,
  hideFareRules: false,


  );
  gblSettings.setDefaults();
}

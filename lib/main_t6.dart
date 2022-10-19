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
      progressTextColor: Colors.grey,
      statusBar: Brightness.light);

  _systemColors.setDefaults();
  gblSystemColors =_systemColors;
  gblTitleStyle =  new TextStyle( color: Colors.grey.shade400) ;
  gblAppTitle = 'airswift';
  gblBuildFlavor = 'T6';


  gblSettings = Settings (
      latestBuildiOS: '105',
      latestBuildAndroid: '108',
    wantRememberMe: false,
    wantHomeFQTVButton: true,
    wantFQTV:  true,
    wantMyAccount: true,

    airlineName: "Air SWIFT",
      xmlToken: "token=tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo%3D",
      xmlTokenPost: "tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo=",
    gblServerFiles: 'https://booking.air-swift.com/AppFiles',
    testServerFiles: 'https://customertest.videcom.com/airswift/AppFiles',
    faqUrl: 'https://air-swift.com/faqs/ ',
    contactUsUrl: 'https://air-swift.com/contact-us/ ',
    termsAndConditionsUrl: 'https://air-swift.com/full-terms-conditions/',
    privacyPolicyUrl:  'https://air-swift.com/privacy-policy/',
    prohibitedItemsNoticeUrl:  'https://air-swift.com/restricted-items/ ',

    aircode: 'T6',

      locale: 'en-EN',
      bookingLeadTime: 60,
      webCheckinNoSeatCharge: false,
      vrsGuid: '6e294c5f-df72-4eff-b8f3-1806b247340c',
      autoSeatOption: true,
 //     hostBaseUrl:  'https://customertest.videcom.com/airswift/VARS/public',
      iOSAppId: '1457545908',
      androidAppId: 'com.airswift',
      fqtvName: 'Travel Club',
      appFeedbackEmail: 'appfeedback@air-swift.com',
      groupsBookingsEmail: 'groups@air-swift.com',
      bpShowFastTrack: true,
      bpShowLoungeAccess: true,
  	  bpShowAddPassToWalletButton: false,
      buttonStyle: 'RO2',
      wantAllColorButtons: true,
      wantNewEditPax: true,
      //wantMaterialControls: true,
      wantCitySwap: true,
      wantPageImages: true,
    wantProducts: true,
    wantFindBookings: true,
    wantClassBandImages: true,
    wantCountry: true,
    wantTallPageImage: true,
    pageStyle: 'V2',
    pageImageMap: '{"flightSummary": "summary", "paymentPage": "paymentPage", "editPax": "editPax", "options": "editPax", "paxDetails": "passengers", "FQTV": "FQTV login"}',
    useWebApiforVrs: true,
    wantEnglishTranslation: true,


    passengerTypes: PassengerTypes(
      adults: true,
      child: true,
      infant: true,
      youths: false,
      senior:  true,
      wantAdultDOB: true,
      wantChildDOB: true,
      wantInfantDOB: true,
      wantSeniorDOB: true,
      wantStudentDOB: true,
      wantYouthDOB: true,
  ),

//Production setttings
  liveXmlUrl:      "https://booking.air-swift.com/VARS/Public/WebServices/VrsApi.asmx/PostVRSCommand?",
  liveApisUrl:      'https://booking.air-swift.com/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
  liveApiUrl: 'https://booking.air-swift.com/webApiv2/api/',
    livePayPage: 'https://booking.air-swift.com/VARS/Public/MobilePaymentStart.aspx',
    liveSmartApiUrl:  "https://booking.air-swift.co.uk/VARS/Public/webservices/VrsApi.asmx/MobileSmartApi",
  liveCreditCardProvider: 'worldpaydirect',

  eVoucher: true,

//Staging setttings
  xmlUrl:      "https://customertest.videcom.com/airswift/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
  apisUrl:      'https://customertest.videcom.com/airswift/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
  apiUrl:      'https://customertest.videcom.com/airswift/VARS/webApiv2/api/',  // InHouse
  creditCardProvider: 'videcard',

    testPayPage: 'https://customertest.videcom.com/airswift/VARS/Public/MobilePaymentStart.aspx',
 // testXmlUrl:      "https://customertest.videcom.com/airswift/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    testXmlUrl:      "https://customertest.videcom.com/airswift/VARS/Public/WebServices/VrsApi.asmx/PostVRSCommand?",
   // testXmlUrl:      "http://10.0.2.2:50311/webservices/VrsApi.asmx/PostVRSCommand?",
  testApisUrl:      'https://customertest.videcom.com/airswift/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
  testApiUrl:      'https://customertest.videcom.com/airswift/VARS/webApiv2/api/',  // InHouse
 testSmartApiUrl:      "https://customertest.videcom.com/airswift/VARS/Public/webservices/VrsApi.asmx/MobileSmartApi",
  testCreditCardProvider: 'videcard' , //MX payment,3DS_Paynamics|Paynamics payment',
    //payStartUrl: 'http://10.0.2.2:51088/MobilePaymentStart.aspx',

  wantPayStack: false,
    wantPushNoticications: true,
    wantNotificationEdit: false,
    wantNewPayment: true,
    wantMmbProducts: true,
    productImageMode: 'none',
    wantStatusLine: true,
    wantSeatsWithProducts: true,

    wantLeftLogo: false,
  apiKey: '26d5a5deaf774724bb5d315dbb8bfee2',
  maxNumberOfPax: 8,
  hideFareRules: false,
    searchDateOut: 1,
    searchDateBack: 6,
  );
  gblSettings.setDefaults();
}


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/data/SystemColors.dart';
import 'package:vmba/data/settings.dart';
import 'package:vmba/data/models/passengerTypesDisplay.dart';
import 'resources/app_config.dart';
import 'main.dart';
import 'data/globals.dart';

void main() {
  config9Q();

  var configuredApp = AppConfig(
    appTitle: 'Caicos Express Airways',
    child: App(),
    buildFlavor: '9Q',
    systemColors: gblSystemColors,
    settings: gblSettings,);
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(configuredApp);
  });
}
void config9Q() {
  SystemColors _systemColors = SystemColors(
    primaryButtonColor: Color.fromRGBO(0XF9, 0x96, 0x24, 1),
    accentButtonColor: Color.fromRGBO(0XF9, 0x96, 0x24, 1),
    accentColor: Colors.grey, // used for calendar selection ends
    primaryColor: Colors.yellow,
    textButtonTextColor: Colors.black54,
    primaryButtonTextColor: Colors.black,
    primaryHeaderColor: Color.fromRGBO(0X13, 0x3E, 0x68, 1),
    headerTextColor: Colors.white,
    statusBar: Brightness.dark,
    seatPlanColorEmergency: Colors.red, //Colors.yellow
    seatPlanColorAvailable: Colors.blue, //Colors.green
    seatPlanColorSelected: Colors.blue.shade900, //Colors.grey.shade600
    seatPlanColorUnavailable:      Colors.grey.shade300, //Colors.grey.shade300
    seatPlanColorRestricted: Colors.green[200], //Colors.grey.shade300
    home1ButtonColor: Color.fromRGBO(0X1A, 0x1E, 0x4E, 1),
    home2ButtonColor: Colors.white,
    home1ButtonTextColor: Colors.white,
    home2ButtonTextColor: Color.fromRGBO(0X2E, 0x31, 0x92, 1),
  );
  _systemColors.setDefaults();
  gblSystemColors =_systemColors;
  gblTitleStyle =  new TextStyle( color: Colors.white) ;

  gblAppTitle = 'caicos';
  gblBuildFlavor = '9Q';
  gblCurrentRloc = '';


  gblSettings = Settings (
    pageStyle: 'V1',
    homePageStyle: 'V1',
    buttonStyle: 'RO3',
    wantRememberMe: false,
    wantHomeFQTVButton: false,
    gblLanguages: 'en,English',
//    currencies: 'eu,EUR,us,USD,ro,RON,gb,GBP,md,MDL',
    currency: 'USD',
    wantCurrencyPicker: false,
    wantPassengerPassport: true,
    wantCanFacs: true,
    canGoBackFromPaxPage: true,

    airlineName: "Caicos Express Airways",
    gblServerFiles: 'https://customer.videcom.com/CaicosExpressAirways/VARS/AppFiles/',
    testServerFiles: 'https://customertest.videcom.com/CaicosExpressAirways/VARS/AppFiles/',
    xmlToken: "token=tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo%3D",
    xmlTokenPost: "tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo=",
    aircode: '9Q',
    termsAndConditionsUrl: '', //'''{"en": "https://hisky.aero/en/terms-and-conditions", "ro": "https://hisky.aero/termeni-si-conditii"}',
    privacyPolicyUrl:  '', //'''{"en": "https://hisky.aero/en/data-protection","ro": "https://hisky.aero/protectia-datelor-personale" }',
    //prohibitedItemsNoticeUrl:  'https://www.loganair.co.uk/prohibited-items-notice/',
    //ccUrl: 'https://customertest.videcom.com/loganair/vars/public/MobileStartPage.aspx',

    locale: 'en-EN',
    bookingLeadTime: 60,
    webCheckinNoSeatCharge: false,
    vrsGuid: '6e294c5f-df72-4eff-b8f3-1806b247340c',
    autoSeatOption: true,
    useWebApiforVrs: true,
//  hostBaseUrl:  'https://customertest.videcom.com/LoganAirInHouse/VARS/public',
    iOSAppId: '1457545908',
    androidAppId: 'com.caicosexpressairways.reservations',
    fqtvName: 'Club',
    appFeedbackEmail: 'appfeedback@turksandcaicosflights.com',
    groupsBookingsEmail: 'groups@turksandcaicosflights.com',
//    pageImageMap: '{"flightSummary": "summary", "paymentPage": "paymentPage", "editPax": "editPax", "paxDetails": "passengers"}',
//    wantClassBandImages: true,
    bpShowFastTrack: true,
    bpShowLoungeAccess: true,
    bpShowAddPassToWalletButton: false,
    searchDateOut: 1,
    searchDateBack: 6,
    wantApis: false,
    wantMmbProducts: true,
    wantProducts: true,
    wantStatusLine: true,
    wantSeatsWithProducts: true,

    passengerTypes: PassengerTypes(
      adults: true,
      child: true,
      infant: true,
      youths: false,
      wantYouthDOB: false,

    ),

//Production setttings

    liveXmlUrl:      "https://customer.videcom.com/caicosexpressairways/VARS/Public/WebServices/VrsApi.asmx/PostVRSCommand?",
    liveApisUrl:      'https://customer.videcom.com/caicosexpressairways/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    liveApiUrl:      'https://customer.videcom.com/caicosexpressairways/VARS/webApiV2/api/',
    //liveApiUrl:      'http://10.0.2.2:5000/api',
    livePayPage:      'https://customer.videcom.com/caicosexpressairways/VARS/Public/MobilePaymentStart.aspx',
    liveSmartApiUrl:  "https://customer.videcom.com/caicosexpressairways/VARS/Public/webservices/VrsApi.asmx/MobileSmartApi",

    //liveCreditCardProvider: 'worldpaydirect',

    eVoucher: true,
    xmlUrl:      "https://customertest.videcom.com/caicosexpressairways/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    apisUrl:      'https://customertest.videcom.com/caicosexpressairways/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    apiUrl:      'http://10.0.2.2:5000/api',  // InHouse


//    testPayPage: 'http://10.0.2.2:51088/MobilePaymentStart.aspx',
    testPayPage: 'https://customertest.videcom.com/caicosexpressairways/VARS/Public/MobilePaymentStart.aspx',

//    testXmlUrl:      "http://10.0.2.2:61670/VRSXMLwebService3.asmx/PostVRSCommand?",
//    testXmlUrl:      "http://10.0.2.2:57793/webservices/VrsApi.asmx/PostVRSCommand?",
    testXmlUrl:      "https://customertest.videcom.com/caicosexpressairways/VARS/Public/WebServices/VrsApi.asmx/PostVRSCommand?",

    //   testSmartApiUrl:      "http://10.0.2.2:51088/webservices/VrsApi.asmx/MobileSmartApi",
    testSmartApiUrl:      "https://customertest.videcom.com/caicosexpressairways/VARS/Public/webservices/VrsApi.asmx/MobileSmartApi",
    testApisUrl:      'https://customertest.videcom.com/caicosexpressairways/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    testApiUrl:      'https://customertest.videcom.com/caicosexpressairways/VARS/webApiv2/api/',
//    testApiUrl:      'http://10.0.2.2:5000/api',  // local

// website
// http://10.0.2.2:50311/TEST/PushTest.aspx

 /*   creditCardProvider: '3DS_videcard',
    testCreditCardProvider: 'videcard', //'videcard|MX payment,3DS_WorldPay3DS|WorldPay payment',
*/
    wantPayStack: false,
    wantPageImages: false,
    wantLeftLogo: false,
    wantCurrencySymbols: true,
    wantMyAccount: true,
    wantFQTV: false,
    wantFindBookings: true,
    wantNewEditPax: true,
    //wantMaterialControls: true,
    wantCitySwap: true,
    wantPushNoticications: true,
    wantNotificationEdit: false,
    wantRefund: false,
    wantNewPayment: true,
    wantCountry: false,
    useSmartPay: false,

    wantFQTVNumber: true,
    apiKey: 'c7137da1854e4e3f9e5d58f6e78616ee',
    maxNumberOfPax: 8,
    hideFareRules: false,

  );
  gblSettings.setDefaults();
}

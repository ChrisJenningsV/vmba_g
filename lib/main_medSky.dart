
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/data/SystemColors.dart';
import 'package:vmba/data/settings.dart';
import 'package:vmba/data/models/passengerTypesDisplay.dart';
import 'resources/app_config.dart';
import 'main.dart';
import 'data/globals.dart';

void main() {
  configM1();

  var configuredApp = AppConfig(
    appTitle: 'medsky',
    child: App(),
    buildFlavor: 'M1',
    systemColors: gblSystemColors,
    settings: gblSettings,);
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(configuredApp);
  });
}
void configM1() {
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

  gblAppTitle = 'medsky';
  gblBuildFlavor = 'M1';
  gblCurrentRloc = '';


  gblSettings = Settings (
    pageStyle: 'V2',
    homePageStyle: 'V2',
    buttonStyle: 'RO3',
    wantRememberMe: false,
    wantHomeFQTVButton: false,
    gblLanguages: 'ar,Arabic,en,English',
//    currencies: 'eu,EUR,us,USD,ro,RON,gb,GBP,md,MDL',
    currency: 'RON',
    wantCurrencyPicker: false,
    wantPassengerPassport: true,
    wantCanFacs: false,

    airlineName: "Medsky",
    gblServerFiles: 'https://customer3.videcom.com/Medsky/VARS/AppFiles/',
    testServerFiles: 'https://customertest.videcom.com/medsky/VARS/AppFiles/',
    xmlToken: "token=tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo%3D",
    xmlTokenPost: "tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo=",
    aircode: 'H4',
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
    androidAppId: 'aero.medsky.reservations',
    fqtvName: 'Club',
    appFeedbackEmail: 'appfeedback@medsky.md',
    groupsBookingsEmail: 'groups@medsky.md',
    pageImageMap: '{"flightSummary": "summary", "paymentPage": "paymentPage", "editPax": "editPax", "paxDetails": "passengers"}',
    wantClassBandImages: true,
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
      youths: true,
      wantYouthDOB: true,

    ),

//Production setttings

    liveXmlUrl:      "https://customer3.videcom.com/Medsky/VARS/Public/WebServices/VrsApi.asmx/PostVRSCommand?",
    liveApisUrl:      'https://customer3.videcom.com/Medsky/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    liveApiUrl:      'https://customer3.videcom.com/Medsky/VARS/webApiV2/api/',
    //liveApiUrl:      'http://10.0.2.2:5000/api',
    livePayPage:      'https://customer3.videcom.com/Medsky/VARS/Public/MobilePaymentStart.aspx',
    liveSmartApiUrl:  "https://customer3.videcom.com/Medsky/VARS/Public/webservices/VrsApi.asmx/MobileSmartApi",

    //liveCreditCardProvider: 'worldpaydirect',

    eVoucher: true,
    xmlUrl:      "https://customertest.videcom.com/medsky/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    apisUrl:      'https://customertest.videcom.com/medsky/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    apiUrl:      'http://10.0.2.2:5000/api',  // InHouse


//    testPayPage: 'http://10.0.2.2:51088/MobilePaymentStart.aspx',
    testPayPage: 'https://customertest.videcom.com/medsky/VARS/Public/MobilePaymentStart.aspx',

//    testXmlUrl:      "http://10.0.2.2:61670/VRSXMLwebService3.asmx/PostVRSCommand?",
//    testXmlUrl:      "http://10.0.2.2:50311/webservices/VrsApi.asmx/PostVRSCommand?",
    testXmlUrl:      "https://customertest.videcom.com/medsky/VARS/Public/WebServices/VrsApi.asmx/PostVRSCommand?",
///////    testXmlUrl:      "https://customertest.videcom.com/FastJet/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    //   testSmartApiUrl:      "http://10.0.2.2:51088/webservices/VrsApi.asmx/MobileSmartApi",
    testSmartApiUrl:      "https://customertest.videcom.com/medsky/VARS/Public/webservices/VrsApi.asmx/MobileSmartApi",
    testApisUrl:      'https://customertest.videcom.com/medsky/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    testApiUrl:      'https://customertest.videcom.com/medsky/VARS/webApiv2/api/',
  //  testApiUrl:      'http://10.0.2.2:5000/api',  // local

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
    apiKey: '93a9626c78514c2baab494f4f6e0c197',
    maxNumberOfPax: 8,
    hideFareRules: false,

  );
  gblSettings.setDefaults();
}

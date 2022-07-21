import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/data/SystemColors.dart';
import 'package:vmba/data/settings.dart';
import 'package:vmba/data/models/passengerTypesDisplay.dart';
import 'resources/app_config.dart';
import 'main.dart';
import 'data/globals.dart';

void main() {
  configH4();

  var configuredApp = AppConfig(
    appTitle: 'hisky',
    child: App(),
    buildFlavor: 'H4',
    systemColors: gblSystemColors,
    settings: gblSettings,);
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(configuredApp);
  });
}
void configH4() {
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
  );
  _systemColors.setDefaults();
  gblSystemColors =_systemColors;
  gblTitleStyle =  new TextStyle( color: Colors.white) ;

  gblAppTitle = 'hisky';
  gblBuildFlavor = 'H4';
  gblCurrentRloc = '';

  gblSettings = Settings (
//    latestBuildiOS: '1.0.5',
//    latestBuildAndroid: '1.0.0.98',
    wantRememberMe: false,
    wantHomeFQTVButton: false,
    gblLanguages: 'ro,Romanian,en,English',
    currencies: 'eu,EUR,us,USD,ro,RON,gb,GBP,md,MDL',
    currency: 'RON',
    wantCurrencyPicker: true,
    wantPassengerPassport: true,

    airlineName: "hiSky",
    gblServerFiles: 'https://booking.hisky.md/hisky/AppFiles/',
    testServerFiles: 'https://customertest.videcom.com/hisky/VARS/AppFiles/',
    xmlToken: "token=tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo%3D",
    xmlTokenPost: "tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo=",
    aircode: 'H4',
    termsAndConditionsUrl: 'https://loganair.co.uk/terms-m/',
    privacyPolicyUrl:  'https://booking.loganair.co.uk/vars/public/CustomerFiles/LoganAir/mobile/LoganPrivacyPolicy.html',
    prohibitedItemsNoticeUrl:  'https://www.loganair.co.uk/prohibited-items-notice/',
    //ccUrl: 'https://customertest.videcom.com/loganair/vars/public/MobileStartPage.aspx',

    locale: 'en-EN',
    bookingLeadTime: 60,
    webCheckinNoSeatCharge: false,
    vrsGuid: '6e294c5f-df72-4eff-b8f3-1806b247340c',
    autoSeatOption: true,
    useWebApiforVrs: true,
//  hostBaseUrl:  'https://customertest.videcom.com/LoganAirInHouse/VARS/public',
    iOSAppId: '1457545908',
    androidAppId: 'aero.hisky.reservations',
    fqtvName: 'Club',
    appFeedbackEmail: 'appfeedback@hisky.com',
    groupsBookingsEmail: 'groups@hisky.com',
    pageImageMap: '{"flightSummary": "summary", "paymentPage": "paymentPage", "editPax": "editPax", "paxDetails": "passengers"}',
    wantClassBandImages: true,
    bpShowFastTrack: true,
    bpShowLoungeAccess: true,
    bpShowAddPassToWalletButton: false,
    searchDateOut: 1,
    searchDateBack: 6,
    wantApis: false,
   // wantProducts: true,

    adsTermsUrl: 'https://www.loganair.co.uk/travel-help/ads-terms/',
    passengerTypes: PassengerTypes(
      adults: true,
      child: true,
      infant: true,
      youths: true,
      wantYouthDOB: true,

    ),

//Production setttings

    liveXmlUrl:      "https://booking.hisky.com/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    liveApisUrl:      'https://booking.hisky.com/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    liveApiUrl:      'https://booking.hisky.com/VARS/webApiv2/api/',
    livePayPage:      'https://booking.hisky.com/VARS/Public/MobilePaymentStart.aspx',
    liveSmartApiUrl:  "https://booking.hisky.com/VARS/Public/webservices/VrsApi.asmx/MobileSmartApi",

    liveCreditCardProvider: 'worldpaydirect',

    eVoucher: true,
    xmlUrl:      "https://customertest.videcom.com/hisky/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    apisUrl:      'https://customertest.videcom.com/hisky/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    apiUrl:      'http://10.0.2.2:5000/api',  // InHouse


//    testPayPage: 'http://10.0.2.2:51088/MobilePaymentStart.aspx',
    testPayPage: 'https://customertest.videcom.com/hisky/VARS/Public/MobilePaymentStart.aspx',

//    testXmlUrl:      "http://10.0.2.2:61670/VRSXMLwebService3.asmx/PostVRSCommand?",
//    testXmlUrl:      "http://10.0.2.2:50311/webservices/VrsApi.asmx/PostVRSCommand?",
    testXmlUrl:      "https://customertest.videcom.com/hisky/VARS/Public/WebServices/VrsApi.asmx/PostVRSCommand?",
///////    testXmlUrl:      "https://customertest.videcom.com/FastJet/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    //   testSmartApiUrl:      "http://10.0.2.2:51088/webservices/VrsApi.asmx/MobileSmartApi",
    testSmartApiUrl:      "https://customertest.videcom.com/hisky/VARS/Public/webservices/VrsApi.asmx/MobileSmartApi",
    testApisUrl:      'https://customertest.videcom.com/hisky/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    testApiUrl:      'https://customertest.videcom.com/hisky/VARS/webApiv2/api/',
//    testApiUrl:      'http://10.0.2.2:5000/api',  // local


    creditCardProvider: '3DS_videcard',
    testCreditCardProvider: 'videcard', //'videcard|MX payment,3DS_WorldPay3DS|WorldPay payment',

    displayErrorPnr: true,    // just for test, to display pnr problems
    wantPayStack: false,
    wantPageImages: false,
    wantLeftLogo: false,
    wantCurrencySymbols: true,
    wantMyAccount: true,
    wantFQTV: true,
    wantFindBookings: true,
    wantNewEditPax: true,
    wantMaterialControls: true,
    wantCitySwap: true,
    wantPushNoticications: true,
    wantNotificationEdit: false,
    wantRefund: true,
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


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
    appTitle: 'HiSky',
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
    borderColor: Color.fromRGBO(0X13, 0x3E, 0x68, 1),
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

  gblAppTitle = 'HiSky';
  gblBuildFlavor = 'H4';
  gblCurrentRloc = '';


  gblSettings = Settings (
//    latestBuildiOS: '1.0.5',
//    latestBuildAndroid: '1.0.0.98',
//    homePageStyle: 'V2',
    //pageStyle: 'V2',
    wantRememberMe: false,
    wantHomeFQTVButton: false,
    gblLanguages: 'ro,Romanian,en,English',
    currencies: 'eu,EUR,us,USD,ro,RON,gb,GBP,md,MDL',
    currency: 'MDL',
    wantCurrencyPicker: true,
    wantPassengerPassport: true,
    wantCanFacs: true,

    airlineName: "HiSky",
    gblServerFiles: 'https://booking.hisky.md/VARS/AppFiles/',
    testServerFiles: 'https://customertest.videcom.com/hisky/VARS/AppFiles/',
    xmlToken: "token=tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo%3D",
    xmlTokenPost: "tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo=",
    aircode: 'H4',
    altAircode: 'H7',

    termsAndConditionsUrl: '{"en": "https://hisky.aero/en/terms-and-conditions", "ro": "https://hisky.aero/termeni-si-conditii"}',
    privacyPolicyUrl:  '{"en": "https://hisky.aero/en/data-protection","ro": "https://hisky.aero/protectia-datelor-personale" }',
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
    androidAppId: 'aero.hisky.reservations',
    fqtvName: '',
    appFeedbackEmail: 'appfeedback@hisky.md',
    groupsBookingsEmail: 'groups@hisky.md',
    pageImageMap: '{"flightSummary": "summary", "paymentPage": "paymentPage", "editPax": "editPax", "paxDetails": "passengers"}',
    wantClassBandImages: true,
    bpShowFastTrack: true,
    bpShowLoungeAccess: true,
    bpShowAddPassToWalletButton: false,
    searchDateOut: 1,
    searchDateBack: 6,
    wantApis: true,
    wantMmbProducts: true,
    wantProducts: true,
    wantStatusLine: true,
    wantSeatsWithProducts: true,

    passengerTypes: PassengerTypes(
      adults: true,
      child: true,
      infant: true,
      youths: false,
      wantYouthDOB: true,
      wantAdultDOB: true,

    ),

//Production setttings

    liveXmlUrl:      "https://booking.hisky.md/VARS/Public/WebServices/VrsApi.asmx/PostVRSCommand?",
    //    liveXmlUrl:      "http://10.0.2.2:57793/webservices/VrsApi.asmx/PostVRSCommand?",
    liveApisUrl:      'https://booking.hisky.md/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    liveApiUrl:      'https://booking.hisky.md/VARS/webApiV2/api/',
    //liveApiUrl:      'http://10.0.2.2:5000/api',
    livePayPage:      'https://booking.hisky.md/VARS/Public/MobilePaymentStart.aspx',
    liveSmartApiUrl:  "https://booking.hisky.md/VARS/Public/webservices/VrsApi.asmx/MobileSmartApi",

    liveCreditCardProvider: 'worldpaydirect',

    eVoucher: true,
    xmlUrl:      "https://customertest.videcom.com/hisky/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    apisUrl:      'https://customertest.videcom.com/hisky/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    apiUrl:      'http://10.0.2.2:5000/api',  // InHouse


//    testPayPage: 'http://10.0.2.2:57793/MobilePaymentStart.aspx',
    testPayPage: 'https://customertest.videcom.com/hisky/VARS/Public/MobilePaymentStart.aspx',

//    testXmlUrl:      "http://10.0.2.2:63954/webservices/VrsApi.asmx/PostVRSCommand?",
    testXmlUrl:      "https://customertest.videcom.com/hisky/VARS/Public/WebServices/VrsApi.asmx/PostVRSCommand?",
    //   testSmartApiUrl:      "http://10.0.2.2:51088/webservices/VrsApi.asmx/MobileSmartApi",
    testSmartApiUrl:      "https://customertest.videcom.com/hisky/VARS/Public/webservices/VrsApi.asmx/MobileSmartApi",
    testApisUrl:      'https://customertest.videcom.com/hisky/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    testApiUrl:      'https://customertest.videcom.com/hisky/VARS/webApiv2/api/',
//    testApiUrl:      'http://10.0.2.2:5000/api',  // local


    creditCardProvider: '3DS_videcard',
    testCreditCardProvider: 'videcard', //'videcard|MX payment,3DS_WorldPay3DS|WorldPay payment',

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

    wantFQTVNumber: false,
    apiKey: 'c7137da1854e4e3f9e5d58f6e78616ee',
    maxNumberOfPax: 8,
    hideFareRules: false,

  );
  gblSettings.setDefaults();
}

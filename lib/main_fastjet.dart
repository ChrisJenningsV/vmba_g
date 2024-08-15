
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/data/SystemColors.dart';
import 'package:vmba/data/settings.dart';
import 'package:vmba/data/models/passengerTypesDisplay.dart';
import 'resources/app_config.dart';
import 'main.dart';
import 'data/globals.dart';

void main() {
  configFN();

  var configuredApp = AppConfig(
    appTitle: 'fastjet',
    child: App(),
    buildFlavor: 'FN',
    systemColors: gblSystemColors,
    settings: gblSettings,);
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(configuredApp);
  });
}
void configFN() {
  SystemColors _systemColors = SystemColors(
    progressColor: Colors.yellow,
    primaryButtonColor: Color.fromRGBO(0XFF, 0xC8, 0x32, 1),
    accentButtonColor: Color.fromRGBO(0X48, 0x53, 0x5B, 1),
    accentColor: Colors.grey, // used for calendar selection ends
    primaryColor: Colors.yellow,
    textButtonTextColor: Colors.black54,
    primaryButtonTextColor: Colors.white,
    primaryHeaderColor: Color.fromRGBO(0XFF, 0xC8, 0x32, 1),
    headerTextColor: Color.fromRGBO(0X48, 0x53, 0x5B, 1),
    statusBar: Brightness.dark,
    seatPlanColorEmergency: Colors.red, //Colors.yellow
    seatPlanColorAvailable: Colors.blue, //Colors.green
    seatPlanColorSelected: Colors.blue.shade900, //Colors.grey.shade600
    seatPlanColorUnavailable:      Colors.grey.shade300, //Colors.grey.shade300
    seatPlanColorRestricted: Colors.green[200], //Colors.grey.shade300
    inputFillColor: Colors.white,
  );
  _systemColors.setDefaults();
  gblSystemColors =_systemColors;
  gblTitleStyle =  new TextStyle( color: Colors.white) ;

  gblAppTitle = 'fastjet';
  gblBuildFlavor = 'FN';
  gblCurrentRloc = '';

  gblSettings = Settings (
//    latestBuildiOS: '1.0.5',
//    latestBuildAndroid: '1.0.0.98',
    paySettings: PaySettings(payImageMap: '{"Cellulant": "none", "Directpay3g": "visaMC", "Directpay3gSecondary": "none", "CBZ": "none", "ZPGENERIC": "none"}' ),
    wantRememberMe: false,
    wantApis: true,
//    wantNewDatepicker: true,
    wantHomeFQTVButton: false,
    currencies: 'bw,BWP,gb,GBP,eu,EUR,us,USD,za,ZAR,zw,ZWG',
    currency: 'ZAR',
    wantCurrencyPicker: true,
    wantCentreTitle: true,
    avTimeFormat: 'HH:mm',
    homePageStyle: 'V1',
    pageStyle: 'V1',

    airlineName: "fastjet",
    gblServerFiles: 'https://customer3.videcom.com/FastJet/AppFiles/',
    testServerFiles: 'https://customertest.videcom.com/FastJet/AppFiles/',
    xmlToken: "token=tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo%3D",
    xmlTokenPost: "tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo=",
    aircode: 'FN',
    termsAndConditionsUrl: 'https://fastjet.com/terms-conditions/',
    privacyPolicyUrl:  'https://www.fastjet.com/our-policies/',
    prohibitedItemsNoticeUrl:  'https://www.fastjet.com/flying-with-us/baggage-allowances/',
    faqUrl: '', //'''https://www.fastjet.com/en/footer-contact/faqs',
    contactUsUrl: 'https://fastjet.com/contact-us/',
    //ccUrl: 'https://customertest.videcom.com/loganair/vars/public/MobileStartPage.aspx',

    locale: 'en-EN',
    bookingLeadTime: 60,
    webCheckinNoSeatCharge: true,
    vrsGuid: '6e294c5f-df72-4eff-b8f3-1806b247340c',
    autoSeatOption: false,
    useWebApiforVrs: true,
//  hostBaseUrl:  'https://customertest.videcom.com/LoganAirInHouse/VARS/public',
    iOSAppId: '6443695568',
    androidAppId: 'com.fastjet.reservations',
    fqtvName: 'Club',
    appFeedbackEmail: 'appfeedback@fastjet.com',
    groupsBookingsEmail: 'groups@fastjet.com',
    //pageImageMap: '{"flightSummary": "summary", "paymentPage": "paymentPage", "editPax": "editPax", "paxDetails": "passengers"}',
    wantClassBandImages: false,
    bpShowFastTrack: true,
    bpShowLoungeAccess: true,
    bpShowAddPassToWalletButton: true,
    searchDateOut: 1,
    searchDateBack: 6,

    adsTermsUrl: 'https://www.loganair.co.uk/travel-help/ads-terms/',
    passengerTypes: PassengerTypes(
      adults: true,
      child: true,
      infant: true,
      youths: false,
      wantYouthDOB: false,

    ),

//Production setttings

    liveXmlUrl:      "https://booking.FastJet.com/VARS/Public/WebServices/VrsApi.asmx/PostVRSCommand?",
    liveApisUrl:      'https://booking.FastJet.com/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    liveApiUrl:      'https://booking.FastJet.com/VARS/webApiv2/api/',
    livePayPage:      'https://booking.FastJet.com/VARS/Public/MobilePaymentStart.aspx',
    liveSmartApiUrl:  "https://booking.FastJet.com/VARS/Public/webservices/VrsApi.asmx/MobileSmartApi",

    liveCreditCardProvider: 'worldpaydirect',

    eVoucher: false,
    xmlUrl:      "https://customertest.videcom.com/LoganAirInHouse/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    apisUrl:      'https://customertest.videcom.com/LoganAirInHouse/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    apiUrl:      'http://10.0.2.2:5000/api',  // InHouse

//Staging setttings
/*  testXmlUrl:      "https://10.0.2.2:51088/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
  testApisUrl:      'https://10.0.2.2:51088/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
  testApiUrl:      'https://10.0.2.2:51088/webApiv2/api/',  // InHouse

 */

 //   testPayPage: 'http://10.0.2.2:62559/MobilePaymentStart.aspx',
   testPayPage: 'https://customertest.videcom.com/FastJet/VARS/Public/MobilePaymentStart.aspx',

   // testXmlUrl:      "http://10.0.2.2:57793/webservices/VrsApi.asmx/PostVRSCommand?",
    testXmlUrl:      "https://customertest.videcom.com/FastJet/VARS/Public/WebServices/VrsApi.asmx/PostVRSCommand?",
    //testSmartApiUrl:      "http://10.0.2.2:57793/webservices/VrsApi.asmx/MobileSmartApi",
    testSmartApiUrl:      "https://customertest.videcom.com/FastJet/VARS/Public/webservices/VrsApi.asmx/MobileSmartApi",
    testApisUrl:      'https://customertest.videcom.com/FastJet/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    testApiUrl:      'https://customertest.videcom.com/FastJet/VARS/webApiv2/api/',
//    testApiUrl:      'http://10.0.2.2:5000/api',  // local


    creditCardProvider: '3DS_videcard',
    testCreditCardProvider: 'videcard', //'videcard|MX payment,3DS_WorldPay3DS|WorldPay payment',

    displayErrorPnr: false,    // just for test, to display pnr problems
    wantPageImages: false,
    wantLeftLogo: true,
    wantCurrencySymbols: true,
    wantMyAccount: true,
    wantFQTV: false,
    wantInternatDialCode: true,
    wantFindBookings: true,
    wantNewEditPax: true,
    //wantMaterialControls: true,
    wantCitySwap: true,
    wantPushNoticications: true,
    wantNotificationEdit: false,
    //wantRefund: true,
    wantNewPayment: true,
    wantCountry: false,
    wantMmbProducts: true,
    wantProducts: true,
    productImageMode: 'none',
    wantStatusLine: true,
    wantSeatsWithProducts: true,
    wantEnglishTranslation: true,
    wantBpLogo: false,
    defaultCountryCode: 'ZA',
    canChangeCancelledFlight: false,

    wantFQTVNumber: false,
    apiKey: 'c7137da1854e4e3f9e5d58f6e78616ee',
    maxNumberOfPax: 8,
    hideFareRules: false,

  );
  gblSettings.setDefaults();
}


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/data/SystemColors.dart';
import 'package:vmba/data/settings.dart';
import 'package:vmba/data/models/passengerTypesDisplay.dart';
import 'resources/app_config.dart';
import 'main.dart';
import 'data/globals.dart';

void main() {
  configU5();

  var configuredApp = AppConfig(
    appTitle: 'United Nigeria',
    child: App(),
    buildFlavor: 'U5',
    systemColors: gblSystemColors,
    settings: gblSettings,);
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(configuredApp);
  });
}
void configU5() {
  SystemColors _systemColors = SystemColors(
    progressColor: Color.fromRGBO(0X13, 0x3E, 0x67, 1),
    primaryButtonColor: Colors.black,
    accentButtonColor: Color.fromRGBO(0xF8, 0x99, 0x23, 1),
    classBandIconColor: Color.fromRGBO(0xF8, 0x99, 0x23, 1),
    accentColor: Colors.grey, // used for calendar selection ends
    primaryColor: Colors.yellow,
    textButtonTextColor: Colors.orange,
    primaryButtonTextColor: Colors.white,
    primaryHeaderColor: Color.fromRGBO(0X13, 0x3E, 0x67, 1),
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

  gblAppTitle = 'unitednigeria';
  gblBuildFlavor = 'U5';
  gblCurrentRloc = '';

  gblSettings = Settings (
//    latestBuildiOS: '1.0.5',
//    latestBuildAndroid: '1.0.0.98',
    paySettings: PaySettings(payImageMap: '{"Cellulant": "none", "Directpay3g": "visaMC", "Directpay3gSecondary": "none", "CBZ": "none", "ZPGENERIC": "none"}' ),
    wantRememberMe: false,
    wantApis: false,
//    wantNewDatepicker: true,
    wantHomeFQTVButton: false,
    currencies: 'ng,NGN,us,USD',
    currency: 'NGN',
    wantCurrencyPicker: true,
    wantBuyNowPayLater: true,
    wantCentreTitle: true,
    avTimeFormat: 'HH:mm',
    homePageStyle: 'V1',
    pageStyle: 'V1',

    airlineName: "UnitedNigeria",
    gblServerFiles: 'https://customer3.videcom.com/UnitedNigeria/AppFiles/',
    testServerFiles: 'https://customertest.videcom.com/UnitedNigeria/AppFiles/',
    xmlToken: "token=tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo%3D",
    xmlTokenPost: "tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo=",
    aircode: 'FN',
    termsAndConditionsUrl: 'https://flyUnitedNigeria.com/terms-conditions/',
    privacyPolicyUrl:  'https://www.flyUnitedNigeria.com/our-policies/',
    prohibitedItemsNoticeUrl:  'https://www.flyUnitedNigeria.com/flying-with-us/baggage-allowances/s',
    faqUrl: 'https://flyunitednigeria.com/faq/',
    contactUsUrl: 'https://flyUnitedNigeria.com/contact-us/',
    //ccUrl: 'https://customertest.videcom.com/loganair/vars/public/MobileStartPage.aspx',

    locale: 'en-EN',
    bookingLeadTime: 60,
    webCheckinNoSeatCharge: true,
    vrsGuid: '6e294c5f-df72-4eff-b8f3-1806b247340c',
    autoSeatOption: false,
    useWebApiforVrs: true,
//  hostBaseUrl:  'https://customertest.videcom.com/LoganAirInHouse/VARS/public',
    iOSAppId: '1457545908',
    androidAppId: 'com.UnitedNigeria.reservations',
    fqtvName: 'Club',
    appFeedbackEmail: 'appfeedback@flyunitednigeria.com',
    groupsBookingsEmail: 'groups@flyunitednigeria.com',
    //pageImageMap: '{"flightSummary": "summary", "paymentPage": "paymentPage", "editPax": "editPax", "paxDetails": "passengers"}',
    wantClassBandImages: false,
    bpShowFastTrack: true,
    bpShowLoungeAccess: true,
    bpShowAddPassToWalletButton: true,
    searchDateOut: 1,
    searchDateBack: 6,

    passengerTypes: PassengerTypes(
      adults: true,
      child: true,
      infant: true,
      youths: false,
      wantYouthDOB: false,

    ),

//Production setttings

    liveXmlUrl:      "https://booking.flyunitednigeria.com/VARS/Public/WebServices/VrsApi.asmx/PostVRSCommand?",
    liveApisUrl:      'https://booking.flyunitednigeria.com/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    liveApiUrl:      'https://booking.flyunitednigeria.com/VARS/webApiv2/api/',
    livePayPage:      'https://booking.flyunitednigeria.com/VARS/Public/MobilePaymentStart.aspx',
    liveSmartApiUrl:  "https://booking.flyunitednigeria.com/VARS/Public/webservices/VrsApi.asmx/MobileSmartApi",

    liveCreditCardProvider: 'worldpaydirect',

    eVoucher: false,
    xmlUrl:      "https://customertest.videcom.com/unitednigeria/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    apisUrl:      'https://customertest.videcom.com/unitednigeria/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    apiUrl:      'http://10.0.2.2:5000/api',  // InHouse

    testPayPage: 'https://customertest.videcom.com/unitednigeria/VARS/Public/MobilePaymentStart.aspx',

   // testXmlUrl:      "http://10.0.2.2:57793/webservices/VrsApi.asmx/PostVRSCommand?",
    testXmlUrl:      "https://customertest.videcom.com/unitednigeria/VARS/Public/WebServices/VrsApi.asmx/PostVRSCommand?",
//       testSmartApiUrl:      "http://10.0.2.2:62559/webservices/VrsApi.asmx/MobileSmartApi",
    testSmartApiUrl:      "https://customertest.videcom.com/unitednigeria/VARS/Public/webservices/VrsApi.asmx/MobileSmartApi",
    testApisUrl:      'https://customertest.videcom.com/unitednigeria/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    testApiUrl:      'https://customertest.videcom.com/unitednigeria/VARS/webApiv2/api/',
  // testApiUrl:      'http://10.0.2.2:5000/api',  // local


    creditCardProvider: '3DS_videcard',
    testCreditCardProvider: 'videcard', //'videcard|MX payment,3DS_WorldPay3DS|WorldPay payment',

    displayErrorPnr: false,    // just for test, to display pnr problems
    wantPayStack: false,
    wantPageImages: false,
    wantLeftLogo: false,
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
    wantEnglishTranslation: false,
    wantBpLogo: false,
    defaultCountryCode: 'NG',

    wantFQTVNumber: false,
    apiKey: 'c7137da1854e4e3f9e5d58f6e78616ee',
    maxNumberOfPax: 8,
    hideFareRules: false,

  );
  gblSettings.setDefaults();
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/data/SystemColors.dart';
import 'package:vmba/data/settings.dart';
import 'package:vmba/data/models/passengerTypesDisplay.dart';
import 'resources/app_config.dart';
import 'main.dart';
import 'data/globals.dart';

void main() {
  configGR();

  var configuredApp = AppConfig(
    appTitle: 'aurigny',
    child: App(),
    buildFlavor: 'GR',
    systemColors: gblSystemColors,
    settings: gblSettings,);
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(configuredApp);
  });
}
void configGR() {
  SystemColors _systemColors = SystemColors(
    primaryButtonColor: Colors.black,
    accentButtonColor: Colors.black,
    accentColor: Colors.grey, // used for calendar selection ends
    primaryColor: Colors.yellow,
    textButtonTextColor: Colors.black54,
    primaryButtonTextColor: Colors.white,
    primaryHeaderColor: Color.fromRGBO(0XFF, 0xD3, 0x02, 1),
    headerTextColor: Color.fromRGBO(0X0C, 0x3B, 0x62, 1),
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

  gblAppTitle = 'aurigny';
  gblBuildFlavor = 'GR';
  gblCurrentRloc = '';

  gblSettings = Settings (
//    latestBuildiOS: '1.0.5',
//    latestBuildAndroid: '1.0.0.98',
    wantRememberMe: false,
    wantApis: true,
    wantHomeFQTVButton: false,
    wantDangerousGoods: false,

    airlineName: "Aurigny",
    gblServerFiles: 'https://customer3.videcom.com/aurignyairservices/AppFiles/',
    testServerFiles: 'https://customertest.videcom.com/aurignyairservices/AppFiles/',
    xmlToken: "token=tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo%3D",
    xmlTokenPost: "tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo=",
    aircode: 'GR',
    termsAndConditionsUrl: 'https://www.aurigny.com/legal?headless=1',
    privacyPolicyUrl:  'https://www.aurigny.com/legal?headless=1',
    prohibitedItemsNoticeUrl:  'https://www.aurigny.com/faqs?headless=1#prohibited_articles',
    faqUrl: 'https://www.aurigny.com/faqs?headless=1',
    contactUsUrl:	'https://www.aurigny.com/contact?headless=1',

    locale: 'en-EN',
    bookingLeadTime: 60,
    webCheckinNoSeatCharge: false,
    vrsGuid: '6e294c5f-df72-4eff-b8f3-1806b247340c',
    autoSeatOption: false,
    useWebApiforVrs: true,
    iOSAppId: '1457545908',
    androidAppId: 'com.aurigny.reservations',
    fqtvName: 'Frequent Flyer',
    appFeedbackEmail: 'appfeedback@aurigny.com',
    groupsBookingsEmail: 'groups@aurigny.com',
    pageImageMap: '{"flightSummary": "flight summary", "paymentPage": "payment Page", "editPax": "edit Pax", "paxDetails": "passenger details"}',
    wantClassBandImages: false,
    bpShowFastTrack: true,
    bpShowLoungeAccess: true,
    bpShowAddPassToWalletButton: true,
    searchDateOut: 1,
    searchDateBack: 6,
    wantProducts: true,
    wantMmbProducts: true,
    productImageMode: 'none',
    wantSeatsWithProducts: true,

    //adsTermsUrl: 'https://www.aurigny.com/travel-help/ads-terms/',
    passengerTypes: PassengerTypes(
      adults: true,
      child: true,
      infant: true,
      youths: true,
      wantYouthDOB: true,

    ),

//Production setttings

    liveXmlUrl:      "https://booking.aurigny.com/VARS/Public/WebServices/VrsApi.asmx/PostVRSCommand?",
    liveApisUrl:      'https://booking.aurigny.com/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    liveApiUrl:      'https://booking.aurigny.com/VARS/webApiv2/api/',
    livePayPage:      'https://booking.aurigny.com/VARS/Public/MobilePaymentStart.aspx',
    liveSmartApiUrl:  "https://booking.aurigny.com/VARS/Public/webservices/VrsApi.asmx/MobileSmartApi",

    liveCreditCardProvider: 'worldpaydirect',

    eVoucher: true,
    xmlUrl:      "https://customertest.videcom.com/aurigny/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    apisUrl:      'https://customertest.videcom.com/aurigny/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    apiUrl:      'http://10.0.2.2:5000/api',  // InHouse

//Staging setttings
/*  testXmlUrl:      "https://10.0.2.2:51088/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
  testApisUrl:      'https://10.0.2.2:51088/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
  testApiUrl:      'https://10.0.2.2:51088/webApiv2/api/',  // InHouse

 */

//    testPayPage: 'http://10.0.2.2:51088/MobilePaymentStart.aspx',
    testPayPage: 'https://customertest.videcom.com/aurignyairservices/VARS/Public/MobilePaymentStart.aspx',

//    testXmlUrl:      "http://10.0.2.2:50311/webservices/VrsApi.asmx/PostVRSCommand?",
    testXmlUrl:      "https://customertest.videcom.com/aurignyairservices/VARS/Public/WebServices/VrsApi.asmx/PostVRSCommand?",
    testSmartApiUrl:      "https://customertest.videcom.com/aurignyairservices/VARS/Public/webservices/VrsApi.asmx/MobileSmartApi",
    testApisUrl:      'https://customertest.videcom.com/aurignyairservices/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    testApiUrl:      'https://customertest.videcom.com/aurignyairservices/VARS/webApiv2/api/',
//   testApiUrl:      'http://10.0.2.2:5000/api',  // local


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
    wantCitySwap: true,
    wantPushNoticications: true,
    wantNotificationEdit: false,
    wantRefund: false,
    wantNewPayment: true,
    wantCountry: false,

    wantFQTVNumber: true,
    apiKey: 'c7137da1854e4e3f9e5d58f6e78616ee',
    maxNumberOfPax: 8,
    hideFareRules: false,

  );
  gblSettings.setDefaults();
}

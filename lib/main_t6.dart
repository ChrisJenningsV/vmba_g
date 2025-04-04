
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
      seatPlanColorAvailable: Color.fromRGBO(0, 0x9A, 0xCE, 1), //Colors.green
      seatPlanColorSelected: Color.fromRGBO(0, 0x67, 0xA0, 1), //Colors.grey.shade600
      seatPlanColorUnavailable:      Colors.grey.shade300, //Colors.grey.shade300
      seatPlanColorRestricted: Color.fromRGBO(0x80, 0x80, 0x80, 1),
      seatPlanBackColor: Colors.grey.shade300, //Colors.grey.shade300
      seatPriceColor: Color.fromRGBO(0x1C, 0x37, 0x5F, 1),
      seatSelectButtonColor: Color.fromRGBO(0x1C, 0x37, 0x5F, 1),
      seatSelectTextColor: Colors.white,

      primaryButtonColor: Color.fromRGBO(83, 40, 99, 1),
      accentButtonColor: Color.fromRGBO(83, 40, 99, 1),
         // Color.fromRGBO(73, 201, 245, 1), 
      accentColor: Color.fromRGBO(83, 40, 99, 1),//Color.fromRGBO( 241, 182, 0, 1), //Color.fromRGBO(0, 83, 55, 1), //Colors.white,
      primaryColor: Colors.white,
      primaryButtonTextColor: Colors.white,
      primaryHeaderColor: Colors.white,//Color.fromRGBO(12, 59, 111, 1),
      headerTextColor: Colors.black,
      progressTextColor: Colors.grey,
      inputFillColor: Colors.white,
      tabUnderlineColor: Color.fromRGBO(52, 23, 73, 1),
      statusBar: Brightness.light);

  _systemColors.setDefaults();
  gblSystemColors =_systemColors;
  gblTitleStyle =  new TextStyle( color: Colors.grey.shade400) ;
  gblAppTitle = 'airswift';
  gblBuildFlavor = 'T6';
  gblTitles = <String>['Mr','Mrs','Ms','Miss','Mstr','Dr'  ];
  gblRememberMe = true;

  gblSettings = Settings (
/*  new features settings */
    homePageStyle: 'V3',
    inputStyle: 'V2',
    seatStyle:'line',
    seatPriceStyle:'round',
    smartApiVersion: 2,
    wantShadows: false,
    wantTransapentHomebar: true,
    wantVericalFaresCalendar: true,
    wantCustomHomepage:false,
    wantPriceCalendar: true ,
    wantIconsOnPriceCalendar: true,
    wantNewMMB: true,
    wantNewSeats: true,
    wantSeatPlanImages: false,
    wantUpgradePrices: true,
    wantButtonIcons: false,
    wantPriceCalendarRounding: false,
    wantUnlock:false,
    wantEnglishTranslation: true,
    //wantProducts: true,
    wantStatusLine: true,
    wantNews: false,
    wantFopVouchers: false,
    wantLocation: false,
//    wantDarkSite: true,
    wantAdminLogin: true,
    wantGeoLocationHopePage: false,
    wantNewDialogs: true,
    wantNewPaxDialogs: true,
    wantCustomAnimations: false,
    wantHomepageButtons: false,

    wantSeatsWithProducts: false,
    useLogin2: true,
    homePageMessage: '',
    bottomNavPages: 'HOME,FLIGHTSEARCH',
    imageBackgroundPages: 'HOME,FLIGHTSEARCH,FLIGHTSTATUS,DATEPICKER,FQTVLOGIN,FQTVRESET',


    wantNewCalendar: true,
    wantCalendarBigMonth: true,


// end new features

      latestBuildiOS: '105',
      latestBuildAndroid: '108',
    wantHomeFQTVButton: false,
    wantFQTV:  false,
    wantMyAccount: true,

    airlineName: "AirSWIFT",
      xmlToken: "token=tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo%3D",
      xmlTokenPost: "tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo=",
    gblServerFiles: 'https://booking.air-swift.com/AppFiles',
    testServerFiles: 'https://customertest.videcom.com/airswift/AppFiles',
    faqUrl: 'https://air-swift.com/faqs/ ',
    contactUsUrl: 'https://air-swift.com/contact-us-mobile/ ',
    //contactUsUrl: 'https://www.easyjet.com/en/flight-tracker/EZY308 ',
    termsAndConditionsUrl: 'https://air-swift.com/full-terms-conditions/',
    privacyPolicyUrl:  'https://air-swift.com/privacy-policy/',
    prohibitedItemsNoticeUrl:  'https://air-swift.com/restricted-items/',
    //customMenu1: 'SWIFT Rewards Registration , SWIFT Rewards Registration ,https://booking.air-swift.com/vars/Public/FQTV/FqtvRegisterBS.aspx',

    aircode: 'T6',
      currency: 'PHP',
      currencyDecimalPlaces: 0,
      locale: 'en-EN',
      bookingLeadTime: 60,
      webCheckinNoSeatCharge: false,
      vrsGuid: '6e294c5f-df72-4eff-b8f3-1806b247340c',
      autoSeatOption: true,
 //     hostBaseUrl:  'https://customertest.videcom.com/airswift/VARS/public',
      iOSAppId: '1571286915', // CHECk THIS
      androidAppId: 'com.airswift.reservations',
      fqtvName: 'SWIFT Rewards ',
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
    wantApis: false,
    wantTallPageImage: true,
    //pageStyle: 'V2',
    pageImageMap: '{"flightSummary": "summary", "paymentPage": "paymentPage", "editPax": "editPax", "options": "editPax", "paxDetails": "passengers", "FQTV": "FQTV login"}',
    //useWebApiforVrs: true,
    progressFactor: -25, //-30,
    blockedUrls: '',


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
      seniorMinAge: 70,
  ),

//Production settings
  liveXmlUrl:      "https://booking.air-swift.com/VARS/Public/WebServices/VrsApi.asmx/PostVRSCommand?",
  liveApisUrl:      'https://booking.air-swift.com/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
  liveApiUrl: 'https://booking.air-swift.com/VARS/webApiv2/api/',
  //  liveApiUrl:      'http://10.0.2.2:5000/api',
    livePayPage: 'https://booking.air-swift.com/VARS/Public/MobilePaymentStart.aspx',
    liveSmartApiUrl:  "https://booking.air-swift.com/VARS/Public/webservices/VrsApi.asmx/MobileSmartApi",
  liveCreditCardProvider: 'worldpaydirect',

  eVoucher: true,

//Staging settings
  xmlUrl:      "https://customertest.videcom.com/airswift/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
  apisUrl:      'https://customertest.videcom.com/airswift/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
  apiUrl:      'https://customertest.videcom.com/airswift/VARS/webApiv2/api/',  // InHouse
  creditCardProvider: 'videcard',

    testPayPage: 'https://customertest.videcom.com/airswift/VARS/Public/MobilePaymentStart.aspx',
    //testPayPage: 'http://10.0.2.2:50311/MobilePaymentStart.aspx',
 // testXmlUrl:      "https://customertest.videcom.com/airswift/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    testXmlUrl:      "https://customertest.videcom.com/airswift/VARS/Public/WebServices/VrsApi.asmx/PostVRSCommand?",
//    testXmlUrl:      "http://10.0.2.2:57793/webservices/VrsApi.asmx/PostVRSCommand?",
  testApisUrl:      'https://customertest.videcom.com/airswift/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
  testApiUrl:      'https://customertest.videcom.com/airswift/VARS/webApiv2/api/',  // InHouse
  //  testApiUrl:      'http://10.0.2.2:5000/api',
  testSmartApiUrl:      "https://customertest.videcom.com/airswift/VARS/Public/webservices/VrsApi.asmx/MobileSmartApi",
  //  testSmartApiUrl:      "http://10.0.2.2:57793/webservices/VrsApi.asmx/MobileSmartApi",
//    testCreditCardProvider: 'videcard' , //MX payment,3DS_Paynamics|Paynamics payment',
    //payStartUrl: 'http://10.0.2.2:51088/MobilePaymentStart.aspx',

    wantPushNoticications: true,
    wantNotificationEdit: false,
    wantNewPayment: true,
    useScrollWebViewiOS: true,
    wantMmbProducts: true,
    productImageMode: 'index',
    wantFqtvAutologin: false,
    wantFqtvHomepage: false ,
    wantFqtvRegister: true,


    wantLeftLogo: false,
  apiKey: '26d5a5deaf774724bb5d315dbb8bfee2',
  maxNumberOfPax: 9,
    maxNumberOfInfants: 4,
  hideFareRules: false,
    searchDateOut: 1,
    searchDateBack: 6,
  );
  gblSettings.setDefaults();
}

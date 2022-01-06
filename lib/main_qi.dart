import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/data/SystemColors.dart';
import 'package:vmba/data/settings.dart';
import 'package:vmba/data/models/passengerTypesDisplay.dart';
import 'resources/app_config.dart';
import 'main.dart';
import 'data/globals.dart';

void main() {
  configQI();


  var configuredApp = AppConfig(
    appTitle: 'ibomair',
    child: App(),
    buildFlavor: 'QI',
    systemColors: gblSystemColors,
    settings: gblSettings,);
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(configuredApp);
  });
}

void configQI() {
  SystemColors _systemColors = SystemColors(
      primaryButtonColor: Color.fromRGBO(0, 83, 55, 1),
      accentButtonColor:
      Color.fromRGBO(243, 135, 57, 1),
      //Color.fromRGBO(243, 135, 57, 1),
      accentColor: Color.fromRGBO(0, 83, 55, 1),
      //Colors.white,
      primaryColor: Colors.white,
      primaryButtonTextColor: Colors.white,
      textButtonTextColor: Colors.black54,
      primaryHeaderColor: Color.fromRGBO(0x1C, 0x37, 0x48, 1),
      // orange Color.fromRGBO(0xF0, 0x81,0,1),
      headerTextColor: Colors.white,
      statusBar: Brightness.light,
    seatPlanColorEmergency: Colors.red, //Colors.yellow
    seatPlanColorAvailable: Colors.blue, //Colors.green
    seatPlanColorSelected: Colors.blue.shade900, //Colors.grey.shade600
    seatPlanColorUnavailable:      Colors.grey.shade300, //Colors.grey.shade300
    seatPlanColorRestricted: Colors.green[200],
  );
  _systemColors.setDefaults();
  gblSystemColors = _systemColors;
  gblTitleStyle = new TextStyle(color: Colors.white);


  gblAppTitle = 'ibomair';
  gblBuildFlavor = 'QI';
  //gbl_language = 'en';

  gblSettings = Settings(
    latestBuildiOS: '105',
    latestBuildAndroid: '15',
    wantRememberMe: false,
    wantMyAccount: true,
    wantHomeFQTVButton: true,
    airlineName: "IBOM Air",
    xmlToken: "token=jgxD8XX48HgiBqGbkqmR2qmq6WzfWaQCi59Aa3s1StA%3D",
    xmlTokenPost: "tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo=",
    aircode: "QI",

    termsAndConditionsUrl: "",
    privacyPolicyUrl: "",
    faqUrl: "",
    contactUsUrl: "https://www.ibomair.com/contact-us/",
    locale: 'en-EN',
    bookingLeadTime: 60,
    webCheckinNoSeatCharge: false,
    vrsGuid: '6e294c5f-df72-4eff-b8f3-1806b247340c',
    autoSeatOption: true,
    backgroundImageUrl: "",
 //   hostBaseUrl: 'https://customertest.videcom.com/ibomair/VARS/public',
    iOSAppId: '1457545908',
    androidAppId: 'com.ibomair',

    eVoucher: false,
    passengerTypes: PassengerTypes(
      adults: true,
      child: true,
      infant: true,
      youths: true,
    ),
    fqtvName: "",
    appFeedbackEmail: "",
    prohibitedItemsNoticeUrl: null,
    groupsBookingsEmail: "",
    maxNumberOfPax: 8,
    hideFareRules: true,
    liveXmlUrl:      "https://booking.ibom.com/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    liveApisUrl:       'https://booking.ibom.com/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    liveApiUrl: 'https://booking.ibom.com/ANCwebApi/api/',
    livePayPage:      'https://booking.ibom.com/VARS/Public/MobilePaymentStart.aspx',
    liveCreditCardProvider: 'worldpaydirect',

    apiKey: "2edd1519899a4e7fbf9a307a0db4c17a" ,//'a4768447e0ae4e4688b6783377bed3b6',
//Staging setttings
    testPayPage: 'https://customertest.videcom.com/ibomair/VARS/Public/MobilePaymentStart.aspx',
    testXmlUrl: "https://customertest.videcom.com/ibomair/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    testApisUrl: 'https://customertest.videcom.com/ibomair/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    testApiUrl: 'https://customertest.videcom.com/ibomair/VARS/webApiV2/api/',
//    testApiUrl:      'http://10.0.2.2:5000/api',  // local

    testCreditCardProvider: 'videcard',

    xmlUrl: "https://customertest.videcom.com/ibomair/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    apisUrl: 'https://customertest.videcom.com/ibomair/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    apiUrl: 'https://customertest.videcom.com/ibomair/VARS/webApiV2/api/',
    creditCardProvider: 'videcard',

    wantNewPayment: true,
    wantNewEditPax: true,
    wantMaterialControls: true,
    wantPayStack: false,
    wantLeftLogo: false,
    bpShowFastTrack: true,
    bpShowLoungeAccess: true,
  	bpShowAddPassToWalletButton: false,
    searchDateOut: 1,
    searchDateBack: 6,


  );
  gblSettings.setDefaults();
}


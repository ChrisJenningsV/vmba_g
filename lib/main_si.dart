
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/data/SystemColors.dart';
import 'package:vmba/data/settings.dart';
import 'package:vmba/data/models/passengerTypesDisplay.dart';
import 'resources/app_config.dart';
import 'main.dart';
import 'data/globals.dart';

void main() {
  configSI();

  var configuredApp = AppConfig(
    appTitle: 'blueislands',
    child: App(),
    buildFlavor: 'SI',
    systemColors: gblSystemColors,
    settings: gblSettings,
  );
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(configuredApp);
  });
}

void configSI() {

  SystemColors _systemColors = SystemColors(
    primaryButtonColor: Color.fromRGBO(12, 59, 111, 1),
    otherButtonColor: Color.fromRGBO(229, 0, 91, 1),

    accentButtonColor: Color.fromRGBO(241, 182, 0, 1),
    accentColor: Colors.grey, // used for calendar selection ends
    primaryHeaderColor: Color.fromRGBO(12, 59, 111, 1),

    primaryColor: Colors.white,// colour for datepicker header - also it changes menu icon color !!
    textButtonTextColor: Colors.black54,
    primaryButtonTextColor: Colors.white,
    //   primaryHeaderColor: Colors.red,
    headerTextColor: Colors.white,
    statusBar: Brightness.dark,
  );

  _systemColors.setDefaults();
  gblSystemColors =_systemColors;
  gblTitleStyle =  new TextStyle( color: Colors.white) ;
  gblCentreTitle = true;

  gblAppTitle = 'blueislands';
  gblBuildFlavor = 'SI';

  gblSettings = Settings(
      wantLeftLogo:  true,
    //useWebApiforVrs: true,
    wantRememberMe: false,
    wantApis: true,
    wantHomeFQTVButton: true,
      latestBuildiOS: '105',
      latestBuildAndroid: '105',
      airlineName: "Blue Islands",
      xmlToken: "token=tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo%3D",
      xmlTokenPost: "tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo=",
      aircode:  "SI",
      termsAndConditionsUrl:  "https://www.blueislands.com/terms-and-conditions/",
      buttonStyle: 'OFFSET',

      privacyPolicyUrl:  "https://www.blueislands.com/privacy-policy/",
      faqUrl: "",
      contactUsUrl: "",
      locale:  'en-EN',
      bookingLeadTime:  60,
      webCheckinNoSeatCharge:  false,
      vrsGuid:  '6e294c5f-df72-4eff-b8f3-1806b247340c',
      autoSeatOption:  true,
      backgroundImageUrl:  "",
 //     hostBaseUrl: 'https://customertest.videcom.com/BlueIslands/VARS/public',
      iOSAppId:  '1521495071',
      androidAppId:  'com.blueislands',

      eVoucher:  false,
      passengerTypes:  PassengerTypes(
      adults: true,
      child: true,
      infant: true,
      youths: true,
      wantYouthDOB: true,
  ),
  fqtvName:  "Blue Skies",
  appFeedbackEmail:  "webmaster@blueislands.com",
  prohibitedItemsNoticeUrl: '',
  groupsBookingsEmail:  "groups@blueislands.com",
  maxNumberOfPax:  8,
  hideFareRules:  false,
    wantInternatDialCode: true,
    wantFQTV:  true,
    wantNewEditPax: true,
    wantAllColorButtons: false,
    wantBpLogo: false,
    saveChangeBookingBeforePay: false,
    //wantMaterialControls: true,
    wantCitySwap: true,
    wantPageImages: false,
    gblServerFiles: 'https://booking.blueislands.com/AppFiles',
    testServerFiles: 'https://customertest.videcom.com/blueislands/AppFiles',
    pageImageMap: '{"flightSummary": "happystaff", "paymentPage": "paymentPage", "editPax": "editPax", "paxDetails": "happypax"}',
    wantClassBandImages: false,
    defaultCountryCode: 'GB',


 // liveXmlUrl:      "https://booking.blueislands.com/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    liveXmlUrl:      "https://booking.blueislands.com/VARS/Public/WebServices/VrsApi.asmx/PostVRSCommand?",
  //liveXmlUrl:      "http://10.0.2.2:63954/webservices/VrsApi.asmx/PostVRSCommand?",
  liveApisUrl:       'https://booking.blueislands.com/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
  liveApiUrl: 'https://booking.blueislands.com/VARS/webApiV2/api/',
  livePayPage:      'https://booking.blueislands.com/VARS/Public/MobilePaymentStart.aspx',
  liveSmartApiUrl:  "https://booking.blueislands.com/VARS/Public/webservices/VrsApi.asmx/MobileSmartApi",
    //liveSmartApiUrl:  "https://booking.blueislands.com/VARS/Public/webservices/VrsApi.asmx/MobileSmartApi",
    liveCreditCardProvider: 'citypaydirect',

  apiKey: '4d332cf7134f4a43958d954278474b41', // '2edd1519899a4e7fbf9a307a0db4c17a',
//Staging settings
  xmlUrl:      "https://customertest.videcom.com/blueislands/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
  apisUrl:      'https://customertest.videcom.com/blueislands/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
  apiUrl:      'https://customertest.videcom.com/blueislands/VARS/webApiV2/api/',
  creditCardProvider: 'videcard', // citypaydirect

    // for local debugging \VARS\Config\applicationhost.config needs (in <site name="VARS Public(7)" id="23">)
    //<binding protocol="http" bindingInformation="*:63954:localhost" />
    // 					<binding protocol="http" bindingInformation="*:63954:127.0.0.1" />

    testXmlUrl:      "https://customertest.videcom.com/blueislands/VARS/Public/WebServices/VrsApi.asmx/PostVRSCommand?",
 //   testXmlUrl:      "http://10.0.2.2:57793/webservices/VrsApi.asmx/PostVRSCommand?",
  testSmartApiUrl:  "https://customertest.videcom.com/blueislands/VARS/Public/webservices/VrsApi.asmx/MobileSmartApi",
//    testSmartApiUrl:  "http://10.0.2.2:57793/webservices/VrsApi.asmx/MobileSmartApi",
  testApisUrl:      'https://customertest.videcom.com/blueislands/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',

  testApiUrl:      'https://customertest.videcom.com/blueislands/VARS/webApiV2/api/',
//  testPayPage: 'http://10.0.2.2:57793/MobilePaymentStart.aspx',
    testPayPage: 'https://customertest.videcom.com/blueislands/VARS/Public/MobilePaymentStart.aspx',
//    testApiUrl:      'http://10.0.2.2:5000/api',
  testCreditCardProvider: 'videcard', // citypaydirect

    wantNewPayment: true,
  bpShowFastTrack: false,
  bpShowLoungeAccess: false,
  wantPushNoticications: true,
  wantNotificationEdit: false,
  bpShowAddPassToWalletButton: false,
  wantMyAccount: true,
    searchDateOut: 1,
    searchDateBack: 6,

  );
  gblSettings.setDefaults();
}
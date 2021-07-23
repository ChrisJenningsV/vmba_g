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
  /*
  SystemColors _systemColors = SystemColors(
      primaryButtonColor: Color.fromRGBO(12, 59, 111, 1),
      accentButtonColor: Color.fromRGBO(241, 182, 0, 1),
      accentColor: Color.fromRGBO(
          241, 182, 0, 1), //Color.fromRGBO(0, 83, 55, 1), //Colors.white,
      primaryColor: Colors.white,
      primaryButtonTextColor: Colors.white,
      textButtonTextColor: Colors.black54  ,
      primaryHeaderColor: Color.fromRGBO(12, 59, 111, 1),
      headerTextColor: Colors.white,
      statusBar: Brightness.dark,
    seatPlanColorEmergency: Colors.red, //Colors.yellow
    seatPlanColorAvailable: Colors.blue, //Colors.green
    seatPlanColorSelected: Colors.blue.shade900, //Colors.grey.shade600
    seatPlanColorUnavailable:      Colors.grey.shade300, //Colors.grey.shade300
    seatPlanColorRestricted: Colors.green[200],
  );

   */
  SystemColors _systemColors = SystemColors(
    primaryButtonColor: Color.fromRGBO(12, 59, 111, 1),
    otherButtonColor: Color.fromRGBO(229, 0, 91, 1),

    accentButtonColor: Color.fromRGBO(241, 182, 0, 1),
    accentColor: Colors.black,
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
    wantRememberMe: false,
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
  ),
  fqtvName:  "",
  appFeedbackEmail:  "webmaster@blueislands.com",
  prohibitedItemsNoticeUrl: null,
  groupsBookingsEmail:  "groups@blueislands.com",
  maxNumberOfPax:  8,
  hideFareRules:  true,
  fqtvEnabled:  false,

  liveXmlUrl:      "https://booking.blueislands.com/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
  liveApisUrl:       'https://booking.blueislands.com/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
  liveApiUrl: 'https://booking.blueislands.com/VARS/webApiV2/api/',
  liveCreditCardProvider: 'citypaydirect',

  apiKey: '4d332cf7134f4a43958d954278474b41', // '2edd1519899a4e7fbf9a307a0db4c17a',
//Staging setttings
  xmlUrl:      "https://customertest.videcom.com/blueislands/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
  apisUrl:      'https://customertest.videcom.com/blueislands/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
  apiUrl:      'https://customertest.videcom.com/blueislands/VARS/webApiV2/api/',
  creditCardProvider: 'videcard', // citypaydirect

  testXmlUrl:      "https://customertest.videcom.com/blueislands/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
  testApisUrl:      'https://customertest.videcom.com/blueislands/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
  testApiUrl:      'https://customertest.videcom.com/blueislands/VARS/webApiV2/api/',
  testCreditCardProvider: 'videcard', // citypaydirect

  wantPayStack: false,
  bpShowFastTrack: false,
  bpShowLoungeAccess: false,
  wantMyAccount: true,
    searchDateOut: 1,
    searchDateBack: 6,

  );
  gblSettings.setDefaults();
}
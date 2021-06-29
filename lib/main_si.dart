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
      accentButtonColor:
      Color.fromRGBO(241, 182, 0, 1), //Color.fromRGBO(243, 135, 57, 1),
      accentColor: Color.fromRGBO(
          241, 182, 0, 1), //Color.fromRGBO(0, 83, 55, 1), //Colors.white,
      primaryColor: Colors.white,
      primaryButtonTextColor: Colors.white,
      textButtonTextColor: Colors.black54  ,
      primaryHeaderColor: Color.fromRGBO(12, 59, 111, 1),
      headerTextColor: Colors.white,
      statusBar: Brightness.dark);

  gblSystemColors =_systemColors;
  gblTitleStyle =  new TextStyle( color: Colors.white) ;


  gblAppTitle = 'blueislands';
  gblBuildFlavor = 'SI';

  gblSettings = Settings(
      wantLeftLogo:  true,
      latestBuildiOS: '1.0.8.15',
      latestBuildAndroid: '1.0.8.15',
      airlineName: "Blue Islands",
      xmlToken: "token=tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo%3D",
      xmlTokenPost: "tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo=",
      aircode:  "SI",
      termsAndConditionsUrl:  "https://www.blueislands.com/terms-and-conditions/",

      privacyPolicyUrl:  "https://www.blueislands.com/privacy-policy/",
      faqUrl: "",
      contactUsUrl: "",
      locale:  'en-EN',
      bookingLeadTime:  60,
      webCheckinNoSeatCharge:  false,
      vrsGuid:  '6e294c5f-df72-4eff-b8f3-1806b247340c',
      autoSeatOption:  true,
      backgroundImageUrl:  "",
      hostBaseUrl: 'https://customertest.videcom.com/BlueIslands/VARS/public',
      iOSAppId:  '1521495071',
      androidAppId:  'com.blueislands.reservations',

      eVoucher:  false,
      passengerTypes:  PassengerTypes(
      adult: true,
      child: true,
      infant: true,
      youth: true,
  ),
  fqtvName:  "",
  appFeedbackEmail:  "webmaster@blueislands.com",
  prohibitedItemsNoticeUrl: null,
  groupsBookingsEmail:  "groups@blueislands.com",
  maxNumberOfPax:  8,
  hideFareRules:  true,
  fqtvEnabled:  false,
//      xmlUrl:      "https://booking.loganair.co.uk/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
//      apisUrl:       'https://booking.loganair.co.uk/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
//      apiUrl: 'https://booking.loganair.co.uk/ANCwebApi/api/',
//      creditCardProviderProduction: 'worldpaydirect',

  apiKey: '4d332cf7134f4a43958d954278474b41', // '2edd1519899a4e7fbf9a307a0db4c17a',
//Staging setttings
  xmlUrl:      "https://customertest.videcom.com/blueislands/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
  apisUrl:      'https://customertest.videcom.com/blueislands/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
  apiUrl:      'https://customertest.videcom.com/blueislands/VARS/webApiV2/api/',
  creditCardProvider: 'videcard', // citypaydirect
  wantPayStack: false,
  bpShowFastTrack: false,
  bpShowLoungeAccess: false,
  wantMyAccount: true,
    searchDateOut: 1,
    searchDateBack: 6,

  );
}
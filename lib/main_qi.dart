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
      statusBar: Brightness.light);

  gblSystemColors = _systemColors;
  gblTitleStyle = new TextStyle(color: Colors.white);


  gblAppTitle = 'ibomair';
  gblBuildFlavor = 'QI';
  //gbl_language = 'en';

  gblSettings = Settings(
    latestBuildiOS: '1.0.8.15',
    latestBuildAndroid: '1.0.8.15',
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
    hostBaseUrl: 'https://customertest.videcom.com/ibomair/VARS/public',
    iOSAppId: '1457545908',
    androidAppId: 'se.ibomair.reservations',

    eVoucher: false,
    passengerTypes: PassengerTypes(
      adult: true,
      child: true,
      infant: true,
      youth: true,
    ),
    fqtvName: "",
    appFeedbackEmail: "",
    prohibitedItemsNoticeUrl: null,
    groupsBookingsEmail: "",
    maxNumberOfPax: 8,
    hideFareRules: true,
    fqtvEnabled: false,
//      xmlUrl:      "https://booking.loganair.co.uk/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
//      apisUrl:       'https://booking.loganair.co.uk/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
//      apiUrl: 'https://booking.loganair.co.uk/ANCwebApi/api/',
//      creditCardProviderProduction: 'worldpaydirect',

    apiKey: '2edd1519899a4e7fbf9a307a0db4c17a',
//Staging setttings
    xmlUrl: "https://customertest.videcom.com/ibomair/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    apisUrl: 'https://customertest.videcom.com/ibomair/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    apiUrl: 'https://customertest.videcom.com/ibomair/VARS/webApi/api/',
    creditCardProvider: 'videcard',
    wantPayStack: false,
    wantLeftLogo: false,
    bpShowFastTrack: true,
    bpShowLoungeAccess: true,

  );
}

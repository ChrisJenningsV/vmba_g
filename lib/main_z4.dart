import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/data/SystemColors.dart';
import 'package:vmba/data/settings.dart';
import 'package:vmba/data/models/passengerTypesDisplay.dart';
import 'resources/app_config.dart';
import 'main.dart';
import 'data/globals.dart';

void main() {
  configZ4();


  var configuredApp = AppConfig(
    appTitle: 'ibomair',
    child: App(),
    buildFlavor: 'Z4',
    systemColors: gblSystemColors,
    settings: gblSettings,);
  return runApp(configuredApp);
}
void configZ4() {
  SystemColors _systemColors = SystemColors(
      primaryButtonColor: Color.fromRGBO(0, 83, 55, 1),
      accentButtonColor:
      Color.fromRGBO(243, 135, 57, 1), //Color.fromRGBO(243, 135, 57, 1),
      accentColor: Color.fromRGBO(0, 83, 55, 1), //Colors.white,
      primaryColor: Colors.white,
      primaryButtonTextColor: Colors.white,
      statusBar: Brightness.light,

    textButtonTextColor: Colors.black54,
    primaryHeaderColor: Colors.red,
    headerTextColor: Colors.white,
    seatPlanColorEmergency: Colors.red, //Colors.yellow
    seatPlanColorAvailable: Colors.blue, //Colors.green
    seatPlanColorSelected: Colors.blue.shade900, //Colors.grey.shade600
    seatPlanColorUnavailable:      Colors.grey.shade300, //Colors.grey.shade300
    seatPlanColorRestricted: Colors.green[200], //Colors.grey.shade300


  );

  gblSystemColors =_systemColors;
  gblAppTitle = 'ibomair';
  gblBuildFlavor = 'Z4';

  gblSettings = Settings (
      latestBuildiOS: '1.0.5',
      latestBuildAndroid: '1.0.0.98',
      airlineName: "Ibom Air",
      xmlToken: "token=jgxD8XX48HgiBqGbkqmR2qmq6WzfWaQCi59Aa3s1StA%3D",
      xmlTokenPost: "jgxD8XX48HgiBqGbkqmR2qmq6WzfWaQCi59Aa3s1StA=",
      aircode: 'Z4',
      termsAndConditionsUrl: '',
      privacyPolicyUrl:  '',
      prohibitedItemsNoticeUrl:  '',
      locale: 'en-EN',
      bookingLeadTime: 60,
      webCheckinNoSeatCharge: false,
      vrsGuid: '6e294c5f-df72-4eff-b8f3-1806b247340c',
      autoSeatOption: true,
      hostBaseUrl:  'https://customertest.videcom.com/ibom/VARS/public',
      iOSAppId: '1457545908',
      androidAppId: 'com.ibom.reservations',
      fqtvName: 'FQTV',
      appFeedbackEmail: '',
      groupsBookingsEmail: '',
      bpShowFastTrack: true,
      bpShowLoungeAccess: true,


      passengerTypes: PassengerTypes(
      adult: true,
      child: true,
      infant: true,
      youth: true,
  ),

//Production setttings
/*  xmlUrl:      "https://booking.loganair.co.uk/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
  apisUrl:      'https://booking.loganair.co.uk/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
  apiUrl: 'https://booking.loganair.co.uk/ANCwebApi/api/',
  creditCardProvider: 'worldpaydirect',
 */
  eVoucher: true,

//Staging setttings
  xmlUrl:      "https://customertest.videcom.com/ibomair/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
  apisUrl:      'https://customertest.videcom.com/ibomair/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
  apiUrl:      'https://customertest.videcom.com/ibomair/VARS/webApiV2/api/',  // InHouse

/*
    xmlUrl:      "https://customertest.videcom.com/LoganAir/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?",
    apisUrl:      'https://customertest.videcom.com/LoganAir/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?',
    apiUrl:      'https://customertest.videcom.com/LoganAir/VARS/webApiv2/api/',  // InHouse

 */
  creditCardProvider: 'videcard',
  wantPayStack: false,
  wantLeftLogo: false,
  apiKey: 'a4768447e0ae4e4688b6783377bed3b6',
  maxNumberOfPax: 8,
  hideFareRules: false,
  fqtvEnabled: false,
    searchDateOut: 1,
    searchDateBack: 6,
  );


}

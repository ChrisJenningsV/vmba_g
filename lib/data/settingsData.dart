//import 'package:vmba/data/models/apis_pnr.dart';
//import 'package:vmba/data/models/models.dart';


final String latestBuildiOS = '1.0.5';
final String latestBuildAndroid = '1.0.0.98';

/*  Loganair */
/*
final String airlineName = 'Loganair';

final String xmlToken = "token=tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo%3D";
final String xmlTokenPost = "tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo=";
final String aircode = 'LM';
final String termsAndConditionsUrl = 'https://loganair.co.uk/terms-m/';
final String privacyPolicyUrl =
    'https://loganair.co.uk/wp-content/uploads/2018/05/Privacy-policy-2205.pdf';
final String prohibitedItemsNoticeUrl =
    'https://www.loganair.co.uk/prohibited-items-notice/';
final String locale = 'en-EN';
final int bookingLeadTime = 60;
final bool webCheckinNoSeatCharge = false;
final String vrsGuid = '6e294c5f-df72-4eff-b8f3-1806b247340c';
final bool autoSeatOption = true;
final String backgroundImageUrl =
    'https://customertest.videcom.com/LoganAir/VARS/public/CustomerFiles/LoganAir/App/HOGMANAY_SALE1.png';
final String hostBaseUrl =
    'https://customertest.videcom.com/LoganAir/VARS/public';
final String iOSAppId = '1457545908';
final String androidAppId = 'uk.co.loganair.booking';
final String fqtvName = 'Clan';
final String appFeedbackEmail = 'appfeedback@loganair.co.uk';
final String groupsBookingsEmail = 'groups@loganair.co.uk';

final PassengerTypes passengerTypes = PassengerTypes(
  adult: true,
  child: true,
  infant: true,
  youth: true,
);

//Production setttings
final String xmlUrlProduction =
    "https://booking.loganair.co.uk/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?";
final String apisUrlProduction =
    'https://booking.loganair.co.uk/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?';
final String apiUrlProduction = 'https://booking.loganair.co.uk/ANCwebApi/api/';
final String creditCardProviderProduction = 'worldpaydirect';
final bool eVoucher = true;

//Staging setttings
final String xmlUrlStaging =
    "https://customertest.videcom.com/LoganAir/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?";
final String apisUrlStaging =
    'https://customertest.videcom.com/LoganAir/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?';
final String apiUrlStaging =
    'https://customertest.videcom.com/LoganAir/VARS/webApi/api/';
final String creditCardProviderStaging = 'videcard';
final String apiKey = '93a9626c78514c2baab494f4f6e0c197';

final String creditCardProvider = 'worldpaydirect';
final int maxNumberOfPax = 8;
final bool hideFareRules = false;
final bool fqtvEnabled = false;
final bool bpShowLoungeAccess = true;
final bool bpShowFastTrack = true;
final Color seatPlanColorEmergency = Colors.red; //Colors.yellow
final Color seatPlanColorAvailable = Colors.blue; //Colors.green
final Color seatPlanColorSelected = Colors.blue.shade900; //Colors.grey.shade600
final Color seatPlanColorUnavailable =
    Colors.grey.shade300; //Colors.grey.shade300
final Color seatPlanColorRestricted = Colors.green[200]; //Colors.grey.shade300
*/

/* ibomair 
final String airlineName = 'airswift';

final String xmlToken = "token=jgxD8XX48HgiBqGbkqmR2qmq6WzfWaQCi59Aa3s1StA%3D";
final String xmlTokenPost = "jgxD8XX48HgiBqGbkqmR2qmq6WzfWaQCi59Aa3s1StA=";
final String aircode = 't6';
final String termsAndConditionsUrl = ''; //'https://loganair.co.uk/terms-m/';
final String privacyPolicyUrl =
    ''; //'https://loganair.co.uk/wp-content/uploads/2018/05/Privacy-policy-2205.pdf';
final String prohibitedItemsNoticeUrl = '';
final String locale = 'en-EN';
final int bookingLeadTime = 60;
final bool webCheckinNoSeatCharge = true;
final String vrsGuid = '6e294c5f-df72-4eff-b8f3-1806b247340c';
final bool autoSeatOption = false;
final String backgroundImageUrl = '';
//'https://customertest.videcom.com/LoganAir/VARS/public/CustomerFiles/LoganAir/App/HOGMANAY_SALE1.png';
final String iOSAppId = ''; //'1457545908';
final String androidAppId = ''; //'uk.co.loganair.booking';
final String fqtvName = 'FQTV';
final String appFeedbackEmail = 'appfeedback@ibomair.com';
final bool bpShowLoungeAccess = true;
final bool bpShowFastTrack = true;
final String groupsBookingsEmail = 'groups@ibomair.com';
final bool hideFareRules = false;
final bool fqtvEnabled = false;

final PassengerTypes passengerTypes = PassengerTypes(
  adult: true,
  child: true,
  infant: true,
  youth: false,
  senior: false,
);

final Color seatPlanColorEmergency = Colors.red; //Colors.yellow
final Color seatPlanColorAvailable = Colors.blue; //Colors.green
final Color seatPlanColorSelected = Colors.blue.shade900; //Colors.grey.shade600
final Color seatPlanColorUnavailable =
    Colors.grey.shade300; //Colors.grey.shade300
final Color seatPlanColorRestricted = Colors.green[200]; //Colors.grey.shade300

//Production setttings
final String xmlUrlProduction =
    "https://booking.ibomair.com/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?";
final String apisUrlProduction =
    'https://booking.ibomair.com/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?';
final String apiUrlProduction = 'https://booking.ibomair.com/VARS/webApi/api/';
final String creditCardProviderProduction = '';
final String apiKey = 'a4768447e0ae4e4688b6783377bed3b6';
final bool eVoucher = false;

//Staging setttings
final String xmlUrlStaging =
    'https://customertest.videcom.com/IbomAir/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?';
final String apisUrlStaging =
    'https://customertest.videcom.com/IbomAir/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?';
final String apiUrlStaging =
    'https://customertest.videcom.com/IbomAir/VARS/webApi/api/';
final String creditCardProviderStaging = 'videcard';

final String creditCardProvider = '';

final int maxNumberOfPax = 8;
*/

/*  Blue Island 
final String airlineName = 'BlueIslands';

final String xmlToken = "token=tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo%3D";
final String xmlTokenPost = "tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo=";

final String aircode = 'SI';
final String termsAndConditionsUrl =
    'https://www.blueislands.com/terms-and-conditions/';
final String privacyPolicyUrl = 'https://www.blueislands.com/privacy-policy/';
final String prohibitedItemsNoticeUrl = '';
final String locale = 'en-EN';
final int bookingLeadTime = 60;
final bool webCheckinNoSeatCharge = false;
final String vrsGuid = '6e294c5f-df72-4eff-b8f3-1806b247340c';
final bool autoSeatOption = true;
final String backgroundImageUrl =
    'https://booking.blueisland.com/VARS/public/CustomerFiles/BlueIslands/App/Blue_Islands_ATR.png';
final String iOSAppId = '1521495071';
final String androidAppId = 'com.blueislands.booking';
final String fqtvName = 'Blue Skies';
final String appFeedbackEmail = 'webmaster@blueislands.com';
final String groupsBookingsEmail = 'groups@blueislands.com';
final bool hideFareRules = true;
final bool fqtvEnabled = true;

final bool bpShowLoungeAccess = false;
final bool bpShowFastTrack = false;
final int maxNumberOfPax = 9;

final Color seatPlanColorEmergency = Colors.red; //Colors.yellow
final Color seatPlanColorAvailable = Colors.blue; //Colors.green
final Color seatPlanColorSelected = Colors.blue.shade900; //Colors.grey.shade600
final Color seatPlanColorUnavailable =
    Colors.grey.shade300; //Colors.grey.shade300
final Color seatPlanColorRestricted = Colors.green[200]; //Colors.grey.shade300

final PassengerTypes passengerTypes = PassengerTypes(
  adult: true,
  child: true,
  infant: true,
  youth: true,
);
final bool eVoucher = true;
final String creditCardProvider = 'citypaydirect';

//Production setttings
final String xmlUrlProduction =
    "https://customer3.videcom.com/BlueIslands/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?";
final String apisUrlProduction =
    'https://customer3.videcom.com/BlueIslands/VRSXMLwebService3.asmx/PostApisData?';
final String apiUrlProduction =
    'https://booking.BlueIslands.com/vars/webApi/api';
final String creditCardProviderProduction = 'citypaydirect';

//Staging setttings
final String xmlUrlStaging =
    "https://customertest.videcom.com/BlueIslands/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?";
final String apisUrlStaging =
    'https://customertest.videcom.com/BlueIslands/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?';
final String apiUrlStaging =
    'https://customertest.videcom.com/BlueIslands/VARS/webApi/api';
 final String apiKey = '4d332cf7134f4a43958d954278474b41';
final String creditCardProviderStaging = 'videcard'; */

/*  AirSwift 
final String airlineName = 'AirSwift';

final String xmlToken = "token=tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo%3D";
final String xmlTokenPost = "tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo=";

final String aircode = 'T6';
final String termsAndConditionsUrl = '';
final String privacyPolicyUrl = '';
final String prohibitedItemsNoticeUrl =
    '';
final String locale = 'en-EN';
final int bookingLeadTime = 60;
final bool webCheckinNoSeatCharge = false;
final String vrsGuid = '6e294c5f-df72-4eff-b8f3-1806b247340c';
final bool autoSeatOption = true;
final String backgroundImageUrl = '';
final String iOSAppId = '1521495071';
final String androidAppId = 'com.air-swift.booking';
final String fqtvName = '';
final String appFeedbackEmail = 'webmaster@air-swift.com';
final String groupsBookingsEmail = 'groups@air-swift.com';
final bool hideFareRules = false;
final bool fqtvEnabled = false;

final bool bpShowLoungeAccess = false;
final bool bpShowFastTrack = false;
final int maxNumberOfPax = 8;

final Color seatPlanColorEmergency = Colors.red; //Colors.yellow
final Color seatPlanColorAvailable = Colors.blue; //Colors.green
final Color seatPlanColorSelected = Colors.blue.shade900; //Colors.grey.shade600
final Color seatPlanColorUnavailable =
    Colors.grey.shade300; //Colors.grey.shade300
final Color seatPlanColorRestricted = Colors.green[200]; //Colors.grey.shade300

final PassengerTypes passengerTypes = PassengerTypes(
  adult: true,
  child: true,
  infant: true,
  youth: true,
);
final bool eVoucher = true;
final String creditCardProvider = 'videcard';

//Production setttings
final String xmlUrlProduction =
    "https://booking.Air-Swift.com/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?";
final String apisUrlProduction =
    'https://booking.Air-Swift.com/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?';
final String apiUrlProduction =
    'https://booking.Air-Swift.com/vars/webApi/api';
final String creditCardProviderProduction = 'videcard';


//Staging setttings
final String xmlUrlStaging =
    "https://customertest.videcom.com/AirSwift/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?";
final String apisUrlStaging =
    'https://customertest.videcom.com/AirSwift/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?';
final String apiUrlStaging =
    'https://customertest.videcom.com/AirSwift/VARS/webApi/api';
final String apiKey = '26d5a5deaf774724bb5d315dbb8bfee2';
final String creditCardProviderStaging = 'videcard';
*/

/*  air leap */
/*
final String airlineName = 'Air Leap';

final String xmlToken = "token=tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo%3D";
final String xmlTokenPost = "tKXalaKEJHvQdwV4eN02v073sLxYwU97VoZsOpvxfOo=";
final String aircode = 'FL';
final String termsAndConditionsUrl = 'https://www.airleap.se/sv/allt-for-resan/fore-resan/resebestammelser';
final String privacyPolicyUrl =
    'https://www.airleap.se/sv/om-airleap/integritetspolicy';
final String prohibitedItemsNoticeUrl =
    '';
final String locale = 'en-EN';
final int bookingLeadTime = 60;
final bool webCheckinNoSeatCharge = false;
final String vrsGuid = '6e294c5f-df72-4eff-b8f3-1806b247340c';
final bool autoSeatOption = true;
final String backgroundImageUrl =
    'https://customertest.videcom.com/LoganAir/VARS/public/CustomerFiles/LoganAir/App/HOGMANAY_SALE1.png';
final String hostBaseUrl =
    'https://customertest.videcom.com/airleap/VARS/public';
final String iOSAppId = '1457545908';
final String androidAppId = 'se.airleap.booking';
final String fqtvName = 'Clan';
final String appFeedbackEmail = 'appfeedback@loganair.co.uk';
final String groupsBookingsEmail = 'groups@loganair.co.uk';

final PassengerTypes passengerTypes = PassengerTypes(
  adult: true,
  child: true,
  infant: true,
  youth: true,
);

//Production setttings
final String xmlUrlProduction =
    "https://customer3.videcom.com/AirLeap/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?";
final String apisUrlProduction =
    'https://customer3.videcom.com/AirLeap/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?';
final String apiUrlProduction = 'https://customer3.videcom.com/AirLeap/webapi/api/';
final String creditCardProviderProduction = 'worldpaydirect';
final bool eVoucher = true;

//Staging setttings
final String xmlUrlStaging =
    "https://customertest.videcom.com/airleap/VRSXMLService/VRSXMLwebService3.asmx/PostVRSCommand?";
final String apisUrlStaging =
    'https://customertest.videcom.com/airleap/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?';
final String apiUrlStaging =
    'https://customertest.videcom.com/airleap/VARS/webApi/api/';
final String apiKey = '2edd1519899a4e7fbf9a307a0db4c17a';
//'https://customer3.videcom.com/AirLeap/vars/webApi/api/';
final String creditCardProviderStaging = 'videcard';

final String creditCardProvider = 'worldpaydirect';
final int maxNumberOfPax = 8;
final bool hideFareRules = false;
final bool fqtvEnabled = false;
final bool bpShowLoungeAccess = true;
final bool bpShowFastTrack = true;
final Color seatPlanColorEmergency = Colors.red; //Colors.yellow
final Color seatPlanColorAvailable = Colors.blue; //Colors.green
final Color seatPlanColorSelected = Colors.blue.shade900; //Colors.grey.shade600
final Color seatPlanColorUnavailable =
    Colors.grey.shade300; //Colors.grey.shade300
final Color seatPlanColorRestricted = Colors.green[200]; //Colors.grey.shade300
*/

/* Air North */
/*
final String apiKey = '7d8a80fae6c6424c8d09d4b03098a10d';
 */
/* Air Peace */
/*
final String apiKey = '0dc43646b379435695a28688ee5c9468';
 */




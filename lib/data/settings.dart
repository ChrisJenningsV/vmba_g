import 'package:vmba/data/repository.dart';
import 'package:meta/meta.dart';
import 'models/passengerTypesDisplay.dart';
import 'dart:convert' as myJson;




class KeyPair {
  static final dbName = "name";
  static final dbValue = "value";

  String key, value;
  KeyPair({
    @required this.key,
    @required this.value,
  });

  KeyPair.fromMap(Map<String, dynamic> map)
      : this(
          key: map[dbName],
          value: map[dbValue],
        );

  // Currently not used
  Map<String, dynamic> toMap() {
    return {
      dbName: key,
      dbValue: value,
    };
  }
}

class GobalSettings {
  static final GobalSettings _settings = GobalSettings._internal();

  factory GobalSettings() => _settings;

  GobalSettings._internal(); // private constructor
  static GobalSettings get shared => _settings;

  Future init() async {
    return await _init();
  }

  Future _init() async {
    //get inital settings
    /*
    settings.xmlToken = xmlToken;
    settings.xmlTokenPost = xmlTokenPost;
    settings.aircode = aircode;

    settings.termsAndConditionsUrl = termsAndConditionsUrl;
    settings.privacyPolicyUrl = privacyPolicyUrl;
    settings.locale = locale;
    settings.bookingLeadTime = bookingLeadTime;
    settings.webCheckinNoSeatCharge = webCheckinNoSeatCharge;
    settings.vrsGuid = vrsGuid;
    settings.autoSeatOption = autoSeatOption;
    settings.backgroundImageUrl = backgroundImageUrl;
    settings.hostBaseUrl = hostBaseUrl;
    settings.iOSAppId = iOSAppId;
    settings.androidAppId = androidAppId;

    settings.latestBuildiOS = latestBuildiOS;
    settings.latestBuildAndroid = latestBuildAndroid;

    settings.eVoucher = eVoucher;
    settings.passengerTypes = passengerTypes;
    settings.fqtvName = fqtvName;
    settings.appFeedbackEmail = appFeedbackEmail;
    settings.prohibitedItemsNoticeUrl = prohibitedItemsNoticeUrl;
    settings.groupsBookingsEmail = groupsBookingsEmail;
    settings.maxNumberOfPax = maxNumberOfPax;
    settings.hideFareRules = hideFareRules;
    settings.fqtvEnabled = fqtvEnabled;

    if (isLive) {
      setToLive();
    } else {
      setToTest();
    }
    */

    return await Repository.get().settings();
  }

  void setToLive() {
 /*   settings.xmlUrl = xmlUrlProduction;
    settings.apisUrl = apiUrlProduction;
    settings.apiUrl = apiUrlProduction;
    settings.apiKey= apiKey;
    settings.creditCardProvider = creditCardProviderProduction;

  */
  }

  void setToTest() {
    /*
    settings.xmlUrl = xmlUrlStaging;
    settings.apisUrl = apisUrlStaging;
    settings.apiUrl = apiUrlStaging;
    settings.apiKey= apiKey;
    settings.creditCardProvider = creditCardProviderStaging;

     */
  }

  Settings settings = Settings();
}

class Settings {
  String xmlToken;
  String xmlTokenPost;
  String aircode;
  String airlineName;
  bool wantPayStack = false;
  bool wantLeftLogo = false;
  bool wantMyAccount = false;
  bool wantProfileList = false;
  bool wantFQTV = false;
  bool wantCurrencySymbols = false;
  bool wantRememberMe = false;
  bool wantHomeFQTVButton = false;
  String termsAndConditionsUrl="";
  String adsTermsUrl='';
  String privacyPolicyUrl='';
  String specialAssistanceUrl;
  String faqUrl;
  String contactUsUrl;
  String stopUrl;
  String locale = 'en-EN';
  int bookingLeadTime = 60;
  bool webCheckinNoSeatCharge;
  String vrsGuid;
  String previousVrsGuid;
  bool autoSeatOption;
  String backgroundImageUrl;
  String hostBaseUrl;
  String iOSAppId;
  String androidAppId;
  String latestBuildiOS = '1.0.5';
  String latestBuildAndroid = '1.0.0.98';
  String fQTVpointsName = 'airmiles';
  String reqUpdateMsg;
  String optUpdateMsg;

  String xmlUrl;
  String apisUrl;
  String apiUrl;
  String apiKey;
  String creditCardProvider;

  String testXmlUrl;
  String testApisUrl;
  String testApiUrl;
  String testCreditCardProvider;

  String liveXmlUrl;
  String liveApisUrl;
  String liveApiUrl;
  String liveCreditCardProvider;

  bool eVoucher;
  PassengerTypes passengerTypes;

  String fqtvName="";
  String appFeedbackEmail="";

  String prohibitedItemsNoticeUrl="";
  String groupsBookingsEmail ="";
  bool hideFareRules;
  int maxNumberOfPax;
  bool fqtvEnabled;
  bool bpShowLoungeAccess;
  int searchDateOut;
  int searchDateBack;

bool bpShowFastTrack;
  Settings({
    this.xmlToken,
    this.xmlTokenPost,
    this.aircode,
    this.airlineName,
    this.creditCardProvider,
    this.wantPayStack,
    this.wantLeftLogo,
    this.wantCurrencySymbols,
    this.wantRememberMe,
    this.wantHomeFQTVButton,
    this.termsAndConditionsUrl,
    this.adsTermsUrl,
    this.privacyPolicyUrl,
    this.faqUrl,
    this.contactUsUrl,
    this.specialAssistanceUrl,
    this.locale,
    this.bookingLeadTime,
    this.webCheckinNoSeatCharge,
    this.vrsGuid,
    this.previousVrsGuid,
    this.autoSeatOption,
    this.backgroundImageUrl,
    this.hostBaseUrl,
    this.iOSAppId,
    this.androidAppId,
    this.latestBuildiOS,
    this.latestBuildAndroid,
    this.xmlUrl,
    this.apisUrl,
    this.apiUrl,
    this.apiKey,
    this.eVoucher,
    this.passengerTypes,
    this.fqtvName,
    this.appFeedbackEmail,
    this.prohibitedItemsNoticeUrl,
    this.groupsBookingsEmail,
    this.maxNumberOfPax,
    this.hideFareRules,
    this.fqtvEnabled,
    this.bpShowFastTrack,
    this.bpShowLoungeAccess,
    this.wantMyAccount,
    this.wantFQTV,
    this.searchDateOut,
    this.searchDateBack,
    this.reqUpdateMsg,
    this.optUpdateMsg,

    this.testXmlUrl,
    this.testApisUrl,
    this.testApiUrl,
    this.testCreditCardProvider,

    this.liveXmlUrl,
    this.liveApisUrl,
    this.liveApiUrl,
    this.liveCreditCardProvider,
    this.fQTVpointsName,

  });


/*
  Settings.fromJson(Map<String, dynamic> json) {
    xmlToken = json['xmlToken'];
    xmlTokenPost = json['xmlTokenPost'];
    aircode = json['aircode'];
    creditCardProvider = json['creditCardProvider'];
    termsAndConditionsUrl = json['termsAndConditionsUrl'];
    privacyPolicyUrl = json['privacyPolicyUrl'];
    locale = json['locale'];
    bookingLeadTime = int.parse(json['bookingLeadTime'].toString());
    webCheckinNoSeatCharge =
        json['webCheckinNoSeatCharge'].toString().toLowerCase() == 'true'
            ? true
            : false;
    vrsGuid = json['vrsGuid'];
    previousVrsGuid = json['previousVrsGuid'];
    autoSeatOption = json['autoSeatOption'].toString().toLowerCase() == 'true'
        ? true
        : false;
    backgroundImageUrl = json['backgroundImageUrl'];
    hostBaseUrl = json['hostBaseUrl'];
    iOSAppId = json['iOSAppId'];
    androidAppId = json['androidAppId'];
    latestBuildiOS = json['latestBuildiOS'];
    latestBuildAndroid = json['latestBuildAndroid'];
    xmlUrl = json['xmlUrl'];
    apisUrl = json['apisUrl'];
    apiUrl = json['apiUrl'];
    apiKey = json['apiKey'];

    eVoucher =
        json['eVoucher'].toString().toLowerCase() == 'true' ? true : false;
    passengerTypes = json['passengerTypes'] != null
        ? new PassengerTypes.fromJson(myJson.json
            .decode(json['passengerTypes'].toString().replaceAll("'", '"')))
        : PassengerTypes();

    if (json['fqtvName'].toString() != "null") {
      fqtvName = json['fqtvName'];
    }

    if (json['appFeedbackEmail'].toString() != "null") {
      appFeedbackEmail = json['appFeedbackEmail'];
    }
    if (json['prohibitedItemsNoticeUrl'].toString() != "null") {
      prohibitedItemsNoticeUrl = json['prohibitedItemsNoticeUrl'];
    }

    if (json['groupsBookingsEmail'].toString() != "null") {
      groupsBookingsEmail = json['groupsBookingsEmail'];
    }

    if (json['maxNumberOfPax'].toString() != "null" &&
        json['maxNumberOfPax'].toString() != "0") {
      maxNumberOfPax = int.parse(json['maxNumberOfPax'].toString());
    } else {
      maxNumberOfPax = 8;
    }
    hideFareRules =
        json['hideFareRules'].toString().toLowerCase() == 'true' ? true : false;

    fqtvEnabled =
        json['fqtvEnabled'].toString().toLowerCase() == 'false' ? false : true;
  }
*/
  /*
  Map toJson() {
    Map map = new Map();
    map['xmlToken'] = xmlToken;
    map['xmlTokenPost'] = xmlTokenPost;
    map['aircode'] = aircode;
    map['creditCardProvider'] = creditCardProvider;
    map['termsAndConditionsUrl'] = termsAndConditionsUrl;
    map['privacyPolicyUrl'] = privacyPolicyUrl;
    map['locale'] = locale;
    map['bookingLeadTime'] = bookingLeadTime;
    map['webCheckinNoSeatCharge'] = webCheckinNoSeatCharge;
    map['vrsGuid'] = vrsGuid;
    map['previousVrsGuid'] = previousVrsGuid;
    map['autoSeatOption'] = autoSeatOption;
    map['backgroundImageUrl'] = backgroundImageUrl;
    map['hostBaseUrl'] = hostBaseUrl;
    map['iOSAppId'] = iOSAppId;
    map['androidAppId'] = androidAppId;
    map['latestBuildiOS'] = latestBuildiOS;
    map['latestBuildAndroid'] = latestBuildAndroid;
    map['xmlUrl'] = xmlUrl;
    map['apisUrl'] = apisUrl;
    map['apiUrl'] = apiUrl;
    map['apiKey'] = apiKey;
    map['eVoucher'] = eVoucher;
    map['passengerTypes'] = passengerTypes.toJson();
    map['fqtvName'] = fqtvName;
    map['appFeedbackEmail'] = appFeedbackEmail;
    map['prohibitedItemsNoticeUrl'] = prohibitedItemsNoticeUrl;
    map['groupsBookingsEmail'] = groupsBookingsEmail;
    map['maxNumberOfPax'] = maxNumberOfPax;
    map['hideFareRules'] = hideFareRules;
    map['fqtvEnabled'] = fqtvEnabled;
    return map;
  }
*/

  List<KeyPair> toList() {
    List<KeyPair> listKeyPair = [];
    // List<KeyPair>();

    if (xmlToken != null) {
      listKeyPair.add(new KeyPair(key: 'xmlToken', value: xmlToken));
    }

    listKeyPair.add(new KeyPair(key: 'xmlTokenPost', value: xmlTokenPost));
    listKeyPair.add(new KeyPair(key: 'aircode', value: aircode));
    listKeyPair
        .add(new KeyPair(key: 'creditCardProvider', value: creditCardProvider));
    listKeyPair.add(new KeyPair(
        key: 'termsAndConditionsUrl', value: termsAndConditionsUrl));
    listKeyPair
        .add(new KeyPair(key: 'privacyPolicyUrl', value: privacyPolicyUrl));
    listKeyPair.add(new KeyPair(key: 'locale', value: locale));
    listKeyPair.add(
        new KeyPair(key: 'bookingLeadTime', value: bookingLeadTime.toString()));
    listKeyPair.add(new KeyPair(
        key: 'webCheckinNoSeatCharge',
        value: webCheckinNoSeatCharge.toString()));
    listKeyPair.add(new KeyPair(key: 'vrsGuid', value: vrsGuid));
    listKeyPair
        .add(new KeyPair(key: 'previousVrsGuid', value: previousVrsGuid));
    listKeyPair.add(
        new KeyPair(key: 'autoSeatOption', value: autoSeatOption.toString()));
    listKeyPair
        .add(new KeyPair(key: 'backgroundImageUrl', value: backgroundImageUrl));
    listKeyPair.add(new KeyPair(key: 'hostBaseUrl', value: hostBaseUrl));
    listKeyPair.add(new KeyPair(key: 'iOSAppId', value: iOSAppId));
    listKeyPair.add(new KeyPair(key: 'androidAppId', value: androidAppId));
    listKeyPair.add(new KeyPair(key: 'latestBuildiOS', value: latestBuildiOS));
    listKeyPair
        .add(new KeyPair(key: 'latestBuildAndroid', value: latestBuildAndroid));
    listKeyPair.add(new KeyPair(key: 'xmlUrl', value: xmlUrl));
    listKeyPair.add(new KeyPair(key: 'apisUrl', value: apisUrl));
    listKeyPair.add(new KeyPair(key: 'apiUrl', value: apiUrl));
    listKeyPair.add(new KeyPair(key: 'apiKey', value: apiKey));
    listKeyPair.add(new KeyPair(key: 'eVoucher', value: eVoucher.toString()));

    listKeyPair.add(new KeyPair(
        key: 'passengerTypes', value: myJson.json.encode(passengerTypes)));

    listKeyPair
        .add(new KeyPair(key: 'fqtvName', value: myJson.json.encode(fqtvName)));
    listKeyPair.add(new KeyPair(
        key: 'appFeedbackEmail', value: myJson.json.encode(appFeedbackEmail)));
    if (prohibitedItemsNoticeUrl != null) {
      listKeyPair.add(new KeyPair(
          key: 'prohibitedItemsNoticeUrl',
          value: myJson.json.encode(prohibitedItemsNoticeUrl)));
    }

    listKeyPair.add(new KeyPair(
        key: 'groupsBookingsEmail',
        value: myJson.json.encode(groupsBookingsEmail)));
    listKeyPair.add(new KeyPair(
        key: 'maxNumberOfPax', value: myJson.json.encode(maxNumberOfPax)));
    listKeyPair.add(new KeyPair(
        key: 'hideFareRules', value: myJson.json.encode(hideFareRules)));
    listKeyPair.add(new KeyPair(
        key: 'fqtvEnabled', value: myJson.json.encode(fqtvEnabled)));

    return listKeyPair;
  }
}

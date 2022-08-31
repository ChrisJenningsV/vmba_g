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

    return await Repository.get().settings();
  }



  Settings settings = Settings();
}

class Settings {
  String xmlToken;
  String xmlTokenPost;
  String aircode;
  String brandID;
  String airlineName;
  bool wantApis;
  bool displayErrorPnr;
  bool wantPayStack = false;
  bool wantLeftLogo = false;
  bool wantMyAccount ;
  bool wantProfileList = false;
  bool wantFQTV = false;
  bool wantFindBookings = false;
  bool wantFQTVNumber = false;
  bool want2Dbarcode = true;
  bool wantCurrencySymbols = false;
  bool wantCurrencyPicker = false;
  bool wantPassengerPassport = false;
  bool wantRememberMe = false;
  bool wantHomeFQTVButton = false;
  bool wantUmnr = false;
  bool youthIsAdult = false;
  bool wantEnglishTranslation = false;
  bool want24HourClock;
  bool wantNewEditPax;
  bool wantMaterialControls;
  bool wantCitySwap;
  bool wantPageImages;
  bool wantProducts;
  bool wantSeatsWithProducts;
  bool wantMmbProducts;
  String productImageMode;
  bool wantDangerousGoods;
  bool wantInternatDialCode;
  bool wantCovidWarning;
  bool wantCountry;
  bool wantClassBandImages;
  bool wantStatusLine;
  bool wantTallPageImage;
  bool wantProgressBar;
  bool wantGender;
  bool wantMiddleName;
  bool wantRedressNo;
  bool wantKnownTravNo;
  bool wantPushNoticications;
  bool wantNotificationEdit;
  bool wantCentreTitle;
  bool wantRefund;
  bool wantNewPayment;
  bool wantButtonIcons;
  bool useWebApiforVrs;
  bool bpShowAddPassToWalletButton;
  bool disableBookings;
  bool useSmartPay;

  String homePageStyle;
  String pageStyle;
  String defaultCountryCode;
  String termsAndConditionsUrl="";
  String adsTermsUrl='';
  String privacyPolicyUrl='';
  String specialAssistanceUrl;
  String faqUrl;
  String contactUsUrl;
  //String payStartUrl;
  String paySuccessUrl;
  String payFailUrl;
  String stopUrl;
  String stopTitle;
  String locale = 'en-EN';
  int bookingLeadTime = 60;
  bool webCheckinNoSeatCharge;
  String vrsGuid;
  String previousVrsGuid;
  bool autoSeatOption;
  String backgroundImageUrl;
  String customMenu1;
  String customMenu2;
  String customMenu3;
  String pageImageMap;
  String productImageMap;
  String skyFlyToken;

 // String hostBaseUrl;
  String iOSAppId;
  String androidAppId;
  String latestBuildiOS = '1';
  String latestBuildAndroid = '1';
  String fQTVpointsName = 'airmiles';
  String reqUpdateMsg;
  String optUpdateMsg;

  String xmlUrl;
  //String payUrl;
  String payPage;
  String apisUrl;
  String apiUrl;
  String smartApiUrl;
  String apiKey;
  String creditCardProvider;
  String currency;
  String gblLanguages ;
  String currencies;
  String gblServerFiles;
  String testServerFiles;
  String covidText;


  //String testPayUrl;
  String testPayPage;
  String testXmlUrl;
  String testApisUrl;
  String testApiUrl;
  String testSmartApiUrl;
  String testCreditCardProvider;

  //String livePayUrl;
  String livePayPage;
  String liveXmlUrl;
  String liveApisUrl;
  String liveApiUrl;
  String liveSmartApiUrl;
  String liveCreditCardProvider;
  String avTimeFormat;

  bool eVoucher;
  PassengerTypes passengerTypes;

  String fqtvName="";
  String appFeedbackEmail="";
  String buttonStyle;
  String upgradeMessage;

  String prohibitedItemsNoticeUrl="";
  String groupsBookingsEmail ="";
  bool hideFareRules;
  int maxNumberOfPax;
//  bool fqtvEnabled;
  bool bpShowLoungeAccess;
  int searchDateOut;
  int searchDateBack;
  int payTimeout;
  int passportLayoutStyle;

bool bpShowFastTrack;
  Settings({
    this.xmlToken,
    this.xmlTokenPost,
    this.aircode,
    this.brandID,
    this.airlineName,
    this.creditCardProvider,
    this.displayErrorPnr = false,
    this.wantPayStack = false,
    this.wantLeftLogo = false,
    this.wantCurrencySymbols,
    this.wantCurrencyPicker = false,
    this.wantPassengerPassport = false,
    this.wantRememberMe = false ,
    this.wantHomeFQTVButton = false,
    this.wantUmnr = false,
    this.want24HourClock = false,
    this.wantNewEditPax = false,
    this.wantMaterialControls = false,
    this.wantCitySwap = false,
    this.wantPageImages = false,
    this.wantProducts = false,
    this.wantSeatsWithProducts = false,
    this.wantMmbProducts = false,
    this.productImageMode = 'index',
    this.wantDangerousGoods = false,
    this.wantInternatDialCode = false,
    this.defaultCountryCode,
    this.wantCovidWarning = false,
    this.wantCountry = false,
    this.wantClassBandImages = false,
    this.wantTallPageImage = false,
    this.wantStatusLine = false,
    this.wantProgressBar = false,
    this.wantApis = false,
    this.wantGender = false,
    this.wantMiddleName = false,
    this.wantRedressNo = false,
    this.wantKnownTravNo = false,
    this.wantPushNoticications = false,
    this.wantNotificationEdit = false,
    this.wantCentreTitle = false,
    this.wantRefund = false,
    this.wantNewPayment = false,
    this.wantButtonIcons = true,
    this.useWebApiforVrs: false,
    this.youthIsAdult = false,
    this.disableBookings = false,
    this.useSmartPay = false,
    this.avTimeFormat='HHmm',
    this.homePageStyle='V1',
    this.pageStyle = 'V2',

    this.wantEnglishTranslation = false,
    this.termsAndConditionsUrl,
    this.adsTermsUrl,
    this.privacyPolicyUrl,
    this.faqUrl,
    this.contactUsUrl,
    //this.payStartUrl,
    this.paySuccessUrl = 'paySuccess.aspx',
    this.payFailUrl = 'payFail.aspx',
    this.specialAssistanceUrl,
    this.locale,
    this.bookingLeadTime,
    this.webCheckinNoSeatCharge,
    this.vrsGuid,
    this.previousVrsGuid,
    this.autoSeatOption,
    this.backgroundImageUrl,
//    this.hostBaseUrl,
    this.iOSAppId,
    this.androidAppId,
    this.latestBuildiOS,
    this.latestBuildAndroid,
    //this.payUrl,
    this.payPage,
    this.xmlUrl,
    this.apisUrl,
    this.apiUrl,
    this.apiKey,
    this.smartApiUrl,
    this.eVoucher,
    this.passengerTypes,
    this.currency,
    this.gblLanguages,
    this.covidText,
    this.currencies,
    this.gblServerFiles,
    this.testServerFiles,
    this.pageImageMap = '{"flightSummary": "happystaff", "paymentPage": "paymentPage", "editPax": "[dest]", "paxDetails": "happypax"}',
    this.productImageMap = '{"BAG2": "golfBag", "BAG1": "holdBag"}',
    this.skyFlyToken,

    this.fqtvName,
    this.appFeedbackEmail,
    this.prohibitedItemsNoticeUrl,
    this.groupsBookingsEmail,
    this.maxNumberOfPax,
    this.hideFareRules,
    //this.fqtvEnabled,
    this.bpShowFastTrack,
    this.bpShowLoungeAccess,
    this.wantMyAccount = true,
    this.wantFQTV = false,
    this.wantFindBookings = false,
    this.wantFQTVNumber = false,
    this.searchDateOut,
    this.searchDateBack,
    this.reqUpdateMsg,
    this.optUpdateMsg,
    this.payTimeout = 10,

    //this.testPayUrl,
    this.testPayPage,
    this.testXmlUrl,
    this.testApisUrl,
    this.testApiUrl,
    this.testSmartApiUrl,
    this.testCreditCardProvider,

    //this.livePayUrl,
    this.livePayPage,
    this.liveXmlUrl,
    this.liveApisUrl,
    this.liveApiUrl,
    this.liveSmartApiUrl,
    this.liveCreditCardProvider,
    this.fQTVpointsName,
    this.buttonStyle,
    this.upgradeMessage,
    this.bpShowAddPassToWalletButton,
    this.passportLayoutStyle = 1,
  });
  void setDefaults() {
    if( searchDateOut == null || searchDateOut == 0) {
      searchDateOut = 1;
    }
    if( searchDateBack == null || searchDateBack == 0) {
      searchDateBack = 6;
    }

    if( maxNumberOfPax == null || maxNumberOfPax == 0) {
      maxNumberOfPax = 9;
    }
    if( bookingLeadTime == null ||bookingLeadTime == 0) {
      bookingLeadTime = 60;
    }

    if( locale == null || locale.isEmpty){
      locale = 'en-EN';
    }
    if( backgroundImageUrl == null ) {
      backgroundImageUrl = '';
    }
    if( buttonStyle== null ){
      buttonStyle = 'RO';
    }
    if( wantCurrencyPicker == null ) {
      wantCurrencyPicker = false;
    }
    if( gblLanguages == null ) {
      gblLanguages =  '' ; //'''sv,Swedish,no,Norwegian,da,Danish,fi,Finnish,en,English,fr,French';
    }
    if( gblServerFiles == null ) {
      gblServerFiles = '';
    }
    if( wantEnglishTranslation == null) {
      wantEnglishTranslation = false;
    }
    if( want24HourClock == null ) {
      want24HourClock = false;
    }
    if( wantNewEditPax == null ) {
      wantNewEditPax = false;
    }
    if( wantCitySwap == null ) {
      wantCitySwap= false;
    }
    if(wantMaterialControls == null ){
      wantMaterialControls= false;
    }
    if( wantPageImages == null ) {
      wantPageImages = false;
    }
    if (passengerTypes.student == null  ){
      passengerTypes.student = false;
    }
    if (passengerTypes.senior == null  ){
      passengerTypes.senior = false;
    }
    if (passengerTypes.youths == null  ){
      passengerTypes.youths = false;
    }
    if (passengerTypes.child  == null  ){
      passengerTypes.child = false;
    }
    if( wantApis) {
   /*   passengerTypes.wantAdultDOB = true;
      passengerTypes.wantYouthDOB = true;
      passengerTypes.wantSeniorDOB = true;
      passengerTypes.wantStudentDOB = true;

      wantMiddleName = true;
      wantGender = true;*/

    }

  }

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
 //   listKeyPair.add(new KeyPair(key: 'hostBaseUrl', value: hostBaseUrl));
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
//    listKeyPair.add(new KeyPair(
  //      key: 'fqtvEnabled', value: myJson.json.encode(fqtvEnabled)));

    return listKeyPair;
  }
}

import 'package:vmba/data/repository.dart';
import 'package:meta/meta.dart';
import 'models/passengerTypesDisplay.dart';
import 'dart:convert' as myJson;


class KeyPair {
  static final dbName = "name";
  static final dbValue = "value";

  String key, value;
  KeyPair({
    required this.key,
    required this.value,
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

  late Settings settings ;
}
class PaySettings {
  String payImageMap;


  PaySettings({this.payImageMap =''});
}

class Settings {
  PaySettings? paySettings;
  String xmlToken = '';
  String xmlTokenPost ='';
  String aircode ='';
  String altAircode ='';
  String brandID ='';
  String airlineName ='';
  bool wantApis =false;
  bool displayErrorPnr=false;
  bool needTicketsToImport = false;
  bool wantLeftLogo = false;
  bool wantMyAccount =true;
  bool wantProfileList = false;
  bool wantUnlock = false;
  bool wantFQTV = false;
  bool wantFindBookings = false;
  bool wantFQTVNumber = false;
  bool want2Dbarcode = true;
  bool wantCurrencySymbols = false;
  bool wantCurrencyPicker = false;
//  bool wantBuyNowPayLater = false;
  bool wantPassengerPassport = false;
  bool wantRememberMe = false;
  bool wantCustomProgress =false;
  bool wantHomeFQTVButton = false;
  bool wantUmnr = false;
  bool youthIsAdult = false;
  bool wantEnglishTranslation = false;
  bool want24HourClock = false;
  bool wantNewEditPax = true;
// bool wantMaterialControls;
  bool wantCitySwap = true;
  bool wantPageImages = false;
  bool wantProducts = false;
  bool wantSeats = true;
  bool wantGiftVouchers;
  bool wantSeatsWithProducts = false;
  bool wantMmbProducts = false;
  String productImageMode ='';
  bool wantDangerousGoods = false;
  bool wantInternatDialCode=false;
  bool wantCovidWarning = false;
  bool wantCountry = false;
  bool wantWeight = false;
  bool wantClassBandImages = false;
  bool wantStatusLine = false ;
  bool wantTallPageImage = false;
  bool wantProgressBar = false;
  bool wantGender = false;
  bool wantMiddleName = false ;
  bool wantRedressNo = false ;
  bool wantKnownTravNo;
  bool wantPushNoticications;
  bool wantNotificationEdit;
  bool wantCentreTitle;
  bool wantRefund;
  bool wantNewPayment;
  bool useScrollWebViewiOS;
  bool wantButtonIcons;
//  bool useWebApiforVrs;
  bool bpShowAddPassToWalletButton;
  bool disableBookings;
  bool useSmartPay;
  bool wantAllColorButtons;
  bool wantBpLogo;
  bool useAppBarImeonBP;
  bool wantCanFacs;
  bool wantTerminal;
  bool wantMaterialFonts;
  bool wantPriceCalendar;
  bool wantNewMMB;
  bool wantNewSeats;
  bool wantSeatKeyExpanded;
  bool wantUpgradePrices;
  bool wantPriceCalendarRounding;
  bool wantMonthOnCalendar;
  bool canGoBackFromPaxPage;
  bool canGoBackFromOptionsPage;
  bool canChangeCancelledFlight;
  bool canUndoCheckin;
  bool wantEnglishDates;
  bool wantTandCCheckBox;
  bool saveChangeBookingBeforePay;
  bool wantSaveSettings;
  bool wantShadows;
  bool wantTransapentHomebar;
  bool wantVericalFaresCalendar;
  bool wantFqtvAutologin;
  bool wantFqtvHomepage;
  bool wantCustomHomepage;
  bool useLogin2;
  // new gui opts
  bool wantCityDividers;

  String dagerousdims;
  String domesticCountryCode;
  String currencyLimitedToDomesticRoutes;
  String homePageMessage;
  String productFormat;
  String homePageStyle;
  String homePageFilename;
  String pageStyle;
  String defaultCountryCode;
  String termsAndConditionsUrl="";
  String adsTermsUrl='';
  String privacyPolicyUrl='';
  String trackerUrl='';
  String specialAssistanceUrl='';
  String faqUrl='';
  String contactUsUrl='';
  //String payStartUrl;
  String paySuccessUrl='';
  String payFailUrl='';
  String stopUrl='';
  String stopTitle='';
  String stopMessage='';
  String locale = 'en-EN';
  int bookingLeadTime = 60;
  int smartApiVersion = 1;
  int styleVersion;
  bool webCheckinNoSeatCharge;
  String vrsGuid='';
  String previousVrsGuid='';
  bool autoSeatOption;
  String backgroundImageUrl='';
  String iOSDemoBuilds='';
  String androidDemoBuilds='';
  String demoUser='';
  String demoPassword='';
  String debugUser='';
  String debugPassword='';

  String customMenu1='';
  String customMenu2='';
  String customMenu3='';
  String pageImageMap='';
  String homepageImageMap='';
  int homepageImageDelay=0;
  String productImageMap='';
  String paxWeight='';
  String skyFlyToken='';

 // String hostBaseUrl;
  String iOSAppId='';
  String androidAppId='';
  String latestBuildiOS = '1';
  String latestBuildAndroid = '1';
  String lowestValidBuildiOS = '1';
  String lowestValidBuildAndroid = '1';
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
  int currencyDecimalPlaces;
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
  String updateMessage='';
  String appFeedbackEmail="";
  String buttonStyle;
  String upgradeMessage;

  String prohibitedItemsNoticeUrl="";
  String groupsBookingsEmail ="";
  bool hideFareRules;
  int maxNumberOfPax;
  int maxNumberOfInfants;
//  bool fqtvEnabled;
  bool bpShowLoungeAccess;
  int searchDateOut;
  int searchDateBack;
  int payTimeout;
  int hideBookingHours;
  int passportLayoutStyle;
  double progressFactor;
  String blockedUrls;

bool bpShowFastTrack;
  Settings({
    this.paySettings ,
    this.xmlToken ='',
    this.xmlTokenPost ='',
    this.aircode ='',
    this.altAircode = '',
    this.brandID ='',
    this.airlineName ='',
    this.creditCardProvider ='',
    this.homePageMessage = '',
    this.currencyLimitedToDomesticRoutes = '',
    this.domesticCountryCode = '',
    this.dagerousdims = '',
    this.displayErrorPnr = false,
    this.wantLeftLogo = false,
    this.needTicketsToImport = false,
    this.wantCurrencySymbols =false,
    this.wantCurrencyPicker = false,
    this.wantPassengerPassport = false,
    this.wantRememberMe = false ,
    this.wantCustomProgress = true,
    this.wantHomeFQTVButton = false,
    this.wantUmnr = false,
    this.want24HourClock = false,
    this.wantNewEditPax = false,
    //this.wantMaterialControls = false,
    this.wantCitySwap = false,
    this.wantPageImages = false,
    this.wantProducts = false,
    this.wantSeats = true,
    this.wantGiftVouchers = false,
    this.wantSeatsWithProducts = false,
    this.wantMmbProducts = false,
    this.productImageMode = 'index',
    this.wantDangerousGoods = false,
    this.wantInternatDialCode = false,
    this.defaultCountryCode ='',
    this.wantCovidWarning = false,
    this.wantCountry = false,
    this.wantWeight = false,
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
    this.wantNewPayment = true,
    this.useScrollWebViewiOS = false,
    this.wantButtonIcons = true,
    this.wantAllColorButtons = true,
    this.wantBpLogo = true,
    this.useAppBarImeonBP = false,
    this.wantCanFacs = true,
    this.canGoBackFromPaxPage = false,
    this.canGoBackFromOptionsPage = false,
    this.canChangeCancelledFlight = true,
    this.canUndoCheckin = true,
    this.wantEnglishDates = false,
    this.wantTandCCheckBox = false,
    this.saveChangeBookingBeforePay = false,
    this.wantTerminal = true,
    this.wantMaterialFonts = false,
    this.wantPriceCalendar = false,
    this.wantNewSeats = false,
    this.wantSeatKeyExpanded = false,
    this.wantNewMMB = false,
    this.wantUpgradePrices = false,
    this.wantPriceCalendarRounding = false,
    this.wantMonthOnCalendar = false,
    this.wantSaveSettings = false,
    this.wantShadows = true,
    this.wantTransapentHomebar = false,
    this.wantVericalFaresCalendar = false,
    this.wantFqtvAutologin = false,
    this.wantFqtvHomepage = false,
    this.wantCustomHomepage = false,
    this.useLogin2 = false,
    this.wantUnlock = false,

    // new Gui
    this.wantCityDividers = false,

//    this.useWebApiforVrs: false,
    this.youthIsAdult = false,
    this.disableBookings = false,
    this.useSmartPay = false,
    this.avTimeFormat='HHmm',
    this.homePageStyle='V1',
    this.homePageFilename = '',
    this.pageStyle = 'V1',
    this.styleVersion = 1,

    this.productFormat = 'web',
    this.wantEnglishTranslation = false,
    this.termsAndConditionsUrl='',
    this.adsTermsUrl='',
    this.privacyPolicyUrl='',
    this.trackerUrl = '',
    this.faqUrl='',
    this.contactUsUrl='',
    //this.payStartUrl,
    this.paySuccessUrl = 'paySuccess.aspx',
    this.payFailUrl = 'payFail.aspx',
    this.specialAssistanceUrl='',
    this.locale = 'en-EN',
    this.bookingLeadTime =60,
    this.smartApiVersion = 1,
    this.webCheckinNoSeatCharge = false,
    this.vrsGuid='',
    this.previousVrsGuid='',
    this.autoSeatOption=false,
    this.backgroundImageUrl='',
//    this.hostBaseUrl,
    this.iOSAppId='',
    this.androidAppId='',
    this.latestBuildiOS='',
    this.latestBuildAndroid='',
    this.lowestValidBuildiOS='',
    this.lowestValidBuildAndroid='',
    //this.payUrl,
    this.payPage='',
    this.xmlUrl='',
    this.apisUrl='',
    this.apiUrl='',
    this.apiKey='',
    this.smartApiUrl='',
    this.eVoucher=false,
    required this.passengerTypes,
    this.currency='GBP',
    this.currencyDecimalPlaces = 2,
    this.gblLanguages='',
    this.covidText='',
    this.currencies='',
    this.gblServerFiles='',
    this.testServerFiles='',
    this.pageImageMap = '{"flightSummary": "happystaff", "paymentPage": "paymentPage", "editPax": "[dest]", "paxDetails": "happypax"}',
    this.homepageImageMap = '',
    this.homepageImageDelay = 0,
    this.productImageMap = '{"BAG2": "golfBag", "BAG1": "holdBag"}',
    this.paxWeight = '{"lb": "lb(s)", "kg": "kg(s)"}',
    this.skyFlyToken = '',

    this.fqtvName = '',
    this.updateMessage = '',
    this.appFeedbackEmail = '',
    this.prohibitedItemsNoticeUrl = '',
    this.groupsBookingsEmail = '',
    this.maxNumberOfPax = 9,
    this.maxNumberOfInfants = 9,
    this.hideFareRules = false,
    //this.fqtvEnabled,
    this.bpShowFastTrack = false,
    this.bpShowLoungeAccess = false,
    this.wantMyAccount = true,
    this.wantFQTV = false,
    this.wantFindBookings = false,
    this.wantFQTVNumber = false,
    this.searchDateOut = 1,
    this.searchDateBack = 1,
    this.reqUpdateMsg ='',
    this.optUpdateMsg = '',
    this.payTimeout = 10,
    this.hideBookingHours = 36,

    //this.testPayUrl,
    this.testPayPage ='',
    this.testXmlUrl ='',
    this.testApisUrl ='',
    this.testApiUrl ='',
    this.testSmartApiUrl ='',
    this.testCreditCardProvider ='',

    //this.livePayUrl,
    this.livePayPage ='',
    this.liveXmlUrl='',
    this.liveApisUrl='',
    this.liveApiUrl='',
    this.liveSmartApiUrl='',
    this.liveCreditCardProvider='',
    this.fQTVpointsName='',
    this.buttonStyle='',
    this.upgradeMessage='',
    this.bpShowAddPassToWalletButton=false,
    this.passportLayoutStyle = 1,
    this.iOSDemoBuilds='',
    this.androidDemoBuilds='',
    this.demoUser='',
    this.demoPassword='',
    this.customMenu1='',
    this.customMenu2='',
    this.customMenu3='',
    this.progressFactor = 25,
    this.blockedUrls='',
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
/*
    if(wantMaterialControls == null ){
      wantMaterialControls= false;
    }
*/
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

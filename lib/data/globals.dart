
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:vmba/data/models/models.dart';
import '../components/vidButtons.dart';
import '../flightStatus/flightStatusPage.dart';
import '../home/searchParams.dart';
import '../v3pages/homePageHelper.dart';
import '../v3pages/v3Theme.dart';
import 'SystemColors.dart';
import 'package:vmba/data/settings.dart';

import 'models/cities.dart';
import 'models/flightPrices.dart';
import 'models/notifyMsgs.dart';
import 'models/paxContacts.dart';
import 'models/pnr.dart';
import 'models/products.dart';
import 'models/providers.dart';
import 'models/seatplan.dart';
import 'models/trips.dart';
import 'models/vouchers.dart';

// variable shared to whole app
// initialized in main_XX.dart
// M1 = LM new stuff
// 9Q caicos
//  YL lyb wings
// H4 hisky
// X4 excursions
// KG key lime / Dallas
String gblBuildFlavor = 'X4';
bool gblIsLive = true;
bool gblWantLogBuffer = false;
int requiredXmlVersion = 117; // now 119 for LM NEW, 120 for FQTV reg
int requiredApiVersion = 105;
int apiBuldVersion = 0;
bool gblDoVersionCheck = false;

bool gblUseCache = false;
bool gblContinueAsGuest = false;
String gblTestFlags = '';
List<String> gblLogBuffer= [];
DateTime? startTime;
DateTime? gblDepartDate;
DateTime? gblReturnDate;

String gblValidationPin2='';
String gblValidationPin='';
String gblAppTitle ='';
String gblLanguage = 'en' ;
bool gblLangFileLoaded = false;
bool gblIs24HoursFormat = false;
bool gblSaveLangsFile = true;
String gblLangFileModTime = '';
String gblError= '';
String gblWarning = '';
String gblErrorTitle = '';
String gblSine = '';
String gblVersion = '';
String gblAction='';
String gblPayAction ='';
String gblPayCmd ='';
//String gblMobileFlags = '';
String gblDestination ='';
String gblOrigin ='';
String gblFltNo = '';
String gblPayable = '';
String gblCurrentRloc ='';
String gblPaymentMsg ='';
String gblNotifyToken ='';
String gblDeviceId ='';
String gblCurPage ='';
String gblUndoCommand ='';
String gblBookSeatCmd = '';
String gblPageName = '';
String gblValidationEmail = '';
int gblValidationPinTries = 0;
int gblValidationEmailTries = 0;

//      r'^(([^<>()[\]#$!%&^*+-=?\\.,;:\s@\"]+(\.[^<>()[\]#$!%&^*+-=?\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

String  gblEmailValidationPattern = r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";

/* logging */
bool gblLogProducts = false;
bool gblLogPayment = false;
bool gblLogFQ = false;
bool gblLogCities = false;
bool gblLogSummary = false;
bool gblLanguageLogging = false;
bool gblInRefreshing = false;
bool? gblIsNewInstall;


int gblSecurityLevel = 0;
int gblFqtvBalance = 0;
bool gblIsIos = false;
bool gblPaySuccess = false;
bool gblInReview = false;
bool gblTimerExpired = false;
bool gblPayBtnDisabled = false;
bool gblActionBtnDisabled = false;
bool gblRememberMe = false;
bool gblRedeemingAirmiles = false;
bool gblShowRedeemingAirmiles = false;
bool shownUpdate = false;
bool gblCentreTitle = false;
bool gblFqtvLoggedIn = false;
String gblFqtvNumber = '';
//String gblAdsNo = '';
//String gblAdsPin = '';
PassengerDetail? gblPassengerDetail;
late SystemColors gblSystemColors;
Session? gblSession;
Map? gblLangMap ;
Map<String,String>? gblAirportCache;
late Settings gblSettings;
bool gblNoNetwork = false;
bool gblPushInitialized = false;
bool gblVerbose = false;
bool  gblWantLogin = false;
bool gblDemoMode = false;
bool gblDebugMode = false;
bool gblLoginSuccessful = false;
bool gblNeedPnrReload = false;
PnrModel? gblPnrModel;
PnrModel? gblNextPnr;
NewBooking? gblNewBooking;
SeatPlanDefinition? gblSeatPlanDef;
int gblCurPax = 0;
int gblCurJourney = 0;
FQTVMemberTransactions? gblUpcomingFlights;
//bool  gblUseWebApiforVrs = false;

enum LoadDataType {settings, routes, cities, products, language, providers, calprices}
enum VrsCmdType {bookSeats, loadSeatplan}
enum LoadState { none, loading, loaded, loadFailed }
enum VrsCmdState { none, loading, loaded, loadFailed }
enum BookingState { none, newBooking, changeSeat, bookSeat, changeFlt }
enum PaymentState { none, start, needCheck, success, declined }

LoadState gblSettingsState = LoadState.none;
LoadState gblRoutesState = LoadState.none;
LoadState gblCitiesState = LoadState.none;
LoadState gblProductsState = LoadState.none;
LoadState gblProvidersState = LoadState.none;
LoadState gblCalPriceState = LoadState.none;
LoadState gblLanguageState = LoadState.none;
BookingState gblBookingState = BookingState.none;
PaymentState gblPaymentState = PaymentState.none;

VrsCmdState gblLoadSeatState = VrsCmdState.none;
VrsCmdState gblBookSeatState = VrsCmdState.none;

ProductCategorys? gblProducts ;
String gblProductCacheDeparts='';
String gblProductCacheArrives='';
String gblSelectedCurrency='';
String gblLastCurrecy = '';
String gblLastProviderCurrecy = '';
Providers? gblProviders;
FlightPrices? gblFlightPrices;
String gblBookingCurrency='';
NotificationStore? gblNotifications;
PageListHolder? gblHomeCardList;
V3Theme? gblV3Theme;
Cities? gblCityList;
Trips? gblTrips;
FopVouchers? gblFopVouchers;
PaxContacts? gblContacts;
ButtonClickParams? gblButtonClickParams;

TextStyle? gblTitleStyle;
List<String> gblTitles = <String>[
  'Mr',
  'Mrs',
  'Ms',
  'Dr',
  'Miss',
  'Mstr',
  'Prof',
  'Rev'
];
Map<String, String >? gblPayFormVals;

TextEditingController? gblPhoneCodeEditingController;
Timer? gblTimer;
StackTrace? gblStack;
//List<String>? gblCityData;


SearchParams gblSearchParams = new SearchParams();
FlightStatuss? gblFlightStatuss;
String gblLoadedHomeCountry = '';
Placemark? gblCurLocation;
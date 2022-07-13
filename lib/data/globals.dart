import 'package:flutter/material.dart';
import 'package:vmba/data/models/models.dart';
import 'SystemColors.dart';
import 'package:vmba/data/settings.dart';

import 'models/notifyMsgs.dart';
import 'models/products.dart';
import 'models/providers.dart';

// variable shared to whole app
// initialized in main_XX.dart
//
String gblBuildFlavor = 'SI';
bool gblIsLive = false;
int requiredXmlVersion = 100;
int requiredApiVersion = 100;
int apiBuldVersion;
bool gblDoVersionCheck = true;

String gblAppTitle ;
String gblLanguage = 'en' ;
bool gblLangFileLoaded = false;
bool gblSaveLangsFile = true;
String gblLangFileModTime = '';
String gblError = '';
String gblErrorTitle = '';
String gblSine = '';
String gblVersion = '';
String gblAction='';
//String gblMobileFlags = '';
String gblDestination;
String gblOrigin;
String gblPayable = '';
String gblCurrentRloc;
String gblPaymentMsg;
String gblNotifyToken;
String gblDeviceId;

int gblSecurityLevel = 0;
int gblFqtvBalance = 0;
bool gblUseCache = true;
bool gblIsIos = false;
bool gblPaySuccess = false;
bool gblInReview = false;
bool gblTimerExpired = false;
bool gblPayBtnDisabled = false;
bool gblRememberMe = false;
bool gblRedeemingAirmiles = false;
bool shownUpdate = false;
bool gblCentreTitle = false;
String gblFqtvNumber = '';
//String gblAdsNo = '';
//String gblAdsPin = '';
PassengerDetail gblPassengerDetail;
SystemColors gblSystemColors;
Session gblSession;
Map gblLangMap ;
Settings gblSettings;
bool gblNoNetwork;
bool gblPushInitialized = false;
bool gblVerbose = false;
bool  gblWantLogin = true;
//bool  gblUseWebApiforVrs = false;

enum LoadDataType {settings, routes, cities, products, language, providers}
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
LoadState gblLanguageState = LoadState.none;
BookingState gblBookingState = BookingState.none;
PaymentState gblPaymentState = PaymentState.none;

VrsCmdState gblLoadSeatState = VrsCmdState.none;
VrsCmdState gblBookSeatState = VrsCmdState.none;

ProductCategorys gblProducts ;
Providers gblProviders;
List<NotificationMessage> gblNotifications;


TextStyle gblTitleStyle;
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
Map<String, String > gblPayFormVals;

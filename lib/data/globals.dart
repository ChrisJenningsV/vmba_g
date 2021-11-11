import 'package:flutter/material.dart';
import 'package:vmba/data/models/models.dart';
import 'SystemColors.dart';
import 'package:vmba/data/settings.dart';

import 'models/products.dart';

// variable shared to whole app
// initialized in main_XX.dart
//
String gblAppTitle ;
String gblLanguage = 'en' ;
bool gblLangFileLoaded = false;
bool gblSaveLangsFile = true;
String gblLangFileModTime = '';
String gblBuildFlavor = 'LM';
String gblError = '';
String gblErrorTitle = '';
String gblSine = '';
String gblVersion = '';
String gblAction='';
String gblMobileFlags = '';
String gblDestination;
String gblOrigin;
String gblPayable = '';

int gblSecurityLevel = 0;
int gblFqtvBalance = 0;
bool gblIsIos = false;
bool gblIsLive = true;
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
bool gblVerbose = false;
bool  gblWantLogin = true;

enum LoadDataType {settings, routes, cities, products, language}
enum VrsCmdType {bookSeats, loadSeatplan}
enum LoadState { none, loading, loaded, loadFailed }
enum VrsCmdState { none, loading, loaded, loadFailed }
enum BookingState { none, newBooking, changeSeat, bookSeat }

LoadState gblSettingsState = LoadState.none;
LoadState gblRoutesState = LoadState.none;
LoadState gblCitiesState = LoadState.none;
LoadState gblProductsState = LoadState.none;
LoadState gblLanguageState = LoadState.none;
BookingState gblBookingState = BookingState.none;

VrsCmdState gblLoadSeatState = VrsCmdState.none;
VrsCmdState gblBookSeatState = VrsCmdState.none;

ProductCategorys gblProducts ;


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

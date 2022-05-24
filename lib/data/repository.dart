import 'dart:async' show Future;
import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:vmba/data/database.dart';
import 'package:http/http.dart' as http;
import 'package:vmba/data/models/routes.dart';
import 'package:vmba/data/xmlApi.dart';
import '../Helpers/networkHelper.dart';
import 'models/cities.dart';
import 'package:vmba/data/models/boardingpass.dart';
import 'package:vmba/data/models/pnrs.dart';
import 'package:vmba/data/models/apis_pnr.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/models/user_profile.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/availability.dart';
import 'package:vmba/data/models/seatplan.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models/notifyMsgs.dart';
import 'models/vrsRequest.dart';

//import 'package:flutter/services.dart' show rootBundle;

/// A class similar to http.Response but instead of a String describing the body
/// it already contains the parsed Dart-Object
class ParsedResponse<T> {
  ParsedResponse(this.statusCode, this.body, {this.error});
  final int statusCode;
  final T body;
  final String error;

  bool isOk() {
    return statusCode >= 200 && statusCode < 300;
  }
  String errorStatus() {
    if (statusCode == noInterent) {
      return 'Please check your internet connection';
    }
    if (statusCode == notSinedIn) {
      return 'Not sined in';
    }
    if (statusCode == noFlights) {
      return "No flights for these cities and dates";
    }
    if( error != null && error.isNotEmpty){
      return error;
    }
    return "Unknown error";
  }
}

final int noInterent = 404;
final int noFlights = 405;
final int notSinedIn = 406;

class Repository {
  static final Repository _repo = new Repository._internal();

  AppDatabase database;

  static Repository get() {
    return _repo;
  }

  Repository._internal() {
    database = AppDatabase.get();
  }

  Future init() async {
    return await database.init();
  }


    initFqtv() async {
    if( gblSettings.wantFQTV == false ){
      return null;
    }
    database.getNamedUserProfile('PAX1').then((profile) {
      if (profile != null) {

        try {
          Map map = json.decode(
              profile.value.toString().replaceAll(
                  "'", '"')); // .replaceAll(',}', '}')
            gblPassengerDetail = PassengerDetail.fromJson(map);

            if( gblPassengerDetail!= null &&
                gblPassengerDetail.fqtv != null && gblPassengerDetail.fqtv.isNotEmpty &&
                gblPassengerDetail.fqtvPassword != null && gblPassengerDetail.fqtvPassword.isNotEmpty){
              // get balance
              if ( gblSession != null ){
                FqtvMemberloginDetail fqtvMsg = FqtvMemberloginDetail(gblPassengerDetail.email,
                    gblPassengerDetail.fqtv,
                    gblPassengerDetail.fqtvPassword);
                String msg = json.encode(FqTvCommand(gblSession, fqtvMsg ).toJson());
                String method = 'GetAirMilesBalance';

                //print(msg);
                _sendVRSCommand(msg, method).then((result){
                  Map map = json.decode(result);
                  ApiFqtvMemberAirMilesResp resp = new ApiFqtvMemberAirMilesResp.fromJson(map);
                  if( resp.statusCode != 'OK') {
/*                    _error = resp.message;
                    _actionCompleted();
                    _showDialog();

 */
                  } else {
                    gblFqtvBalance = resp.balance;
                  }
                });
              }
            }
        } catch (e) {
          print(e);
        }
      }
    });
  }
  Future _sendVRSCommand(msg, method) async {
    final http.Response response = await http.post(
        Uri.parse(gblSettings.apiUrl + "/FqTvMember/$method"),
        headers: getApiHeaders(),
        body: msg);

    if (response.statusCode == 200) {
      print('message send successfully: $msg' );
      return response.body.trim();
    } else {
      print('failed: $msg');
      try{
        print (response.body);
      } catch(e){}

    }
  }


  /// Fetches the list of cities from the VRS XML Api with the query parameter being input.
  Future<ParsedResponse<List<City>>> initCities() async {
    var prefs = await SharedPreferences.getInstance();
    logit('initCities');
    var cacheTime = prefs.getString('cache_time2');
    if( cacheTime!= null && cacheTime.isNotEmpty && gblUseCache){
      var cached = DateTime.parse(cacheTime);

      if( cached.isAfter(DateTime.now().subtract(Duration(days: 2)))) {
        // change to 2 days!
        logit('city cache good');
        return null;
      }
    }

    Map<String, String>  userHeader = {"Content-type": "application/json"};
    if (gblSettings.apiKey.isNotEmpty) {
      userHeader = {          'Content-Type': 'application/json',
        'Videcom_ApiKey': gblSettings.apiKey      };
    }

    //http request, catching error like no internet connection.
    //If no internet is available for example response is
    final http.Response response = await http.get(
        Uri.parse('${gblSettings.apiUrl}/cities/GetCityList'),
        headers: userHeader
    ).catchError((resp) {
      print('initcities error $resp');
    });

    if (response == null) {
      return new ParsedResponse(noInterent, []);
    }

    //If there was an error return an empty list
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw(response.reasonPhrase);
    }

    Map map = jsonDecode('{ \"Cities\":' + response.body + '}');
    Cities networkCities = Cities.fromJson(map);

    // cache age
    prefs.setString('cache_time2', DateTime.now().toString());
    await database.updateCities(networkCities);
    logit('cache cities');

    return new ParsedResponse(response.statusCode, networkCities.cities);
  }

  Future settings() async {
    //get values from db
  // CJ overwrites hardcoded!!! -  await getSettingsFromDatabase();
    //get values from webservice
  // cj - test returning live vals
    await getSettingsFromApi();
    if(gblNoNetwork == true){
      await getSettingsFromApi();
    }
    //Save GobalSetting to DB
    //await database.saveAllSettings(gbl_settings);
    return true;
  }

  /*
  Future getSettingsFromDatabase() async {
    List<KeyPair> _settings;
    //Get settings from db
    _settings = await database.getAllSettings();
    //If has settings in db update, GobalSettings with these
    if (_settings.length > 0) {
      //update GobalSettings
      StringBuffer stringBuffer = new StringBuffer();
      stringBuffer.write('{');
      _settings.forEach((item) => stringBuffer
          .write('"${item.key.trim()}": "${item.value.toString().trim()}",'));
      stringBuffer.write('}');
      Map map = json.decode(stringBuffer.toString().replaceAll(',}', '}'));
      gblSettings = Settings.fromJson(map);
    }
  }
*/
  Future getSettingsFromApi() async {
    var body = {"AgentGuid": "${gblSettings.vrsGuid}"};
    Map<String, String>       headers = {
        'Content-Type': 'application/json',
        'Videcom_ApiKey': gblSettings.apiKey,
        '__SkyFkyTok': gblSettings.skyFlyToken,
        'VARS_SessionId': 'TestTest'};


    if( gblSettings.brandID != null && gblSettings.brandID.isNotEmpty) {
     // body["BrandId"] = "${gblSettings.brandID}";
       body = {"AgentGuid": "${gblSettings.vrsGuid}",
                "BrandId": "${gblSettings.brandID}"};
      if( gblLanguage!= null && gblLanguage.isNotEmpty && gblLanguage != 'en') {
        body = {"AgentGuid": "${gblSettings.vrsGuid}",
          "BrandId": "${gblSettings.brandID}",
          "AppFile": '$gblLanguage.json'};  // ${gblLanguage}
      }
    } else {
      if( gblLanguage!= null  && gblLanguage.isNotEmpty && gblLanguage != 'en') {
        body = {"AgentGuid": "${gblSettings.vrsGuid}",
          "AppFile": '$gblLanguage.json'};  // ${gblLanguage}
      }
    }


    try {
      logit('getSettingsFromApi - login');
      http.Response response ;

      if( gblSettings.useWebApiforVrs) {
        if( gblSession == null ) gblSession = new Session('0', '', '0');
        String msg =  json.encode(VrsApiRequest(gblSession, '', gblSettings.vrsGuid, appFile: '$gblLanguage.json', vrsGuid: gblSettings.vrsGuid, brandId: gblSettings.brandID)); // '{VrsApiRequest: ' + + '}' ;
        print('msg = ${msg}');

        response = await http.get(
            Uri.parse(gblSettings.xmlUrl.replaceFirst('PostVRSCommand?', '') + "Login?req=$msg"),
                headers: getXmlHeaders(),
             );

      } else {
        print('login_uri = ${gblSettings.apiUrl + "/login"}');
        print('login_headers = ${headers}');
        print('login_body = ${JsonEncoder().convert(body)}');
        response = await http.post(
            Uri.parse(gblSettings.apiUrl + "/login"),
            headers: headers,
            body: JsonEncoder().convert(body));
      }
      if (response.statusCode == 200) {
        String data = response.body;
        if( gblSettings.useWebApiforVrs) {
            data = data
                .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
                .replaceAll('<string xmlns="http://videcom.com/">', '')
                .replaceAll('</string>', '');

//            VrsApiResponse rs = VrsApiResponse.fromJson(map);
  //          data = rs.data;
        }

        Map map = json.decode(data);
        if ( map != null ) {
          String settingsString = map["mobileSettingsJson"];
          String langFileModifyString = map["appFileModifyTime"];
          gblSettings.skyFlyToken = map["skyFlyToken"];

          // get language file last modified
          if( langFileModifyString != null && langFileModifyString.isNotEmpty ){
            gblLangFileModTime = langFileModifyString;
          }

          if( gblSettings.useWebApiforVrs) {
            gblSession = Session(map['sessionId'], map['varsSessionId'], map['vrsServerNo'].toString());
            logit('Server IP ${map['serverIP']}');
          } else {
            gblSession = Session(map['sessionId'], map['varsSessionId'], map['vrsServerNo'].toString());
          }
          //

          List <dynamic> settingsJson;
          if (settingsString != null && settingsString.isNotEmpty) {
            settingsJson = json.decode(settingsString);
          }
          LoginResponse loginResponse = new LoginResponse.fromJson(map);
          if (loginResponse.isSuccessful) {
            String exactMatchVersioAction = '';
            String mainMatchVersioAction = '';
            //If has settings update GobalSettings with these
            // cj bad vals from server!

            // pick out the values we want from server
            // cj work in progress
            if (settingsJson != null) {
              for (var item in settingsJson) {
                String param =item['parameter'];
                switch (param.trim()) {
                  case 'creditCardProvider':
                    gblSettings.creditCardProvider = item['value'];
                    break;
                  case 'appLive':
                    gblIsLive = parseBool(item['value']);
                    break;
                  case 'Languages':
                    gblSettings.gblLanguages = item['value'];
                    break;
                  case 'currencies':
                    gblSettings.currencies = item['value'];
                    break;
                  case 'ServerFiles':
                    gblSettings.gblServerFiles = item['value'];
                    break;
                  case 'titles':
                    gblTitles = item['value'].split(',');
                    break;
                  case 'fqtvName':
                    gblSettings.fqtvName = item['value'];
                    logit('load FQTV name [${gblSettings.fqtvName}]');
                    break;
                  case 'latestBuildAndroid':
                    gblSettings.latestBuildAndroid = item['value'];
                    break;
                  case 'latestBuildiOS':
                    gblSettings.latestBuildiOS = item['value'];
                    break;
                  case 'reqUpdateMsg':
                    gblSettings.reqUpdateMsg = item['value'];
                    break;
                  case 'optUpdateMsg':
                    gblSettings.optUpdateMsg = item['value'];
                    break;
                  case 'FQTVpointsName':
                    gblSettings.fQTVpointsName = item['value'];
                    break;
                  case 'currency':
                    gblSettings.currency = item['value'];
                    break;
                  case 'covidText':
                    gblSettings.covidText = item['value'];
                    break;
                  case 'pageImageMap':
                    gblSettings.pageImageMap = item['value'];
                    break;
                  case 'productImageMap':
                    gblSettings.productImageMap = item['value'];
                    break;


                /*
                  BOOLS
                   */
                //case 'wantLoadingLogo':
                //gbl_settings.privacyPolicyUrl =item['value'];
                //break;
                  case 'disableBookings':
                    gblSettings.disableBookings = parseBool(item['value']);
                    break;

                  case 'InReview':
                    gblInReview = parseBool(item['value']);
                    break;
                  case 'wantDangerousGoods':
                    gblSettings.wantDangerousGoods = parseBool(item['value']);
                    break;

                  case 'wantYouthDOB':
                    gblSettings.passengerTypes.wantYouthDOB = parseBool(item['value']);
                    break;
                  case 'wantCityImages': // for back compatibility
                    gblSettings.wantPageImages = parseBool(item['value']);
                    break;
                  case 'wantPageImages': // was wantCityImages
                    gblSettings.wantPageImages = parseBool(item['value']);
                    break;
                  case 'wantProducts':
                    gblSettings.wantProducts = parseBool(item['value']);
                    break;
                  case 'wantCitySwap':
                    gblSettings.wantCitySwap = parseBool(item['value']);
                    break;
                  case 'wantNewPayment':
                    gblSettings.wantNewPayment =  parseBool(item['value']);
                    break;
                  case 'wantRefund':
                    gblSettings.wantRefund  = parseBool(item['value']);
                    break;
                  case 'wantMaterialControls':
                    gblSettings.wantMaterialControls = parseBool(item['value']);
                    break;
                  case 'wantProfileList':
                    gblSettings.wantProfileList = parseBool(item['value']);
                    break;
                  case 'wantRememberMe':
                    gblSettings.wantRememberMe = parseBool(item['value']);
                    break;
                  case 'wantHomeFQTVButton':
                    gblSettings.wantHomeFQTVButton = parseBool(item['value']);
                    print('wantHomeFQTVButton = ${gblSettings.wantHomeFQTVButton}');
                    break;
                  case 'want2Dbarcode':
                    gblSettings.want2Dbarcode = parseBool(item['value']);
                    break;
                  case 'wantMyAccount':
                    gblSettings.wantMyAccount = parseBool(item['value']);
                    break;
                  case 'wantFQTV2':
                    gblSettings.wantFQTV = parseBool(item['value']);
                    break;
                  case 'wantEnglishTranslation':
                    gblSettings.wantEnglishTranslation = parseBool(item['value']);
                    break;
                  case 'want24HourClock':
                    gblSettings.want24HourClock = parseBool(item['value']);
                    break;
                  case 'wantFQTVNumber':
                    gblSettings.wantFQTVNumber = parseBool(item['value']);
                    break;
                  case 'wantCurrencyPicker':
                    gblSettings.wantCurrencyPicker = parseBool(item['value']);
                    break;
                  case 'wantClassBandImages':
                    gblSettings.wantClassBandImages = parseBool(item['value']);
                    break;
                  case 'wantPushNoticications':
                    gblSettings.wantPushNoticications = parseBool(item['value']);
                    break;
                  case 'wantNotificationEdit':
                    gblSettings.wantNotificationEdit = parseBool(item['value']);
                    break;
                  case 'eVoucher':
                    gblSettings.eVoucher = parseBool(item['value']);
                    break;
                  case 'bpShowFastTrack':
                    gblSettings.bpShowFastTrack = parseBool(item['value']);
                    break;
                  case 'bpShowLoungeAccess':
                    gblSettings.bpShowLoungeAccess = parseBool(item['value']);
                    break;
                  case 'bpShowAddPassToWalletButton':
                    gblSettings.bpShowAddPassToWalletButton = parseBool(item['value']);
                    break;	
					
                  case 'HideFareRules':
                    gblSettings.hideFareRules = parseBool(item['value']);
                    break;

                  /* custom menu items

                   */
                  case 'customMenu1':
                    gblSettings.customMenu1 = item['value'];
                    break;
                  case 'customMenu2':
                    gblSettings.customMenu2 = item['value'];
                    break;
                  case 'customMenu3':
                    gblSettings.customMenu3 = item['value'];
                    break;

                /*
                  URLs
                   */

                  case 'backgroundImageUrl':
                    gblSettings.backgroundImageUrl = item['value'];
                    print(gblSettings.backgroundImageUrl);
                    break;
                  case 'adsTermsUrl':
                    gblSettings.adsTermsUrl = item['value'];
                    break;
                  case 'termsAndConditionsUrl':
                    gblSettings.termsAndConditionsUrl = item['value'];
                    break;
                  case 'faqUrl':
                    gblSettings.faqUrl = item['value'];
                    break;
                  case 'privacyPolicyUrl':
                    gblSettings.privacyPolicyUrl = item['value'];
                    break;
                  case 'specialAssistanceUrl':
                    gblSettings.specialAssistanceUrl = item['value'];
                    break;
                  case 'contactUsUrl':
                    gblSettings.contactUsUrl =  item['value'];
                    break;
                  case 'stopUrl':
                    gblSettings.stopUrl = item['value'];
                    break;
                  case 'stopTitle':
                    gblSettings.stopTitle =item['value'];
                    break;
                  case 'action':
                    gblAction = item['value'];
                    break;
                /*
                  EMAILS
                   */
                  case 'appFeedbackEmail':
                    gblSettings.appFeedbackEmail = item['value'];
                    break;
                  case 'groupsBookingsEmail':
                    gblSettings.groupsBookingsEmail = item['value'];
                    break;
                    /*
                    integers
                     */
                  case 'youthMaxAge':
                    gblSettings.passengerTypes.youthMaxAge = parseInt(item['value']);
                    break;
                  case 'youthMinAge':
                    gblSettings.passengerTypes.youthMinAge = parseInt(item['value']);
                    break;

                  case 'bookingLeadTime':
                    gblSettings.bookingLeadTime = parseInt(item['value']);
                    break;
                  case 'maxNumberOfPax':
                    gblSettings.maxNumberOfPax = parseInt(item['value']);
                    break;
                  case 'searchDateOut' :
                    gblSettings.searchDateOut = parseInt(item['value']);
                    break;

                  case 'searchDateBack':
                    gblSettings.searchDateBack = parseInt(item['value']);
                    break;


                  default:
                    String param = item['parameter'];
                    if (param.startsWith('appVersion')) {
                      String vers = param.replaceAll('appVersion_', '');
                      if (vers == gblVersion) {
                        exactMatchVersioAction =  item['value'].toString().toUpperCase();

                      } else if ( gblVersion.startsWith(vers)) {
                        mainMatchVersioAction =  item['value'].toString().toUpperCase();
                      }
                    } else {
                      if( gblVerbose == true ) {print('Parameter not found ${item["parameter"]}');}
                    }
                }
              }
            } else {
              print('settingsJson == null');
              log('[settings string]' + settingsString);
              log('[body]' + response.body);
            }
            if( gblVerbose == true ) {print('successful login');}

            if( exactMatchVersioAction.isNotEmpty) {
              gblAction = exactMatchVersioAction;

            } else if ( mainMatchVersioAction.isNotEmpty){
              gblAction =mainMatchVersioAction;
            }
          }
          else {
            logit('login failed');
            print(response.body);
            gblErrorTitle = 'Login';
            if ( map != null ) {
              gblError = map['errorMessage'] + ' :' + map['errorCode'];
            } else {
              gblError = response.body;
            }
            gblNoNetwork = true;
          }
        } else {
          logit('login - map null');
          print(response.body);
          gblErrorTitle = 'Login:';
          gblError = response.body;
          gblNoNetwork = true;

        }
      } else {
        logit('login - status=${response.statusCode}');
        gblErrorTitle = 'Login-';
        gblError = response.statusCode.toString();
      }
    } catch (e) {
      logit('login - catch error');
      print(e);
      gblErrorTitle = 'Login-';
      gblError = e.toString();
      gblNoNetwork = true;
      //rethrow;
    }
  }

  bool parseBool( String str ){
    if( str == null ) {
      return false;
    }
    if( str.isEmpty) {
      return false;
    }
    if( str == '-1') {
      return true;
    }
    return (str.toLowerCase() == 'true');
  }

  int parseInt( String str ){
    if( str == null ) {
      return 0;
    }
    if( str.isEmpty) {
      return 0;
    }
    return int.parse(str);
  }
  /// Fetches the list of cities from the VRS XML Api with the query parameter being input.
  Future<ParsedResponse<List<City>>> getCities() async {
    //http request, catching error like no internet connection.
    //If no internet is available for example response is
    logit('get cities ${gblSettings.apiUrl}/cities/GetCityList');
    http.Response response = await http
        .get(
            //"${gbl_settings.xmlUrl}${gbl_settings.xmlToken}&command=ssrpmacitylist")
            Uri.parse(
                '${gblSettings.apiUrl}/cities/GetCityList'),
      headers: getApiHeaders(),)
        .catchError((resp) {});

    if (response == null) {
      return new ParsedResponse(noInterent, []);
    }

    //If there was an error return an empty list
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return new ParsedResponse(response.statusCode, []);
    }

    List<dynamic> list = jsonDecode(response.body
        .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
        .replaceAll('<string xmlns="http://videcom.com/">', '')
        .replaceAll('</string>', ''))['xml']['rs:data']['z:row'];

    Map<String, City> networkCities = {};

    for (dynamic jsonCity in list) {
      City city = parseNetworkCity(jsonCity);
      networkCities[city.code] = city;
    }

    //Adds information (if available) from database
    List<City> databaseCities =
        await database.getCities([]..addAll(networkCities.keys));
    for (City city in databaseCities) {
      networkCities[city.code] = city;
    }

    return new ParsedResponse(
        response.statusCode, []..addAll(networkCities.values));
  }

  City parseNetworkCity(jsonCity) {
    return new City(
      code: jsonCity["code"],
      name: jsonCity["name"],
      shortName: jsonCity["shortName"],
      mobileBarcodeType: jsonCity["mobileBarcodeType"],
      webCheckinEnabled: jsonCity["webCheckinEnabled"] == "True" ? 1 : 0,
      webCheckinStart: int.parse(jsonCity["webCheckinStart"]),
      webCheckinEnd: int.parse(jsonCity["webCheckinEnd"]),
    );
  }

  Future updateCity(City city) async {
    await database.updateCity(city);
  }

  Future updateCities(Cities cities) async {
    await database.updateCities(cities);
  }

  Future close() async {
    return database.close();
  }

  Future<List<City>> getAllCities() {
    return database.getAllCities();
  }

  Future<List<NotificationMessage>> getAllNotifications() {
    return database.getAllNotifications();
  }

  Future updateNotification(RemoteMessage msg, bool background) async {
    try{
      print('saving push msg');
      final Map<String, dynamic> notifyMap = new Map<String, dynamic>();
      final Map<String, dynamic> msgMap = new Map<String, dynamic>();

      if( msg.notification != null ) {
        notifyMap['body'] = msg.notification.body;
        notifyMap['title'] = msg.notification.title;
        String sNot = jsonEncode(notifyMap);
        msgMap['notification'] = sNot;
      }

      final Map<String, dynamic> dataMap = new Map<String, dynamic>();
      dataMap['rloc'] = msg.data['rloc'];
      dataMap['format'] = msg.data['format'];
      dataMap['html'] = msg.data['html'];

      String sData = jsonEncode(dataMap);

      msgMap['category'] = msg.category;
      msgMap['background'] = background.toString();
      if( msg.sentTime.toString() != 'null') {
        msgMap['sentTime'] = msg.sentTime.toString();
      } else {
        msgMap['sentTime'] = DateTime.now().toString();
      }
      msgMap['data'] = sData;

      String sMsg = jsonEncode(msgMap);
    await database.updateNotification(sMsg.replaceAll('"', '|'), msgMap['sentTime']);
    } catch(e) {
      String m = e.toString();
      print(m);
    }
  }

  Future deleteNotifications() {
    return database.deleteNotifications();
  }
  Future deleteNotification(String sTime) {
    return database.deleteNotification(sTime);
  }


  Future<City> getCityByCode(String code) {
    return database.getCityByCode(code);
  }

  //BoardingPass
  Future<BoardingPass> getBoardingPass(String fltno, String rloc, int paxno) {
    return database.getBoardingPass(fltno, rloc, paxno);
  }

  Future<bool> hasDownloadedBoardingPass(String fltno, String rloc, int paxno) {
    return database.hasDownloadedBoardingPass(fltno, rloc, paxno);
  }

  Future<List<BoardingPass>> getBoardingPasses(String fltno, String rloc) {
    return database.getBoardingPasses(fltno, rloc);
  }

  Future updateBoardingPass(BoardingPass boardingPass) async {
    await database.updateBoardingPass(boardingPass);
  }

  Future<BoardingPass> getVRSMobileBP(String cmd) async {
    //await database.updateBoardingPass(boardingPass);
   /* http.Response response = await http
        .get(Uri.parse(
            "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$cmd"))
        .catchError((resp) {});

    if (response == null) {
      //return new ParsedResponse(NO_INTERNET, []);
    }

    //If there was an error return an empty list
    if (response.statusCode < 200 || response.statusCode >= 300) {
      // return new ParsedResponse(response.statusCode, []);
    }

    String pnrJson;

    pnrJson = response.body
        .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
        .replaceAll('<string xmlns="http://videcom.com/">', '')
        .replaceAll('</string>', '');*/

    String data = await runVrsCommand(cmd);
    String pnrJson;
    pnrJson = data
        .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
        .replaceAll('<string xmlns="http://videcom.com/">', '')
        .replaceAll('</string>', '');

    Map map = json.decode(pnrJson);
    print('Fetch BPP');
    var months = [
      "",
      "JAN",
      "FEB",
      "MAR",
      "APR",
      "MAY",
      "JUN",
      "JUL",
      "AUG",
      "SEP",
      "OCT",
      "NOV",
      "DEC"
    ];
    print(months.indexOf("SEP"));
    VrsBoardingPass vrsBoardingPass = new VrsBoardingPass.fromJson(map);
    DateTime flightdate = DateTime.parse(vrsBoardingPass
            .mobileboardingpass.flightdate
            .toString()
            .substring(5, 9) +
        '-' +
        months
            .indexOf(vrsBoardingPass.mobileboardingpass.flightdate
                .toString()
                .substring(2, 5)
                .toUpperCase())
            .toString()
            .padLeft(2, "0") +
        '-' +
        vrsBoardingPass.mobileboardingpass.flightdate
            .toString()
            .substring(0, 2));
    BoardingPass boardingPass = new BoardingPass(
      rloc: vrsBoardingPass.mobileboardingpass.rloc,
      fltno: vrsBoardingPass.mobileboardingpass.flight,
      depart: vrsBoardingPass.mobileboardingpass.departcitycode,
      arrive: vrsBoardingPass.mobileboardingpass.arrivecitycode,
      depdate: flightdate,
      // boarding: vrsBoardingPass.mobileboardingpass.boardtime,
      // depa
      paxname: vrsBoardingPass.mobileboardingpass.passengername,
      paxno: int.parse(cmd[34]) - 1,
      barcodedata: vrsBoardingPass.mobileboardingpass.barcode,
      seat: vrsBoardingPass.mobileboardingpass.seat,
      gate: null,
      classBand: vrsBoardingPass.mobileboardingpass.classband,
    );

    await database.updateBoardingPass(boardingPass);

    return boardingPass;
  }

  //Pnrs
  Future<List<PnrDBCopy>> getAllPNRs() {
    return database.getAllPNRs();
  }

  Future updatePnr(PnrDBCopy pnrDBCopy) async {
    await database.updatePnr(pnrDBCopy);
  }

  Future<PnrDBCopy> getPnr(String rloc) {
    return database.getPnr(rloc);
  }

  Future<PnrDBCopy> fetchPnr2(String rloc) async {


    sendXmlMsg( new XmlRequest(command: '*$rloc~x')).then((xmlResponse) {
      if (xmlResponse.success) {
        print('Fetch PNR OK');
        PnrModel pnrModel = new PnrModel.fromJson(xmlResponse.map);

        PnrDBCopy pnrDBCopy = new PnrDBCopy(
            rloc: pnrModel.pNR.rLOC, //_rloc,
            data: xmlResponse.data,
            delete: 0,
            success: true,
            nextFlightSinceEpoch: pnrModel.getnextFlightEpoch());
        Repository.get().updatePnr(pnrDBCopy);

        return pnrDBCopy;
      } else {
        PnrDBCopy pnrDBCopy = new PnrDBCopy( rloc: rloc, success: false, delete: 0, data: '');
        print('Fetch PNR ERROR');
        return pnrDBCopy;
      }
    });
    return null;
  }



    Future<PnrDBCopy> fetchPnr(String rloc) async {


 /*   http.Response response = await http
        .get(Uri.parse(
            "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=*$rloc~x"))
        .catchError((resp) {});

    if (response == null) {
      //return new ParsedResponse(NO_INTERNET, []);
    }

    //If there was an error return an empty list
    if (response.statusCode < 200 || response.statusCode >= 300) {
      // return new ParsedResponse(response.statusCode, []);
    }

    String pnrJson;

    pnrJson = response.body
        .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
        .replaceAll('<string xmlns="http://videcom.com/">', '')
        .replaceAll('</string>', '');
*/
      String data = await runVrsCommand('*$rloc~x');
      String pnrJson;

      pnrJson = data
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', '');
    Map map = json.decode(pnrJson);
    print('Fetch PNR');
    PnrModel pnrModel = new PnrModel.fromJson(map);

    PnrDBCopy pnrDBCopy = new PnrDBCopy(
        rloc: pnrModel.pNR.rLOC, //_rloc,
        data: pnrJson,
        success: true,
        delete: 0,
        nextFlightSinceEpoch: pnrModel.getnextFlightEpoch());
    Repository.get().updatePnr(pnrDBCopy);

    return pnrDBCopy;
  }

  Future deletePnr(String rloc) async {
    await database.deletePnr(rloc);
  }
  Future deleteApisPnr(String rloc) async {
    await database.deletePnrApis(rloc);
  }

  //Apis status
  Future updatePnrApisStatus(DatabaseRecord apisPnr) async {
    await database.updatePnrApisStatus(apisPnr);
  }

  Future<DatabaseRecord> getPnrApisStatus(String rloc) {
    return database.getPnrApisStatus(rloc);
  }

  Future<DatabaseRecord> fetchApisStatus(String rloc) async {

 /*
    http.Response response = await http
        .get(Uri.parse(
            "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=DSP/$rloc'"))
        .catchError((resp) {});

    if (response == null) {
      //return new ParsedResponse(NO_INTERNET, []);
    }

    //If there was an error return an empty list
    if (response.statusCode < 200 || response.statusCode >= 300) {
      // return new ParsedResponse(response.statusCode, []);
    }*/

    String data = await runVrsCommand('DSP/$rloc');
    String apisStatusJson;

    apisStatusJson = data
        .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
        .replaceAll('<string xmlns="http://videcom.com/">', '')
        .replaceAll('</string>', '')
        .replaceAll('<string xmlns="http://videcom.com/" />', '');
    if (apisStatusJson.trim() != '') {
      Map map = json.decode(apisStatusJson);
      print('Loaded APIS status');
      ApisPnrStatusModel apisPnrStatus = new ApisPnrStatusModel.fromJson(map);

      DatabaseRecord databaseRecord = new DatabaseRecord(
          rloc: apisPnrStatus.xml.pnrApis.pnr, //_rloc,
          data: apisStatusJson,
          delete: 0);
      Repository.get().updatePnrApisStatus(databaseRecord);
      return databaseRecord;
    }
    return null;
  }

  //UserProfile status
  Future updateUserProfile(List<UserProfileRecord> userProfileRecord) async {
    await database.updateUserProfile(userProfileRecord);
  }

  Future<List<UserProfileRecord>> getUserProfile() {
    return database.getUserProfile();
  }
  Future<UserProfileRecord> getNamedUserProfile(String name) {
    return database.getNamedUserProfile(name);
  }

  Future <String> deleteUserProfile(String name) {
    return database.deleteUserProfile(name);
  }
  Future<ADS> getADSDetails() {
    return database.getADSDetails();
  }

  Future<ParsedResponse<List<String>>> getFareRules(String fareIds) async {
    //http request, catching error like no internet connection.
    //If no internet is available for example response is
    var body = {"IDs": "$fareIds"};
    final http.Response response = await http
        .post(
            Uri.parse(
                '${gblSettings.apiUrl}/fare/GetFareRules'),
            headers: getApiHeaders(),
            body: JsonEncoder().convert(body))
        .catchError((resp) {});

    if (response == null) {
      return new ParsedResponse(noInterent, null);
    }

    if (response.statusCode == 200) {
      Map map = jsonDecode('{ \"FareRules\":' + response.body + '}');

      List<String> rules = [];
      // List<String>();
      map['FareRules'].forEach((v) => rules.add(v));

      return new ParsedResponse(response.statusCode, rules);
    }
    return new ParsedResponse(response.statusCode, null);
  }


  Future<ParsedResponse<AvailabilityModel>> getAv(String avCmd) async {
    AvailabilityModel objAv = AvailabilityModel();
    if(gblSettings.useWebApiforVrs) {
      String data = await runVrsCommand(avCmd);
      Map map    = jsonDecode(data
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', ''));

      objAv = new AvailabilityModel.fromJson(map);
      return new ParsedResponse(200, objAv);
    } else {
      String msg = json.encode(RunVRSCommand(gblSession, avCmd));

      final http.Response response = await http.post(
          Uri.parse(gblSettings.apiUrl + "/RunVRSCommand"),
          headers: getApiHeaders(),
          body: msg);

/*
    http.Response response = await http
        .get(Uri.parse(
            "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$avCmd"))
        .catchError((resp) {});
*/
      if (response == null) {
        return new ParsedResponse(noInterent, null);
      }

      //If there was an error return null
      if (response.statusCode < 200 || response.statusCode >= 300) {
        logit('Availability error: ' + response.statusCode.toString() + ' ' +
            response.reasonPhrase);
        return new ParsedResponse(response.statusCode, null);
      }

      if (response.body.contains('NotSinedInException')) {
        return new ParsedResponse(notSinedIn, null);
      }


      if (response.body.contains('<string xmlns="http://videcom.com/">Error')) {
        return new ParsedResponse(noFlights, null);
      }
      if (response.body.contains('ERROR')) {
        return new ParsedResponse(0, null, error: response.body);
      }
      if (!response.body.contains('<string xmlns="http://videcom.com/" />')) {
        Map map    = jsonDecode(response.body
            .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
            .replaceAll('<string xmlns="http://videcom.com/">', '')
            .replaceAll('</string>', ''));

        objAv = new AvailabilityModel.fromJson(map);
      }
      return new ParsedResponse(response.statusCode, objAv);
    }
  }

  Future<ParsedResponse<PnrModel>> getFareQuote(String cmd) async {
    PnrModel pnrModel = PnrModel();
    if( gblSettings.useWebApiforVrs) {
      String data = await runVrsCommand(cmd);
      if (!data.contains('<string xmlns="http://videcom.com/" />')) {
        Map map = jsonDecode(data
            .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
            .replaceAll('<string xmlns="http://videcom.com/">', '')
            .replaceAll('</string>', ''));

        pnrModel = new PnrModel.fromJson(map);
      }
      return new ParsedResponse(200, pnrModel);
    } else {
        http.Response response = await http
        .get(Uri.parse(
            "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$cmd"),
            headers: getXmlHeaders())
        .catchError((resp) {

          return new ParsedResponse(0, null, error: resp);
        });
      if (response == null) {
        return new ParsedResponse(noInterent, null);
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return new ParsedResponse(response.statusCode, null);
      }
      if( response.body.toUpperCase().contains('ERROR' )){
        String er = response.body.replaceAll('<?xml version=\"1.0\" encoding=\"utf-8\"?>', '')
          .replaceAll('<string xmlns=\"http://videcom.com/\">', '')
            .replaceAll('</string>', '');
        return new ParsedResponse(0, null, error: er);
      }

      if (!response.body.contains('<string xmlns="http://videcom.com/" />')) {
        Map map = jsonDecode(response.body
            .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
            .replaceAll('<string xmlns="http://videcom.com/">', '')
            .replaceAll('\r\n', '')
            .replaceAll('</string>', ''));

        pnrModel = new PnrModel.fromJson(map);
      }
      return new ParsedResponse(response.statusCode, pnrModel);
    }
  }

  Future<ParsedResponse<Seatplan>> getSeatPlan(String seatPlanCmd) async {
    Seatplan seatplan = Seatplan();

    try {

    String data = await runVrsCommand(seatPlanCmd);
 /*   http.Response response = await http
        .get(Uri.parse(
            "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$seatPlanCmd"))
        .catchError((resp) {});
    if (response == null) {
      return new ParsedResponse(noInterent, null);
    }

    //If there was an error return null
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return new ParsedResponse(response.statusCode, null);
    }
   if (!response.body.contains('<string xmlns="http://videcom.com/" />')) {
      Map map = jsonDecode(response.body
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', ''));

      seatplan = new Seatplan.fromJson(map);
    }    */
    if (!data.contains('<string xmlns="http://videcom.com/" />')) {
      Map map = jsonDecode(data
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', ''));

      seatplan = new Seatplan.fromJson(map);
    }
    return new ParsedResponse(200, seatplan);
    } catch (e) {
      return new ParsedResponse(0, seatplan, error: e.toString());
    }

  }

  Future<ParsedResponse<RoutesModel>> initRoutes() async {
    //http request, catching error like no internet connection.
    //If no internet is available for example response is
    var prefs = await SharedPreferences.getInstance();
    logit('initRoutes');
    var cacheTime = prefs.getString('route_cache_time2');
    if( cacheTime!= null && cacheTime.isNotEmpty && gblUseCache){
      var cached = DateTime.parse(cacheTime);

      if( cached.isAfter(DateTime.now().subtract(Duration(days: 2)))) {
        // change to 2 days!
        logit('route cache good');
        return null;
      }
    }
    final http.Response response = await http.get(
        Uri.parse(
            '${gblSettings.apiUrl}/cities/Getroutelist'),
        headers: getApiHeaders()).catchError((resp) {});

    if (response == null) {
      return new ParsedResponse(noInterent, null);
    }

    //If there was an error return an empty list
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return new ParsedResponse(response.statusCode, null);
    }
    Map map = jsonDecode('{ \"Routes\":' + response.body + '}');
    prefs.setString('route_cache_time2', DateTime.now().toString());

    RoutesModel networkRoutes = RoutesModel.fromJson(map);
    await database.updateRoutes('{ \"Routes\":' + response.body + '}');
    return new ParsedResponse(response.statusCode, networkRoutes);
  }

  Future <List<String>> getAllDepartures() async {
    if (gblVerbose) {print('start getRoutesData');}
    List<String> departureCities = [];
    // new List<String>();
    try {


    database.getRoutesData().then((valueMap) {
      if (gblVerbose) {print('getRoutesData');}
      valueMap['Routes'].forEach((item) {
        departureCities.add(item.values.first['airportCode'] +
            "|" +
            item.values.first['airportName'] +
            " (" +
            item.values.first['airportCode'] +
            ")");
      });
      if( departureCities.length==0){
        print("No departures");
      }
      if (gblVerbose) {print("routes len ${departureCities.length}");}
      return departureCities;
    });
    return departureCities;
    } catch (e) {
      print(e);
      return null;
    }
  }

  Future <List<String>> getDestinations(String departure) async {
    List<String> destinationCities = [];
    // new List<String>();
    if (gblVerbose) {print('getDestinations');}

    database.getRoutesData().then((valueMap) {
      valueMap['Routes'].forEach((f) {
       // print(f['departure']['airportCode']);
        if (f['departure']['airportCode'] == departure) {
          f['destinations'].forEach((dest) {
            String newDest = dest['airportCode'] +
                "|" +
                dest['airportName'] +
                " (" +
                dest['airportCode'] +
                ")";
            if( ! destinationCities.contains(newDest)){
              destinationCities.add(newDest);
            }
          });
        }
      });
      if( destinationCities.length==0){
        print("No destinations");
        print("routes len" + valueMap['Routes'].length);
      }
      return destinationCities;
    });
    return destinationCities;
  }
}

class FareRules {
  List<FareRule> fareRule;

  FareRules({this.fareRule});

  FareRules.fromJson(Map<String, dynamic> json) {
    if (json['FareRules'] != null) {
      fareRule = [];
      // new List<FareRule>();
      if (json['FareRules'] is List) {
        json['FareRules'].forEach((v) {
          fareRule.add(new FareRule.fromJson(v));
        });
      } else {
        fareRule.add(new FareRule.fromJson(json['FareRules']));
      }
    } else {
      fareRule = null;
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.fareRule != null) {
      data['z:row'] = this.fareRule.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FareRule {
  String rule;

  FareRule({this.rule});

  FareRule.fromJson(Map<String, dynamic> json) {
    rule = json['FareRule'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FareRule'] = this.rule;
    return data;
  }
}



Future<String> runFunctionCommand(String function,String cmd) async {
  String msg =  json.encode(VrsApiRequest(gblSession, cmd,
      gblSettings.xmlToken.replaceFirst('token=', ''),
      vrsGuid: gblSettings.vrsGuid,
      notifyToken: gblNotifyToken,
      rloc: gblCurrentRloc,
      phoneId: gblDeviceId
  )); // '{VrsApiRequest: ' + + '}' ;

  http.Response response = await http
      .get(Uri.parse(
      "${gblSettings.xmlUrl.replaceFirst('PostVRSCommand?', function)}?VarsSessionID=${gblSession.varsSessionId}&req=$msg"),
      headers: getXmlHeaders())
      .catchError((resp) {
    logit(resp);
  });
  if (response == null) {
    throw 'No Internet';
    //return new ParsedResponse(noInterent, null);
  }

  //If there was an error return null
  if (response.statusCode < 200 || response.statusCode >= 300) {
    logit('runFunctionCommand ($cmd): ' + response.statusCode.toString() + ' ' + response.reasonPhrase);
    throw 'runFunctionCommand: ' + response.statusCode.toString() + ' ' + response.reasonPhrase;
    //return new ParsedResponse(response.statusCode, null);
  }

  if (response.body.contains('<string xmlns="http://videcom.com/">Error')) {
    String er = response.body.replaceAll('<string xmlns="http://videcom.com/">' , '');
    throw er;

  }
  if (response.body.contains('ERROR')) {
    Map map = jsonDecode(response.body
        .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
        .replaceAll('<string xmlns="http://videcom.com/">', '')
        .replaceAll('</string>', ''));
    throw map["errorMsg"];
    //return new ParsedResponse(0, null, error: response.body);
  }

  //String jsn = response.body;
  Map map = jsonDecode(response.body
      .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
      .replaceAll('<string xmlns="http://videcom.com/">', '')
      .replaceAll('</string>', ''));

  VrsApiResponse rs = VrsApiResponse.fromJson(map);
  gblSession = Session(map['sessionId'], map['varsSessionId'], map['vrsServerNo'].toString());
  logit('Server IP ${map['serverIP']}');
  if( rs.data == null ) {
    throw 'no data returned';
  }
  return rs.data;
}




Future<String> callSmartApi(String action, String data) async {
    String msg =  json.encode(VrsApiRequest(gblSession, action,
        gblSettings.xmlToken.replaceFirst('token=', ''),
        vrsGuid: gblSettings.vrsGuid,
        data: data,
        notifyToken: gblNotifyToken,
        rloc: gblCurrentRloc,
        phoneId: gblDeviceId
    )); // '{VrsApiRequest: ' + + '}' ;

    print('callSmartApi::${gblSettings.smartApiUrl}?VarsSessionID=${gblSession.varsSessionId}&req=$msg');

    http.Response response = await http
        .get(Uri.parse(
        "${gblSettings.smartApiUrl}?VarsSessionID=${gblSession.varsSessionId}&req=$msg"))
        .catchError((resp) {
          logit(resp);
    });
    if (response == null) {
      throw 'No Internet';
      //return new ParsedResponse(noInterent, null);
    }

    //If there was an error return null
    if (response.statusCode < 200 || response.statusCode >= 300) {
      logit('callSmartApi (): ' + response.statusCode.toString() + ' ' + response.reasonPhrase);
      throw 'callSmartApi: ' + response.statusCode.toString() + ' ' + response.reasonPhrase;
      //return new ParsedResponse(response.statusCode, null);
    }

    print('callSmartApi_response::${response.body}');

    if (response.body.contains('<string xmlns="http://videcom.com/">Error')) {
      String er = response.body.replaceAll('<string xmlns="http://videcom.com/">' , '');
      throw er;

    }

    String responseData = response.body
        .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
        .replaceAll('<string xmlns="http://videcom.com/">', '')
        .replaceAll('</string>', '');

    Map map = jsonDecode(responseData);

   // gblSession = Session(map['sessionId'], map['varsSessionId'], map['vrsServerNo'].toString());
    if (response.body.contains('ERROR')) {

      throw map["errorMsg"];
      //return new ParsedResponse(0, null, error: response.body);
    }

    //String jsn = response.body;

    VrsApiResponse rs = VrsApiResponse.fromJson(map);
   // gblSession = Session(map['sessionId'], map['varsSessionId'], map['vrsServerNo'].toString());
    logit('Server IP ${map['serverIP']}');
    if( rs.data == null ) {
      throw 'no data returned';
    }
    return rs.data;
}


Future<String> runVrsCommand(String cmd) async {
  if( gblSettings.useWebApiforVrs) {

    String msg =  json.encode(VrsApiRequest(gblSession, cmd,
        gblSettings.xmlToken.replaceFirst('token=', ''),
        vrsGuid: gblSettings.vrsGuid,
        notifyToken: gblNotifyToken,
        rloc: gblCurrentRloc,
        phoneId: gblDeviceId
     )); // '{VrsApiRequest: ' + + '}' ;

    http.Response response = await http
        .get(Uri.parse(
        "${gblSettings.xmlUrl.replaceFirst('?', '')}?VarsSessionID=${gblSession.varsSessionId}&req=$msg"),
          headers: getXmlHeaders())
        .catchError((resp) {
/*
      var error = '';
*/
    });

    if (response == null) {
      throw 'No Internet';
      //return new ParsedResponse(noInterent, null);
    }

    //If there was an error return null
    if (response.statusCode < 200 || response.statusCode >= 300) {
      logit('runFunctionCommand ($cmd): ' + response.statusCode.toString() + ' ' + response.reasonPhrase);
      throw 'runFunctionCommand: ' + response.statusCode.toString() + ' ' + response.reasonPhrase;
      //return new ParsedResponse(response.statusCode, null);
    }


    if (response.body.contains('<string xmlns="http://videcom.com/">Error')) {
      String er = response.body.replaceAll('<string xmlns="http://videcom.com/">' , '');
      throw er;
      //return new ParsedResponse(noFlights, null);
    }
    if (response.body.contains('ERROR')) {
      Map map = jsonDecode(response.body
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', ''));
      if( map["errorMsg"] != null ) {
        throw map["errorMsg"];
      }
      if( map["data"] != null ) {
        throw map["data"];
      }
      throw "Error returned from server";
    }

    //String jsn = response.body;
    Map map = jsonDecode(response.body
        .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
        .replaceAll('<string xmlns="http://videcom.com/">', '')
        .replaceAll('</string>', ''));

    VrsApiResponse rs = VrsApiResponse.fromJson(map);
    gblSession = Session(map['sessionId'], map['varsSessionId'], map['vrsServerNo'].toString());
    logit('Server IP ${map['serverIP']}');
    if( rs.data == null ) {
      throw 'no data returned';
    }
    return rs.data;
  } else {
    String url = "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$cmd";
    if( gblSettings.wantPushNoticications) {
      url += "&notToken=$gblNotifyToken&phone=$gblDeviceId&rloc=$gblCurrentRloc";
    }


      http.Response response = await http
        .get(Uri.parse(url
        ),
        headers: getXmlHeaders())
        .catchError((resp) {

    });
    if( response == null )
      {
        throw 'no data returned';
      }
    return response.body;
  }


}
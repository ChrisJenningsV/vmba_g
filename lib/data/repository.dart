import 'dart:io';
import 'dart:async' show Future;
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:vmba/data/database.dart';
import 'package:http/http.dart' as http;
import 'package:vmba/data/models/routes.dart';
import 'package:vmba/data/settings.dart';
import 'package:vmba/data/xmlApi.dart';
import '../Helpers/networkHelper.dart';
import '../calendar/bookingFunctions.dart';
import '../main.dart';
import '../utilities/messagePages.dart';
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
  ParsedResponse(this.statusCode, this.body, {this.error=''});
  final int statusCode;
  final T? body;
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

  late AppDatabase database;

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
      if (profile != null && profile.value != '') {

        try {
          Map<String, dynamic> map = json.decode(
              profile.value.toString().replaceAll(
                  "'", '"')); // .replaceAll(',}', '}')
            gblPassengerDetail = PassengerDetail.fromJson(map);

            if( gblPassengerDetail!= null &&
                gblPassengerDetail!.fqtv != null && gblPassengerDetail!.fqtv.isNotEmpty &&
                gblPassengerDetail!.fqtvPassword != null && gblPassengerDetail!.fqtvPassword.isNotEmpty){
              // get balance
            }
        } catch (e) {
          print(e);
        }
      }
    });
  }


  /// Fetches the list of cities from the VRS XML Api with the query parameter being input.
  Future<ParsedResponse<List<City>>?> initCities() async {
    var prefs = await SharedPreferences.getInstance();
    if(gblLogCities) {logit('initCities');}
    var cacheTime = prefs.getString('cache_time2');
    if( cacheTime!= null && cacheTime.isNotEmpty && gblUseCache){
      var cached = DateTime.parse(cacheTime);

      if( cached.isAfter(DateTime.now().subtract(Duration(days: 2)))) {
        // change to 2 days!
        if(gblLogCities) {logit('city cache good');}

        Repository.get().getAllCities().then((cities) {
          gblAirportCache = Map <String,String>();
          cities.forEach((element) {
            gblAirportCache![element.code] = element.name;
          });

        });


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
      print('GetCityList error ${response.reasonPhrase}');
      throw(response.reasonPhrase as String );
    }

    Map<String, dynamic> map = jsonDecode('{ \"Cities\":' + response.body + '}');
    Cities networkCities = Cities.fromJson(map);

    networkCities.cities!.forEach((c) {
      if( c.code == '####') {
        apiBuldVersion = int.parse(c.shortName) ;
        //networkCities.cities.remove(c);
      }
    });
    // cache age
    prefs.setString('cache_time2', DateTime.now().toString());
    await database.updateCities(networkCities);
    gblAirportCache = Map <String,String>();
    networkCities.cities!.forEach((element) {
      gblAirportCache![element.code] = element.name;
    });

    logit('cache cities');

    logit('webAPI version $apiBuldVersion');
    if( gblDoVersionCheck && (apiBuldVersion== null ||  apiBuldVersion < requiredApiVersion )){
      gblError = 'WebApi needs upgrade';
      criticalErrorPage(NavigationService.navigatorKey.currentContext!,'WebApi needs upgrade',title: 'Login', wantButtons: false);
      //throw('WebApi needs upgrade');
    }


    return new ParsedResponse(response.statusCode, networkCities.cities as List<City>);
  }

  Future settings() async {
    //get values from db
  // CJ overwrites hardcoded!!! -  await getSettingsFromDatabase();
    //get values from webservice
  // cj - test returning live vals
    gblLoginSuccessful = true;
    await getSettingsFromApi();
  /*  if(gblNoNetwork == true){
      await getSettingsFromApi();
    }*/
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
    gblLoginSuccessful = true;
    Map<String, String>       headers = {
        'Content-Type': 'application/json',
        'Videcom_ApiKey': gblSettings.apiKey,
        '__SkyFlyTok_V1': gblSettings.skyFlyToken,
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
        String msg =  json.encode(VrsApiRequest(gblSession as Session, '', gblSettings.vrsGuid, appFile: '$gblLanguage.json',
            vrsGuid: gblSettings.vrsGuid, brandId: gblSettings.brandID, appVersion: gblVersion)); // '{VrsApiRequest: ' + + '}' ;
        print('msg = $msg');
        print('login_uri = ${gblSettings.xmlUrl}');

        response = await http.get(
            Uri.parse(gblSettings.xmlUrl.replaceFirst('PostVRSCommand?', '') + "Login?req=$msg"),
                headers: getXmlHeaders(),
             );

      } else {
        print('login_uri = ${gblSettings.apiUrl + "/login"}');
        print('login_headers = $headers');
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

        Map<String, dynamic> map = json.decode(data);
        if ( map != null && map['isSuccessful']  == true) {
          String settingsString = map["mobileSettingsJson"];
          String langFileModifyString = map["appFileModifyTime"];
          String xmlVersion = map["version"];
          if(map["skyFlyToken"] != null )          gblSettings.skyFlyToken = map["skyFlyToken"];

          // get language file last modified
          if( langFileModifyString != null && langFileModifyString.isNotEmpty ){
            gblLangFileModTime = langFileModifyString;
          }

          if( gblSettings.useWebApiforVrs) {
            gblSession = Session(map['sessionId'], map['varsSessionId'], map['vrsServerNo'].toString());
            logit('gs Server IP ${map['serverIP']}');
          } else {
            gblSession = Session(map['sessionId'], map['varsSessionId'], map['vrsServerNo'].toString());
          }
          //

          List <dynamic>? settingsJson;
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
                  case 'updateMessage':
                    gblSettings.updateMessage = item['value'];
                    break;
                  case 'latestBuildAndroid':
                    if( !item['value'].toString().contains('.')) {
                      gblSettings.latestBuildAndroid = item['value'];
                      if (gblVersion.isNotEmpty && gblVersion != "") {
                        if (int.parse(gblSettings.latestBuildAndroid) >
                            int.parse(gblVersion.split('.')[3])) {
                          if (!gblIsIos && gblAction != "STOP") {
                            gblAction = "UPDATE";
                          }
                        }
                      }
                    }
                    break;
                  case 'latestBuildiOS':
                    if( !item['value'].toString().contains('.')) {
                      gblSettings.latestBuildiOS = item['value'];
                      if (gblVersion.isNotEmpty && gblVersion != "") {
                        if (int.parse(gblSettings.latestBuildiOS) >
                            int.parse(gblVersion.split('.')[3])) {
                          if (gblIsIos && gblAction != "STOP") {
                            gblAction = "UPDATE";
                          }
                        }
                      }
                    }
                    break;
                  case 'lowestValidBuildAndroid':
                    gblSettings.lowestValidBuildAndroid = item['value'];
                    // check that this build is valid
                    if( gblVersion.isNotEmpty && gblVersion != "" ){
                      if( int.parse(gblSettings.lowestValidBuildAndroid) > int.parse(gblVersion.split('.')[3])) {
                        if( !gblIsIos) {
                          gblAction = "STOP";
                        }
                      }
                    }
                    break;
                  case 'lowestValidBuildiOS':
                    gblSettings.lowestValidBuildiOS = item['value'];
                    if( gblVersion.isNotEmpty && gblVersion != "" ){
                      if( int.parse(gblSettings.lowestValidBuildiOS) != int.parse(gblVersion.split('.')[3])) {
                        if( gblIsIos) {
                          gblAction = "STOP";
                        }
                      }
                    }
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
                  case 'payImageMap':
                    if( gblSettings.paySettings == null  ){
                      gblSettings.paySettings = PaySettings();
                    }
                    gblSettings.paySettings!.payImageMap = item['value'];
                    break;

                  case 'productImageMap':
                    gblSettings.productImageMap = item['value'];
                    break;
                  case'productImageMode':
                    gblSettings.productImageMode = item['value'];
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
                  case 'canGoBackFromPaxPage':
                    gblSettings.canGoBackFromPaxPage = parseBool(item['value']);
                    break;

                  case 'wantYouthDOB':
                    gblSettings.passengerTypes.wantYouthDOB = parseBool(item['value']);
                    break;
                  case 'wantCityImages': // for back compatibility
                    gblSettings.wantPageImages = parseBool(item['value']);
                    break;
                  case 'wantLogBuffer': // for back compatibility
                    gblWantLogBuffer = parseBool(item['value']);
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
/*
                  case 'wantMaterialControls':
                    gblSettings.wantMaterialControls = parseBool(item['value']);
                    break;
*/
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
                  case 'wantPassengerPassport':
                    gblSettings.wantPassengerPassport = parseBool(item['value']);
                    break;
                  case 'webCheckinNoSeatCharge':
                    gblSettings.webCheckinNoSeatCharge = parseBool(item['value']);
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
                  case 'wantCanFacs':
                    gblSettings.wantCanFacs = parseBool(item['value']);
                    break;
                  case 'wantTerminal':
                    gblSettings.wantTerminal = parseBool(item['value']);
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
                  case 'iOSDemoBuilds':
                    gblSettings.iOSDemoBuilds = item['value'];
                    break;
                  case 'androidDemoBuilds':
                    gblSettings.androidDemoBuilds = item['value'];
                    break;
                  case 'demoUser':
                    gblSettings.demoUser = item['value'];
                    break;
                  case 'demoPassword':
                    gblSettings.demoPassword = item['value'];
                    break;
                  case 'debugUser':
                    gblSettings.debugUser = item['value'];
                    break;
                  case 'debugPassword':
                    gblSettings.debugPassword = item['value'];
                    break;

                  case 'oldPriceColor':
                    gblSystemColors.oldPriceColor = item['value'];
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
                  case 'trackerUrl':
                    gblSettings.trackerUrl = item['value'];
                    break;
                  case 'privacyPolicyUrl':
                    gblSettings.privacyPolicyUrl = item['value'];
                    break;
                  case 'prohibitedItemsNoticeUrl':
                    gblSettings.prohibitedItemsNoticeUrl = item['value'];
                    break;
                  case 'specialAssistanceUrl':
                    gblSettings.specialAssistanceUrl = item['value'];
                    break;
                  case 'contactUsUrl':
                    gblSettings.contactUsUrl =  item['value'];
                    break;
                  case 'stopRedirectUrl':
                    gblSettings.stopUrl = item['value'];
                    break;
                  case 'stopMessage':
                    gblSettings.stopMessage = item['value'];
                    break;
                  case 'stopTitle':
                    gblSettings.stopTitle =item['value'];
                    break;
                  case 'action':
                    gblAction = item['value'];
                    break;
                  case 'testflags':
                    gblTestFlags = item['value'];
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
              gblLoginSuccessful = true;
            } else {
              print('settingsJson == null');
/*
              log('[settings string]' + settingsString);
              log('[body]' + response.body);
              gblError = 'settingsJson == null';
              throw('settingsJson == null');
*/
            }
            if( gblVerbose == true ) {print('successful login');}

            if( exactMatchVersioAction.isNotEmpty) {
              gblAction = exactMatchVersioAction;

            } else if ( mainMatchVersioAction.isNotEmpty){
              gblAction =mainMatchVersioAction;
            }
            if( gblSettings.useWebApiforVrs) {
              logit('website version $xmlVersion required XML version $requiredXmlVersion' );
            } else {
              logit('API version $xmlVersion');
            }
            if(gblDoVersionCheck && ( xmlVersion == null || xmlVersion == '' || (gblSettings.useWebApiforVrs) ? int.parse(xmlVersion) < requiredXmlVersion : int.parse(xmlVersion) < requiredApiVersion  )) {
              if( gblSettings.useWebApiforVrs) {
                gblError = 'WebService needs update';
              } else {
                gblError = 'WebApi needs update';
              }
              print(gblError);
              criticalErrorPage(NavigationService.navigatorKey.currentContext!,gblError,title: 'Login', wantButtons: false );
              //throw(gblError);
            }         } else {
            logit('login failed');
            print(response.body);
            gblErrorTitle = 'Login';
            if ( map != null && map['errorMessage'] != null && map['errorCode'] != null) {
              gblError = map['errorMessage'] + ' :' + map['errorCode'];
            } else if (map['errorMsg'] != null ) {
              gblError = map['errorMsg'];
            } else {
              gblError = response.body;
            }
            gblNoNetwork = true;
          }
        }
        else if(map['isSuccessful']  == false) {
          logit('login - ${map['errorMsg']}');
          gblErrorTitle = 'Login:';
          gblError = 'login - ${map['errorMsg']}';
          gblNoNetwork = true;

        }
        else {
          logit('login - map null');
          print(response.body);
          gblErrorTitle = 'Login:';
          gblError = response.body;
          gblNoNetwork = true;

        }
      } else {
        gblLoginSuccessful = false;
        logit('login - status=${response.statusCode}'+ response.body );
        gblErrorTitle = 'Login-';
        gblError = response.statusCode.toString();
      }
    } catch (e) {
      gblLoginSuccessful = false;
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
 /* Future<ParsedResponse<List<City>>> getCities() async {
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
      if( city.code == "####") {
        apiBuldVersion = int.parse(city.code);
      } else {
        networkCities[city.code] = city;
      }
    }

    //Adds information (if available) from database
    List<City> databaseCities =
        await database.getCities([]..addAll(networkCities.keys));
    for (City city in databaseCities) {
      if( city.code == "####") {
        apiBuldVersion = int.parse(city.code);
      } else {
        networkCities[city.code] = city;
      }
    }

    return new ParsedResponse(
        response.statusCode, []..addAll(networkCities.values));
  }
*/
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

  Future<NotificationStore> getAllNotifications() {
    return database.getAllNotifications();
  }

  Future updateNotification(RemoteMessage msg, bool background, bool replace) async {
    try{
      print('saving push msg');
      final Map<String, dynamic> notifyMap = new Map<String, dynamic>();
      final Map<String, dynamic> msgMap = new Map<String, dynamic>();

      try {
        if (msg.notification != null) {
          notifyMap['body'] = msg.notification!.body;
          notifyMap['title'] = msg.notification!.title;
          String sNot = jsonEncode(notifyMap);
          msgMap['notification'] = sNot;
        }
      } catch(e){
        notifyMap['body'] = 'error ${e.toString()}';
      }

      final Map<String, dynamic> dataMap = msg.data; // = new Map<String, dynamic>();


      String sData = jsonEncode(dataMap);

      try {
        msgMap['category'] = msg.category;
      } catch(e){
        notifyMap['body'] = 'cat error ${e.toString()}';
      }
      try {
        msgMap['background'] = background.toString();
      } catch(e){
        notifyMap['body'] = 'bg error ${e.toString()}';
      }
      try {
        if (msg.sentTime.toString() != 'null') {
          msgMap['sentTime'] = msg.sentTime.toString();
        } else {
          msgMap['sentTime'] = DateTime.now().toString();
        }
        } catch(e){
        notifyMap['body'] = 'date error ${e.toString()}';
        }
        try{
          msgMap['data'] = sData;
        } catch(e){
          notifyMap['body'] = 'data error ${e.toString()}';
        }

      String sMsg = jsonEncode(msgMap);
    await database.updateNotification(sMsg.replaceAll('"', '|'), msgMap['sentTime'], replace);
    } catch(e) {
      String m = e.toString();
      gblError = 'notify error ${e.toString()}';
      print(m);
    }
  }

  Future deleteNotifications() {
    return database.deleteNotifications();
  }
  Future deleteNotification(String sTime) {
    return database.deleteNotification(sTime);
  }


  Future<City?> getCityByCode(String code) {
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

    logit('get BP $cmd');
    String data = await runVrsCommand(cmd);
    String pnrJson;
    pnrJson = data
        .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
        .replaceAll('<string xmlns="http://videcom.com/">', '')
        .replaceAll('</string>', '');

    Map<String, dynamic> map = json.decode(pnrJson);
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
    //print(months.indexOf("SEP"));
    VrsBoardingPass vrsBoardingPass = new VrsBoardingPass.fromJson(map);
    DateTime flightdate = DateTime.parse(vrsBoardingPass
            .mobileboardingpass!.flightdate
            .toString()
            .substring(5, 9) +
        '-' +
        months
            .indexOf(vrsBoardingPass.mobileboardingpass!.flightdate
                .toString()
                .substring(2, 5)
                .toUpperCase())
            .toString()
            .padLeft(2, "0") +
        '-' +
        vrsBoardingPass.mobileboardingpass!.flightdate
            .toString()
            .substring(0, 2));
    BoardingPass boardingPass = new BoardingPass(
      rloc: vrsBoardingPass.mobileboardingpass!.rloc,
      fltno: vrsBoardingPass.mobileboardingpass!.flight,
      depart: vrsBoardingPass.mobileboardingpass!.departcitycode,
      arrive: vrsBoardingPass.mobileboardingpass!.arrivecitycode,
      gate: vrsBoardingPass.mobileboardingpass!.gate,
      depdate: flightdate,
      departTime: vrsBoardingPass.mobileboardingpass!.departtime,
      arriveTime: vrsBoardingPass.mobileboardingpass!.arrivetime,
      boardingTime: vrsBoardingPass.mobileboardingpass!.boardtime,
      // boarding: vrsBoardingPass.mobileboardingpass.boardtime,
      // depa
      paxname: vrsBoardingPass.mobileboardingpass!.passengername,
      paxno: int.parse(cmd[34]) - 1,
      barcodedata: vrsBoardingPass.mobileboardingpass!.barcode,
      seat: vrsBoardingPass.mobileboardingpass!.seat,
      classBand: vrsBoardingPass.mobileboardingpass!.classband,
      fastTrack: (vrsBoardingPass.mobileboardingpass!.fareextras != null && vrsBoardingPass.mobileboardingpass!.fareextras.contains('FAST')) ? 'true': 'false',
    );

    await database.updateBoardingPass(boardingPass);

    return boardingPass;
  }

  //Pnrs
  Future<List<PnrDBCopy>> getAllPNRs() {
    return database.getAllPNRs();
  }

  Future updatePnr(PnrDBCopy pnrDBCopy) async {
    logit('update pnr');

    // set app version saved with
    String latestVersion = Platform.isIOS
        ? gblSettings.latestBuildiOS
        : gblSettings.latestBuildAndroid;

    if( pnrDBCopy.data.contains('APPVERSION') == false) {
      pnrDBCopy.data = pnrDBCopy.data.replaceAll(
          '{"RLOC":', '{"APPVERSION": "$latestVersion", "RLOC":');
    }
    await database.updatePnr(pnrDBCopy);
    if( gblVerbose) logit('e update pnr');
  }

  Future<PnrDBCopy> getPnr(String rloc) {
    return database.getPnr(rloc);
  }

  Future<PnrDBCopy?> fetchPnr2(String rloc) async {


    sendXmlMsg( new XmlRequest(command: '*$rloc~x')).then((xmlResponse) {
      if (xmlResponse.success) {
        print('Fetch PNR OK');
        PnrModel pnrModel = new PnrModel.fromJson(xmlResponse.map as Map<String, dynamic>);

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



    Future<PnrDBCopy?> fetchPnr(String rloc) async {
      String data;
      try {
        data = await runVrsCommand('*$rloc~x');
      } catch(e) {
        logit('catch ${e.toString()}');
        throw (e);
      }
      if( ! data.startsWith('{')){
        PnrDBCopy pnr = PnrDBCopy(rloc: '', data: data, delete: 0);
        pnr.success = false;
        return pnr;

      }

      String pnrJson;
      //logit('RX: $data');

      pnrJson = data
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', '');
    Map<String, dynamic> map = json.decode(pnrJson);
    print('Fetch PNR');
    PnrModel pnrModel = new PnrModel.fromJson(map);

      // {"RLOC":

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

  Future<DatabaseRecord?> fetchApisStatus(String rloc) async {

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
      Map<String, dynamic> map = json.decode(apisStatusJson);
      if( gblVerbose) logit('Loaded APIS status');
      ApisPnrStatusModel apisPnrStatus = new ApisPnrStatusModel.fromJson(map);

      DatabaseRecord databaseRecord = new DatabaseRecord(
          rloc: apisPnrStatus.xml!.pnrApis.pnr, //_rloc,
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
      Map<String, dynamic> map    = jsonDecode(data
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', ''));

      objAv = new AvailabilityModel.fromJson(map);
      return new ParsedResponse(200, objAv);
    } else {
      String msg = json.encode(RunVRSCommand(gblSession!, avCmd));

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
            (response.reasonPhrase as String));
        return new ParsedResponse(response.statusCode, null);
      }

      if (response.body.contains('NotSinedInException')) {
        logit('GetAV: Not sined in ');
        return new ParsedResponse(notSinedIn, null);
      }


      if (response.body.contains('<string xmlns="http://videcom.com/">Error')) {
        return new ParsedResponse(noFlights, null);
      }
      if (response.body.contains('ERROR')) {
        return new ParsedResponse(0, null, error: response.body);
      }
      if (!response.body.contains('<string xmlns="http://videcom.com/" />')) {
        Map<String, dynamic> map    = jsonDecode(response.body
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
      if( data.contains('ERROR')){
        return new ParsedResponse(0, null, error: data);
      }
      if(gblLogFQ) {logit('getfareQuote3: ' + data); }
      if (!data.contains('<string xmlns="http://videcom.com/" />')) {
        Map<String, dynamic> map = jsonDecode(data
            .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
            .replaceAll('<string xmlns="http://videcom.com/">', '')
            .replaceAll('</string>', ''));

        pnrModel = new PnrModel.fromJson(map);
        gblPnrModel = pnrModel;
        refreshStatusBar();
      }
      return new ParsedResponse(200, pnrModel);
    } else {
        http.Response response = await http
        .get(Uri.parse(
            "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$cmd"),
            headers: getXmlHeaders())
        .catchError((resp) {
          if(gblLogFQ) {logit('getfareQuote4: ' + resp);}

          return new ParsedResponse(0, null, error: resp);
        });
      if (response == null) {
        if(gblLogFQ) { logit('getfareQuote5: null' ); }

        return new ParsedResponse(noInterent, null);
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        logit('getfareQuote6: error' + response.statusCode.toString());

        return new ParsedResponse(response.statusCode, null);
      }
        if(gblLogFQ) {logit('getfareQuote7: ' + response.body);}

        if( response.body.toUpperCase().contains('ERROR' )){
        String er = response.body.replaceAll('<?xml version=\"1.0\" encoding=\"utf-8\"?>', '')
          .replaceAll('<string xmlns=\"http://videcom.com/\">', '')
            .replaceAll('</string>', '');
        return new ParsedResponse(0, null, error: er);
      }

      if (!response.body.contains('<string xmlns="http://videcom.com/" />')) {
        Map<String, dynamic> map = jsonDecode(response.body
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

    if (!data.contains('<string xmlns="http://videcom.com/" />')) {
      Map<String, dynamic> map = jsonDecode(data
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', ''));

      seatplan = new Seatplan.fromJson(map);
    }
    return new ParsedResponse(200, seatplan);
    } catch (e) {
      gblError = e.toString();
      return new ParsedResponse(0, seatplan, error: e.toString());
    }

  }

  Future<ParsedResponse<RoutesModel>?> initRoutes() async {
    //http request, catching error like no internet connection.
    //If no internet is available for example response is
    var prefs = await SharedPreferences.getInstance();
    if(gblLogCities) {logit('initRoutes');}
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
    Map<String, dynamic> map = jsonDecode('{ \"Routes\":' + response.body + '}');
    prefs.setString('route_cache_time2', DateTime.now().toString());

    RoutesModel networkRoutes = RoutesModel.fromJson(map);
    await database.updateRoutes('{ \"Routes\":' + response.body + '}');
    return new ParsedResponse(response.statusCode, networkRoutes);
  }

  Future <List<String>> getAllDepartures(void Function() onComplete) async {
    if (gblVerbose) {print('start getRoutesData');}
    List<String> departureCities = [];
    // new List<String>();
    try {


    database.getRoutesData().then((valueMap) {
      if (gblVerbose) {print('getRoutesData');}
      valueMap!['Routes'].forEach((item) {
        //logit(item.toString());
        departureCities.add(item.values.first['airportCode'] +
            "|" +
            item.values.first['airportName'] +
            " (" +
            item.values.first['airportCode'] +
            ")");
        /*logit(item.values.first['airportCode'] +
            "|" +
            item.values.first['airportName'] +
            " (" +
            item.values.first['airportCode'] +
            ")");*/
      });
      if( departureCities.length==0){
        print("No departures");
      }
      if (gblVerbose) {print("routes len ${departureCities.length}");}
      onComplete();
      return departureCities;
    });
    return departureCities;
    } catch (e) {
      print(e);
      return departureCities;
    }
  }

  Future <List<String>> getDestinations(String departure) async {
    List<String> destinationCities = [];
    // new List<String>();
    if (gblVerbose) {print('getDestinations');}

    database.getRoutesData().then((valueMap) {
      valueMap!['Routes'].forEach((f) {
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
        print("routes len" + valueMap['Routes'].length.toString());
      }
      return destinationCities;
    });
    return destinationCities;
  }
}

class FareRules {
  List<FareRule> fareRule = List.from([FareRule()]);

  FareRules();

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
/*
    } else {
      fareRule = null;
*/
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
  String rule ='';

  FareRule();

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
  logit('runFunctionCommand $cmd');
  String msg =  json.encode(VrsApiRequest(gblSession!, cmd,
      gblSettings.xmlToken.replaceFirst('token=', ''),
      vrsGuid: gblSettings.vrsGuid,
      notifyToken: gblNotifyToken,
      rloc: gblCurrentRloc,
      language: gblLanguage,
      phoneId: gblDeviceId
  )); // '{VrsApiRequest: ' + + '}' ;

  http.Response response = await http
      .get(Uri.parse(
      "${gblSettings.xmlUrl.replaceFirst('PostVRSCommand?', function)}?VarsSessionID=${gblSession!.varsSessionId}&req=$msg"),
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
    logit('runFunctionCommand ($cmd): ' + response.statusCode.toString() + ' ' + (response.reasonPhrase as String));
    throw 'runFunctionCommand: ' + response.statusCode.toString() + ' ' + (response.reasonPhrase as String);
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
  Map<String, dynamic> map = jsonDecode(response.body
      .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
      .replaceAll('<string xmlns="http://videcom.com/">', '')
      .replaceAll('</string>', ''));

  VrsApiResponse rs = VrsApiResponse.fromJson(map);
  if( gblSession == null && map['sessionId'] != null && map['varsSessionId'] != null && map['vrsServerNo'] != null ) {
    gblSession = Session(map['sessionId'], map['varsSessionId'],
        map['vrsServerNo'] == null ? '1' : map['vrsServerNo'].toString());
  }
  logit('rfc Server IP ${map['serverIP']}');
  if( rs.data == null ) {
    throw 'no data returned';
  }
  return rs.data;
}




Future<String> runVrsCommand(String cmd) async {
  gblError ='';
  logit('runVrsCommand $cmd');
  if( gblSettings.useWebApiforVrs) {

    String msg =  json.encode(VrsApiRequest(gblSession!, cmd,
        gblSettings.xmlToken.replaceFirst('token=', ''),
        vrsGuid: gblSettings.vrsGuid,
        notifyToken: gblNotifyToken,
        rloc: gblCurrentRloc,
        language: gblLanguage,
        phoneId: gblDeviceId
     )); // '{VrsApiRequest: ' + + '}' ;

    http.Response response = await http
        .get(Uri.parse(
        "${gblSettings.xmlUrl.replaceFirst('?', '')}?VarsSessionID=${gblSession!.varsSessionId}&req=$msg"),
          headers: getXmlHeaders())
        .catchError((resp) {
      logit('runVrsCommand error ${resp.toString()}');
/*
      var error = '';
*/
    });

    if (response == null) {
      logit('runVrsCommand response null');
      throw 'No Internet';
      //return new ParsedResponse(noInterent, null);
    }

    //If there was an error return null
    if (response.statusCode < 200 || response.statusCode >= 300) {
      logit('runFunctionCommand ($cmd): ' + response.statusCode.toString() + ' ' + (response.reasonPhrase as String));
      throw 'runFunctionCommand: ' + response.statusCode.toString() + ' ' + (response.reasonPhrase as String);
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
        logit('runVrs ${map["errorMsg"]}');
        //throw map["errorMsg"];
        return map["errorMsg"];
      }
      if( map["data"] != null ) {
        logit('runVrs ${map["data"]}');
        throw map["data"];
      }
      throw "Error returned from server";
    }

    //String jsn = response.body;
    Map<String, dynamic> map = jsonDecode(response.body
        .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
        .replaceAll('<string xmlns="http://videcom.com/">', '')
        .replaceAll('</string>', ''));

    VrsApiResponse rs = VrsApiResponse.fromJson(map);
    if(gblSession != null  ) {
      String id = '';
      if(map['sessionId'] != null ){
        id = map['sessionId'];
      }
      String sid = '';
      if(map['varsSessionId'] != null ){
        sid = map['varsSessionId'];
      }
      String no = '';
      if(map['vrsServerNo'] != null ){
        no = map['vrsServerNo'];
      }
      gblSession = Session(id, sid, no);
    }
    if( gblVerbose) logit('rvc Server IP ${map['serverIP']}');
    if( rs.data == null ) {
      logit('no data returned');
      throw 'no data returned';
    }
    return rs.data;
  } else {
    String url = "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$cmd";
    if( gblSettings.wantPushNoticications && gblCurrentRloc != null ) {
      url += "&notToken=$gblNotifyToken&phone=$gblDeviceId&rloc=$gblCurrentRloc";
      if( gblLanguage != null && gblLanguage.isNotEmpty) {
        url += "&language=$gblLanguage";
      }
    }


      http.Response response = await http
        .get(Uri.parse(url
        ),
        headers: getXmlHeaders())
        .catchError((resp) {

    });
    if( response == null )
      {
        logit('no data returned 2');
        throw 'no data returned';
      }
    return response.body;
  }
 }

RemoteMessage? convertMsg(NotificationMessage msg)
{
    try {
      RemoteNotification rNote = new RemoteNotification(
        title:  msg.notification!.title,
        body: msg.notification!.body,
      ) ;
      RemoteMessage rMsg = new RemoteMessage( notification: rNote,
          data: msg.data as Map<String, dynamic>,
          sentTime: msg.sentTime,
          category: msg.category
      );
      return rMsg;

      } catch(e) {
          print(e.toString());
    }
    return null;
}
void saveSetting(String key, String value) async {
  try {
    var prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  } catch(e){
    print('save error: key $key $e');
  }
}
Future<String?> getSetting(String key ) async {
  try {
    var prefs = await SharedPreferences.getInstance();
    if (prefs.getString(key) == null) {
      return '';
    }
    return prefs.getString(key);
  } catch(e){
    print('getSetting $key error: $e');
  }
  return '';
}

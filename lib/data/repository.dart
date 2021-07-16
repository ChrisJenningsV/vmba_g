import 'dart:async' show Future;
import 'dart:convert';
import 'package:vmba/data/database.dart';
import 'package:http/http.dart' as http;
import 'package:vmba/data/models/routes.dart';
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

//import 'package:flutter/services.dart' show rootBundle;

/// A class similar to http.Response but instead of a String describing the body
/// it already contains the parsed Dart-Object
class ParsedResponse<T> {
  ParsedResponse(this.statusCode, this.body);
  final int statusCode;
  final T body;

  bool isOk() {
    return statusCode >= 200 && statusCode < 300;
  }
  String errorStatus() {
    if (statusCode == noInterent) {
      return 'Please check your internet connection';
    }
    if (statusCode == noFlights) {
      return "No flights for these cities and dates";
    }
    return "Unknown error";
  }
}

final int noInterent = 404;
final int noFlights = 405;

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

  Future<ParsedResponse<List<City>>> initSettings() async {
    http.Response response = await http
        .get(Uri.parse(
            "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=ssrpmasettings"))
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
    // await database.updateCities([]..addAll(networkCities.values));

    return new ParsedResponse(
        response.statusCode, []..addAll(networkCities.values));
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
        headers: {'Content-Type': 'application/json',
          'Videcom_ApiKey': gblSettings.apiKey
        },
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

    await database.updateCities(networkCities);

    return new ParsedResponse(response.statusCode, networkCities.cities);
  }

  Future settings() async {
    //get values from db
  // CJ overwrites hardcoded!!! -  await getSettingsFromDatabase();
    //get values from webservice
  // cj - test returning live vals
    await getSettingsFromApi();
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
    Map<String, String>       headers = {'Content-Type': 'application/json',
        'Videcom_ApiKey': gblSettings.apiKey};

    if( gblSettings.brandID != null && gblSettings.brandID.isNotEmpty) {
       body = {"AgentGuid": "${gblSettings.vrsGuid}",
                "BrandId": "${gblSettings.brandID}"};
    }
    try {
      final http.Response response = await http.post(
          Uri.parse(gblSettings.apiUrl + "/login"),
          headers: headers,
          //       headers: {'Content-Type': 'application/json'},
          body: JsonEncoder().convert(body));

      if (response.statusCode == 200) {
        Map map = json.decode(response.body);
        if ( map != null ) {
          String settingsString = map["mobileSettingsJson"];
          gblSession = Session(map['sessionId'], map['varsSessionId'], map['vrsServerNo'].toString());

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
                switch (item['parameter']) {
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
                    print('load FQTV name [${gblSettings.fqtvName}]');
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


                /*
                  BOOLS
                   */
                //case 'wantLoadingLogo':
                //gbl_settings.privacyPolicyUrl =item['value'];
                //break;
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
                  case 'wantFQTV':
                    gblSettings.wantFQTV = parseBool(item['value']);
                    break;
                  case 'wantFQTVNumber':
                    gblSettings.wantFQTVNumber = parseBool(item['value']);
                    break;
                  case 'wantCurrencyPicker':
                    gblSettings.wantCurrencyPicker = parseBool(item['value']);
                    break;
                  case 'eVoucher':
                    gblSettings.eVoucher =parseBool(item['value']);
                    break;
                  case 'bpShowFastTrack':
                    gblSettings.bpShowFastTrack =parseBool(item['value']);
                    break;
                  case 'bpShowLoungeAccess':
                    gblSettings.bpShowLoungeAccess =parseBool(item['value']);
                    break;
                  case 'HideFareRules':
                    gblSettings.hideFareRules =parseBool(item['value']);
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
            }
            if( gblVerbose == true ) {print('successful login');}

            if( exactMatchVersioAction.isNotEmpty) {
              gblAction = exactMatchVersioAction;

            } else if ( mainMatchVersioAction.isNotEmpty){
              gblAction =mainMatchVersioAction;
            }
          }
          else {
            gblError = response.body;
            gblNoNetwork = true;
          }
        } else {
          gblError = response.body;
          gblNoNetwork = true;

        }
      }
    } catch (e) {
      print(e);
      gblError = e.toString();
      gblNoNetwork = true;
      rethrow;
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
    http.Response response = await http
        .get(
            //"${gbl_settings.xmlUrl}${gbl_settings.xmlToken}&command=ssrpmacitylist")
            Uri.parse(
                '${gblSettings.apiUrl}/cities/GetCityList'),
      headers: {
        'Content-Type': 'application/json',
        'Videcom_ApiKey': gblSettings.apiKey
      },)
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
    http.Response response = await http
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

  Future<PnrDBCopy> fetchPnr(String rloc) async {
    http.Response response = await http
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

    Map map = json.decode(pnrJson);
    print('Fetch PNR');
    PnrModel pnrModel = new PnrModel.fromJson(map);

    PnrDBCopy pnrDBCopy = new PnrDBCopy(
        rloc: pnrModel.pNR.rLOC, //_rloc,
        data: pnrJson,
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
    }

    String apisStatusJson;

    apisStatusJson = response.body
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
            headers: {
              'Content-Type': 'application/json',
              'Videcom_ApiKey': gblSettings.apiKey
            },
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
    http.Response response = await http
        .get(Uri.parse(
            "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$avCmd"))
        .catchError((resp) {});
    if (response == null) {
      return new ParsedResponse(noInterent, null);
    }

    //If there was an error return null
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return new ParsedResponse(response.statusCode, null);
    }
    if (response.body.contains('<string xmlns="http://videcom.com/">Error')) {
      return new ParsedResponse(noFlights, null);
    }
    if (!response.body.contains('<string xmlns="http://videcom.com/" />')) {
      Map map = jsonDecode(response.body
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', ''));

      objAv = new AvailabilityModel.fromJson(map);
    }
    return new ParsedResponse(response.statusCode, objAv);
  }

  Future<ParsedResponse<PnrModel>> getFareQuote(String cmd) async {
    PnrModel pnrModel = PnrModel();
    http.Response response = await http
        .get(Uri.parse(
            "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$cmd"))
        .catchError((resp) {});
    if (response == null) {
      return new ParsedResponse(noInterent, null);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      return new ParsedResponse(response.statusCode, null);
    }

    if (!response.body.contains('<string xmlns="http://videcom.com/" />')) {
      Map map = jsonDecode(response.body
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', ''));

      pnrModel = new PnrModel.fromJson(map);
    }
    return new ParsedResponse(response.statusCode, pnrModel);
  }

  Future<ParsedResponse<Seatplan>> getSeatPlan(String seatPlanCmd) async {
    Seatplan seatplan = Seatplan();
    http.Response response = await http
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
    }
    return new ParsedResponse(response.statusCode, seatplan);
  }

  Future<ParsedResponse<RoutesModel>> initRoutes() async {
    //http request, catching error like no internet connection.
    //If no internet is available for example response is
    final http.Response response = await http.get(
        Uri.parse(
            '${gblSettings.apiUrl}/cities/Getroutelist'),
        headers: {
          'Content-Type': 'application/json',
          'Videcom_ApiKey': gblSettings.apiKey
        }).catchError((resp) {});

    if (response == null) {
      return new ParsedResponse(noInterent, null);
    }

    //If there was an error return an empty list
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return new ParsedResponse(response.statusCode, null);
    }
    Map map = jsonDecode('{ \"Routes\":' + response.body + '}');
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

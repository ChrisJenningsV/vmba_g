import 'dart:async' show Future;
import 'dart:convert';
import 'package:vmba/data/database.dart';
import 'package:http/http.dart' as http;
import 'package:vmba/data/models/routes.dart';
import 'package:vmba/data/settings.dart';
import 'models/cities.dart';
//import 'package:loganair/data/settings.dart';
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
            "${gbl_settings.xmlUrl}${gbl_settings.xmlToken}&command=ssrpmasettings"))
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

  /// Fetches the list of cities from the VRS XML Api with the query parameter being input.
  Future<ParsedResponse<List<City>>> initCities() async {
    //http request, catching error like no internet connection.
    //If no internet is available for example response is
    final http.Response response = await http.get(
        Uri.parse('${gbl_settings.apiUrl}/cities/GetCityList'),
        headers: {          'Content-Type': 'application/json',
          'Videcom_ApiKey': gbl_settings.apiKey
        }
    ).catchError((resp) {
      print('initcities error $resp');
    });

    if (response == null) {
      return new ParsedResponse(noInterent, []);
    }

    //If there was an error return an empty list
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw(response.reasonPhrase);
      return new ParsedResponse(response.statusCode, []);
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
      gbl_settings = Settings.fromJson(map);
    }
  }

  Future getSettingsFromApi() async {
    var body = {"AgentGuid": "${gbl_settings.vrsGuid}"};
    try {
      final http.Response response = await http.post(
          Uri.parse(gbl_settings.apiUrl + "/login"),
          headers: {
            'Content-Type': 'application/json',
            'Videcom_ApiKey': gbl_settings.apiKey
          },
          //       headers: {'Content-Type': 'application/json'},
          body: JsonEncoder().convert(body));

      if (response.statusCode == 200) {
        Map map = json.decode(response.body);
        if ( map != null ) {
          String settingsString = map["mobileSettingsJson"];
          List <dynamic> settingsJson;
          if (settingsString != null && settingsString.isNotEmpty) {
            settingsJson = json.decode(settingsString);
          }
          LoginResponse loginResponse = new LoginResponse.fromJson(map);
          if (loginResponse.isSuccessful) {
            //If has settings update GobalSettings with these
            // cj bad vals from server!

            // pick out the values we want from server
            // cj work in progress
            if (settingsJson != null) {
              for (var item in settingsJson) {
                switch (item['parameter']) {
                  case 'creditCardProvider':
                    gbl_settings.creditCardProvider = item['value'];
                    break;
                  case 'appLive':
                    gblIsLive = parseBool(item['value']);
                    break;
                  case 'Languages':
                    gblLanguages = item['value'];
                    break;
                  case 'titles':
                    gbl_titles = item['value'].split(',');
                    break;
                /*
                  BOOLS
                   */
                //case 'wantLoadingLogo':
                //gbl_settings.privacyPolicyUrl =item['value'];
                //break;
                  case 'wantProfileList':
                    gbl_settings.wantProfileList = parseBool(item['value']);
                    break;
                  case 'wantMyAccount':
                    gbl_settings.wantMyAccount = parseBool(item['value']);
                    break;
                /*
                  URLs
                   */
                  case 'adsTermsUrl':
                    gbl_settings.adsTermsUrl = item['value'];
                    break;
                  case 'termsAndConditionsUrl':
                    gbl_settings.termsAndConditionsUrl = item['value'];
                    break;
                  case 'faqUrl':
                    gbl_settings.faqUrl = item['value'];
                    break;
                  case 'privacyPolicyUrl':
                    gbl_settings.privacyPolicyUrl = item['value'];
                    break;
                  case 'specialAssistanceUrl':
                    gbl_settings.specialAssistanceUrl = item['value'];
                    break;
                  case 'contactUsUrl':
                    gbl_settings.contactUsUrl =  item['value'];
                    break;
                /*
                  EMAILS
                   */
                  case 'appFeedbackEmail':
                    gbl_settings.appFeedbackEmail = item['value'];
                    break;
                  case 'groupsBookingsEmail':
                    gbl_settings.groupsBookingsEmail = item['value'];
                    break;
                  default:
                    String param = item['parameter'];
                    if (param.startsWith('appVersion')) {
                      String vers = param.replaceAll('appVersion_', '');
                      if (vers == gblVersion) {
                        gblAction = item['value'].toString().toUpperCase();
                        switch (item['value'].toString().toUpperCase()) {
                          case 'LIVE':
                            break;
                          case 'TEST':
                            break;
                          case 'LOGIN':
                            break;
                          case 'UPDATE':
                            break;
                          case 'SUSSPEND':
                          case 'STOP':
                            break;
                        }
                      }
                    } else {
                      print('Parameter not found ${item["parameter"]}');
                    }
                }
              }
            }
            print('successful login');
          }
          else {
            gblError = response.body;
            gbl_NoNetwork = true;
          }
        } else {
          gblError = response.body;
          gbl_NoNetwork = true;

        }
      }
    } catch (e) {
      print(e);
      gblError = e.toString();
      gbl_NoNetwork = true;
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
    return (str.toLowerCase() == 'true');
  }
  /// Fetches the list of cities from the VRS XML Api with the query parameter being input.
  Future<ParsedResponse<List<City>>> getCities() async {
    //http request, catching error like no internet connection.
    //If no internet is available for example response is
    http.Response response = await http
        .get(
            //"${gbl_settings.xmlUrl}${gbl_settings.xmlToken}&command=ssrpmacitylist")
            Uri.parse(
                '${gbl_settings.apiUrl}/cities/GetCityList'),
      headers: {
        'Content-Type': 'application/json',
        'Videcom_ApiKey': gbl_settings.apiKey
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
            "${gbl_settings.xmlUrl}${gbl_settings.xmlToken}&command=$cmd"))
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
            "${gbl_settings.xmlUrl}${gbl_settings.xmlToken}&command=*$rloc~x"))
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
            "${gbl_settings.xmlUrl}${gbl_settings.xmlToken}&command=DSP/$rloc'"))
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
                '${gbl_settings.apiUrl}/fare/GetFareRules'),
            headers: {
              'Content-Type': 'application/json',
              'Videcom_ApiKey': gbl_settings.apiKey
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
            "${gbl_settings.xmlUrl}${gbl_settings.xmlToken}&command=$avCmd"))
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
            "${gbl_settings.xmlUrl}${gbl_settings.xmlToken}&command=$cmd"))
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
            "${gbl_settings.xmlUrl}${gbl_settings.xmlToken}&command=$seatPlanCmd"))
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
            '${gbl_settings.apiUrl}/cities/Getroutelist'),
        headers: {
          'Content-Type': 'application/json',
          'Videcom_ApiKey': gbl_settings.apiKey
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
    if (gbl_verbose) {print('start getRoutesData');}
    List<String> departureCities = [];
    // new List<String>();
    try {


    database.getRoutesData().then((valueMap) {
      if (gbl_verbose) {print('getRoutesData');}
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
      if (gbl_verbose) {print("routes len ${departureCities.length}");}
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
    if (gbl_verbose) {print('getDestinations');}

    database.getRoutesData().then((valueMap) {
      valueMap['Routes'].forEach((f) {
       // print(f['departure']['airportCode']);
        if (f['departure']['airportCode'] == departure) {
          f['destinations'].forEach((dest) {
            destinationCities.add(dest['airportCode'] +
                "|" +
                dest['airportName'] +
                " (" +
                dest['airportCode'] +
                ")");
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

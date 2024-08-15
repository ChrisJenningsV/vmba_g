
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:vmba/data/models/cities.dart';
import 'package:vmba/data/models/boardingpass.dart';
import 'package:vmba/data/models/pnrs.dart';
import 'package:vmba/data/models/apis_pnr.dart';
import 'package:vmba/data/models/user_profile.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/routes.dart';
import 'package:vmba/data/settings.dart';

import '../utilities/helper.dart';
import 'models/notifyMsgs.dart';

class AppDatabase {
  static final AppDatabase _appDatabase = new AppDatabase._internal();

  final String tableNameCities = "Cities";
  final String tableNameBoardingPasses = "BoardingPasses";
  final String tableNamePNRs = "PNRs";
  final String tableNamePnrApisStatus = "PnrApisStatus";
  final String tableNameUserProfile = "UserProfile";
  final String tableNameRoutes = "Routes";
  final String tableNameSettings = "Settings";
  final String tableNameAppData = "AppData";
  final String tableNameVRSBoardingPasses = "VRSBoardingPasses";
  final String tableNameNotifications = "Notifications";

  static final _databaseVersion = 9;

  late Database db;

  bool didInit = false;

  static AppDatabase get() {
    return _appDatabase;
  }

  AppDatabase._internal() ;

  /// Use this method to access the database, because initialization of the database (it has to go through the method channel)
  Future<Database> _getDb() async {
    if (!didInit) await _init();
    //await _drop();
    return db;
  }

  Future init() async {
    return await _init();
  }

  Future _init() async {
    // Get a location using path_provider
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "app.db");
    db = await openDatabase(path, version: _databaseVersion,
        onCreate: (Database db, int version) async {
          // When creating the db, create the table
          //await _drop();

          await db.execute("CREATE TABLE IF NOT EXISTS $tableNameCities ("
              "${City.dbCode} TEXT PRIMARY KEY,"
              "${City.dbName} TEXT,"
              "${City.dbShortName} TEXT,"
              "${City.dbMobileBarcodeType} TEXT,"
              "${City.dbWebCheckinEnabled} INTEGER,"
              "${City.dbWebCheckinStart} INTEGER,"
              "${City.dbWebCheckinEnd} INTEGER"
              ");");
          await db.execute(
              "CREATE TABLE IF NOT EXISTS $tableNameBoardingPasses ("
                  "${BoardingPass.dbRloc} TEXT PRIMARY KEY,"
                  "${BoardingPass.dbFltno} TEXT,"
                  "${BoardingPass.dbDepart} TEXT,"
                  "${BoardingPass.dbArrive} TEXT,"
                  "${BoardingPass.dbPaxname} TEXT,"
                  "${BoardingPass.dbBarcodedata} TEXT,"
                  "${BoardingPass.dbPaxno} INTEGER,"
                  "${BoardingPass.dbDepdate} TEXT,"
                  "${BoardingPass.dbSeat} TEXT,"
                  "${BoardingPass.dbGate} TEXT,"
                  "${BoardingPass.dbBoarding} INTEGER,"
                  "${BoardingPass.dbClassBand} TEXT,"
                  "${BoardingPass.dbFastTrack} TEXT,"
                  "${BoardingPass.dbLoungeAccess} TEXT,"
                  "${BoardingPass.dbBoardingTime} TEXT"
                  ");");
          await db.execute("CREATE TABLE IF NOT EXISTS $tableNamePNRs ("
              "${PnrDBCopy.dbRloc} TEXT PRIMARY KEY,"
              "${PnrDBCopy.dbData} TEXT,"
              "${PnrDBCopy.dbDelete} INTEGER"
              ");");
          await db.execute(
              "CREATE TABLE IF NOT EXISTS $tableNamePnrApisStatus ("
                  "${PnrDBCopy.dbRloc} TEXT PRIMARY KEY,"
                  "${PnrDBCopy.dbData} TEXT,"
                  "${PnrDBCopy.dbDelete} INTEGER"
                  ");");
          await db.execute("CREATE TABLE IF NOT EXISTS $tableNameUserProfile ("
          //"${UserProfileRecord.db_id} INTEGER PRIMARY KEY,"
              "${UserProfileRecord.dbName} TEXT PRIMARY KEY,"
              "${UserProfileRecord.dbValue} TEXT"
              ");");
          await db.execute("CREATE TABLE IF NOT EXISTS $tableNameRoutes ("
              "${RoutesDB.dbName} TEXT,"
              "${RoutesDB.dbValue} TEXT"
              ");");
          await db.execute("CREATE TABLE IF NOT EXISTS $tableNameSettings ("
              "${KeyPair.dbName} TEXT,"
              "${KeyPair.dbValue} TEXT"
              ");");
          await db.execute("CREATE TABLE IF NOT EXISTS $tableNameAppData ("
              "${KeyPair.dbName} TEXT,"
              "${KeyPair.dbValue} TEXT"
              ");");
          await db.execute("CREATE TABLE IF NOT EXISTS $tableNameNotifications ("
              "${KeyPair.dbName} TEXT,"
              "${KeyPair.dbValue} TEXT"
              ");");
        }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
          if (oldVersion < 2) {
            await db.execute("CREATE TABLE IF NOT EXISTS $tableNameRoutes ("
                "${RoutesDB.dbName} TEXT,"
                "${RoutesDB.dbValue} TEXT"
                ");");
          }

          if (oldVersion < 3) {
            await db.execute("CREATE TABLE IF NOT EXISTS $tableNameSettings ("
                "${KeyPair.dbName} TEXT,"
                "${KeyPair.dbValue} TEXT"
                ");");
          }

          if (oldVersion < 4) {
            await db.execute("CREATE TABLE IF NOT EXISTS $tableNameAppData ("
                "${KeyPair.dbName} TEXT PRIMARY KEY,"
                "${KeyPair.dbValue} TEXT"
                ");");
          }
          if (oldVersion < 5) {
            await db.execute(
                'ALTER TABLE $tableNameCities ADD ${City.dbShortName} TEXT');
          }
          if (oldVersion < 6) {
            await db.execute(
                'ALTER TABLE $tableNameCities ADD ${City.dbMobileBarcodeType} TEXT');
          }
          if (oldVersion < 8) {
            logit('alter boarding pass table');
            await db.execute(
                'ALTER TABLE $tableNameBoardingPasses ADD ${BoardingPass.dbFastTrack} TEXT');
            await db.execute(
                'ALTER TABLE $tableNameBoardingPasses ADD ${BoardingPass.dbLoungeAccess} TEXT');
            /*await db.execute("DROP TABLE [IF EXISTS] $tableNameBoardingPasses ");
            await db.execute(
                "CREATE TABLE IF NOT EXISTS $tableNameBoardingPasses ("
                    "${BoardingPass.dbRloc} TEXT PRIMARY KEY,"
                    "${BoardingPass.dbFltno} TEXT,"
                    "${BoardingPass.dbDepart} TEXT,"
                    "${BoardingPass.dbArrive} TEXT,"
                    "${BoardingPass.dbPaxname} TEXT,"
                    "${BoardingPass.dbBarcodedata} TEXT,"
                    "${BoardingPass.dbPaxno} INTEGER,"
                    "${BoardingPass.dbDepdate} TEXT,"
                    "${BoardingPass.dbSeat} TEXT,"
                    "${BoardingPass.dbGate} TEXT,"
                    "${BoardingPass.dbBoarding} INTEGER,"
                    "${BoardingPass.dbClassBand} TEXT,"
                    "${BoardingPass.dbFastTrack} TEXT,"
                    "${BoardingPass.dbLoungeAccess} TEXT,"
                    "${BoardingPass.dbBoardingTime} TEXT"
                    ");");*/
          }
          if (oldVersion < 9) {
            logit('alter boarding pass table');
            await db.execute(
                'DELETE FROM $tableNameBoardingPasses ');
            await db.execute(
                'ALTER TABLE $tableNameBoardingPasses ADD ${BoardingPass
                    .dbBoardingTime} TEXT');
          }
            //if (oldVersion < 7)
          try {
            await db.execute("CREATE TABLE IF NOT EXISTS $tableNameNotifications ("
                "${KeyPair.dbName} TEXT,"
                "${KeyPair.dbValue} TEXT"
                ");");
          } catch (e) {
            print(e.toString());
          }
        });
    didInit = true;
  }

  /*
  Future _update() async {

  }

   */
  /*
   Future _drop() async {
     await db.execute("DROP TABLE [IF EXISTS] $tableNameCities");
  //       "DROP TABLE [IF EXISTS] $tableNamePNRs; "
  //       "DROP TABLE [IF EXISTS] $tableNameBoardingPasses; "
  //       "DROP TABLE [IF EXISTS] $tableNamePnrApisStatus; "
  //       "DROP TABLE [IF EXISTS] $tableNameRoutes; "
  //       "DROP TABLE [IF EXISTS] $tableNameUserProfile; "
  //       "DROP TABLE [IF EXISTS] $tableNameRoutes; "
  //       "DROP TABLE [IF EXISTS] $tableNameSettings; "
  //       "DROP TABLE [IF EXISTS] $tableNameAppData; ");
   }
   */

  /// Get a city by its ISO Code, if there is not entry for that ISO code, returns null.
  Future<City?> getCityByCode(String code) async {
    var db = await _getDb();
    var result = await db.rawQuery(
        "SELECT * FROM $tableNameCities WHERE ${City.dbCode} = '$code'");
    if (result.length == 0) return null;
    return new City.fromMap(result[0]);
  }

  /// Will return a list of all cities found
  Future<List<City>> getCities(List<String> codes) async {
    var db = await _getDb();
    // Building SELECT * FROM TABLE WHERE ID IN (id1, id2, ..., idn)
    var idsString = codes.map((it) => '"$it"').join(',');
    //var result = await db.rawQuery('SELECT * FROM $tableNameCities WHERE ${City.db_code}');
    var result = await db.rawQuery(
        'SELECT * FROM $tableNameCities WHERE ${City.dbCode} IN ($idsString)');
    List<City> cities = []; // var cities = List<City>;
    for (Map<String, dynamic> item in result) {
      cities.add(new City.fromMap(item));
    }
    return cities;
  }

  /// Inserts or replaces the city.
  Future updateCity(City city) async {
    var db = await _getDb();
    await db.rawInsert('INSERT OR REPLACE INTO '
        '$tableNameCities(${City.dbCode}, ${City.dbName},${City.dbShortName}, '
        '${City.dbMobileBarcodeType}, ${City.dbWebCheckinEnabled}, ${City
        .dbWebCheckinStart}, ${City.dbWebCheckinEnd})'
        ' VALUES("${city.code}", "${city.name}", "${city.shortName}", "${city.mobileBarcodeType}", "${city
        .webCheckinEnabled}", "${city.webCheckinStart}", "${city
        .webCheckinEnd}")');
  }

  /// Inserts or replaces the city in local database
  Future updateCities(Cities cities) async {
    String values = '';

    if(cities.cities == null )
      {
        throw('cities null');
      }
    cities.cities!.forEach((c)  async {
      String name = c.name;
      if( name.contains("'")) {
        name = name.replaceAll("'", "&quot;");
      }
      values +=
      "('${c.code}', '$name', '${c.shortName}', '${c.mobileBarcodeType}', ${c.webCheckinEnabled}, ${c.webCheckinStart}, ${c.webCheckinEnd}),";

    //  '("${c.code}", "${c.name}", "${c.webCheckinEnabled}", "${c.webCheckinStart}", "${c.webCheckinEnd}"),');
    });
    // removefinal comma
    values = values.substring(0, values.length - 1);
    var db = await _getDb();
    await db.rawInsert('INSERT OR REPLACE INTO '
        '$tableNameCities(${City.dbCode}, ${City.dbName}, ${City
        .dbShortName}, ${City.dbMobileBarcodeType}, ${City.dbWebCheckinEnabled}, ${City
        .dbWebCheckinStart}, ${City.dbWebCheckinEnd})'
        ' VALUES $values');

  }

  Future close() async {
    var db = await _getDb();
    return db.close();
  }

  Future<List<City>> getAllCities() async {
    var db = await _getDb();
    var result = await db.rawQuery('SELECT * FROM $tableNameCities');
    if (result.length == 0) return [];
    List<City> cities = []; // new List<City>();
    for (Map<String, dynamic> map in result) {
      cities.add(new City.fromMap(map));
    }
    return cities;
  }

  Future<City> getCity(String code) async {
    var db = await _getDb();
    var result =
    await db.rawQuery('SELECT * FROM $tableNameCities Where code = $code');
    if (result.length == 0)
      return new City(
          code: code,
          name: '',
          shortName: '',
          mobileBarcodeType: '',
          webCheckinEnabled: 0,
          webCheckinStart: 96,
          webCheckinEnd: 1);
    List<City> cities = [];
    // new List<City>();
    for (Map<String, dynamic> map in result) {
      cities.add(new City.fromMap(map));
    }
    return cities.first;
  }

//BOARDING PASSES START

  Future<BoardingPass> getBoardingPass(String fltno, String rloc,
      int paxno) async {
    var db = await _getDb();
    var result = await db.rawQuery(
        "SELECT * FROM $tableNameBoardingPasses Where fltno = '$fltno' and rloc = '$rloc' and paxno = '$paxno'");
    if (result.length == 0)
      return new BoardingPass(
        rloc: rloc,
        fltno: fltno,
        depart: '',
        arrive: '',
        depdate: DateTime.now(),
        paxname: '',
        barcodedata: '',
        paxno: paxno,
        classBand: '',
        gate: '-',
        boarding: 60,
        loungeAccess: '',
        fastTrack: '',
      );
    List<BoardingPass> boardingPasses = [];
    // new List<BoardingPass>();
    for (Map<String, dynamic> map in result) {
      boardingPasses.add(new BoardingPass.fromMap(map));
    }
    return boardingPasses.first;
  }

  Future<bool> hasDownloadedBoardingPass(String fltno, String rloc,
      int paxno) async {
    var db = await _getDb();
    var result = await db.rawQuery(
        "SELECT * FROM $tableNameBoardingPasses Where fltno = '$fltno' and rloc = '$rloc' and paxno = '$paxno'");
    if (result.length == 0) return false;

    return true;
  }

  Future updateBoardingPass(BoardingPass boardingPass) async {
    var db = await _getDb();
    await db.rawInsert("INSERT OR REPLACE INTO "
        "$tableNameBoardingPasses (${BoardingPass.dbRloc}, ${BoardingPass
        .dbFltno}, ${BoardingPass.dbDepart}, "
        "${BoardingPass.dbArrive}, ${BoardingPass.dbDepdate}, ${BoardingPass
        .dbPaxname}, ${BoardingPass.dbBarcodedata}, "
        "${BoardingPass.dbPaxno}, ${BoardingPass.dbGate}, ${BoardingPass
        .dbBoarding}, ${BoardingPass.dbSeat}, ${BoardingPass.dbClassBand},"
        "${BoardingPass.dbFastTrack}, ${BoardingPass.dbLoungeAccess}, ${BoardingPass.dbBoardingTime})"
        " VALUES('${boardingPass.rloc}', '${boardingPass
        .fltno}', '${boardingPass.depart}', '${boardingPass.arrive}', "
        "'${boardingPass.depdate}','${boardingPass.paxname}', '${boardingPass
        .barcodedata}', '${boardingPass.paxno}', "
        "'${boardingPass.gate}', '${boardingPass.boarding}', '${boardingPass
        .seat}', '${boardingPass.classBand}', '${boardingPass.fastTrack}', '${boardingPass.loungeAccess}',"
        "'${boardingPass.boardingTime}' )");
  }

  Future<List<BoardingPass>> getBoardingPasses(String fltno,
      String rloc) async {
    var db = await _getDb();
    var result = await db.rawQuery(
        'SELECT * FROM $tableNameBoardingPasses Where fltno = $fltno and rloc = $rloc order by paxno asc');
    List<BoardingPass> boardingPasses = [];
    // new List<BoardingPass>();
    if (result.length == 0)
      boardingPasses.add(new BoardingPass(
        rloc: rloc,
        fltno: fltno,
        depart: '',
        arrive: '',
        depdate: DateTime.now(),
        paxname: '',
        barcodedata: '',
        paxno: 0,
        classBand: '',
        gate: '-',
        boarding: 60,
        fastTrack: 'false',
        loungeAccess: '',
      ));
    for (Map<String, dynamic> map in result) {
      boardingPasses.add(new BoardingPass.fromMap(map));
    }
    return boardingPasses;
  }

//BOARDING PASSES END

//VRS BOARDING PASSES START
  Future<bool> hasDownloadedVRSBoardingPass(String fltno, String rloc,
      int paxno) async {
    var db = await _getDb();
    var result = await db.rawQuery(
        "SELECT * FROM $tableNameVRSBoardingPasses Where flt = '$fltno' and rloc = '$rloc' and paxno = '$paxno'");
    if (result.length == 0) return false;
    return true;
  }

  Future<BoardingPass> getVrsBoardingPass(String fltno, String rloc,
      int paxno) async {
    var db = await _getDb();
    var result = await db.rawQuery(
        "SELECT * FROM $tableNameVRSBoardingPasses Where fltno = '$fltno' and rloc = '$rloc' and paxno = '$paxno'");
    if (result.length == 0)
      return new BoardingPass(
        rloc: rloc,
        fltno: fltno,
        depart: '',
        arrive: '',
        depdate: DateTime.now(),
        paxname: '',
        barcodedata: '',
        paxno: paxno,
        classBand: '',
        gate: '-',
        boarding: 60,
        loungeAccess: '',
        fastTrack: '',
      );
    List<BoardingPass> boardingPasses = [];
    // new List<BoardingPass>();
    for (Map<String, dynamic> map in result) {
      boardingPasses.add(new BoardingPass.fromMap(map));
    }
    return boardingPasses.first;
  }

  Future updateVRSBoardingPass(BoardingPass boardingPass) async {
    var db = await _getDb();
    await db.rawInsert('INSERT OR REPLACE INTO '
        '$tableNameBoardingPasses (${BoardingPass.dbRloc}, ${BoardingPass
        .dbFltno}, ${BoardingPass.dbDepart}, '
        '${BoardingPass.dbArrive}, ${BoardingPass.dbDepdate}, ${BoardingPass
        .dbPaxname}, ${BoardingPass.dbBarcodedata}, '
        '${BoardingPass.dbPaxno}, ${BoardingPass.dbGate}, ${BoardingPass
        .dbBoarding}, ${BoardingPass.dbSeat}, ${BoardingPass.dbClassBand})'
        ' VALUES("${boardingPass.rloc}", "${boardingPass
        .fltno}", "${boardingPass.depart}", "${boardingPass.arrive}", '
        '"${boardingPass.depdate}","${boardingPass.paxname}", "${boardingPass
        .barcodedata}", "${boardingPass.paxno}", '
        '"${boardingPass.gate}", "${boardingPass.boarding}", "${boardingPass
        .seat}", "${boardingPass.classBand}")');
  }

//VRS BOARDING PASSES END

//PNRS START

  Future<List<PnrDBCopy>> getAllPNRs() async {
    var db = await _getDb();
    var result = await db.rawQuery('SELECT * FROM $tableNamePNRs');
    if (result.length == 0) return [];
    List<PnrDBCopy> pnrs = [];
    //new List<PnrDBCopy>();
    for (Map<String, dynamic> map in result) {
      pnrs.add(new PnrDBCopy.fromMap(map));
    }
    return pnrs;
  }

  Future<PnrDBCopy> getPnr(String rloc) async {
    var db = await _getDb();
    var result =
    await db.rawQuery("SELECT * FROM $tableNamePNRs Where rloc = '$rloc'");
    if (result.length == 0)
      return new PnrDBCopy(
        rloc: rloc,
        data: '',
        delete: 1,
      );
    List<PnrDBCopy> _pnr = [];
    // new List<PnrDBCopy>();
    for (Map<String, dynamic> map in result) {
      _pnr.add(new PnrDBCopy.fromMap(map));
    }
    return _pnr.first;
  }

  Future updatePnr(PnrDBCopy pnr) async {
    try {
      var db = await _getDb();
      Map<String, dynamic> mappedPnr = pnr.toMap();
      if (mappedPnr.containsKey('nextFlightSinceEpoch')) {
        mappedPnr.remove('nextFlightSinceEpoch');
      }

      var rloc = pnr.rloc;
      var result =
      await db.rawQuery(
          "SELECT * FROM $tableNamePNRs Where rloc = '$rloc'");
      if (result.length == 0) {
        // new one, just add
        await db.insert(tableNamePNRs, mappedPnr);
      } else {
        // exists
        await db.update(tableNamePNRs, mappedPnr,
            where: 'rloc = ?', whereArgs: [pnr.rloc]);
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future deletePnr(String rloc) async {
    var db = await _getDb();
    await db.rawQuery('DELETE FROM '
        '$tableNamePNRs WHERE ${PnrDBCopy.dbRloc} = "$rloc" ');
    //await db.rawQuery('DELETE FROM '
    //'$tableNamePNRs WHERE ${PnrDBCopy.dbRloc} = ${pnr.rloc} AND ${PnrDBCopy.dbDelete} =  1 ');
  }

  Future deletePnrs(List<PnrDBCopy> pnrs) async {
    var db = await _getDb();
    for (var pnr in pnrs) {
      await db.rawQuery('DELETE FROM '
          '$tableNamePNRs WHERE ${PnrDBCopy.dbRloc} = ${pnr
          .rloc} AND ${PnrDBCopy.dbDelete} =  1 ');
    }
  }

  //PNRS END

  //APIS STATUS START
  Future<DatabaseRecord> getPnrApisStatus(String rloc) async {
    var db = await _getDb();
    var result = await db
        .rawQuery("SELECT * FROM $tableNamePnrApisStatus Where rloc = '$rloc'");
    if (result.length == 0)
      return new DatabaseRecord(
        rloc: rloc,
        data: '',
        delete: 1,
      );
    List<DatabaseRecord> _pnr = [];
    // new List<DatabaseRecord>();
    for (Map<String, dynamic> map in result) {
      _pnr.add(new DatabaseRecord.fromMap(map));
    }
    return _pnr.first;
  }

  Future updatePnrApisStatus(DatabaseRecord pnr) async {
    var db = await _getDb();
    Map<String, dynamic> map = pnr.toMap();
    try {
      await db.insert(tableNamePnrApisStatus, map);
    } catch (e) {
      logit(e.toString());
      //await db.update(tableNamePnrApisStatus, map);

      await db.update(tableNamePnrApisStatus, map,
          where: 'rloc = ?', whereArgs: [pnr.rloc]);
    }
  }

  Future deletePnrApisStatus(DatabaseRecord record) async {
    var db = await _getDb();
    await db.rawQuery('DELETE FROM '
        '$tableNamePnrApisStatus WHERE ${DatabaseRecord.dbRloc} = ${record
        .rloc} AND ${DatabaseRecord.dbDelete} =  1 ');
  }
  Future deletePnrApis(String rloc) async {
    var db = await _getDb();
    await db.rawQuery('DELETE FROM '
        '$tableNamePnrApisStatus WHERE ${DatabaseRecord.dbRloc} = "$rloc" ');
    //await db.rawQuery('DELETE FROM '
    //'$tableNamePNRs WHERE ${PnrDBCopy.dbRloc} = ${pnr.rloc} AND ${PnrDBCopy.dbDelete} =  1 ');
  }

  Future deletePnrsApisStatus(List<DatabaseRecord> records) async {
    var db = await _getDb();
    for (var record in records) {
      await db.rawQuery('DELETE FROM '
          '$tableNamePnrApisStatus WHERE ${DatabaseRecord.dbRloc} = ${record
          .rloc} AND ${DatabaseRecord.dbDelete} =  1 ');
    }
  }

//APIS STATUS END

//USER PROFILE START

  Future<List<UserProfileRecord>> getUserProfile() async {
    // await _dropADS();
    var db = await _getDb();
    var result = await db.rawQuery('SELECT * FROM $tableNameUserProfile');
    if (result.length == 0) {
      List<UserProfileRecord> _l = [];
      return _l;
    }

    List<UserProfileRecord> _userProfileRecordList = [];
    //new List<UserProfileRecord>();
    for (Map<String, dynamic> map in result) {
      _userProfileRecordList.add(new UserProfileRecord.fromMap(map));
    }
    return _userProfileRecordList;
  }

  Future<UserProfileRecord> getNamedUserProfile(String name) async {
    // await _dropADS();
    var db = await _getDb();
    var result = await db.rawQuery(
        "SELECT * FROM $tableNameUserProfile WHERE ${UserProfileRecord
            .dbName} = '$name' ");
    if (result.length == 0) {
      UserProfileRecord _l = UserProfileRecord(name: 'Error', value: ''); // = new UserProfileRecord();
      return _l;
    }

    List<UserProfileRecord> _userProfileRecordList = [];
    //new List<UserProfileRecord>();
    for (Map<String, dynamic> map in result) {
      _userProfileRecordList.add(new UserProfileRecord.fromMap(map));
    }
    return _userProfileRecordList.first;
  }

  Future updateUserProfile(List<UserProfileRecord> userProfileList) async {
    String values = '';

    userProfileList.forEach((userProfileRecord) =>
    values +=
    '("${userProfileRecord.name}", "${userProfileRecord.value}"),');
    values = values.substring(0, values.length - 1);
    var db = await _getDb();
    await db.rawInsert('INSERT OR REPLACE INTO '
        '$tableNameUserProfile(${UserProfileRecord.dbName}, ${UserProfileRecord
        .dbValue})'
        ' VALUES $values');
  }

/*  Future deleteUserProfile(UserProfileRecord userProfileRecord) async {
    var db = await _getDb();
    await db.rawQuery('DELETE FROM '
        '$tableNameUserProfile WHERE ${UserProfileRecord.dbName} = ${userProfileRecord.name} AND ${userProfileRecord.value} =  ${userProfileRecord.value}  ');
  }
  */

  Future <String> deleteUserProfile(String name) async {
    var db = await _getDb();
    await db.rawQuery('DELETE FROM '
        "$tableNameUserProfile WHERE ${UserProfileRecord.dbName} = '$name' ");
    return 'OK';
  }


  Future<ADS> getADSDetails() async {
    UserProfileRecord profile = await getNamedUserProfile('PAX1');
    try {
      Map<String, dynamic> map = json.decode(
          profile.value.toString().replaceAll(
              "'", '"')); // .replaceAll(',}', '}')
      PassengerDetail pax = PassengerDetail.fromJson(map);

      return new ADS( pax.adsPin, pax.adsNumber);
    } catch (e) {
      print(e);
      return new ADS('', '');
    }
  }

/*
    var db = await _getDb();
    var result = await db.rawQuery(
        'SELECT * FROM $tableNameUserProfile WHERE ${UserProfileRecord.dbName} IN (\'ads_number\',\'ads_pin\')');
    if (result.length != 2) return new ADS('', '');

    ADS aDS = new ADS('', '');
    List<UserProfileRecord> _userProfileRecordList = [];
    //new List<UserProfileRecord>();
    for (Map<String, dynamic> map in result) {
      _userProfileRecordList.add(new UserProfileRecord.fromMap(map));
    }

    aDS.pin =
        _userProfileRecordList.firstWhere((v) => v.name == 'ads_pin').value;
    aDS.number = _userProfileRecordList
        .firstWhere((v) => v.name == 'ads_number')
        .value
        .toUpperCase();

    return aDS;

 */


//USER PROFILE END

//ROUTES START
//  Future<Routes> getRoutes() async {
//     var db = await _getDb();
//     var result = await db.rawQuery(
//         'SELECT * FROM $tableNameRoutes');
//     if (result.length == 0) return new Routes();

//     var newMap = groupBy(result, (obj) =>['org']);

//     Routes routes = new Routes();
//     for (Map<String, dynamic> map in newMap) {
//       routes.add(new Routes.fromMap(map));
//     }

//     return routes;
//   }

  Future<Map?> getRoutesData() async {
    try{
    var db = await _getDb();
    var result = await db
        .rawQuery("SELECT value FROM $tableNameAppData where name = 'routes'");
    Map valueMap = json.decode(result[0].values.first as String);
    return valueMap;
    } catch (e) {
      print(e);
      return null;
    }
  }

//getAllDepartures
  Future<List<String>> getAllDepartures() async {
    try {
      var db = await _getDb();
      //var result = await db.rawQuery('SELECT DISTINCT value FROM $tableNameAppData where name = "routes"');
      var result = await db
          .rawQuery(
          "SELECT value FROM $tableNameAppData where name = 'routes'");

      Map valueMap = json.decode(result[0].values.first as String);
      var departureCities = [];
      //new List<String>();
      for (Map<String, dynamic> item in valueMap['Routes']) {
        var org = item.values.first['airportCode'] +
            "|" +
            item.values.first['airportName'] +
            " (" +
            item.values.first['airportCode'] +
            ")";
        departureCities.add(org);
      }
      return departureCities as List<String>;
    } catch (e) {
      print(e.toString());
      return List.from(['']);
    }
  }

  Future updateRoutes(String routes) async {
    var db = await _getDb();
    Map<String, dynamic> myData = {
      KeyPair.dbName.toString(): 'routes',
      KeyPair.dbValue.toString(): routes
    };

    //routes
    await db.rawDelete("DELETE FROM $tableNameAppData WHERE name = 'routes';");
    await db.insert(tableNameAppData, myData);
    //await db.update(tableNameAppData, myData);
  }

  Future<RoutesModel> getRoutes() async {
    var db = await _getDb();
    var result = await db.rawQuery('SELECT top 1 dest FROM $tableNameRoutes');

    List<String> destinationCities = [];
    // new List<String>();
    for (Map<String, dynamic> item in result) {
      destinationCities.add(item.values.first);
    }
    return RoutesModel();
  }

  Future<List<String>> getDestinations(String departure) async {
    var db = await _getDb();
    var result = await db.rawQuery(
        'SELECT DISTINCT dest FROM $tableNameRoutes where org like \'$departure%\'');

    List<String> destinationCities = [];
    //new List<String>();
    for (Map<String, dynamic> item in result) {
      destinationCities.add(item.values.first);
    }
    return destinationCities;
  }

//ROUTES END

//SETTINGS START
  Future<List<KeyPair>> getAllSettings() async {
    var db = await _getDb();
    var result = await db.rawQuery('SELECT * FROM $tableNameSettings');

    List<KeyPair> settings = [];
    //new List<KeyPair>();
    for (Map<String, dynamic> item in result) {
      settings.add(KeyPair(key: item.values.first, value: item.values.last));
    }
    return settings;
  }

  // void saveAllSettings() async {
  //   var db = await _getDb();
  //   var result = await db.rawQuery('SELECT DISTINCT * FROM $tableNameSettings');

  //   List<KeyPair> settings = new List<KeyPair>();
  //   for (Map<String, dynamic> item in result) {
  //     settings.add(item.values.first);
  //   }
  // }

  Future saveAllSettings(Settings settings) async {
    String values = '';
    List<KeyPair> keyPairList = settings.toList();
    keyPairList.forEach((c) => values +=
      '("${c.key}", "${c.value.toString().replaceAll('"', "'")}"),');
    values = values.substring(0, values.length - 1);
    var db = await _getDb();
    await db.rawDelete('DELETE FROM $tableNameSettings;');
    await db.rawInsert('INSERT OR REPLACE INTO '
        '$tableNameSettings(${KeyPair.dbName}, ${KeyPair.dbValue})'
        ' VALUES $values');
  }

  Future deleteAllSettings() async {
    var db = await _getDb();
    await db.rawDelete('DELETE FROM $tableNameSettings;');
  }


   Future<NotificationStore> getAllNotifications() async {
    var db = await _getDb();
    NotificationStore store = new NotificationStore();
    var result = await db.rawQuery('SELECT * FROM $tableNameNotifications' );
    store.rawCount = result.length;
    if (result.length == 0) return store;
    //List<NotificationMessage> notes = []; // new List<City>();
    for (Map<String, dynamic> map in result) {
      try {
        if( map['value'] != null ) {
          String sMsg = map['value'];
          sMsg = sMsg.replaceAll('|', '"');

          Map<String, dynamic> jsonMap = json.decode(sMsg);
          Notification not = Notification(body: 'body', title: 'title');
          if (jsonMap['notification'] != null) {
            Map<String, dynamic> notMap = json.decode(jsonMap['notification']);
            if( notMap['body'] != null && notMap['title'] != null ) {
              not = Notification(body: notMap['body'],
                  title: notMap['title']);
            }
          }
          Map<String, dynamic> dataMap = Map();
          if (jsonMap['data'] != null) {
            dataMap = json.decode(jsonMap['data']);
          }
          String cat = '';
          String back = '';
          String sent = DateTime.now().toString();

          if (jsonMap['category'] != null) cat = jsonMap['category'];
          if (jsonMap['background'] != null) back = jsonMap['background'];
          if (jsonMap['sentTime'] != null) sent = jsonMap['sentTime'];

          NotificationMessage msg = NotificationMessage(notification: not,
              category: cat,
              background: back,
              data: dataMap,
              sentTime: DateTime.parse(sent));

          store.list.add(msg);
          store.list.sort((a,b) => b.sentTime!.compareTo(a.sentTime as DateTime));
        }
      } catch(e) {
        store.errMsg = e.toString();
        print(e.toString());
      }
    }
    return store;
  }

  Future deleteNotifications() async {
    var db = await _getDb();
    await db.rawDelete('DELETE FROM $tableNameNotifications;');
  }

  Future deleteNotification(String sTime) async {
    var db = await _getDb();
    await db.rawDelete('DELETE FROM $tableNameNotifications WHERE ${KeyPair.dbName}="$sTime";');
  }

  Future updateNotification(String msg, String sTime, bool replace) async {

    try {
      var db = await _getDb();

      await db.rawDelete('DELETE FROM $tableNameNotifications WHERE ${KeyPair.dbName}=\'$sTime\'');

      if (replace) {
        await db.rawInsert('UPDATE '
            '$tableNameNotifications SET  ${KeyPair.dbValue}="$msg"'
            ' WHERE ${KeyPair.dbName}=\'$sTime\'');
      } else {
        await db.rawInsert('INSERT OR REPLACE INTO '
            '$tableNameNotifications(${KeyPair.dbName}, ${KeyPair.dbValue})'
            ' VALUES ( \'$sTime\', \'$msg\')');
      }
    } catch (e) {
        print(e.toString());
    }
  }



  // Future<String> getSetting(String key) async {
  //   var db = await _getDb();
  //   var result =
  //       await db.rawQuery('SELECT * FROM $tableNameSettings Where key = $key');
  //   if (result.length == 0) return '';
  //   List<SettingsDB> settings = new List<SettingsDB>();
  //   for (Map<String, dynamic> map in result) {
  //     settings.add(new SettingsDB.fromMap(map));
  //   }
  //   return settings.first.toString();
  // }

//SETTINGS END
}

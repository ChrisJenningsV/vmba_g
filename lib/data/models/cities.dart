
import 'package:meta/meta.dart';

import '../../utilities/helper.dart';

class Cities {
  List<City>? cities;

  Cities();

  Cities.fromJson(Map<String, dynamic> json) {
    if (json['Cities'] != null) {
      cities = [];
      //new List<City>();
      if (json['Cities'] is List) {
        json['Cities'].forEach((v) {
          if( v != null ) {
            //logit(v.toString());
            cities!.add(new City.fromJson(v));
          }
        });
      } else {
        cities!.add(new City.fromJson(json['Cities']));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    final cities = this.cities;
    if (cities != null) {
      data['City'] = cities.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class City {
  static final dbCode = "code";
  static final dbName = "name";
  static final dbShortName = "shortName";
  static final dbWebCheckinEnabled = "webCheckinEnabled";
  static final dbWebCheckinStart = "webCheckinStart";
  static final dbWebCheckinEnd = "webCheckinEnd";
  static final dbMobileBarcodeType = "mobileBarcodeType";
  static final dbMinimumConnectMins = "minimumConnectMins";

  String code='', name='', shortName='', mobileBarcodeType ='';
  int webCheckinEnabled =0, webCheckinStart =0, webCheckinEnd =0;
  double minimumConnectMins =60;

  City({
    required this.code,
    required this.name,
    required this.shortName,
    required this.webCheckinEnabled,
    required this.webCheckinStart,
    required this.webCheckinEnd,
    required this.mobileBarcodeType,
    this.minimumConnectMins =60,
  });

  City.fromMap(Map<String, dynamic> json){
    if( json['cityCode'] != null ) code = json['cityCode'];
    if( json['airportName'] != null ) name = json['airportName'];
    if( json['shortAirportName'] != null )shortName = json['shortAirportName'];
    if( json['webCheckinEnabled'] != null ) webCheckinEnabled = (json['webCheckinEnabled'] == true || json['webCheckinEnabled'] == 'true')? 1: 0;

    if(  json['webCheckinStart'] != null ) webCheckinStart = json['webCheckinStart'];
    if( json['webCheckinEnd'] != null ) webCheckinEnd = json['webCheckinEnd'];
    if( json['mobileBarcodeType'] != null ) mobileBarcodeType = json['mobileBarcodeType'];
    if( json['minimumConnectMins'] != null ) minimumConnectMins = json['minimumConnectMins'];

  }
/*
      : this(
          code: map[dbCode]== null ? '' : map[dbCode],
          name: map[dbName]== null ? '' : map[dbName],
          shortName: map[dbShortName]== null ? '' : map[dbShortName],
          webCheckinEnabled: map[dbWebCheckinEnabled]== null ? '' :  map[dbWebCheckinEnabled],
          webCheckinStart: map[dbWebCheckinStart]== null ? '' : map[dbWebCheckinStart],
          webCheckinEnd: map[dbWebCheckinEnd]== null ? '' : map[dbWebCheckinEnd],
          mobileBarcodeType: map[dbMobileBarcodeType]== null ? '' : map[dbMobileBarcodeType],
      minimumConnectMins: map[dbMinimumConnectMins]== null ? '' : map[dbMinimumConnectMins]
        );
*/

  // Currently not used
  Map<String, dynamic> toMap() {
    return {
      dbCode: code,
      dbName: name,
      dbName: shortName,
      dbWebCheckinEnabled: webCheckinEnabled,
      dbWebCheckinStart: webCheckinStart,
      dbWebCheckinEnd: webCheckinEnd,
      dbMobileBarcodeType: mobileBarcodeType,
      dbMinimumConnectMins: minimumConnectMins,
    };
  }

  City.fromJson(Map<String, dynamic> json) {
    if( json['cityCode'] != null ) code = json['cityCode'];
    if( json['airportName'] != null ) name = json['airportName'];
    if( json['shortAirportName'] != null )shortName = json['shortAirportName'];
    if( json['webCheckinEnabled'] != null ) webCheckinEnabled = (json['webCheckinEnabled'] == true || json['webCheckinEnabled'] == 'true')? 1: 0;

      if(  json['webCheckinStart'] != null ) webCheckinStart = json['webCheckinStart'];
      if( json['webCheckinEnd'] != null ) webCheckinEnd = json['webCheckinEnd'];
      if( json['mobileBarcodeType'] != null ) mobileBarcodeType = json['mobileBarcodeType'];
      if( json['minimumConnectMins'] != null ) minimumConnectMins = json['minimumConnectMins'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cityCode'] = this.code;
    data['airportName'] = this.name;
    data['shortAirportName'] = this.shortName;
    data['webCheckinEnabled'] = this.webCheckinEnabled == 1 ? 'true' : 'false';
    data['webCheckinStart'] = this.webCheckinStart;
    data['webCheckinEnd'] = this.webCheckinEnd;
    data['mobileBarcodeType'] = this.mobileBarcodeType;
    data['minimumConnectMins'] = this.minimumConnectMins;

    return data;
  }
}

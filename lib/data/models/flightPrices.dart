import 'dart:convert';

import 'package:vmba/utilities/helper.dart';


class FlightSearchRequest
{
  String departCity='';
  String arrivalCity='';
 String flightDateStart ='';
 String flightDateEnd = '';
 int isReturnJourney = 0;
  String selectedCurrency='';
 bool isADS=false;
 bool? showFlightPrices=null;

  FlightSearchRequest({this.departCity='', this.arrivalCity='', this.flightDateEnd='', this.flightDateStart='',
      this.isADS=false, this.isReturnJourney=0, this.selectedCurrency='GBP', this.showFlightPrices});

  Map toJson() {
    Map map = new Map();
    map['departCity'] = departCity;
    map['arrivalCity'] = arrivalCity;
    map['flightDateStart'] = flightDateStart;
    map['flightDateEnd'] = flightDateEnd;
    map['isReturnJourney'] = isReturnJourney;
    map['selectedCurrency'] = selectedCurrency;
    map['IsADS'] = isADS;
    map['showFlightPrices'] = showFlightPrices;
    return map;
  }

}

class FlightPrices {
  List<FlightPrice> flightPrices = List.from([FlightPrice()]);

  FlightPrices.fromJson(String str) {
    try {
      flightPrices = [];
      List<dynamic> j = json.decode(str);

      flightPrices = [];
      //new List<PAX>();
      j.forEach((v) {
        flightPrices.add(new FlightPrice.fromJson(v));
      });
    } catch (e) {
      logit(e.toString());
    }
  }
}


class FlightPrice
{
  String FlightDate ='';
  double Price = 0;
  String Currency='GBP';
  bool Selectable=true;
  String CssClass='';

  FlightPrice();

  FlightPrice.fromJson(Map<String, dynamic> json) {
    try {
      if( json['flightDate'] != null ) FlightDate = json['flightDate'];
      if( json['price'] != null ) Price = json['price'];
      if( json['currency'] != null ) Currency = json['currency'];
      if( json['selectable'] != null ) Selectable = json['selectable'];
      if( json['cssClass'] != null ) CssClass = json['cssClass'];
    } catch(e) {
      logit(e.toString());
    }
  }
}



import 'package:intl/intl.dart';
import 'package:vmba/data/globals.dart';

import '../../utilities/helper.dart';

class Trips {
  List<Trip>? trips;

  Trips();

  Trips.fromJson(Map<String, dynamic> json) {
    if (json['trips'] != null) {
      trips = [];
      //new List<City>();
      if (json['trips'] is List) {
        json['trips'].forEach((v) {
          if( v != null ) {
            //logit(v.toString());
            trips!.add(new Trip.fromJson(v));
          }
        });
      } else {
        trips!.add(new Trip.fromJson(json['Cities']));
      }
    }
  }

 /* Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    final cities = this.cities;
    if (cities != null) {
      data['City'] = cities.map((v) => v.toJson()).toList();
    }
    return data;
  }*/
}


class Trip {
  String rloc = '';
  String firstname = '';
  String lastname = '';
  String title = '';
  String contact = '';
  String DOB = '';
  String nextFlight = '';
  String fltNo = '';
  String depart = '';
  String destin = '';
  String cabin = '';
  DateTime? fltdate;  


  Trip.fromJson(Map<String, dynamic> json) {
    if( json['rloc'] != null ) rloc = json['rloc'];
    if( json['CTC'] != null ) contact = json['CTC'];
    if( json['DOB'] != null ) DOB = json['DOB'];
    if( json['NextFlt'] != null ) nextFlight = json['NextFlt'];

    if( contact != ''){
      contact = contact.replaceAll('.','').replaceAll(RegExp('[0-9]'), '');
      List<String> aStr = contact.split('\/');
      firstname = aStr[1];
      lastname = aStr[0];
      // look for titles
      gblTitles.forEach((eTitle) {
        if( firstname.endsWith(eTitle.toUpperCase())){
          title = eTitle.toUpperCase();
          firstname = firstname.substring(0, firstname.length - eTitle.length);
        }
      });

    }
    //  "01 GFXO-1 DOB 29NOV1996[T6]~N"
    if( DOB != '' && DOB.contains('DOB')){
      List<String> arDob = DOB.split(' DOB');
      DOB = arDob[1].substring(0,10);
    }
    //  "T60106  MNL  ENI  Y Nov 15 2024 12:00AM"
    if( nextFlight != '' ){
      nextFlight = nextFlight.replaceAll('  ', ' ');
      List<String> arFlt = nextFlight.split(' ');
      fltNo = arFlt[0];
      depart = arFlt[1];
      destin = arFlt[2];
      cabin = arFlt[3];
      final formatter2 = DateFormat( 'MMM dd yyyy');
      String sD = arFlt[4] + ' ' + arFlt[5] + ' ' + arFlt[6];
      try {
        fltdate = formatter2.parse(sD);
      } catch(e) {
        logit(' error ${e.toString()} parsing date  $sD');
      }
    }


  }

}
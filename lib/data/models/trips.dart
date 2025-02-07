
import 'package:intl/intl.dart';
import 'package:vmba/data/globals.dart';

import '../../utilities/helper.dart';

class Trips {
  List<Trip>? trips;

  Trips();

  Trips.fromJson(Map<String, dynamic> json) {
    if (json['trips'] != null) {
      trips = [];
      if (json['trips'] is List) {
        json['trips'].forEach((v) {
          if( v != null ) {
            //logit(v.toString());
            trips!.add(new Trip.fromJson(v));
          }
        });
      } else {
        trips!.add(new Trip.fromJson(json['trips']));
      }
    }
  }
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
    try {
      if (json['rloc'] != null) rloc = json['rloc'];
      if (json['RLOC'] != null) rloc = json['RLOC'];
      if (json['CTC'] != null) contact = json['CTC'];
      if (json['DOB'] != null) DOB = json['DOB'];
      if (json['fltno'] != null) fltNo = json['fltno'].trim();
      if (json['depart'] != null) depart = json['depart'].trim();
      if (json['destin'] != null) destin = json['destin'].trim();
      try {
        //"flt_date" -> "2025-01-29T00:00:00"
        if (json['flt_date'] != null) {
          final formatter2 = DateFormat('MM dd yyyy');
          String fdStr = json['flt_date'];
          String sD = fdStr.substring(5, 7) + ' ' + fdStr.substring(8, 10) +
              ' ' + fdStr.substring(0, 4);
          fltdate = formatter2.parse(sD);
        }
      } catch (e) {
        logit('Trip.fromJson ' + e.toString());
      }


      if (contact != '') {
        contact = contact.replaceAll('.', '').replaceAll(RegExp('[0-9]'), '');
        List<String> aStr = contact.split('\/');
        firstname = aStr[1];
        lastname = aStr[0];
        // look for titles
        gblTitles.forEach((eTitle) {
          if (firstname.endsWith(eTitle.toUpperCase())) {
            title = eTitle.toUpperCase();
            firstname =
                firstname.substring(0, firstname.length - eTitle.length);
          }
        });
      }
      //  "01 GFXO-1 DOB 29NOV1996[T6]~N"
      if (DOB != '' && DOB.contains('DOB')) {
        List<String> arDob = DOB.split(' DOB');
        DOB = arDob[1].substring(0, 10);
      }
    } catch(e) {
      logit('Trip.fromJson ' + e.toString());
    }

  }

}

//  *************************
//  manage pax details
//  *************************


import 'dart:convert';

import '../data/globals.dart';
import '../data/models/models.dart';
import '../data/models/user_profile.dart';
import '../data/models/vrsRequest.dart';
import '../data/repository.dart';
import '../utilities/helper.dart';

class PaxManager {
  static PassengerDetail passengerDetail = new PassengerDetail();

  static populate( String email,
      { String firstName = '',
        String lastName = '',
        String middleName = '',
        String title = '',
        String joiningDate ='',
        String phone = '',
        String dOB = '',
        DateTime? dateOfBirth,
        String country = ','
      } ) async {
    passengerDetail = new PassengerDetail(); // gblPassengerDetail;

    passengerDetail.email = email;
    passengerDetail.title = title;
    passengerDetail.firstName = firstName;
    passengerDetail.lastName = lastName;
    passengerDetail.phonenumber = phone;
    if( dOB != null &&  dOB != ''){
      passengerDetail.dateOfBirth = DateTime.parse(dOB);
    } else if( dateOfBirth != null ){
      passengerDetail.dateOfBirth = dateOfBirth;
    }
    if(country != '') {
      passengerDetail.country = country;

      if( gblPassengerDetail!.country.length <= 3){
        Countrylist list = await getCountrylist();
        if( list != null && list.countries != null  ) {
          list.countries!.forEach((element) {
            if( element.alpha2code ==gblPassengerDetail!.country ){
              gblPassengerDetail!.country = element.enShortName;
            }
          });
        }
      }
    }

    passengerDetail.phonenumber = phone;
    passengerDetail.joiningDate = joiningDate;
  }

  static save(){
    List<UserProfileRecord> _userProfileRecordList = [];


    UserProfileRecord _profileRecord = new UserProfileRecord(
        name: 'PAX1',
        value: json
            .encode(passengerDetail!.toJson())
            .replaceAll('"', "'"));

    _userProfileRecordList.add(_profileRecord);
    Repository.get().updateUserProfile(_userProfileRecordList);
  }

  static  populateFromFqtvMember(FqtvLoginReply fqtvLoginReply, String fqtvNo, String fqtvPass) async {
    if( gblPassengerDetail == null ) {
      gblPassengerDetail = new PassengerDetail( email:  '', phonenumber: '');
    }

    gblFqtvLoggedIn = true;
    gblPassengerDetail!.fqtv = fqtvNo;
    gblPassengerDetail!.fqtvPassword = fqtvPass;


    gblPassengerDetail!.title = fqtvLoginReply.title;
    gblPassengerDetail!.firstName = fqtvLoginReply.firstname;
    gblPassengerDetail!.lastName = fqtvLoginReply.surname;
//    widget.passengerDetail!.firstName = fqtvLoginReply.firstname;
//    widget.passengerDetail!.lastName = fqtvLoginReply.surname;
    if( fqtvLoginReply.dOB != null &&  fqtvLoginReply.dOB != ''){
      gblPassengerDetail!.dateOfBirth = DateTime.parse(fqtvLoginReply.dOB);
//      widget.passengerDetail!.dateOfBirth = DateTime.parse(fqtvLoginReply.dOB);
    }
    if(fqtvLoginReply.member != null && fqtvLoginReply.member!.country != '') {
      gblPassengerDetail!.country = fqtvLoginReply.member!.country;

      if( gblPassengerDetail!.country.length <= 3){
        Countrylist list = await getCountrylist();
        if( list != null && list.countries != null  ) {
          list.countries!.forEach((element) {
            if( element.alpha2code ==gblPassengerDetail!.country ){
              gblPassengerDetail!.country = element.enShortName;
            }
          });
        }
      }
      //widget.passengerDetail!.country = fqtvLoginReply.member!.country;
    }

    gblPassengerDetail!.phonenumber = fqtvLoginReply.phoneMobile;
    if (gblPassengerDetail!.phonenumber == null ||
        gblPassengerDetail!.phonenumber.isEmpty) {
      gblPassengerDetail!.phonenumber = fqtvLoginReply.phoneHome;
    }
    gblFqtvBalance = int.parse(fqtvLoginReply.balance);

    gblPassengerDetail!.email =fqtvLoginReply.email;
//    widget.passengerDetail!.email = fqtvLoginReply.email;
//    widget.joiningDate = fqtvLoginReply.joiningDate;
    gblPassengerDetail!.joiningDate = fqtvLoginReply.joiningDate;

    gblUpcomingFlights = fqtvLoginReply.transactions;
  }

  static String getPaxEmail(){
    if( gblPassengerDetail != null && gblPassengerDetail!.email != ''){
      return gblPassengerDetail!.email;
    }
    if( gblIsLive) return '';

    return gblValidationEmail;
  }

  static bool wantDobForPax(PaxType paxType){

    bool wantDOB = false;
    switch (paxType) {
      case PaxType.adult:
        if( gblSettings.passengerTypes.wantAdultDOB) {
          wantDOB = true;
        }
        break;
      case PaxType.senior:
        if( gblSettings.passengerTypes.wantSeniorDOB) {
          wantDOB = true;
        }
        break;
      case PaxType.student:
        if( gblSettings.passengerTypes.wantStudentDOB) {
          wantDOB = true;
        }
        break;
      case PaxType.youth:
        if( gblSettings.passengerTypes.wantYouthDOB) {
          wantDOB = true;
        }
        break;

      default:
        wantDOB = true;
        break;
    }
    return wantDOB;
  }


}


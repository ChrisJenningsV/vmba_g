
//  *************************
//  manage pax details
//  *************************


import '../data/globals.dart';
import '../data/models/models.dart';
import '../data/models/vrsRequest.dart';
import 'helper.dart';

class PaxManager {
  static  populateFromFqtvMember(FqtvLoginReply fqtvLoginReply, String fqtvNo, String fqtvPass) async {
    if( gblPassengerDetail == null ) {
      gblPassengerDetail = new PassengerDetail( email:  '', phonenumber: '');
    }

    gblFqtvLoggedIn = true;
    gblPassengerDetail!.fqtv = fqtvNo;
    gblPassengerDetail!.fqtvPassword = fqtvPass;

//    widget.passengerDetail!.fqtv = fqtvNo;
//    widget.passengerDetail!.fqtvPassword = fqtvPass;

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
    if( gblPassengerDetail != null ){
      return gblPassengerDetail!.email;
    }
    if( gblIsLive) return '';
    return '';
  }

}


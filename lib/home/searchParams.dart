
import 'package:intl/intl.dart';

import '../components/trText.dart';
import '../data/models/models.dart';

class SearchParams {
  String searchOrigin = '';
  String searchOriginCode = '';
  String searchDestination = '';
  String searchDestinationCode = '';
  Passengers passengers = new Passengers(1, 0, 0, 0, 0, 0, 0);
  DateTime ? departDate;
  DateTime ? returnDate;
  String VoucherCode = '';
  int adults = 1;
  int children = 0;
  int infants = 0;
  int youths = 0;
  int students = 0;
  int seniors = 0;
  int teachers = 0;
  bool isReturn = true;

  void initAirports() {
    searchOrigin = translate('Select departure airport');
    searchDestination = translate('Select arrival airport');
    searchOriginCode = '';
    searchDestinationCode = '';

  }

  void init(){
    searchOrigin = '';
    searchDestination = '';
    departDate = null;
    returnDate = null;
    VoucherCode = '';
  /*  adults = 1;
    children = 0;
    infants = 0;
    youths = 0;
    students = 0;
    seniors = 0;
    teachers = 0;*/
    isReturn = true;

  }


  bool gotAirports(){
    if( searchOrigin!= '' && searchDestination != '' ) return true;
    return false;
  }

  bool gotDates() {
  if(departDate != null && (isReturn == false || returnDate != null)) return true;
    return false;
  }
  bool gotPassengers() {
    return false;
  }

  String toLog() {
    String output = '';

    output += 'o:' + searchOrigin + ', ';
    output += 'd:' + searchDestination + ', ';
    output += 'dd:' + DateFormat('dd/MM/yyyy hh:mm ').format(departDate!) + ', ';
    if( returnDate != null ) {
      output += 'rd:' + DateFormat('dd/MM/yyyy hh:mm ').format(returnDate!) + ',';
    }
    output += 'v:' + VoucherCode + ',';
    output += 'NoA:' + passengers.adults.toString() + ',';
    output += 'NoC:' + passengers.children.toString() + ',';
    output += 'NoI:' + passengers.infants.toString() + ',';
    output += 'NoY:' + passengers.youths.toString() + ',';
    output += 'NoSt:' + passengers.students.toString() + ',';
    output += 'NoS:' + passengers.seniors.toString() + ',';
    output += 'NoT:' + passengers.teachers.toString() + ',';
    output += 'ret:' + isReturn.toString()  + ',';


    return output;
  }
}
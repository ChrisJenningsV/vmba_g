
class SearchParams {
  String searchOrigin = '';
  String searchDestination = '';
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

  void init(){
    searchOrigin = '';
    searchDestination = '';
    departDate = null;
    returnDate = null;
    VoucherCode = '';
    adults = 1;
    children = 0;
    infants = 0;
    youths = 0;
    students = 0;
    seniors = 0;
    teachers = 0;
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
}
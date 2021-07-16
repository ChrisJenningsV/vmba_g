
//
// Building VRS ProcessCimport 'package:vmba/completed/ProcessCommands
//

String addFg(String currency, bool multiPart) {
  var msg;
  if(currency != null && currency.isNotEmpty) {
     msg = 'fg/$currency';
  } else {
    msg = 'fg';
  }
  if( multiPart) {
    msg += '^';
  }
  return msg;
}
String addFareStore(bool multiPart) {
  var msg = 'fs1';
  if( multiPart) {
    msg += '^';
  }
  return msg;
}

String addCreditCard(String currency, double amount, String provider ){
  return 'MK$currency${amount.toStringAsFixed(2)}($provider)';
}
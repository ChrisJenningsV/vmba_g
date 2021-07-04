import 'package:intl/intl.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';





String calenderPrice(String currency, String price, String miles) {
  NumberFormat numberFormat = NumberFormat.simpleCurrency(
      locale: gblSettings.locale, name: currency);
  String _currencySymbol;
  _currencySymbol = numberFormat.currencySymbol;
  if( gblRedeemingAirmiles== true && miles.isNotEmpty){
    // print("Miles =$miles");
    return '$miles ${translate("points")}';
  } else {
    if (price.length == 0) {
      return 'N/A';
    } else {
      return _currencySymbol + price;
    }
  }
}
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/calendar/widgets/langConstants.dart';





String calenderPrice(String currency, String price, String miles) {
//  NumberFormat numberFormat = NumberFormat.simpleCurrency(
 //     locale: gblSettings.locale, name: currency);

  //  String _currencySymbol;
//  _currencySymbol = numberFormat.currencySymbol;
  String _currencySymbol = currency;
  if( gblSettings.wantCurrencySymbols == true ) {
    _currencySymbol = simpleCurrencySymbols[currency] ?? currency;
  }

  //String _currencySymbol =  numberFormat.simpleCurrencySymbol(currency);
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
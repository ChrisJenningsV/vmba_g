import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/calendar/widgets/langConstants.dart';
import 'package:intl/intl.dart';
//import 'package:vmba/data/models/apis_pnr.dart';
import 'package:vmba/data/models/models.dart';




String calenderPrice(String currency, String price, String miles) {
  String _currencySymbol = currency;
  if( gblSettings.wantCurrencySymbols == true ) {
    _currencySymbol = simpleCurrencySymbols[currency] ?? currency;
  }
  if( gblRedeemingAirmiles== true && miles.isNotEmpty){
    return '$miles ${translate("points")}';
  } else {
    if (price.length == 0) {
      return 'N/A';
    } else {
      return _currencySymbol + price;
    }
  }
}

String getIntlDate(String format, DateTime dt ) {
  Intl.defaultLocale = gblLanguage;
  if ( gblSettings.want24HourClock ) {
    format = format.replaceFirst('H:mm a', 'HH:mm');
    format = format.replaceFirst('h:mm a', 'HH:mm');
  }
  String formattedDate = DateFormat(format).format(dt);
  Intl.defaultLocale = 'en';
  return formattedDate;
}


String getPaxTypeCounts(Passengers passengers ) {
  var buffer = new StringBuffer();

  if( passengers.adults != null && passengers.adults > 0 ) {
    buffer.write(',AD=${passengers.adults}');
  }
  if( passengers.children != null &&  passengers.children > 0 ) {
    buffer.write(',CH=${passengers.children}');
  }
  if( passengers.smallChildren != null &&  passengers.smallChildren > 0 ) {
    buffer.write(',CS=${passengers.smallChildren}');
  }
  if(  passengers.seatedInfants != null && passengers.seatedInfants > 0 ) {
    buffer.write(',IS=${passengers.seatedInfants}');
  }
  if(  passengers.infants != null && passengers.infants > 0 ) {
    buffer.write(',IN=${passengers.infants}');
  }
  if(  passengers.youths != null && passengers.youths > 0) {
    buffer.write(',TH=${passengers.youths}');
  }
  if(  passengers.seniors != null && passengers.seniors > 0 ) {
    buffer.write(',CD=${passengers.seniors}');
  }
  if(  passengers.students != null && passengers.students > 0 ) {
    buffer.write(',SD=${passengers.students}');
  }
  if(  passengers.teachers != null && passengers.teachers > 0 ) {
    buffer.write(',TD=${passengers.teachers}');
  }

 return buffer.toString();

}
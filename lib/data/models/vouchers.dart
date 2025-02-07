import 'package:intl/intl.dart';
import 'package:vmba/data/globals.dart';

import '../../utilities/helper.dart';

class FopVouchers {
  List<FopVoucher> vouchers = List.from([FopVoucher()]);

  FopVouchers();

  FopVouchers.fromJson(Map<String, dynamic> json) {
    if (json['fopVouchers'] != null) {
      vouchers = [];
      //new List<Disruption>();
      if (json['fopVouchers'] is List) {
        json['fopVouchers'].forEach((v) {
          vouchers.add(new FopVoucher.fromJson(v));
        });
      } else {
        vouchers.add(new FopVoucher.fromJson(json['fopVouchers']));
      }
    }
  }
}
class FopVoucher {
  String voucherType = '';
  String voucherNumber = '';
  String securityCode = '';
  String voucherCode = '';
  String description='';
  String currency= '';
  double amount = 0;
  double amountUsed = 0;
  double amountRefunded = 0;
  bool multipleUse = true;
  String recipientName = '';
  bool recipientOnly= false;
  String validFromDate = '';
  String validToDate = '';
  String flightsFromDate = '';
  String flightsToDate = '';
  String classes = '';
  bool returnOnly = false;
  String fareCurrency = '';
  bool closed = false;
  bool refunded = false;
  String remarks = '';
  String occasion = '';
  String message = '';
  String recipientEmail = '';
  String senderEmail = '';

  // "routes":{"route":{"depart":"ABZ","arrive":"KOI"}},

  FopVoucher();

  FopVoucher.fromJson(Map<String, dynamic> json) {
//    logit(json.toString());
  try {
    if (json['VoucherType'] != null) voucherType = json['VoucherType'];
    if (json['VoucherNumber'] != null) voucherNumber = json['VoucherNumber'];

    if (json['SecurityCode'] != null) securityCode = json['SecurityCode'];
    if (json['VoucherCode'] != null) voucherCode = json['VoucherCode'];
    if (json['Description'] != null) description = json['Description'];
    if (json['Currency'] != null) currency = json['Currency'];
    if (json['Amount'] != null) amount = json['Amount'];
    if (json['AmountUsed'] != null) amountUsed = json['AmountUsed'];
    if (json['RecipientName'] != null) recipientName = json['RecipientName'];
    if (json['RecipientOnly'] != null) recipientOnly = json['RecipientOnly'];
    if (json['MultipleUse'] != null) multipleUse = json['MultipleUse'];
    if (json['ValidFromDate'] != null) validFromDate = json['ValidFromDate'];
    if (json['FlightsFromDate'] != null) flightsFromDate = json['FlightsFromDate'];
    if (json['FlightsToDate'] != null) flightsToDate = json['FlightsToDate'];
    if (json['Classes'] != null) classes = json['Classes'];

    if (json['ReturnOnly'] != null) returnOnly = json['ReturnOnly'];
    if (json['FareCurrency'] != null) fareCurrency = json['FareCurrency'];
    if (json['Closed'] != null) closed = json['Closed'];
    if (json['Occasion'] != null) occasion = json['Occasion'];
    if (json['Message'] != null) message = json['Message'];
    if (json['RecipientEmail'] != null) recipientEmail = json['RecipientEmail'];
    if (json['SenderEmail'] != null) senderEmail = json['SenderEmail'];
    if (json['Refunded'] != null) refunded = parseBool(json['Refunded']);
    if (json['AmountRefunded'] != null)      amountRefunded = json['AmountRefunded'];
    if (json['Remarks'] != null) remarks = json['Remarks'];
    } catch(e) {
    logit('FopVoucher.fromJson ' + e.toString());
  }
  }

}
import 'package:http/http.dart' as http;

import 'package:vmba/data/globals.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/repository.dart';
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

sendEmailConfirmation(PnrModel pnrModel) async {
  try {
    String msg = '*${pnrModel.pNR.rLOC}^EZRE';
    if( gblLanguage != null && gblLanguage.isNotEmpty && gblLanguage != 'en') {
      msg += '[PLANG=$gblLanguage]';
    }
/*
    http.Response response = await http
        .get(Uri.parse(
        "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg'"))
        .catchError((resp) {});

    if (response == null) {
    }

    //If there was an error return an empty list
    if (response.statusCode < 200 || response.statusCode >= 300) {
    }
*/
    String data = await runVrsCommand(msg);
    print(data
        .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
        .replaceAll('<string xmlns="http://videcom.com/">', '')
        .replaceAll('</string>', ''));
  } catch (e) {
    print(e.toString());
  }
}



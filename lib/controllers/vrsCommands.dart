
import 'dart:convert';

import 'package:vmba/data/globals.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/repository.dart';

import '../utilities/helper.dart';
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
  logit('addCC');
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


void refreshBooking(String rloc) {
  PnrModel? objPNR;
  gblCurrentRloc = rloc;
  try {
    logit('fetchpnr $rloc');
    Repository.get().fetchPnr(rloc).then((pnrDb) {
      if (pnrDb != null) {
        if (pnrDb.success == false) {
          gblError = pnrDb.data;
          return;
        }

        if (pnrDb.success) {
          Map<String, dynamic> map = jsonDecode(pnrDb.data);
          objPNR = new PnrModel.fromJson(map);
//            loadJourneys(objPNR);
        } else {

        }
      } else {
        return;
      }
    }).then((onValue) {
      if (objPNR != null) {
        if( gblVerbose) logit('fetchAPIS $rloc');
        //GET APIS STATUS
        Repository.get()
            .fetchApisStatus(rloc);
        }});

  } catch(e) {
    gblError = e.toString();
    logit(gblError);
  }
}




import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';

import '../components/showDialog.dart';
import '../data/globals.dart';
import '../data/models/vrsRequest.dart';
import '../data/CommsManager.dart';

Future<void> sendUnlockMsg(BuildContext context, String email, void Function() doCallback) async {
  try {
    gblValidationPin2 = gblValidationPin;
    gblValidationPin = generatePin();
    ValidateEmailRequest rq = ValidateEmailRequest(
        email: email, pin: gblValidationPin);

    String data = json.encode(rq);

    String rx = await callSmartApi('VALIDATEEMAIL', data);
    String ok = rx;
    //String ok = await sendValidateEmailMsg(email, gblValidationPin);
    if (ok != 'OK') {
      showVidDialog(context, 'Error', ok);
    } else {
      gblActionBtnDisabled = false;
 /*     _isButtonDisabled = false;
      unlockIsPart2 = true;
*/      doCallback();
    }
  } catch(e) {
    String er= e.toString();
  }
}

String generatePin(){
  String val = '';

  String v1= Random().nextInt(9).toString();
  String v2= Random().nextInt(9).toString();
  String v3= Random().nextInt(9).toString();
  String v4= Random().nextInt(9).toString();

  val = v1 + v2 + v3 + v1 + v4 + v3;

  return val;

}
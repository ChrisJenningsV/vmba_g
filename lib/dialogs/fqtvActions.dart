import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vmba/utilities/navigation.dart';

import '../components/showDialog.dart';
import '../data/globals.dart';
import '../data/models/vrsRequest.dart';
import '../Managers/commsManager.dart';
import '../Managers/PaxManager.dart';
import '../utilities/helper.dart';

void fqtvLogin(BuildContext context, String fqtvNo, String fqtvPass) async {
  gblRedeemingAirmiles = false;
  try {
    String pw = Uri.encodeComponent(fqtvPass);
    //String pw = _passwordEditingController.text;
    FqtvLoginRequest rq = new FqtvLoginRequest( user: fqtvNo,
        password: pw);
    /*
    fqtvNo = _fqtvTextEditingController.text;
    fqtvPass = _passwordEditingController.text;
*/

    String data = json.encode(rq);
    try {
      String reply = await callSmartApi('FQTVLOGIN', data);
      gblActionBtnDisabled = false;
      //      _loadingInProgress = false;
      Map<String, dynamic> map = json.decode(reply);
      FqtvLoginReply fqtvLoginReply = new FqtvLoginReply.fromJson(map);

      gblFqtvLoggedIn = true;
      gblActionBtnDisabled = false;
      Navigator.pop(context);
      PaxManager.populateFromFqtvMember(fqtvLoginReply, fqtvNo, fqtvPass);
      navToFqtvPage(context);

    } catch (e) {
      gblError == e.toString();
      print(gblError);

      showVidDialog(context, 'Information', gblError, onComplete: () {
        gblError = '';
        try {
          gblActionBtnDisabled = false;
          Navigator.of(context).pop();
        } catch(e) {
          gblActionBtnDisabled = false;
          logit('FQTV Login ' + e.toString());
          navToHomepage(context);
        }
      }
      );
/*
      setState(() {
        setError( '');
      });
*/
    }
  } catch(e){
/*
    fqtvNo = '';
    fqtvPass = '';

    _error = e.toString();
    setError( _error);
    _isButtonDisabled = false;
    _loadingInProgress = false;
*/
    showVidDialog(context, gblError,  'Login Error');

/*
    _loadingInProgress = false;
    _actionCompleted();
*/

    return;
  }

}

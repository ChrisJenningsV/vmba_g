import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vmba/utilities/navigation.dart';

import '../components/showDialog.dart';
import '../data/globals.dart';
import '../data/models/vrsRequest.dart';
import '../data/CommsManager.dart';
import '../utilities/PaxManager.dart';
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
      Navigator.pop(context);
      PaxManager.populateFromFqtvMember(fqtvLoginReply, fqtvNo, fqtvPass);
      navToFqtvPage(context);

  /*    widget.passengerDetail = gblPassengerDetail;
      gblError ='';
      _error = '';
      _isButtonDisabled = false;
      _loadingInProgress = false;
      _actionCompleted();

      setState(() {});
*/
    } catch (e) {

      print(gblError);
/*
      _error = gblError;
      _loadingInProgress = false;
*/
      showVidDialog(context, 'Information', gblError, onComplete: () {
        gblError = '';
        try {
          Navigator.of(context).pop();
        } catch(e) {
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




import 'package:flutter/material.dart';
import 'package:vmba/data/models/dialog.dart';
import 'package:vmba/dialogs/smartDialog.dart';
import 'package:vmba/menu/appFeedBackPage.dart';

import '../components/showDialog.dart';
import '../data/globals.dart';
import '../forms/genericFormPage.dart';
import '../menu/myFqtvPage.dart';
import '../utilities/helper.dart';
import '../utilities/navigation.dart';
import 'fqtvActions.dart';

Future<void> doDialogAction(BuildContext context, DialogDef dialog, DialogFieldDef? field, void Function() doUpdate ) async {
  String action='';
  gblActionBtnDisabled = true;

  if( field != null ) {
    action =  field.action;
  } else {
    action = dialog.action;
  }

  switch( action.toUpperCase()){
    case 'FQTVREGISTER':
      navToSmartDialogHostPage(context, new FormParams(formName: 'FQTVREGISTER',
          formTitle: '${gblSettings.fqtvName} Registration'));
      break;
    case 'FQTVLOGIN':
      navToSmartDialogHostPage(context, new FormParams(formName: 'FQTVLOGIN',
          formTitle: '${gblSettings.fqtvName} Registration'));
      break;
    case 'FQTVRESET':
      navToSmartDialogHostPage(context, new FormParams(formName: 'FQTVRESET',
          formTitle: '${gblSettings.fqtvName} Reset Password'));
      break;
    case 'DOFQTVRESET':
      // chack value input
    String er = validateEmail(dialog.editingControllers[0].value.text);
    if( er == '' ){
      // send reset request
      fqtvResetPassword(context, dialog.editingControllers[0].value.text);
    } else {
      showVidDialog(context, 'Error', er, type: DialogType.Error);
    }
      break;
    case 'DOFQTVLOGIN':
      String FqtvNo = dialog.editingControllers[0].value.text;
      String FqtvPw = dialog.editingControllers[1].value.text;
      if( FqtvNo == '' || FqtvPw == '') {
        showVidDialog(context, 'Error', 'Please complete all details',
            type: DialogType.Error);
      } else {
        fqtvLogin(context, FqtvNo, FqtvPw);
      }
      break;
    case 'DODEVELOPERLOGIN':
      String No = dialog.editingControllers[0].value.text;
      String Pw = dialog.editingControllers[1].value.text;
      if( No == '' || Pw == '') {
        showVidDialog(context, 'Error', 'Please complete all details',
            type: DialogType.Error);
      } else {
        String result = await devSineIn(context, No, Pw);
        if( result == 'OK') {

          Navigator.pop(context);
        } else {
          showVidDialog(context, 'Error', result ,
              type: DialogType.Error);
        }
      }
      break;

  }


}
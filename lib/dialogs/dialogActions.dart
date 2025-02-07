


import 'package:flutter/material.dart';
import 'package:vmba/data/models/dialog.dart';
import 'package:vmba/dialogs/registerActions.dart';
import 'package:vmba/dialogs/smartDialog.dart';
import 'package:vmba/menu/appFeedBackPage.dart';

import '../components/showDialog.dart';
import '../data/globals.dart';
import '../data/repository.dart';
import '../utilities/PaxManager.dart';
import 'genericFormPage.dart';
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

    case 'DOREQUESTPIN':
      String email = dialog.editingControllers[0].value.text;
      if( (email == '' || validateEmail(email) != '') && gblValidationEmail == ''  ) {
        showVidDialog(context, 'Error', 'Please enter a valid email',
            type: DialogType.Error);
      } else {
        if(gblValidationEmail == '') gblValidationEmail = email;
        sendUnlockMsg(context, gblValidationEmail, () {
          showSnackBar('PIN email request sent', context,duration: Duration(seconds: 10),);
          Navigator.pop(context);
          doUpdate();
          navToSmartDialogHostPage(context, new FormParams(formName: 'VALIDATEPIN',
              formTitle: 'Validate PIN'));

        });
      }
      break;
    case 'DORESENDPIN':
      String email = dialog.editingControllers[0].value.text;
      if( (email == '' || validateEmail(email) != '') && gblValidationEmail == ''  ) {
        showVidDialog(context, 'Error', 'Please enter a valid email',
            type: DialogType.Error);
      } else {
        if(gblValidationEmail == '') gblValidationEmail = email;
        sendUnlockMsg(context, gblValidationEmail, () {
          showSnackBar('PIN email request sent', context,duration: Duration(seconds: 10),);
//          Navigator.pop(context);
          doUpdate();
          navToSmartDialogHostPage(context, new FormParams(formName: 'VALIDATEPIN',
              formTitle: 'Validate PIN'));

        });
      }
      break;

    case 'DOVALIDATEPIN':
      gblValidationPinTries +=1;
      String pinInput = dialog.editingControllers[0].text +  dialog.editingControllers[1].text +  dialog.editingControllers[2].text +
          dialog.editingControllers[3].text +  dialog.editingControllers[4].text +  dialog.editingControllers[5].text;
      if( pinInput == gblValidationPin || (gblValidationPin2 != '' && pinInput == gblValidationPin2 )) {
/*
        PaxManager.populate(gblValidationEmail);
        PaxManager.save();
*/
        gblIsNewInstall = false;
        await Repository.get().settings();
        // save new email etc in my account
        String firstName = '', lastName = '', title = '', dOB = '';
        if( gblTrips != null &&  gblTrips!.trips != null && gblTrips!.trips!.length > 0){
          firstName = gblTrips!.trips![0].firstname;
          lastName = gblTrips!.trips![0].lastname;
          title = gblTrips!.trips![0].title;
          dOB = gblTrips!.trips![0].DOB;
        }
        PaxManager.populate(gblValidationEmail, firstName: firstName, title: title, lastName: lastName, dOB: dOB);
        PaxManager.save();
        navToHomepage(context);

      } else {
        logit('bad PIN $gblValidationPinTries');
        if( gblValidationPinTries < 5) {
          showSnackBar(
            'PIN does not match $gblValidationPinTries tries ', context,
            duration: Duration(minutes: 1),);
        } else {
          gblValidationEmail = '';
          gblValidationPin = '';
          gblValidationPinTries = 0;
          navToHomepage(context);
        }
      }
        break;

  }
}
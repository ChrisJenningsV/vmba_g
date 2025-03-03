


import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:vmba/Managers/commsManager.dart';
import 'package:vmba/data/models/dialog.dart';
import 'package:vmba/dialogs/registerActions.dart';
import 'package:vmba/dialogs/smartDialog.dart';
import 'package:vmba/menu/appFeedBackPage.dart';

import '../components/showDialog.dart';
import '../data/globals.dart';
import '../data/models/vrsRequest.dart';
import '../data/repository.dart';
import '../menu/debug.dart';
import '../Managers/PaxManager.dart';
import 'genericFormPage.dart';
import '../menu/myFqtvPage.dart';
import '../utilities/helper.dart';
import '../utilities/navigation.dart';
import 'fqtvActions.dart';

Future<void> doDialogAction(BuildContext context, DialogFieldDef? field, void Function() doUpdate ) async {
  String action='';
  gblActionBtnDisabled = true;

  if( field != null ) {
    action =  field.action;
  } else {
    action = gblCurDialog!.action;
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
    String er = validateEmail(gblCurDialog!.editingControllers[0].value.text);
    if( er == '' ){
      // send reset request
      fqtvResetPassword(context, gblCurDialog!.editingControllers[0].value.text);
    } else {
      showVidDialog(context, 'Error', er, type: DialogType.Error);
    }
      break;
    case 'DOFQTVLOGIN':
      String FqtvNo = gblCurDialog!.editingControllers[0].value.text;
      String FqtvPw = gblCurDialog!.editingControllers[1].value.text;
      if( FqtvNo == '' || FqtvPw == '') {
        showVidDialog(context, 'Error', 'Please complete all details',
            type: DialogType.Error);
      } else {
        fqtvLogin(context, FqtvNo, FqtvPw);
      }
      break;
    case 'DODEVELOPERLOGIN':
      String No = gblCurDialog!.editingControllers[0].value.text;
      String Pw = gblCurDialog!.editingControllers[1].value.text;
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
    case 'DODARKSITEADMIN':
      // save local
      gblSettings.darkSiteTitle =gblCurDialog!.editingControllers[1].value.text;
      gblSettings.darkSiteMessage =gblCurDialog!.editingControllers[2].value.text;
      gblSettings.darkSiteEnabled = parseBool(getGblValue('dark'));
      // save to server
      SaveSettingsRequest saveSettingsRequest = new SaveSettingsRequest();
      saveSettingsRequest.settingsList!.add(MobileSetting('darkSiteEnabled', gblSettings.darkSiteEnabled.toString()));
      saveSettingsRequest.settingsList!.add(MobileSetting('darkSiteMessage', gblSettings.darkSiteMessage));
      saveSettingsRequest.settingsList!.add(MobileSetting('darkSiteTitle', gblSettings.darkSiteTitle));
      if( gblSettings.darkSiteEnabled && (gblSettings.darkSiteMessage == '' || gblSettings.darkSiteTitle == '')) {
        showVidDialog(context, 'Error', 'Please complete Message and Title to save',
            type: DialogType.Error);
      } else {
        String data = json.encode(saveSettingsRequest);
        String reply = await callSmartApi('SAVESETTINGS', data);
        if (reply == 'OK' || reply == '') {
          showVidDialog(context, 'Success', 'Settings saved',
              type: DialogType.Information, onComplete: () {
                // go home
                navToHomepage(context);
              });
        } else {
          showVidDialog(context, 'Error', reply, type: DialogType.Error);
        }
      }
      break;
    case 'DOSEATADMIN':
    // save local
      gblSettings.seatStyle =gblCurDialog!.editingControllers[0].value.text;
      gblSettings.seatPriceStyle =gblCurDialog!.editingControllers[1].value.text;
      // save to server
/*
      SaveSettingsRequest saveSettingsRequest = new SaveSettingsRequest();
      saveSettingsRequest.settingsList!.add(MobileSetting('darkSiteEnabled', gblSettings.darkSiteEnabled.toString()));
      saveSettingsRequest.settingsList!.add(MobileSetting('darkSiteMessage', gblSettings.darkSiteMessage));
      saveSettingsRequest.settingsList!.add(MobileSetting('darkSiteTitle', gblSettings.darkSiteTitle));
      if( gblSettings.darkSiteEnabled && (gblSettings.darkSiteMessage == '' || gblSettings.darkSiteTitle == '')) {
        showVidDialog(context, 'Error', 'Please complete Message and Title to save',
            type: DialogType.Error);
      } else {
        String data = json.encode(saveSettingsRequest);
        String reply = await callSmartApi('SAVESETTINGS', data);
        if (reply == 'OK' || reply == '') {
          showVidDialog(context, 'Success', 'Settings saved',
              type: DialogType.Information, onComplete: () {
                // go home
                navToHomepage(context);
              });
        } else {
          showVidDialog(context, 'Error', reply, type: DialogType.Error);
        }
      }
*/
      Navigator.pop(context);
      break;

    case 'DOAGENTLOGIN':
      String No = gblCurDialog!.editingControllers[0].value.text;
      String Pw = gblCurDialog!.editingControllers[1].value.text;
      if( No == '' || Pw == '') {
        showVidDialog(context, 'Error', 'Please complete all details',
            type: DialogType.Error);
      } else {
        String result = await devSineIn(context, No, Pw);
        if( result == 'OK') {
          if( gblSecurityLevel >= 99) {
            Navigator.push(context,
                SlideTopRoute(page: DebugPage(name: 'ADMIN',)));
          }
        } else {
          showVidDialog(context, 'Error', result ,
              type: DialogType.Error);
        }
      }
      break;

    case 'DOREQUESTPIN':
      String email = gblCurDialog!.editingControllers[0].value.text;
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
      String email = gblCurDialog!.editingControllers[0].value.text;
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
      String pinInput = gblCurDialog!.editingControllers[0].text +  gblCurDialog!.editingControllers[1].text +  gblCurDialog!.editingControllers[2].text +
          gblCurDialog!.editingControllers[3].text +  gblCurDialog!.editingControllers[4].text +  gblCurDialog!.editingControllers[5].text;
      if( pinInput == gblValidationPin || (gblValidationPin2 != '' && pinInput == gblValidationPin2 )) {
/*
        PaxManager.populate(gblValidationEmail);
        PaxManager.save();
*/
        gblIsNewInstall = false;
        await Repository.get().settings();
        // save new email etc in my account
        String firstName = '', lastName = '', title = '', dOB = '', phone = '';
        if( gblTrips != null &&  gblTrips!.trips != null && gblTrips!.trips!.length > 0){
          firstName = gblTrips!.trips![0].firstname;
          lastName = gblTrips!.trips![0].lastname;
          title = gblTrips!.trips![0].title;
          dOB = gblTrips!.trips![0].DOB;
          phone = gblTrips!.trips![0].phone;
        }
        PaxManager.populate(gblValidationEmail, firstName: firstName, title: title, lastName: lastName, dOB: dOB, phone: phone);
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
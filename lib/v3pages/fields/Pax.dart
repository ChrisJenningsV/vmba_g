

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/data/globals.dart';

import '../../Helpers/settingsHelper.dart';
import '../../components/pageStyleV2.dart';
import '../../components/trText.dart';
import '../../utilities/helper.dart';



Widget paxGetFirstName(TextEditingController firstNameTextEditingController, {required void Function(String) onFieldSubmitted,required void Function(String) onSaved}) {
  return V2TextWidget(
    maxLength: 50,
    styleVer: gblSettings.styleVersion,
    decoration: _getDecoration('First name (as Passport)'),
    controller: firstNameTextEditingController,
    onFieldSubmitted: (value) { onFieldSubmitted(value);
    },
    textInputAction: TextInputAction.done,
    // keyboardType: TextInputType.text,
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp("[a-zA-Z- ÆØøäöåÄÖÅæé]"))
    ],
    validator: (value) =>
    value!.isEmpty ? translate('First name cannot be empty') : null,
    onSaved: (value) {
      if (value != null) {
        onSaved(value);
      }
    },
  );
}

Widget paxGetMiddleName(TextEditingController middleNameTextEditingController, {required void Function(String) onFieldSubmitted,required void Function(String) onSaved}) {
  return V2TextWidget(
    maxLength: 50,
    styleVer: gblSettings.styleVersion,
    decoration: _getDecoration('Middle name (or NONE)'),
    controller: middleNameTextEditingController,
    onFieldSubmitted: (value) {
      onFieldSubmitted(value);
    },
    textInputAction: TextInputAction.done,
    // keyboardType: TextInputType.text,
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp("[a-zA-Z- ÆØøäöåÄÖÅæé]"))
    ],
    validator: (value) =>
    value!.isEmpty ? translate(
        'Middle name cannot be empty - type NONE if none') : null,
    onSaved: (value) {
      if (value != null) {
        onSaved(value.trim());
      }
    },
  );
}

Widget paxGetLastName(TextEditingController lastNameTextEditingController, {required void Function(String) onFieldSubmitted,required void Function(String) onSaved}) {
  return   V2TextWidget(
    maxLength: 50,
    styleVer: gblSettings.styleVersion,
    decoration: _getDecoration('Last name (as Passport)'),
    controller: lastNameTextEditingController,
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp("[a-zA-Z- ÆØøäöåÄÖÅæé]"))
    ],
    onFieldSubmitted: (value) {
      onFieldSubmitted(value);
    },
    validator: (value) =>
    value!.isEmpty ? translate('Last name cannot be empty') : null,
    onSaved: (value) {
      if (value != null) {
        onSaved(value);
      }
    },
  );
}

Widget paxGetEmail(TextEditingController emailTextEditingController, {required void Function(String) onFieldSubmitted,required void Function(String) onSaved}) {
  return V2TextWidget(
    maxLength: 50,
    styleVer: gblSettings.styleVersion,
    decoration: _getDecoration('Email'),
    autovalidateMode: AutovalidateMode.onUserInteraction,
    controller: emailTextEditingController,
    inputFormatters: [
      FilteringTextInputFormatter.deny(RegExp("[#'!£^&*(){},|]"))
    ],
    keyboardType: TextInputType.emailAddress,
    validator: (value) {
      String er = validateEmail(value!.trim());
      if(er != '' ) return er;
      return null;

    },
    onFieldSubmitted: (value) {
      onFieldSubmitted( value);
    },
    onSaved: (value) {
      if (value != null) {
        onSaved( value.trim());
      }
    },
  );
}

Widget paxGetPhoneNumber(TextEditingController phoneTextEditingController, {required void Function(String) onFieldSubmitted,required void Function(String) onSaved}){
  return V2TextWidget(
    maxLength: 50,
    styleVer: gblSettings.styleVersion,
    decoration: _getDecoration('Phone Number'),
    controller: phoneTextEditingController,
    keyboardType: TextInputType.number,
    validator: (value) =>
    value!.isEmpty ? translate('Phone Number cannot be empty') : null,
    onFieldSubmitted: (value) {
      onFieldSubmitted(value);
    },
    onSaved: (value) {
      if (value != null) {
        onSaved(value.trim());
      }
    },
  );
}

Widget paxGetTitle(BuildContext context,TextEditingController titleTextEditingController, void Function (String) updateTitle){
  return InkWell(
    onTap: () {
      //formSave();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new TrText('Salutation'),
            content: new Container(
              width: double.maxFinite,
              child: optionListView(context, updateTitle),
            ),
          );
        },
      );
    },
    child: IgnorePointer(
      child: _getTitle(context, titleTextEditingController ),
    ),
  );
}

Widget _getTitle(BuildContext context,TextEditingController titleTextEditingController ){
  if( wantPageV2()) {
    return v2BorderBox(context,  ' ' + translate('Title'),
      TextFormField(
        decoration: v2Decoration(),

        controller: titleTextEditingController,
        validator: (value) =>
        value!.isEmpty ? translate('Title cannot be empty') : null,
        onSaved: (value) {
          if (value != null) {
          }
        },
      ),
      padding: EdgeInsets.only(left: 10, right: 10),
    );
  } else {
    return TextFormField(
      decoration: getDecoration('Title'),
      // initialValue: translate(widget.passengerDetail.title),

      controller: titleTextEditingController,
      validator: (value) =>
      value!.isEmpty ? translate('Title cannot be empty') : null,
      onSaved: (value) {
        if (value != null) {
          //widget.passengerDetail.title = value.trim();
          //_titleTextEditingController.text =translate(widget.passengerDetail.title);
        }
      },
    );
  }
}

ListView optionListView(BuildContext context, void Function (String) updateTitle) {
  List<Widget> widgets = [];
  //new List<Widget>();
  gblTitles.forEach((title) => widgets.add(ListTile(
      title: TrText(title),
      onTap: () {
        Navigator.pop(context, title);
        updateTitle(title);
      })));
  return new ListView(
    children: widgets,
  );
}




InputDecoration _getDecoration( String label){
 /*
  if( gblSettings.styleVersion  == 3){
    Color labelColor = Colors.grey;
    if( gblSystemColors.primaryHeaderColor != Colors.white){
      labelColor = gblSystemColors.primaryHeaderColor;
    }
      return InputDecoration(
        fillColor: Colors.white,
        filled: true,
        counterText: '',
        hintText: label,
        //prefixIcon: prefixIcon,

        labelStyle: TextStyle(color: labelColor),
        labelText: translate(label),
      );
  }*/
  return getDecoration(label);
}


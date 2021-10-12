//library international_phone_input;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
//import 'package:international_phone_input/src/phone_service.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/passengerDetails/widgets/Country.dart';
import 'package:vmba/utilities/helper.dart';

class InternationalPhoneInput extends StatefulWidget {
  final void Function(String phoneNumber, String internationalizedPhoneNumber,      String isoCode) onPhoneNumberChange;
  final String initialPhoneNumber;
  final String initialSelection;
  final String errorText;
  final String hintText;
  final String labelText;
  final TextStyle errorStyle;
  final TextStyle hintStyle;
  final TextStyle labelStyle;
  final int errorMaxLines;
  final List<String> enabledCountries;
  final InputDecoration decoration;
  final Widget dropdownIcon;
  final InputBorder border;
  final EdgeInsetsGeometry padding;
  final String popupTitle;
  final TextEditingController controller;
  TextEditingController codeController;
  final ValueChanged<String> onSaved;

  InternationalPhoneInput(
      {this.onPhoneNumberChange,
        this.initialPhoneNumber,
        this.initialSelection,
        this.errorText,
        this.hintText,
        this.labelText,
        this.errorStyle,
        this.hintStyle,
        this.labelStyle,
        this.enabledCountries = const [],
        this.errorMaxLines,
        this.decoration,
        this.dropdownIcon,
        this.border, this.padding,
        this.popupTitle,
        this.controller,
        this.codeController,
        this.onSaved,
      });

/*  static Future<String> internationalizeNumber(String number, String iso) {
    return PhoneService.getNormalizedPhoneNumber(number, iso);
  }

 */

  @override
  _InternationalPhoneInputState createState() =>
      _InternationalPhoneInputState();
}

class _InternationalPhoneInputState extends State<InternationalPhoneInput> {
  Country selectedItem;
  List<Country> itemList = [];


  String errorText;
  String hintText;
  String labelText;

  TextStyle errorStyle;
  TextStyle hintStyle;
  TextStyle labelStyle;

  int errorMaxLines;

  bool hasError = false;
  String searchString;

  InputDecoration decoration;
  Widget dropdownIcon;
  InputBorder border;

  _InternationalPhoneInputState();

  //final phoneTextController = TextEditingController();

  @override
  void initState() {
    errorText = widget.errorText ?? 'Please enter a valid phone number';
    hintText = widget.hintText ?? 'Code';
    labelText = widget.labelText;
    errorStyle = widget.errorStyle;
    hintStyle = widget.hintStyle;
    labelStyle = widget.labelStyle;
    errorMaxLines = widget.errorMaxLines;
    decoration = widget.decoration;
    dropdownIcon = widget.dropdownIcon;
    searchString = '';

    //phoneTextController.addListener(_validatePhoneNumber);
    //phoneTextController.text = widget.initialPhoneNumber;
    widget.codeController = new TextEditingController();


    _fetchCountryData().then((list) {
      Country preSelectedItem;

      if (widget.initialSelection != null) {
        preSelectedItem = list.firstWhere(
                (e) =>
            (e.code.toUpperCase() ==
                widget.initialSelection.toUpperCase()) ||
                (e.dialCode == widget.initialSelection.toString()),
            orElse: () => list[0]);
      } else if (widget.initialPhoneNumber != null && widget.initialPhoneNumber.isNotEmpty) {
        preSelectedItem = list.firstWhere(
                (e) =>
            (widget.initialPhoneNumber.toUpperCase().startsWith(e.dialCode)),
            orElse: () => list[0]);
      } else if (widget.codeController.text != null && widget.codeController.text.isNotEmpty) {
        preSelectedItem = list.firstWhere(
                (e) =>
            (e.code.toUpperCase() ==
                widget.codeController.text.toUpperCase()) ||
                (e.dialCode == widget.codeController.text.toString()),
            orElse: () => list[0]);
      } else if (gblSettings.defaultCountryCode != null && gblSettings.defaultCountryCode.isNotEmpty) {
        preSelectedItem = list.firstWhere(
                (e) =>
            (e.code.toUpperCase() ==
                gblSettings.defaultCountryCode),
            orElse: () => list[0]);
      } else {
        preSelectedItem = list[0];
      }
      if(preSelectedItem != null)  {
        widget.codeController.text = preSelectedItem.dialCode ;
        // strip off code
        //phoneTextController.text = widget.initialPhoneNumber.substring(preSelectedItem.dialCode.length);
        widget.controller.text = widget.initialPhoneNumber.substring(preSelectedItem.dialCode.length);
      }

      setState(() {
        itemList = list;
        selectedItem = preSelectedItem;
      });
    });

    super.initState();
  }

  /*
  _validatePhoneNumber() {
    String phoneText = phoneTextController.text;
    if (phoneText != null && phoneText.isNotEmpty && selectedItem != null ) {
      PhoneService.parsePhoneNumber(phoneText, selectedItem.code)
          .then((isValid) {
        setState(() {
          hasError = !isValid;
        });

        if (widget.onPhoneNumberChange != null) {
          if (isValid) {
            PhoneService.getNormalizedPhoneNumber(phoneText, selectedItem.code)
                .then((number) {
              widget.onPhoneNumberChange(phoneText, number, selectedItem.code);
            });
          } else {
            widget.onPhoneNumberChange('', '', selectedItem.code);
          }
        }
      });
    }
  }

   */

  Future<List<Country>> _fetchCountryData() async {
    var list = await DefaultAssetBundle.of(context)
        .loadString('lib/assets/countryCodes.json');
    List<dynamic> jsonList = json.decode(list);

    List<Country> countries = List<Country>.generate(jsonList.length, (index) {
      Map<String, String> elem = Map<String, String>.from(jsonList[index]);
      if (widget.enabledCountries.isEmpty) {
        return Country(
            name: elem['en_short_name'],
            code: elem['alpha_2_code'],
            dialCode: elem['dial_code'],
            flagUri: 'assets/flags/${elem['alpha_2_code'].toLowerCase()}.png');
      } else if (widget.enabledCountries.contains(elem['alpha_2_code']) ||
          widget.enabledCountries.contains(elem['dial_code'])) {
        return Country(
            name: elem['en_short_name'],
            code: elem['alpha_2_code'],
            dialCode: elem['dial_code'],
            flagUri: 'assets/flags/${elem['alpha_2_code'].toLowerCase()}.png');
      } else {
        return null;
      }
    });

    countries.removeWhere((value) => value == null);

    return countries;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widget.padding,
      child: Row( children: [
      SizedBox(
        width: 80,
          child: InkWell(
        onTap: () {
          //formSave();
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return CodeDialog(
                popupTitle: widget.popupTitle,
                itemList: itemList,
                onChanged: (country) {
                  setState(() {
                    selectedItem = country;
                    widget.codeController.text = country.dialCode;

                  });
                },
              );
            },
          );
        },
        child: IgnorePointer(
          child: TextFormField(

            decoration: InputDecoration(
              fillColor: Colors.grey.shade100,
              filled: true,
              //prefix: (selectedItem != null ) ? Image.asset(selectedItem.flagUri,width: 20.0,package: 'international_phone_input',) : null ,
              counterText: '',
              labelText: 'code', //(selectedItem != null ) ? selectedItem.name : 'code',
              hintText: hintText,
              labelStyle: TextStyle(color: Colors.grey),
              border: new OutlineInputBorder( borderSide: BorderSide( color: Colors.grey.shade200 ) )
            ),

            

            //decoration: getDecoration('CC'),
            controller: widget.codeController,
            //validator: (value) => value.isEmpty ? translate('Cannot be empty') : null,
            onSaved: (value) {
              if (value != null) {
                widget.onSaved(value + widget.controller.text);
                //widget.passengerDetail.title = value.trim();
              }
            },
          ),
        ),
      )),

    Flexible( child:
     TextFormField(
       decoration: getDecoration('Phone number'),
       keyboardType: TextInputType.phone,
      controller: widget.controller,
      validator: (value) =>      value.isEmpty ? translate('Phone number cannot be empty') : null,
      onSaved: (value) {
        if (value != null) {
          //widget.passengerDetail.title = value.trim();
        }
      },
    ),
    )],
    

      ));
  }

}
class CodeDialog extends StatefulWidget {
  final String popupTitle;
  String searchString;
  Country selectedItem;
  final List<Country> itemList ;
  final ValueChanged<Country> onChanged;

  CodeDialog({
    this.searchString,
    this.popupTitle,
    this.itemList,
    this.onChanged,
    this.selectedItem,
  });

  @override
  CodeDialogState createState() => new CodeDialogState();
}

class CodeDialogState extends State<CodeDialog> {

  @override void initState() {
    widget.searchString = '';

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
        return AlertDialog(
          title: new Text(widget.popupTitle),
          content: new Container(
            padding: EdgeInsets.only(right: 5),
            width: double.maxFinite,
            child: optionListView(),
          ),
        );
      }

  ListView optionListView() {
    List<Widget> widgets = [];
    widgets.add(TextFormField(

      decoration: InputDecoration(
        fillColor: Colors.grey.shade100,
        filled: true,
        prefixIcon: Icon(Icons.search),
        hintText: translate('Search'),
        counterText: '',
        labelStyle: TextStyle(color: Colors.grey),
      ),

      keyboardType: TextInputType.name,
      onChanged: (value) {
        setState(() {
          widget.searchString = value.toUpperCase();
        });
      }
      ,
//      controller: widget.controller,
      //validator: (value) =>      value.isEmpty ? translate('Cannot be empty') : null,
      onSaved: (value) {
        if (value != null) {
          //widget.passengerDetail.title = value.trim();
        }
      },
    ));
    //new List<Widget>();
    widget.itemList.forEach((country) {
      String match = country.name.toUpperCase();
      if( widget.searchString.isEmpty || match.startsWith(widget.searchString)) {
        widgets.add(ListTile(
            title: Row(
                children: [
                  Image.asset(
                    country.flagUri,
                    width: 32.0,
                    package: 'international_phone_input',
                  ),
                  Padding(padding: EdgeInsets.only(left: 5.0,),),
                  Flexible(
                    child:
                    Text(translate(country.name),),
                  )

                ]),
            onTap: () {
              widget.onChanged(country);
              Navigator.pop(context, country.dialCode);
              _updateTitle(country);
            }));
      }
    });
    return new ListView(
      children: widgets,
    );
  }
  void _updateTitle(Country value) {
    setState(() {
      widget.selectedItem = value;
      if( value != null ) {
        //widget.codeController.text = value.dialCode;
        //widget.controller.text = value.name;
        //FocusScope.of(context).requestFocus(new FocusNode());
      }
    });
  }

}
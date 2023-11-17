import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/utilities/helper.dart';

import '../../data/models/providers.dart';
import '../../data/repository.dart';



class VInputField extends StatefulWidget {
  final FieldParams?  fieldParams;
  final Provider? provider;
  final PnrModel? pnrModel;

  const VInputField({
    Key key= const Key("vinput_key"),
    this.fieldParams,
    this.provider,
    this.pnrModel}) : super(key: key);

  @override
  VInputFieldState createState() => VInputFieldState();
}

class VInputFieldState extends State<VInputField> {

  late TextEditingController _textEditingController;
  String taxAmount = '';


  @override
  void initState() {
    super.initState();

    _textEditingController = new TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = ThemeData(
          primaryColor: Colors.blueAccent,
          primaryColorDark: Colors.blue,
        );


    if ( widget.fieldParams!.ftype == FieldType.country) {
      return Padding(
        padding: EdgeInsets.fromLTRB(0, 8.0, 0, 8),
        child: new Theme(
          data: theme,
          child: countryPicker(EdgeInsets.fromLTRB(0, 8.0, 0, 8), theme)!,
        ),
      );
    }
    if ( widget.fieldParams!.ftype == FieldType.choice) {
      return Padding(
        padding: EdgeInsets.fromLTRB(0, 8.0, 0, 8),
        child: new Theme(
          data: theme,
          child: choicePicker(EdgeInsets.fromLTRB(0, 8.0, 0, 8), theme)!,
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(0, 8.0, 0, 8),
      child: new Theme(
        data: theme ,
        child: TextFormField(
          maxLength: widget.fieldParams!.maxLength,
          decoration:getDecoration(widget.fieldParams!.label),

          controller: _textEditingController,
          onFieldSubmitted: (value) {
            //widget.passengerDetail.firstName = value;
            if( gblPayFormVals == null ) {
              gblPayFormVals = new Map();
            }
//            if( gblPayFormVals.containsKey(widget.fieldParams.id)){
              gblPayFormVals![widget.fieldParams!.id] = value;
          },

          textInputAction: TextInputAction.done,
          // keyboardType: TextInputType.text,
          inputFormatters: widget.fieldParams!.inputFormatters,
          validator: (value) {
            if( widget.fieldParams!.required == false ) return null;
            return value!.isEmpty ? translate('${widget.fieldParams!.label}') + ' ' + translate('cannot be empty') : null;

          },
          onSaved: (value) {
            if (value != null) {
              if( gblPayFormVals == null ) {
                gblPayFormVals = new Map();
              }
//            if( gblPayFormVals.containsKey(widget.fieldParams.id)){
              gblPayFormVals![widget.fieldParams!.id] = value;
            }
          },
        ),
      ),
    );
  }

  void _showDialog(
      String label,

      ) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(label),
          content: Container(
            width: double.maxFinite,
            child: new ListView(
              children: optionList(widget.fieldParams!.options),
            ),
            /*           child: new Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  optionList(sectionname, field.choices, field.displayname),
            ),*/
          ),
        );
      },
    );
  }
  List<Widget> optionList(String choices) {
    List<Widget> widgets = [];
    // new List<Widget>();
    choices.split(',').forEach((c) {
      widgets.add(ListTile(
        title: Text(c),
        onTap: () {
          _textEditingController.text = c;
          if( gblPayFormVals == null ) {
            gblPayFormVals = new Map();
          }
          gblPayFormVals![widget.fieldParams!.id] = c;
          setState(() {

          });

          Navigator.pop(context, c);
        }
        )
      );
    });
    return widgets;
  }

  Widget? choicePicker(EdgeInsetsGeometry padding, ThemeData theme) {
    return InkWell(
      onTap: () {
        _showDialog(widget.fieldParams!.label);
      },
      child: IgnorePointer(
        child: Column( 
      children: [
        TextFormField(
      decoration:getDecoration(widget.fieldParams!.label),


      controller: _textEditingController,
      onFieldSubmitted: (value) {
      },
      textInputAction: TextInputAction.done,
      // keyboardType: TextInputType.text,
      //inputFormatters: widget.fieldParams!.inputFormatters,
      validator: (value) {
        if( widget.fieldParams!.required == false ) return null;
        return value!.isEmpty ? translate('${widget.fieldParams!.label}') +
            ' ' + translate('cannot be empty') : null;
      },
      onSaved: (value) {
      },
    ),
        // assum cc type selection as only choice currently
        FutureBuilder<String>(
            future: getCCFeeMsg(), // function where you call your api
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {  // AsyncSnapshot<Your object type>
              if( snapshot.connectionState == ConnectionState.waiting){
                return  Center(child: Text('Please wait its loading...'));
              }else{
                if (snapshot.hasError)
                  return Center(child: Text('Error: ${snapshot.error}'));
                else
                  return Center(child: new Text('${snapshot.data}', style: TextStyle(color: Colors.red),textScaleFactor: 0.75,));  // snapshot.data  :- get your object which is pass from your downloadData() function
              }
            },
        )

        ])
    )
    );
  }

  Future<String>  getCCFeeMsg() async {
    if(_textEditingController.text == 'Corporate' ) {
      if( taxAmount == '') {
        var amount = widget.pnrModel!.pNR.basket.outstanding.amount;
        var cur = widget.pnrModel!.pNR.basket.outstanding.cur;
        String cmd = 'MCC/4010400000000000/${cur}${amount}[provider=${widget
            .provider?.paymentSchemeName}]~X';

        String data = await runVrsCommand(cmd);
        Map mccmap = json.decode(data);
        Map map = mccmap['mcc'];

        if( map['currency'] == cur) {
          taxAmount = map['currency'] + map['value'];
        } else {
          // need to convert currency!
          //cmd = 'ME/$cur${map['value']}/${2}"
        }
      }

      if( taxAmount != '') {
        return Future.value(translate('Use of Corporate Credit Card – Fee applicable') + ' $taxAmount');
      } else {
        return Future.value(translate('For corporate cards a fee will apply.'));
      }
    }
    return Future.value('');
  }



  Widget? countryPicker(EdgeInsetsGeometry padding, ThemeData theme) {
    // get current country index

    return FutureBuilder(
        future: getCountrylist(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data != null) {
              Countrylist countrylist = snapshot.data;
              // String val = countrylist.countries[0].enShortName;
              var curIndex ;
              var index = 0;
              if(widget.fieldParams!.defaultVal == null ) {
                countrylist.countries!.map((country) {
                  if (widget.fieldParams!.defaultVal.toUpperCase() ==
                      country.enShortName.toUpperCase()) {
                    curIndex = index;
                  }
                  index += 1;
                });
              }
              return Padding(

                  padding: padding,
                  child: new Theme(
                      data: theme,
                      child: DropdownButtonFormField<int>(
                        decoration: getDecoration('Country'),
                        value: curIndex,
                        items: countrylist.countries!.map((country )
                        => DropdownMenuItem(

                          child: addCountry(country), //ext(trimCountry(country.enShortName)),
                          value: index++,
                        )
                        ).toList(),
                        validator: (value) {

                            if( widget.fieldParams!.required == false ) return null;
                            return (value == null) ? translate('${widget.fieldParams!.label}') + ' ' + translate('cannot be empty') : null;
                          },

                        // DbCountryext('Country'),
                        onChanged: (value) {
                          setState(() {
                            logit('Value = ' + value.toString());
                            if( gblPayFormVals == null ) {
                              gblPayFormVals = new Map();
                            }
//            if( gblPayFormVals.containsKey(widget.fieldParams.id)){
                            gblPayFormVals![widget.fieldParams!.id] = countrylist.countries![value!].alpha2code;
                            //'widget.passengerDetail.country = countrylist.countries[value].enShortName;

                          });
                        },
                      ) )
              );
            }
          } else {
            return new CircularProgressIndicator();
          }
          return Container();
        });
  }
  }


enum FieldType { text, country, checkbox, choice}

class FieldParams {
  String label;
  String defaultVal ='';
  int maxLength;
  int minLength;
  bool required;
  String id;
  FieldType ftype;
  String options;

  List<TextInputFormatter>? inputFormatters;

  FieldParams({
    this.label ='',
    this.maxLength =0,
    this.minLength =0,
    this.inputFormatters,
    this.required = false,
    this.id = '',
    this.ftype = FieldType.text,
    this.options = ''
  });


}
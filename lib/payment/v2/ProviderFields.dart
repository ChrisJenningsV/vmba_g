import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/utilities/helper.dart';



class VInputField extends StatefulWidget {
  final FieldParams  fieldParams;

  const VInputField({
    Key key,
    this.fieldParams}) : super(key: key);

  @override
  VInputFieldState createState() => VInputFieldState();
}

class VInputFieldState extends State<VInputField> {

  TextEditingController _textEditingController;


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


    if ( widget.fieldParams.ftype == FieldType.country) {
      return Padding(
        padding: EdgeInsets.fromLTRB(0, 8.0, 0, 8),
        child: new Theme(
          data: theme,
          child: countryPicker(EdgeInsets.fromLTRB(0, 8.0, 0, 8), theme),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(0, 8.0, 0, 8),
      child: new Theme(
        data: theme ,
        child: TextFormField(
          maxLength: widget.fieldParams.maxLength,
          decoration:getDecoration(widget.fieldParams.label),

          controller: _textEditingController,
          onFieldSubmitted: (value) {
            //widget.passengerDetail.firstName = value;
            if( gblPayFormVals == null ) {
              gblPayFormVals = new Map();
            }
//            if( gblPayFormVals.containsKey(widget.fieldParams.id)){
              gblPayFormVals[widget.fieldParams.id] = value;
          },

          textInputAction: TextInputAction.done,
          // keyboardType: TextInputType.text,
          inputFormatters: widget.fieldParams.inputFormatters,
          validator: (value) =>
          value.isEmpty ? translate('${widget.fieldParams.label}') + ' ' + translate('cannot be empty') : null,
          onSaved: (value) {
            if (value != null) {
              if( gblPayFormVals == null ) {
                gblPayFormVals = new Map();
              }
//            if( gblPayFormVals.containsKey(widget.fieldParams.id)){
              gblPayFormVals[widget.fieldParams.id] = value;
            }
          },
        ),
      ),
    );
  }


  Widget countryPicker(EdgeInsetsGeometry padding, ThemeData theme) {
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
              if(widget.fieldParams.defaultVal == null ) {
                countrylist.countries.map((country) {
                  if (widget.fieldParams.defaultVal.toUpperCase() ==
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
                        items: countrylist.countries.map((country )
                        => DropdownMenuItem(

                          child: addCountry(country), //ext(trimCountry(country.enShortName)),
                          value: index++,
                        )
                        ).toList(),
                        validator: (value) =>
                        (value == null) ? translate('${widget.fieldParams.label}') + ' ' + translate('cannot be empty') : null,
                        // DbCountryext('Country'),
                        onChanged: (value) {
                          setState(() {
                            logit('Value = ' + value.toString());
                            if( gblPayFormVals == null ) {
                              gblPayFormVals = new Map();
                            }
//            if( gblPayFormVals.containsKey(widget.fieldParams.id)){
                            gblPayFormVals[widget.fieldParams.id] = countrylist.countries[value].alpha2code;
                            //'widget.passengerDetail.country = countrylist.countries[value].enShortName;

                          });
                        },
                      ) )
              );
            }
          } else {
            return new CircularProgressIndicator();
          }
          return null;
        });
  }

 /* Widget addCountry(DbCountry country) {
    Image img;
    String name = country.enShortName;
    String name2 = '';
    if( name.length > 25) {
      name2 = name.substring(30);
      name = name.substring(0,30);
    }
    //return Text(name);

    try {
      img = Image.asset(
        'icons/flags/png/${country.alpha2code.toLowerCase()}.png',
        package: 'country_icons',
        width: 20,
        height: 20,);
    } catch(e) {
      logit(e);
    }
    List<Widget> list = [];
    if (img != null ) {
      list.add(img);
    }
    list.add(SizedBox(width: 10,));
    if( name2 != '') {
      list.add(Column(
        children: [
          new Text(name),
          new Text(name2)
        ],
      ));
    } else {
      list.add(new Text(name));
    }

 *//*   if (img == null ) {
      return Row(children: <Widget>[
        SizedBox(width: 10,),
        Expanded( child: new Text(name))
      ],
      mainAxisAlignment: MainAxisAlignment.start,);
    } else {
      return Row(children: <Widget>[
        img,
        SizedBox(width: 10,),
        Expanded( child: new Text(name))
      ],
        mainAxisAlignment: MainAxisAlignment.start,
      );*//*

      return Row(children: list);
      }
*/
  }


enum FieldType { text, country, checkbox}

class FieldParams {
  String label;
  String defaultVal;
  int maxLength;
  int minLength;
  bool required;
  String id;
  FieldType ftype;

  List<TextInputFormatter> inputFormatters;

  FieldParams({
    this.label,
    this.maxLength,
    this.minLength,
    this.inputFormatters,
    this.required,
    this.id,
    this.ftype = FieldType.text,
  });


}


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:vmba/data/globals.dart';

import '../../Helpers/settingsHelper.dart';
import '../../components/pageStyleV2.dart';
import '../../components/trText.dart';
import '../../data/models/models.dart';
import '../../utilities/helper.dart';



Widget paxGetFirstName(TextEditingController firstNameTextEditingController,
    {required void Function(String) onFieldSubmitted,required void Function(String) onSaved}) {
  return V2TextWidget(
    maxLength: 50,
    styleVer: gblSettings.styleVersion,
    decoration: getDecoration('First name (as Passport)'),
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
    decoration: getDecoration('Middle name (or NONE)'),
    controller: middleNameTextEditingController,
    onFieldSubmitted: (value) {
      onFieldSubmitted(value);
    },
    textInputAction: TextInputAction.done,
    // keyboardType: TextInputType.text,
    inputFormatters: [
      FilteringTextInputFormatter.allow(RegExp("[a-zA-Z- ÆØøäöåÄÖÅæé]"))
    ],
    validator: (value) {
      if( gblSettings.middleNameRequired ) {
        if(value!.isEmpty) return translate('Middle name cannot be empty - type NONE if none');
      }
      return null;
    },
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
    decoration: getDecoration('Last name (as Passport)'),
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

Widget paxGetEmail(TextEditingController emailTextEditingController, {required void Function(String) onFieldSubmitted,
    required void Function(String) onSaved, bool autofocus = false}) {
  return V2TextWidget(
    maxLength: 50,
    styleVer: gblSettings.styleVersion,
    decoration: getDecoration('Email'),
    autovalidateMode: AutovalidateMode.onUserInteraction,
    controller: emailTextEditingController,
    autofocus: autofocus,
    inputFormatters: [
      FilteringTextInputFormatter.deny(RegExp("[#'!£^&*(){},|]"))
    ],
    keyboardType: TextInputType.emailAddress,
    validator: (value) {
      String er = validateEmail(value!.trim());
      if(er != '' ) return er;
      return null;

    },
    onFieldSubmitted: (value) {onFieldSubmitted( value);
    },
    onSaved: (value) {
      if (value != null) {
        onSaved( value.trim());
      }
    },
  );
}


Widget pax2faNumber(BuildContext context, List<TextEditingController> emailTextEditingController, {required void Function(String) onFieldSubmitted,
  required void Function(String) onSaved, bool autofocus = false,
  FocusNode? focusNode})
{
  List<Widget> cellList = [];
  for( int i = 0 ; i < 6 ; i++) {
    cellList.add( Expanded(
                child:
                    Padding(padding: EdgeInsets.all(4),
                child:
                V2TextWidget(
                  maxLength: 1,
                  styleVer: gblSettings.styleVersion,
                  decoration: getDecoration('', borderColor: Colors.grey),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  controller: emailTextEditingController[i],
                  autofocus: i== 0 ? true: false,
                  //focusNode: i== 0 ? focusNode : null ,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  textInputAction: i < 5 ? TextInputAction.next : TextInputAction.done,
                    onChanged: (value) {
                      String index = i.toString();
                      //logit(' val $value index $i');
                      if( value!.length >=1 && i < 5 ){
                        FocusScope.of(context).nextFocus();
                      }
                    },
                  validator: (value) {
                    if( value!.length >=1 ){
//                      FocusScope.of(context).nextFocus();
                    }
                  },
/*
                  onFieldSubmitted: (value) {
                    onFieldSubmitted(value);
                  },
                  onSaved: (value) {
                    if (value != null) {
                      onSaved(value.trim());
                    }
                  },
*/
                )
            ))
    );
  }
      return
      Row(      children: cellList      );
}


Widget paxGetPhoneNumber(TextEditingController phoneTextEditingController, {required void Function(String) onFieldSubmitted,required void Function(String) onSaved}){
  return V2TextWidget(
    maxLength: 50,
    styleVer: gblSettings.styleVersion,
    decoration: getDecoration('Phone Number'),
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

Widget paxGetWeight(BuildContext context,TextEditingController weightTextEditingController, String unit,
    void Function (String) updateUnits, void Function (String) onSaved){
  List<String> options = ['lb', 'kg'];
  return ListTile(
    contentPadding: EdgeInsets.all(0),
    title: ClipRRect(
      borderRadius: BorderRadius.circular(5.0),
      child: Container(
        //decoration: BoxDecoration( color: Colors.red ),
        margin: EdgeInsets.all(0),
        padding: EdgeInsets.all(0),
        //color: Colors.red,
        child: Row(
          children: [
            _buildDropDownButton(unit,options, updateUnits),
            Expanded(
              child:
              V2TextWidget(
                maxLength: 3,
                styleVer: gblSettings.styleVersion,
                decoration: getDecoration('Weight'),
                controller: weightTextEditingController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                ],
                onFieldSubmitted: (value) {
                 // onFieldSubmitted(value);
                },
                validator: (value) =>
                value!.isEmpty ? translate('Weight cannot be empty') : null,
                onSaved: (value) {
                  if (value != null) {
                    onSaved(value);
                  }
                },
              )
/*
              TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
                controller: weightTextEditingController,
                style:
                TextStyle(fontSize: 20.0, color: Colors.black),
                keyboardType:
                TextInputType.numberWithOptions(decimal: true),
              ),
*/

            ),
          ],
        ),
      ),
    ),
  );
}
Widget _buildDropDownButton(String currencyCategory, List <String> options, void Function (String) updateUnits) {
  return Container(
    decoration:  BoxDecoration(
      color: Colors.grey.shade200,
        shape: BoxShape.rectangle,
      //color: gblSystemColors.seatPlanColorUnavailable,
      borderRadius: new BorderRadius.all(new Radius.circular(5.0)),
        border: Border.all(
            color: Colors.grey, width: 1),
    ),
    //color: Colors.grey,
    margin: EdgeInsets.all(0),
    padding: EdgeInsets.all(0),
    child: Padding(
      padding: EdgeInsets.fromLTRB(10,0,0,0),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
     // child: Expanded(child: DropdownButtonFormField(
          iconEnabledColor: Colors.black,
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
       //   dropdownColor: Colors.grey,

          value: currencyCategory,
          items: options
              .map((String value) => DropdownMenuItem(
            value: value,
            child: Row(
              children: <Widget>[
                Text(value),
              ],
            ),
          ))
              .toList(),
          onChanged: (value) {
            updateUnits(value.toString());
          },
        ),
      ),
    ),
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

Widget paxGetDOB(BuildContext context, TextEditingController  dateOfBirthTextEditingController, PaxType paxType, void Function(DateTime) updateDateOfBirth,
    void Function() formSave, void Function(void Function()) setState){
  return  InkWell(
    onTap: () {
      _showCalenderDialog(context , paxType, updateDateOfBirth, formSave, setState);
    },
    child: IgnorePointer(
      child: TextFormField(
        decoration: getDecoration('Date of Birth'),
        //initialValue: field.value,
        controller: dateOfBirthTextEditingController,
        validator: (value) =>
        value!.isEmpty ? translate('Date of Birth is required') : null,
        onSaved: (value) {
          if (value != '') {
            var date = value!.split('-')[2] +
                ' ' +
                value.split('-')[1] +
                ' ' +
                value.split('-')[0];
/*
            DateFormat format = new DateFormat("yyyy MMM dd");
            widget.passengerDetail.dateOfBirth = format.parse(date);
*/
          }
        },

        // DateFormat format = new DateFormat("yyyy MMM dd"); DateTime.parse(value),  //value.trim(),
      ),
    ),
  );
}

Widget _getTitle(BuildContext context,TextEditingController titleTextEditingController ){
  logit('title val=${titleTextEditingController.text}');
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

Widget? countryPicker(EdgeInsetsGeometry padding, ThemeData theme, String paxCountry, void Function(String ) onChanged) {
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
            var tempIndex = 0;
            if(paxCountry != '' ) {
              countrylist.countries!.forEach((country) {
                if (paxCountry.toUpperCase() ==
                    country.enShortName.toUpperCase()) {
                  curIndex = tempIndex;
                }
                tempIndex += 1;
              });
            }
            return Padding(
                padding: padding,
                child: new Theme(
                    data: theme,
                    child: DropdownButtonFormField<int>(
                      decoration: getDecoration('Country'),
                      value: curIndex,
                      items: countrylist.countries!.map((country ) {
                        // logit('index= $index curIndex=$curIndex ${country.enShortName}');
                        // if( curIndex == index+1) logit('index==curIndex ${country.enShortName}');
                        return DropdownMenuItem(
                          child: addCountry(country), //ext(trimCountry(country.enShortName)),
                          value: index++,
                        );
                      }
                      ).toList(),

                      // DbCountryext('Country'),
                      onChanged: (value) {
                        onChanged(countrylist.countries![value!].enShortName);
                       /* setState(() {
                          logit('Value = ' + value.toString());
                          widget.passengerDetail.country = countrylist.countries![value!].enShortName;
                          logit('sel country = ' + widget.passengerDetail.country);
                          // _ratingController = value;
                        });*/
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






_showCalenderDialog(BuildContext context, PaxType paxType, void Function(DateTime) updateDateOfBirth, void Function() formSave,
    void Function(void Function()) setState ) {

  DateTime dateTime = DateTime.now();
  DateTime _maximumDate;
  DateTime _minimumDate;
  DateTime _initialDateTime;
  int _minimumYear;
  int _maximumYear;
  formSave();

  // VRS uses todays date - not date of travel, code here to use date of travel if required
  DateTime lastFltDate = DateTime.now();
  if( gblDepartDate != null ){
    lastFltDate = gblDepartDate!;
  }
//    DateTime lastFltDate = widget.newBooking.departureDate;
//    if( widget.newBooking.returnDate != null ){
//      lastFltDate = widget.newBooking.returnDate;
//    }

//    logit('dep dt: ' + widget.newBooking.departureDate.toString());
//    logit('ret dt: ' + widget.newBooking.returnDate.toString());

  switch (paxType) {
    case PaxType.infant:
      {
        _initialDateTime = DateTime.now();
        //_minimumDate = DateTime.now().subtract(new Duration(days: (365 * 2 -1 )));
        _minimumDate = DateTime(lastFltDate.year - 2, lastFltDate.month, lastFltDate.day );
        _minimumDate = _minimumDate.add(Duration(days: 1));
      }
      break;
    case PaxType.child:
      {
        //_initialDateTime = DateTime.now().subtract(Duration(days: 731));
        _initialDateTime =DateTime(DateTime.now().year - 2, DateTime.now().month, DateTime.now().day );
            //_minimumDate = DateTime.now().subtract(new Duration(days: (4015)));
        _minimumDate = DateTime(lastFltDate.year - gblSettings.passengerTypes.childMaxAge, lastFltDate.month, lastFltDate.day );
        _minimumDate = _minimumDate.add(Duration(days: 1));
      }
      break;
    case PaxType.youth:
      {
        _initialDateTime = DateTime( lastFltDate.year - gblSettings.passengerTypes.youthMinAge, lastFltDate.month, lastFltDate.day );
        _minimumDate = DateTime( lastFltDate.year - gblSettings.passengerTypes.youthMaxAge, lastFltDate.month, lastFltDate.day );
        logit('init $_initialDateTime' );
        logit('min $_minimumDate' );
        //_initialDateTime =DateTime.now().subtract(new Duration(days: (4015)));
        //_minimumDate = DateTime.now().subtract(new Duration(days: (5840)));
      }
      break;
/*      case PaxType.student:
        {
          _initialDateTime =
              DateTime.now().subtract(new Duration(days: (4015)));
          _minimumDate = DateTime.now().subtract(new Duration(days: (5840)));
        }
        break; */
      case PaxType.senior:
        {
          int minAge  = (gblSettings.passengerTypes.seniorMinAge * 365.25).round();
          int maxAge  = (110 * 365.25).round();
          _initialDateTime =
              DateTime.now().subtract(new Duration(days: (minAge -1)));
          _minimumDate = DateTime.now().subtract(new Duration(days: (maxAge)));
          _maximumDate = DateTime.now().subtract(new Duration(days: (minAge)));
        }
        break;


    case PaxType.adult:
      {
        int minAge  = (gblSettings.passengerTypes.adultMinAge * 365.25).round();
        _initialDateTime =
            DateTime.now().subtract(new Duration(days: (minAge -1)));

//        _initialDateTime = DateTime.now();
        _minimumDate = DateTime( 110, 0, 0 );
      }
      break;
    default:
      {
        _initialDateTime = DateTime.now();
        _minimumDate = DateTime( 110, 0, 0 );
      }
      break;
  }
  _maximumDate = _initialDateTime;
  _minimumYear = _minimumDate.year;
  _maximumYear = _initialDateTime.year;
  dateTime = _initialDateTime;

  updateDateOfBirth(_initialDateTime);

  final Brightness brightnessValue = MediaQuery.of(context).platformBrightness;
  bool isDark = brightnessValue == Brightness.dark;
  Color bgColour = Colors.white;
  Color txtColor = Colors.black;
  if (isDark) {
    bgColour = Colors.black;
    txtColor = Colors.white;
  }

  showDialog(
    context: context,
    builder: (BuildContext context) {
      // return object of type Dialog
      return AlertDialog(
        contentPadding: EdgeInsets.all(0),
        backgroundColor: bgColour,
        title: new TrText('Date of Birth', style: TextStyle(color: txtColor),),
        content: SizedBox(
          //padding: EdgeInsets.all(1),
            height: MediaQuery.of(context).copyWith().size.height / 3,
            child: CupertinoTheme(
              data: CupertinoThemeData(
                brightness: brightnessValue,
                textTheme: CupertinoTextThemeData(
                  dateTimePickerTextStyle: TextStyle(
                    fontSize: 16,
                  ),

                ),
              ),
              child: CupertinoDatePicker(
                backgroundColor: bgColour,
                initialDateTime: _initialDateTime,
                onDateTimeChanged: (DateTime newValue) {
                  dateTime = newValue;

                  setState(() {
                    // print(newValue);

                  });
                },
                use24hFormat: true,
                maximumDate: _maximumDate,
                minimumYear: _minimumYear,
                maximumYear: _maximumYear,
                minimumDate: _minimumDate,
                mode: CupertinoDatePickerMode.date,
              ),
            )),
        actions: <Widget>[
          new TextButton(
            style: TextButton.styleFrom(
                backgroundColor:bgColour ,
                side: BorderSide(color:  txtColor, width: 1),
                foregroundColor:txtColor),
            child: new TrText("OK", style: TextStyle(color: txtColor),
            ),
            onPressed: () {
              Navigator.pop(context, dateTime);
              updateDateOfBirth(dateTime );
            },
          ),
        ],
      );
    },
  );
}



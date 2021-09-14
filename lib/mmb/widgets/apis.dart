import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:vmba/data/models/apis.dart';
import 'package:vmba/data/models/apis_pnr.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/menu/menu.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/showDialog.dart';


class ApisWidget extends StatefulWidget {
  ApisWidget({Key key, this.apisCmd, this.rloc}) : super(key: key);

  final String apisCmd;
  final String rloc;

  _ApisWidgetState createState() => _ApisWidgetState();
}

class _ApisWidgetState extends State<ApisWidget> {
  final formKey = new GlobalKey<FormState>();
  bool _loadingInProgress;
  ApisModel apisForm;

  @override
  void initState() {
    super.initState();
    _loadingInProgress = true;
    _loadData(widget.apisCmd);
  }

  void _dataLoaded() {
    setState(() {
      _loadingInProgress = false;
    });
  }

  Future _loadData(String cmd) async {
    String msg = gblSettings.xmlUrl +
        gblSettings.xmlToken +
        '&Command=' +
        cmd;

    print(msg);
    final response = await http.get(Uri.parse(msg));
    Map map;
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON
      try {
        map = json.decode(response.body
            .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
            .replaceAll('<string xmlns="http://videcom.com/">', '')
            .replaceAll('</string>', ''));
      } catch (e) {
        print(e.toString());
      }
      print('Loaded APIS fields');
      try {
        apisForm = new ApisModel.fromJson(map);

//        logit('loaded');
        _dataLoaded();
      } catch(e) {
        logit(e.toString());
      }
    } else {
      // If that response was not OK, throw an error.
      _dataLoaded();
      //throw Exception('Failed to load post');
    }
  }

  Future _submitApis() async {
    String url = gblSettings.apisUrl;
    // 'https://customertest.videcom.com/LoganAir/VRSXMLService/VRSXMLwebService3.asmx/PostApisData?';
    final response = await http.post(Uri.parse(url), body: {
      'token': gblSettings.xmlTokenPost,
      'Command': 'DAX/',
      'FormData': apisForm.toXmlString()
    });
    if (response.statusCode == 200) {
      try {
        String result;
        result = response.body
            .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
            .replaceAll('<string xmlns="http://videcom.com/">', '')
            .replaceAll('</string>', '');
        print(result);
        if (result.trim() == 'OK') {
          Repository.get().fetchApisStatus(widget.rloc).then((w) {
            Map map = json.decode(w.data);

            ApisPnrStatusModel apisPnrStatus =
                new ApisPnrStatusModel.fromJson(map);

            //Navigator.of(context, w).pop();
            Navigator.pop(context, apisPnrStatus);
          });
        } else {
          showAlertDialog(context, 'Apis Error', result);
          _dataLoaded();
        }
      } catch (e) {
        print(e.toString());
        _showError('Please check your internet connection');
        _dataLoaded();
      }
    } else {
      _dataLoaded();
    }
  }

  void _updateApisData(String sectionname, String fieldname, String value) {
    setState(() {
      apisForm.apis.sections.section
          .firstWhere((section) => section.sectionname == sectionname)
          .fields
          .field
          .firstWhere((field) => field.displayname == fieldname)
          .value = value;
      FocusScope.of(context).requestFocus(new FocusNode());
    });
  }

  _showError(String err) {
    print(err);
    setState(() {
      _loadingInProgress = false;
    });
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        setState(() {
          _loadingInProgress = true;
        });
        _submitApis();
      } catch (e) {
        print('Error: $e');
        showAlertDialog(context, 'Alert', e.toString());
      }
    }
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void formSave() {
    final form = formKey.currentState;
    form.save();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        brightness: gblSystemColors.statusBar,
        backgroundColor: gblSystemColors.primaryHeaderColor,
        iconTheme: IconThemeData(
            color: gblSystemColors.headerTextColor),
        title: new Text('Additional Information',
            style: TextStyle(
                color:
                gblSystemColors.headerTextColor)),
      ),
      endDrawer: DrawerMenu(),
      body: body(),
    );
  }

  Widget body() {
    if (_loadingInProgress) {
      //logit('loading');
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      //logit('display');
      return Container(
        child: //Column(
            // children: <Widget>[
            // Text('As you are travelling internationally, we require you to add passport details to your booking before checking in.'),

            new Form(
          key: formKey,
          child: renderApis(),
        ),
        //  ],
        //  ),
      );
    }
  }

  List<Widget> renderFields(Section section) {
    List<Widget> widgets = [];
    // new List<Widget>();
    widgets.add(Padding(
      padding: EdgeInsets.only(bottom: 2),
    ));
    section.fields.field.forEach((field) {
      //var _textEditingController = new TextEditingController();
      if (field.displayable == 'True') {
        if (field.choices != null ||
            field.fieldtype == 'PastDate' ||
            field.fieldtype == 'FutureDate' ||
            field.fieldtype == 'CountryCode') {
          var _textEditingController = new TextEditingController();
          _textEditingController.text = field.value;
          widgets.add(
            InkWell(
              onTap: () {
                formSave();
                if (field.choices != null) {
                  _showDialog(section.sectionname, field);
                } else if (field.fieldtype == 'PastDate' ||
                    field.fieldtype == 'FutureDate') {
                  _showCalenderDialog(
                      section.sectionname, field, field.fieldtype);
                  print('Show Calender');
                } else if (field.fieldtype == 'CountryCode') {
                  _showCountriesDialog(section.sectionname, field);
                  print('Show Countries');
                }
              },
              child: IgnorePointer(
                child: TextFormField(
                  decoration: getDecoration( field.displayname),
                  //
                  //initialValue: field.value,
                  controller: _textEditingController,
                  //keyboardType: TextInputType.text,
                  validator: (value) =>
                      value.isEmpty && field.required == "True"
                          ? '${field.displayname} cannot be empty'
                          : null,
                  onSaved: (value) {
                    if (value != null) {
                      apisForm.apis.sections.section
                          .firstWhere(
                              (s) => s.sectionname == section.sectionname)
                          .fields
                          .field
                          .firstWhere((f) => f.displayname == field.displayname)
                          .value = value.trim();
                    }
                  },
                ),
              ),
            ),
          );
        } else {
          var _textEditingController = new TextEditingController();
          _textEditingController.text = field.value;
          widgets.add(new TextFormField(
            decoration: getDecoration(field.displayname),


            //initialValue: _textEditingController.text,//field.value,
            keyboardType: TextInputType.text,
            controller: _textEditingController,
            validator: (value) => value.isEmpty && field.required == "True"
                ? '${field.displayname} can\'t be empty'
                : null,
            onFieldSubmitted: (value) {
              apisForm.apis.sections.section
                  .firstWhere((s) => s.sectionname == section.sectionname)
                  .fields
                  .field
                  .firstWhere((f) => f.displayname == field.displayname)
                  .value = value.trim();
            },
            onSaved: (value) {
              if (value != null) {
                apisForm.apis.sections.section
                    .firstWhere((s) => s.sectionname == section.sectionname)
                    .fields
                    .field
                    .firstWhere((f) => f.displayname == field.displayname)
                    .value = value.trim();
              }
            },
          ));
        }

        widgets.add(
          new Padding(padding: EdgeInsets.all(10)),
        );
      }
    });

    return widgets;
  }

  ListView renderApis() {
    List<Widget> expandionTiles = [];
    // List<Widget>();
    expandionTiles.add(
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
            'As you are travelling internationally, we require you to add passport details to your booking before checking in.'),
      ),
    );
    apisForm.apis.sections.section.forEach((section) {
      if (section.displayable == "True") {
        expandionTiles.add(ExpansionTile(
          initiallyExpanded:
              section.sectionname.toLowerCase() == 'passenger visa'
                  ? false
                  : true, //true,
          title: Text(
            section.sectionname,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          children: renderFields(section),
        ));
      }
    });
    expandionTiles.add(
      Padding(
        padding: EdgeInsets.symmetric(vertical: 16.0),
        child: Material(
          color: Colors.black,
          borderRadius: BorderRadius.circular(25.0),
          shadowColor: Colors.grey.shade100,
          elevation: 5.0,
          child: new MaterialButton(
            minWidth: 200,
            height: 60.0,
            child: Text(
              'SUBMIT',
              style: new TextStyle(fontSize: 20.0, color: Colors.white),
            ),
            onPressed: () {
              //print(apisForm.toJson());
              validateAndSubmit();
            }, //validateAndSubmit,
          ),
        ),
      ),
    );

    return ListView(
      padding: EdgeInsets.all(10),
      children: expandionTiles,
    );
  }

  void _showDialog(
    String sectionname,
    Field field,
  ) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(field.displayname),
          content: Container(
            width: double.maxFinite,
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  optionList(sectionname, field.choices, field.displayname),
            ),
          ),
        );
      },
    );
  }

  List<Widget> optionList(
      String sectionname, Choices choices, String fieldname) {
    List<Widget> widgets = [];
    // new List<Widget>();
    choices.choice.forEach((c) => widgets.add(ListTile(
        title: Text(c.description),
        onTap: () {
          Navigator.pop(context, c.value);
          _updateApisData(sectionname, fieldname, c.value);
        })));

    return widgets;
  }

  _showCalenderDialog(String sectionname, Field field, String type) {
    DateTime dateTime;
    DateTime _maximumDate;
    DateTime _minimumDate;
    DateTime _initialDateTime;
    int _minimumYear;
    int _maximumYear;

    DateTime dateNow =
        DateTime.parse(DateFormat('y-MM-dd 00:00:00').format(DateTime.now()));
    if (field.value == '') {
      _initialDateTime =
          dateNow; // DateTime.parse(DateFormat('y-MM-dd 00:00:00').format(DateTime.now()));
    } else {
      var date = field.value.split('-')[2] +
          ' ' +
          field.value.split('-')[1] +
          ' ' +
          field.value.split('-')[0];
      DateFormat format = new DateFormat("yyyy MMM dd");
      _initialDateTime = format.parse(date);
    }
    dateTime = _initialDateTime;

    if (type == 'PastDate') {
      _minimumDate = dateNow.subtract(new Duration(
          days: (365 *
              110))); //DateTime.now().subtract(new Duration(days: (365 * 110)));
      _maximumDate = dateNow; //DateTime.now();
      _minimumYear = dateNow.year - 110; //DateTime.now().year - 110;
      _maximumYear = dateNow.year; //DateTime.now().year;
    } else {
      _minimumDate = dateNow; //DateTime.now();
      _maximumDate = dateNow.add(new Duration(
          days: (365 *
              10))); //DateTime.now().add(new Duration(days: (365 * 10)));
      _minimumYear = dateNow.year; //DateTime.now().year;
      _maximumYear = dateNow.year + 10; //DateTime.now().year + 10;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          title: new Text(field.displayname),
          content: Container(
              width: double.maxFinite,
              height: MediaQuery.of(context).copyWith().size.height / 3,
              child: CupertinoTheme(
                data: CupertinoThemeData(
                  textTheme: CupertinoTextThemeData(
                    dateTimePickerTextStyle: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                child: CupertinoDatePicker(
                  initialDateTime: _initialDateTime,
                  onDateTimeChanged: (DateTime newValue) {
                    setState(() {
                      print(newValue);
                      dateTime = newValue;
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
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                _updateApisData(sectionname, field.displayname,
                    DateFormat('dd-MMM-yyyy').format(dateTime));
              },
            ),
          ],
        );
      },
    );
  }

  void _showCountriesDialog(
    String sectionname,
    Field field,
  ) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
            title: new Text(field.displayname),
            content: new FutureBuilder(
              future: getCountrylist(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data != null) {
                    return Container(
                      width: double.maxFinite,
                      child: new ListView(
                        children: optionCountryList(
                            snapshot, sectionname, field.displayname),
                      ),
                    );
                  } else {
                    return new Center(
                      child: Text('Something when wrong...'),
                    );
                  }
                } else {
                  return new Center(
                    child: new CircularProgressIndicator(),
                  );
                }
              },
            ));
      },
    );
  }

  List<Widget> optionCountryList(
    AsyncSnapshot snapshot,
    String sectionname,
    String fieldname,
  ) {
    List<Widget> widgets = [];
    // new List<Widget>();
    Countrylist countrylist = snapshot.data;
    countrylist.countries.forEach((c) => widgets.add(ListTile(
        title: Text(fieldname == 'Nationality' ? c.nationality : c.enShortName),
        onTap: () {
          Navigator.pop(context, c.alpha3code);
          _updateApisData(sectionname, fieldname, c.alpha3code);
        })));
    return widgets;
  }
}

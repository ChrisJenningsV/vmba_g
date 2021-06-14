import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/user_profile.dart';
import 'package:vmba/data/globals.dart';

class EditDetailsWidget extends StatefulWidget {
  EditDetailsWidget(
      {Key key, this.passengerDetail, this.isAdsBooking, this.isLeadPassenger})
      : super(key: key);
  final PassengerDetail passengerDetail;
  final bool isAdsBooking;
  final bool isLeadPassenger;

  _EditDetailsWidgetWidgetState createState() =>
      _EditDetailsWidgetWidgetState();
}

class _EditDetailsWidgetWidgetState extends State<EditDetailsWidget> {
/*  List<String> _titles = <String>[
    'Mr',
    'Mrs',
    'Ms',
    'Dr',
    'Miss',
    'Mstr',
    'Prof',
    'Rev'
  ];

 */
  bool _loadingInProgress = false;
  final formKey = new GlobalKey<FormState>();
  String _error;
  //var _title = new TextEditingController();
  TextEditingController _titleTextEditingController = TextEditingController();

  TextEditingController _firstNameTextEditingController =
      TextEditingController();

  TextEditingController _lastNameTextEditingController =
      TextEditingController();

  TextEditingController _dateOfBirthTextEditingController =
      TextEditingController();

  TextEditingController _adsNumberTextEditingController =
      TextEditingController();
  TextEditingController _adsPinTextEditingController = TextEditingController();
  TextEditingController _fqtvTextEditingController = TextEditingController();

  List<UserProfileRecord> userProfileRecordList;
  @override
  initState() {
    super.initState();
    _titleTextEditingController.text = widget.passengerDetail.title;
    _firstNameTextEditingController.text = widget.passengerDetail.firstName;
    _lastNameTextEditingController.text = widget.passengerDetail.lastName;
    _dateOfBirthTextEditingController.text =
        widget.passengerDetail.dateOfBirth != null
            ? DateFormat('dd-MMM-yyyy')
                .format(widget.passengerDetail.dateOfBirth)
            : '';
    _adsNumberTextEditingController.text = widget.passengerDetail.adsNumber;
    _adsPinTextEditingController.text = widget.passengerDetail.adsPin;
    _fqtvTextEditingController.text = widget.passengerDetail.fqtv;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        brightness: gblSystemColors.statusBar,
        backgroundColor: gblSystemColors.primaryHeaderColor,
        iconTheme: IconThemeData(
            color: gblSystemColors.headerTextColor),
        title: new Text('Edit Details',
            style: TextStyle(
                color:
                gblSystemColors.headerTextColor)),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      //endDrawer: DrawerMenu(),
      body: _loadingInProgress
          ? new Center(
              child: new CircularProgressIndicator(),
            )
          : new Form(
              key: formKey,
              child: new SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Column(
                    children: render(),
                  ),
                ),
              ),
            ),
    );
  }

  List<Widget> render() {
    List<Widget> paxWidgets = [];
    // List<Widget>();

    paxWidgets.add(renderFields());

    paxWidgets.add(ElevatedButton(
      onPressed: () {
        validateAndSubmit();
      },
      style: ElevatedButton.styleFrom(
          primary: gblSystemColors
              .primaryButtonColor, //Colors.black,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0))),
      child: Row(
        //mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.check,
            color: Colors.white,
          ),
          Text(
            'SAVE',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    ));

    paxWidgets.add(Padding(
      padding: new EdgeInsets.only(top: 60.0),
    ));
    return paxWidgets;
  }

  //Widget renderFields(int paxNo, PaxType paxType) {

  Widget renderFields() {
    return Column(children: <Widget>[
      Padding(
        padding: EdgeInsets.fromLTRB(0, 2, 0, 8),
        child: InkWell(
          onTap: () {
            formSave();
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: new Text('Salutation'),
                  content: new Container(
                    width: double.maxFinite,
                    child: optionListView(),
                  ),
                );
              },
            );
          },
          child: IgnorePointer(
            child: TextFormField(
              decoration: new InputDecoration(
                contentPadding:
                    new EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                labelText: 'Title',
                fillColor: Colors.white,
                border: new OutlineInputBorder(
                  borderRadius: new BorderRadius.circular(25.0),
                  borderSide: new BorderSide(),
                ),
              ),
              controller: _titleTextEditingController,
              validator: (value) =>
                  value.isEmpty ? 'Title can\'t be empty' : null,
              onSaved: (value) {
                if (value != null) {
                  widget.passengerDetail.title = value.trim();
                }
              },
            ),
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(0, 8.0, 0, 8),
        child: new Theme(
          data: new ThemeData(
            primaryColor: Colors.blueAccent,
            primaryColorDark: Colors.blue,
          ),
          child: TextFormField(
            maxLength: 50,
            decoration: InputDecoration(
              contentPadding:
                  new EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
              labelText: 'First name (as Passport)',
              fillColor: Colors.white,
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(25.0),
                borderSide: new BorderSide(),
              ),
            ),
            controller: _firstNameTextEditingController,
            onFieldSubmitted: (value) {
              widget.passengerDetail.firstName = value;
            },
            textInputAction: TextInputAction.done,
            keyboardType: TextInputType.text,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp("[a-zA-Z-]"))
            ],
            validator: (value) =>
                value.isEmpty ? 'First name can\'t be empty' : null,
            onSaved: (value) {
              if (value != null) {
                widget.passengerDetail.firstName = value.trim();
              }
            },
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(0, 8.0, 0, 8),
        child: new Theme(
          data: new ThemeData(
            primaryColor: Colors.blueAccent,
            primaryColorDark: Colors.blue,
          ),
          child: TextFormField(
            maxLength: 50,
            decoration: InputDecoration(
              contentPadding:
                  new EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
              labelText: 'Last name (as Passport)',
              fillColor: Colors.white,
              border: new OutlineInputBorder(
                borderRadius: new BorderRadius.circular(25.0),
                borderSide: new BorderSide(),
              ),
            ),
            keyboardType: TextInputType.text,
            controller: _lastNameTextEditingController,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp("[a-zA-Z-]"))
            ],
            onFieldSubmitted: (value) {
              widget.passengerDetail.lastName = value;
            },
            validator: (value) =>
                value.isEmpty ? 'Last name can\'t be empty' : null,
            onSaved: (value) {
              if (value != null) {
                widget.passengerDetail.lastName = value.trim();
              }
            },
          ),
        ),
      ),
      Padding(
        padding: EdgeInsets.fromLTRB(0, 8.0, 0, 8),
        child: widget.passengerDetail.paxType != PaxType.adult
            ? InkWell(
                onTap: () {
                  _showCalenderDialog(widget.passengerDetail.paxType);
                },
                child: IgnorePointer(
                  child: TextFormField(
                    decoration: new InputDecoration(
                      contentPadding: new EdgeInsets.symmetric(
                          vertical: 15.0, horizontal: 15.0),
                      labelText: 'Date of Birth',
                      fillColor: Colors.white,
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(25.0),
                        borderSide: new BorderSide(),
                      ),
                    ),
                    //initialValue: field.value,
                    controller: _dateOfBirthTextEditingController,
                    validator: (value) =>
                        value.isEmpty ? 'Date of Birth is required' : null,
                    onSaved: (value) {
                      if (value != '') {
                        var date = value.split('-')[2] +
                            ' ' +
                            value.split('-')[1] +
                            ' ' +
                            value.split('-')[0];
                        DateFormat format = new DateFormat("yyyy MMM dd");
                        widget.passengerDetail.dateOfBirth = format.parse(date);
                      }
                    },

                    // DateFormat format = new DateFormat("yyyy MMM dd"); DateTime.parse(value),  //value.trim(),
                  ),
                ),
              )
            : Padding(padding: const EdgeInsets.all(0.0)),
      ),
      widget.passengerDetail.paxType == PaxType.adult &&
              gblSettings.fqtvEnabled
          ? Padding(
              padding: EdgeInsets.fromLTRB(0, 8.0, 0, 8),
              child: new Theme(
                data: new ThemeData(
                  primaryColor: Colors.blueAccent,
                  primaryColorDark: Colors.blue,
                ),
                child: TextFormField(
                  maxLength: 20,
                  decoration: InputDecoration(
                    contentPadding: new EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 15.0),
                    labelText: gblSettings.fqtvName == null
                        ? 'FQTV number'
                        : '${gblSettings.fqtvName} number',
                    fillColor: Colors.white,
                    border: new OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(25.0),
                      borderSide: new BorderSide(),
                    ),
                  ),
                  keyboardType: TextInputType.text,
                  controller: _fqtvTextEditingController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                  ],
                  onFieldSubmitted: (value) {
                    widget.passengerDetail.fqtv = value;
                  },
                  validator: (value) => null, // value.isEmpty ? null, val,
                  onSaved: (value) {
                    if (value != null) {
                      widget.passengerDetail.fqtv = value.trim();
                    }
                  },
                ),
              ),
            )
          : Padding(padding: const EdgeInsets.all(0.0)),
      widget.isAdsBooking
          ? Padding(
              padding: EdgeInsets.fromLTRB(0, 8.0, 0, 8),
              child: TextFormField(
                maxLength: 20,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  contentPadding: new EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 15.0),
                  labelText: 'ADS number',
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(),
                  ),
                ),
                keyboardType: TextInputType.text,
                controller: _adsNumberTextEditingController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[0-9adsADS]"))
                ],
                onFieldSubmitted: (value) {
                  widget.passengerDetail.adsNumber = value;
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'An ADS number is required';
                  } else if (!value.toUpperCase().startsWith('ADS') ||
                      value.length != 16 ||
                      !isNumeric(value.substring(3))) {
                    return 'ADS not valid';
                  } else {
                    return null;
                  }
                },
                onSaved: (value) {
                  if (value != null) {
                    widget.passengerDetail.adsNumber = value.trim();
                  }
                },
              ),
            )
          : Padding(padding: EdgeInsets.zero),
      widget.isAdsBooking && widget.isLeadPassenger
          ? Padding(
              padding: EdgeInsets.fromLTRB(0, 8.0, 0, 8),
              child: TextFormField(
                maxLength: 4,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  contentPadding: new EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 15.0),
                  labelText: 'ADS Pin',
                  fillColor: Colors.white,
                  border: new OutlineInputBorder(
                    borderRadius: new BorderRadius.circular(25.0),
                    borderSide: new BorderSide(),
                  ),
                ),
                keyboardType: TextInputType.text,
                obscureText: true,
                controller: _adsPinTextEditingController,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp("[0-9]"))
                ],
                onFieldSubmitted: (value) {
                  widget.passengerDetail.adsPin = value;
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return 'ADS Pin is required';
                  } else {
                    return null;
                  }
                },
                onSaved: (value) {
                  if (value != null) {
                    widget.passengerDetail.adsPin = value.trim();
                  }
                },
              ),
            )
          : Padding(
              padding: EdgeInsets.zero,
            ),
    ]);
  }

  ListView optionListView() {
    List<Widget> widgets = [];
    //new List<Widget>();
    gblTitles.forEach((title) => widgets.add(ListTile(
        title: Text(title),
        onTap: () {
          Navigator.pop(context, title);
          _updateTitle(title);
        })));
    return new ListView(
      children: widgets,
    );
  }

  void _updateTitle(String value) {
    setState(() {
      _titleTextEditingController.text = value;
      FocusScope.of(context).requestFocus(new FocusNode());
    });
  }

  Future<void> adsValidate() async {
    setState(() {
      _loadingInProgress = true;
    });

//ZADSVERIFY/ADS4000000153501/7978

    http.Response response = await http
        .get(Uri.parse(
            "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=ZADSVERIFY/${_adsNumberTextEditingController.text}/${_adsPinTextEditingController.text}'"))
        .catchError((resp) {});

    if (response == null) {
      //return new ParsedResponse(NO_INTERNET, []);
    }

    //If there was an error return an empty list
    if (response.statusCode < 200 || response.statusCode >= 300) {
      //return new ParsedResponse(response.statusCode, []);
    }

    try {
      String adsJson;
      adsJson = response.body
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', '');

      Map map = json.decode(adsJson);

      if (map['VrsServerResponse']['data']['ads']['users']['user']['isvalid'] ==
          'true') {
        print('Login success');
        Navigator.pop(context, widget.passengerDetail);
      } else {
        _error = 'Please check your details';
        _actionCompleted();
        _showDialog();
      }
    } catch (e) {
      _actionCompleted();
      _showDialog();
    }
  }

  void _actionCompleted() {
    setState(() {
      _loadingInProgress = false;
    });
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("ADS Login"),
          content: _error != null && _error != ''
              ? new Text(_error)
              : new Text("Please try again"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new TextButton(
              child: new Text("Close"),
              onPressed: () {
                _error = '';

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  _showCalenderDialog(PaxType paxType) {
    DateTime dateTime;
    DateTime _maximumDate;
    DateTime _minimumDate;
    DateTime _initialDateTime;
    int _minimumYear;
    int _maximumYear;
    formSave();

    switch (paxType) {
      case PaxType.infant:
        {
          _initialDateTime = DateTime.now();
          _minimumDate = DateTime.now().subtract(new Duration(days: (365 * 2)));
        }
        break;
      case PaxType.child:
        {
          _initialDateTime = DateTime.now().subtract(Duration(days: 731));
          _minimumDate = DateTime.now().subtract(new Duration(days: (4015)));
        }
        break;
      case PaxType.youth:
        {
          _initialDateTime =
              DateTime.now().subtract(new Duration(days: (4015)));
          _minimumDate = DateTime.now().subtract(new Duration(days: (5840)));
        }
        break;
      case PaxType.adult:
        {
          _initialDateTime = DateTime.now();
        }
        break;
    }
    _maximumDate = _initialDateTime;
    _minimumYear = _minimumDate.year;
    _maximumYear = _initialDateTime.year;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          contentPadding: EdgeInsets.all(0),
          title: new Text('Date of Birth'),
          content: SizedBox(
              //padding: EdgeInsets.all(1),
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
                Navigator.pop(context, dateTime);
                _updateDateOfBirth(dateTime);
              },
            ),
          ],
        );
      },
    );
  }

  void _updateDateOfBirth(DateTime dateOfBirth) {
    setState(() {
      _dateOfBirthTextEditingController.text =
          DateFormat('dd-MMM-yyyy').format(dateOfBirth);
      FocusScope.of(context).requestFocus(new FocusNode());
    });
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

  void validateAndSubmit() async {
    if (validateAndSave()) {
      if (widget.isAdsBooking && widget.isLeadPassenger) {
        adsValidate();
      } else {
        try {
          Navigator.pop(context, widget.passengerDetail);
        } catch (e) {
          print('Error: $e');
        }
      }
    }
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return num.tryParse(s) != null;
  }
}

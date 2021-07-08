import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/menu/menu.dart';
import 'package:vmba/payment/choosePaymentMethod.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/utilities/widgets/snackbarWidget.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';

class ContactDetailsWidget extends StatefulWidget {
  ContactDetailsWidget(
      {Key key, this.passengers, this.newbooking, this.preLoadDetails, this.passengerDetailRecord})
      : super(key: key);
  final NewBooking newbooking;
  final Passengers passengers;
  final bool preLoadDetails;
  final PassengerDetail passengerDetailRecord;

  _ContactDetailsWidgetState createState() => _ContactDetailsWidgetState();
}

class _ContactDetailsWidgetState extends State<ContactDetailsWidget> {
  //ContactInfomation _contactInfomation = ContactInfomation();
  GlobalKey<ScaffoldState> _key = GlobalKey();
  bool _displayProcessingIndicator;
  String _displayProcessingText = 'Making your Booking...';
  PnrModel pnrModel;
  String _error;

  TextEditingController _emailTextEditingController = TextEditingController();
  TextEditingController _phoneTextEditingController = TextEditingController();

  @override
  initState() {
    super.initState();
    _displayProcessingIndicator = false;
    widget.newbooking.contactInfomation = new ContactInfomation();
    //_emailTextEditingController.text = widget.passengerDetail.title;
    //_phoneTextEditingController.text = widget.passengerDetail.firstName;
    if (widget.preLoadDetails && widget.passengerDetailRecord != null )
      {
//      Repository.get().getUserProfile().then((profile) {
        if (widget.passengerDetailRecord.email.length > 0) {
          _emailTextEditingController.text =
              widget.passengerDetailRecord.email;
        }

        if (widget.passengerDetailRecord.phonenumber.length > 0) {
          _phoneTextEditingController.text =
              widget.passengerDetailRecord.phonenumber;
        }
      }
  }

  final formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    if (_displayProcessingIndicator) {
      return Scaffold(
        key: _key,
        appBar: new AppBar(
          brightness: gblSystemColors.statusBar,
          backgroundColor:
          gblSystemColors.primaryHeaderColor,
          iconTheme: IconThemeData(
              color: gblSystemColors.headerTextColor),
          title: new TrText('Payment',
              style: TextStyle(
                  color:
                  gblSystemColors.headerTextColor)),
        ),
        endDrawer: DrawerMenu(),
        body: new Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              new CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Text(_displayProcessingText),
              ),
            ],
          ),
        ),
      );
    } else {
      return new Scaffold(
          key: _key,
          appBar: new AppBar(
            brightness: gblSystemColors.statusBar,
            backgroundColor:
            gblSystemColors.primaryHeaderColor,
            iconTheme: IconThemeData(
                color: gblSystemColors.headerTextColor),
            title: new TrText('Contact Details',
                style: TextStyle(
                    color: gblSystemColors
                        .headerTextColor)),
          ),
          endDrawer: DrawerMenu(),
          body: new SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: new Form(
                  key: formKey,
                  child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8),
                          child: new Theme(
                            data: new ThemeData(
                              primaryColor: Colors.blueAccent,
                              primaryColorDark: Colors.blue,
                            ),
                            child: new TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                fillColor: Colors.white,
                                border: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(25.0),
                                  borderSide: new BorderSide(),
                                ),
                              ),
                              controller: _phoneTextEditingController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) => value.isEmpty
                                  ? 'Phone number can\'t be empty'
                                  : null,
                              onSaved: (value) => widget.newbooking
                                  .contactInfomation.phonenumber = value.trim(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8),
                          child: new Theme(
                            data: new ThemeData(
                              primaryColor: Colors.blueAccent,
                              primaryColorDark: Colors.blue,
                            ),
                            child: new TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Email',
                                fillColor: Colors.white,
                                border: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(25.0),
                                  borderSide: new BorderSide(),
                                ),
                              ),
                              controller: _emailTextEditingController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) => validateEmail(value.trim()),
                              onSaved: (value) => widget.newbooking
                                  .contactInfomation.email = value.trim(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Wrap(
                            children: <Widget>[
                              Text(
                                  'A contact number and email address is required to send you check-in advice, and any updates concerning changes to your flights including flight status updates.')
                            ],
                          ),
                        )
                      ]))),
          floatingActionButton: Padding(
              padding: EdgeInsets.only(left: 35.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new FloatingActionButton.extended(
                      elevation: 0.0,
                      isExtended: true,
                      label: Text(
                        'PROCEED TO PAYMENT',
                        style: TextStyle(
                            color: gblSystemColors
                                .primaryButtonTextColor),
                      ),
                      icon: Icon(Icons.check,
                          color: gblSystemColors
                              .primaryButtonTextColor),
                      backgroundColor: gblSystemColors
                          .primaryButtonColor, //new Color(0xFF000000),
                      onPressed: () {
                        validateAndSubmit();
                      }),
                ],
              )));
    }
  }

  String validateEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
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

  showSnackBar(String message) {
    final _snackbar = snackbar(message);
    ScaffoldMessenger.of(context).showSnackBar(_snackbar);
    //_key.currentState.showSnackBar(_snackbar);
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      setState(() {
        _displayProcessingIndicator = true;
      });
      hasDataConnection().then((result) async {
        if (result == true) {
          makeBooking();
        } else {
          setState(() {
            _displayProcessingIndicator = false;
          });
          showSnackBar('Please check your internet connection');
        }
      });
    }
  }

  createPnr() {}

  _gotoPreviousPage() {
    Navigator.pop(context, _error);
  }

  Future makeBooking() async {
    String msg = '';
    msg = buildAddPaxCmd();
    msg += buildAddContactsCmd();
    msg += buildADSCmd();
    msg += buildFQTVCmd();
    widget.newbooking.outboundflight.forEach((flt) {
      msg += flt + '^';
    });
    widget.newbooking.returningflight.forEach((flt) {
      msg += flt + '^';
    });
    //Add connecting indicators for outbound flights
    if (widget.newbooking.outboundflight.length > 1) {
      for (var i = 1; i < widget.newbooking.outboundflight.length; i++) {
        print('.${i}x^');
        msg += '.${i}x^';
      }
    }

    if (widget.newbooking.returningflight.length > 1) {
      for (var i = widget.newbooking.outboundflight.length + 1;
          i <
              widget.newbooking.outboundflight.length +
                  widget.newbooking.returningflight.length;
          i++) {
        print('.${i}x^');
        msg += '.${i}x^';
      }
    }

    //Add voucher code
    if (widget.newbooking.eVoucherCode != null &&
        widget.newbooking.eVoucherCode.trim() != '') {
      msg += '4-1FDISC${widget.newbooking.eVoucherCode.trim()}^';
    }

    msg += 'fg^fs1^8M/20^e*r~x';

    http.Response response = await http
        .get(Uri.parse(
            "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg"))
        .catchError((resp) {});

    if (response == null) {
      //return new ParsedResponse(NO_INTERNET, []);
      setState(() {
        _displayProcessingIndicator = false;
      });
      showSnackBar('Please check your internet connection');
      return null;
    }

    //If there was an error return an empty list
    if (response.statusCode < 200 || response.statusCode >= 300) {
      setState(() {
        _displayProcessingIndicator = false;
      });
      showSnackBar('Please check your internet connection');
      return null;
      // return new ParsedResponse(response.statusCode, []);
    }
    try {
      bool flightsConfirmed = true;
      if (response.body.contains('ERROR - ')) {
        _error = response.body
            .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
            .replaceAll('<string xmlns="http://videcom.com/">', '')
            .replaceAll('</string>', '')
            .replaceAll('ERROR - ', '')
            .trim(); // 'Please check your details';
        _dataLoaded();
        print('makeBooking $_error');
        //_showDialog();
        _gotoPreviousPage();
        return;
      } else {
        String pnrJson = response.body
            .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
            .replaceAll('<string xmlns="http://videcom.com/">', '')
            .replaceAll('</string>', '');
        Map map = json.decode(pnrJson);

        pnrModel = new PnrModel.fromJson(map);
        print(pnrModel.pNR.rLOC);
        //bool flightsConfirmed = true;
        if (pnrModel.hasNonHostedFlights() &&
            pnrModel.hasPendingCodeShareOrInterlineFlights()) {
          int noFLts = pnrModel
              .flightCount(); //if external flights aren't confirmed they get removed from the PNR
          // which makes it look like the flights are confirmed

          flightsConfirmed = false;
          for (var i = 0; i < 4; i++) {
            msg = '*' + pnrModel.pNR.rLOC + '~x';
            response = await http
                .get(Uri.parse(
                    "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg"))
                .catchError((resp) {});
            if (response == null) {
              setState(() {
                _displayProcessingIndicator = false;
              });
              showSnackBar('Please check your internet connection');
              return null;
            }

            //If there was an error return an empty list
            if (response.statusCode < 200 || response.statusCode >= 300) {
              setState(() {
                _displayProcessingIndicator = false;
              });
              showSnackBar('Please check your internet connection');
              return null;
            }
            if (response.body.contains('ERROR - ')) {
              _error = response.body
                  .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
                  .replaceAll('<string xmlns="http://videcom.com/">', '')
                  .replaceAll('</string>', '')
                  .replaceAll('ERROR - ', '')
                  .trim(); // 'Please check your details';
              _dataLoaded();
              //_showDialog();
              _gotoPreviousPage();
              return;
            } else {
              String pnrJson = response.body
                  .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
                  .replaceAll('<string xmlns="http://videcom.com/">', '')
                  .replaceAll('</string>', '');
              Map map = json.decode(pnrJson);

              pnrModel = new PnrModel.fromJson(map);
            }

            if (!pnrModel.hasPendingCodeShareOrInterlineFlights()) {
              if (noFLts == pnrModel.flightCount()) {
                flightsConfirmed = true;
              } else {
                flightsConfirmed = false;
              }
              break;
            }
            await new Future.delayed(const Duration(seconds: 2));
            //sleep(const Duration(seconds: 2));
          }
        }
      }
      if (flightsConfirmed) {
        _dataLoaded();
        gotoChoosePaymentPage();
      } else {
        setState(() {
          _displayProcessingIndicator = false;
        });
        showSnackBar('Unable to confirm partner airlines flights.');
        return null;
      }
    } catch (e) {
      _error = response.body
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', '');
      print(_error);
      _dataLoaded();
      _showDialog();
    }
  }

  void gotoChoosePaymentPage() {
    try {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChoosePaymenMethodWidget(
                  newBooking: widget.newbooking, pnrModel: pnrModel, isMmb: false,)
              //CreditCardExample()
              ));
    } catch (e) {
      print('Error: $e');
    }
  }

  void _dataLoaded() {
    setState(() {
      _displayProcessingIndicator = false;
    });
  }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Error"),
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

  String buildAddContactsCmd() {
    StringBuffer sb = new StringBuffer();

    sb.write('9M*${widget.newbooking.contactInfomation.phonenumber}^');
    sb.write('9E*${widget.newbooking.contactInfomation.email}^');

    return sb.toString();
  }

  String buildFQTVCmd() {
    StringBuffer sb = new StringBuffer();
    this.widget.newbooking.passengerDetails.asMap().forEach((index, pax) {
      if (pax.fqtv != null && pax.fqtv != '') {
        sb.write('4-${index + 1}FFQTV${pax.fqtv}^');
      } else {
        if( gblFqtvNumber != null && gblFqtvNumber.isNotEmpty && index == 0) {
          sb.write('4-${index + 1}FFQTV$gblFqtvNumber^');

        }
      }
    });

    return sb.toString();
  }

  String buildADSCmd() {
    StringBuffer sb = new StringBuffer();
    String paxNo = '1';
    if (this.widget.newbooking.ads.pin != null &&
        this.widget.newbooking.ads.pin != '' &&
        this.widget.newbooking.ads.number != null &&
        this.widget.newbooking.ads.number != '') {
      sb.write(
          '4-${paxNo}FADSU/${this.widget.newbooking.ads.number}/${this.widget.newbooking.ads.pin}^');
    }

    this.widget.newbooking.passengerDetails.asMap().forEach((index, pax) {
      if (pax.adsNumber != null && pax.adsNumber != '' && index != 0) {
        sb.write('4-${index + 1}FADSU${pax.adsNumber}^');
      }
    });

    return sb.toString();
  }

  int ageInMonths(DateTime dateOfBirth) {
    int _ageInMonths = 0;
    var date = new DateTime(
        DateTime.now().year, DateTime.now().month, DateTime.now().day);

    while (date.isAfter(dateOfBirth)) {
      _ageInMonths += 1;
      dateOfBirth = new DateTime(
          dateOfBirth.year, dateOfBirth.month + _ageInMonths, dateOfBirth.day);
    }
    return _ageInMonths - 1;
  }

  String buildAddPaxCmd() {
    StringBuffer sb = new StringBuffer();
    widget.newbooking.passengerDetails.forEach((pax) {
      if (pax.lastName != '') {
        sb.write('-${pax.lastName}/${pax.firstName}${pax.title}');
        if (pax.dateOfBirth != null) {
          if (pax.paxType == PaxType.child) {
            sb.write('.CH');
          } else if (pax.paxType == PaxType.youth) {
            sb.write('.TH');
          } else if (pax.paxType == PaxType.infant) {
            sb.write('.IN');
          }
          String _dob =
              DateFormat('ddMMMyy').format(pax.dateOfBirth).toString();
          sb.write('($_dob)');
        }
      }
      sb.write('^');
    });
    return sb.toString();
  }
}

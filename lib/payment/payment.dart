import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/models/pnrs.dart';
import 'package:vmba/data/settings.dart';
import 'package:vmba/data/settingsData.dart';
import 'package:vmba/menu/menu.dart';
import 'package:vmba/payment/choosePaymentMethod.dart';
import 'package:vmba/resources/app_config.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/utilities/widgets/snackbarWidget.dart';
import '../data/repository.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:vmba/data/globals.dart';

class PaymentWidget extends StatefulWidget {
  PaymentWidget({
    Key key,
    this.newBooking,
    this.pnrModel,
    this.stopwatch,
    this.isMmb,
    this.mmbBooking,
    this.session,
  }) : super(key: key);
  final NewBooking newBooking;
  final PnrModel pnrModel;
  final Stopwatch stopwatch;
  final bool isMmb;
  final MmbBooking mmbBooking;
  final Session session;

  _PaymentWidgetState createState() => _PaymentWidgetState();
}

class _PaymentWidgetState extends State<PaymentWidget> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  final formKey = new GlobalKey<FormState>();
  String currencyCode;
  MaskedTextController _cardNumberTextEditingController;
  //TextEditingController _cardNumberTextEditingController;
  TextEditingController _cvvTextEditingController;
  TextEditingController _expiryDateTextEditingController;
  TextEditingController _cardHolderNameTextEditingController;
  TextEditingController _addressLine1TextEditingController;
  TextEditingController _townTextEditingController;
  TextEditingController _stateTextEditingController;
  TextEditingController _postcodeTextEditingController;
  TextEditingController _countryTextEditingController;
  PaymentDetails paymentDetails = new PaymentDetails();
  String nostop = '';
  //var controller = new MaskedController(mask: '0000 0000 0000 0000');

  bool _displayProcessingIndicator;
  String _displayProcessingText;
  PnrModel pnrModel;
  String _error;
  String rLOC = '';

  @override
  initState() {
    super.initState();

    rLOC = widget.pnrModel.pNR.rLOC;

    if (widget.isMmb) {
      // rLOC = widget.mmbBooking.rloc;
      paymentDetails = new PaymentDetails();
    } else {
      //  rLOC = widget.pnrModel.pNR.rLOC;

      paymentDetails = widget.newBooking.paymentDetails;
    }
    if (widget.newBooking == null) {
      print('newBooking is null');
    }

    //widget.newBooking.paymentDetails = new PaymentDetails();
    //_displayProcessingText = 'Making your Booking...';
    _displayProcessingIndicator = false;
    _cardNumberTextEditingController =
        MaskedTextController(mask: '0000 0000 0000 0000');
    //_cardNumberTextEditingController = new TextEditingController();
    _cvvTextEditingController = new TextEditingController();
    _expiryDateTextEditingController = new TextEditingController();
    _cardHolderNameTextEditingController = new TextEditingController();
    _addressLine1TextEditingController = new TextEditingController();
    _townTextEditingController = new TextEditingController();
    _stateTextEditingController = new TextEditingController();
    _postcodeTextEditingController = new TextEditingController();
    _countryTextEditingController = new TextEditingController();

    _cardNumberTextEditingController.addListener(() {
      setState(() {
        //  widget.newBooking.paymentDetails.cardNumber =
        //        _cardNumberTextEditingController.text;
        paymentDetails.cardNumber = _cardNumberTextEditingController.text;
      });
    });

    _cvvTextEditingController.addListener(() {
      setState(() {
        // widget.newBooking.paymentDetails.cVV = _cvvTextEditingController.text;
        paymentDetails.cVV = _cvvTextEditingController.text;
      });
    });

    _expiryDateTextEditingController.addListener(() {
      setState(() {
        //widget.newBooking.paymentDetails.expiryDate =
        //   _expiryDateTextEditingController.text;
        paymentDetails.expiryDate = _expiryDateTextEditingController.text;
      });
    });

    _cardHolderNameTextEditingController.addListener(() {
      setState(() {
        // widget.newBooking.paymentDetails.cardHolderName =
        //  _cardHolderNameTextEditingController.text;
        paymentDetails.cardHolderName =
            _cardHolderNameTextEditingController.text;
      });
    });

    _addressLine1TextEditingController.addListener(() {
      setState(() {
        // widget.newBooking.paymentDetails.addressLine1 =
        //     _addressLine1TextEditingController.text;
        paymentDetails.addressLine1 = _addressLine1TextEditingController.text;
      });
    });
    _townTextEditingController.addListener(() {
      setState(() {
        // widget.newBooking.paymentDetails.town = _townTextEditingController.text;
        paymentDetails.town = _townTextEditingController.text;
      });
    });

    _stateTextEditingController.addListener(() {
      setState(() {
        // widget.newBooking.paymentDetails.state = _stateTextEditingController.text;
        paymentDetails.state = _stateTextEditingController.text;
      });
    });

    _postcodeTextEditingController.addListener(() {
      setState(() {
        //widget.newBooking.paymentDetails.postCode =_postcodeTextEditingController.text;
        paymentDetails.postCode = _postcodeTextEditingController.text;
      });
    });

    _countryTextEditingController.addListener(() {
      setState(() {
        // widget.newBooking.paymentDetails.country =_countryTextEditingController.text;
        paymentDetails.country = _countryTextEditingController.text;
      });
    });
    pnrModel = widget.pnrModel;
    setCurrencyCode();
    //makeBookingV2();
  }

  Future setCurrencyCode() async {
    try {
      currencyCode = this
          .pnrModel
          .pNR
          .fareQuote
          .fareStore
          .where((fareStore) => fareStore.fSID == 'Total')
          .first
          .cur;
    } catch (ex) {
      currencyCode = '';
      print(ex.toString());
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

  Future _sendVRSCommand(msg) async {
    final http.Response response = await http.post(
        Uri.parse(gbl_settings.apiUrl + "/RunVRSCommand"),
        headers: {'Content-Type': 'application/json',
          'Videcom_ApiKey': gbl_settings.apiKey
        },
        body: msg);

    if (response.statusCode == 200) {
      return response.body.trim();
    }
  }

  Future makePayment() async {
    String msg = '';
    http.Response response;
    setState(() {
      _displayProcessingText = 'Processing your payment...';
      _displayProcessingIndicator = true;
    });

    if (widget.session != null) {
      //String msg = getPaymentCmd();
      _sendVRSCommand(json.encode(
              RunVRSCommand(widget.session, getPaymentCmd(false)).toJson()))
          .then((result) {
        if (result == 'Payment Complete') {
          _sendVRSCommand(json.encode(RunVRSCommand(widget.session, "EMT*R~x")))
              .then((onValue) {
            Map map = json.decode(onValue);
            PnrModel pnrModel = new PnrModel.fromJson(map);
            PnrDBCopy pnrDBCopy = new PnrDBCopy(
                rloc: pnrModel.pNR.rLOC, //_rloc,
                data: onValue,
                delete: 0,
                nextFlightSinceEpoch: pnrModel.getnextFlightEpoch());
            Repository.get()
                .updatePnr(pnrDBCopy)
                .then((n) => getArgs())
                .then((arg) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/CompletedPage', (Route<dynamic> route) => false,
                  arguments: arg);
            });
          });
        } else {
          _error = 'Declined';
          _dataLoaded();
          _showDialog();
        }
      });
    } else {
      if (widget.isMmb) {
        msg = '*$rLOC';
        widget.mmbBooking.newFlights.forEach((flt) {
          print(flt);
          msg += '^' + flt;
        });
        msg += '^e*r~x';
      } else {
        msg = '*$rLOC~x';
      }
      //msg += '~x';
      print(msg);
      response = await http
          .get(Uri.parse(
              "${gbl_settings.xmlUrl}${gbl_settings.xmlToken}&command=$msg'"))
          .catchError((resp) {});
      if (response == null) {
        setState(() {
          _displayProcessingIndicator = false;
        });
        showSnackBar('Please check your internet connection');
        return null;
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        setState(() {
          _displayProcessingIndicator = false;
        });
        showSnackBar('Please check your internet connection');
        return null;
      }

      bool flightsConfirmed = true;
      String _response = response.body
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', '');
      if (response.body.contains('ERROR - ') ||
          !_response.trim().startsWith('{')) {
        _error = _response.replaceAll('ERROR - ', '').trim();
        _dataLoaded();
        showSnackBar(_error);
        return null;
      } else {
        Map map = json.decode(_response);
        pnrModel = new PnrModel.fromJson(map);
        print(pnrModel.pNR.rLOC);
        if (pnrModel.hasNonHostedFlights() &&
            pnrModel.hasPendingCodeShareOrInterlineFlights()) {
          int noFLts = pnrModel
              .flightCount(); //if external flights aren't confirmed they get removed from the PNR
          // which makes it look like the flights are confirmed

          flightsConfirmed = false;
          for (var i = 0; i < 10; i++) {
            msg = '*' + pnrModel.pNR.rLOC + '~x';
            response = await http
                .get(Uri.parse(
                    "${gbl_settings.xmlUrl}${gbl_settings.xmlToken}&command=$msg"))
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
              return null;
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
          }
        }
      }
      if (!flightsConfirmed) {
        setState(() {
          _displayProcessingIndicator = false;
        });
        showSnackBar('Unable to confirm partner airlines flights.');
        //Cnx new flights
        msg = '*${widget.mmbBooking.rloc}';
        widget.mmbBooking.newFlights.forEach((flt) {
          print('x' + flt.split('NN1')[0].substring(2));
          msg += '^' + 'x' + flt.split('NN1')[0].substring(2);
        });
        response = await http
            .get(Uri.parse(
                "${gbl_settings.xmlUrl}${gbl_settings.xmlToken}&command=$msg"))
            .catchError((resp) {});
        return null;
      }

      msg = '*$rLOC^';
      //update to use full cancel segment command
      if (widget.isMmb) {
        //msg += '^';

        for (var i = 0;
            i <
                widget.mmbBooking.journeys
                    .journey[widget.mmbBooking.journeyToChange - 1].itin.length;
            i++) {
          Itin f = widget.mmbBooking.journeys
              .journey[widget.mmbBooking.journeyToChange - 1].itin[i];
          String _depDate =
              DateFormat('ddMMM').format(DateTime.parse(f.depDate)).toString();
          msg +=
              'X${f.airID}${f.fltNo}${f.xclass}$_depDate${f.depart}${f.arrive}^';
          if (f.nostop == 'X') {
            nostop += ".${f.line}X^";
          }
        }

        // widget.mmbBooking.journeys
        //     .journey[widget.mmbBooking.journeyToChange - 1].itin.reversed
        //     .forEach((f) {
        //   //msg += 'X${f.line}^';

        //   String _depDate =
        //       DateFormat('ddMMM').format(DateTime.parse(f.depDate)).toString();
        //   msg +=
        //       'X${f.airID}${f.fltNo}${f.cabin}$_depDate${f.depDate}${f.arrive}^';
        //   if (f.nostop == 'X') {
        //     nostop += ".${f.line}X^";
        //   }
        // });

        // widget.mmbBooking.newFlights.forEach((flt) {
        //   print(flt);
        //   msg += flt + '^';
        // });

        msg += 'fg^fs1^e*r^';
      }

      //msg = '*$rLOC^';
      msg += getPaymentCmd(true);

      response = await http
          .get(Uri.parse(
              "${gbl_settings.xmlUrl}${gbl_settings.xmlToken}&command=$msg'"))
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

      try {
        String result = response.body
            .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
            .replaceAll('<string xmlns="http://videcom.com/">', '')
            .replaceAll('</string>', '');

        if (result.trim() == 'Payment Complete') {
          print('Payment success');
          setState(() {
            _displayProcessingText = 'Completing your booking...';
            _displayProcessingIndicator = true;
          });
          if (pnrModel.pNR.tickets != null) {
            await pullTicketControl(pnrModel.pNR.tickets);
          }
          ticketBooking();
        } else {
          _error = 'Declined';
          _dataLoaded();
          _showDialog();
        }
      } catch (e) {
        _error = response.body; // 'Please check your details';
        _dataLoaded();
        _showDialog();
      }
    }
  }

  String getTicketingCmd() {
    var buffer = new StringBuffer();
    if (widget.isMmb) {
      buffer.write(nostop);
      buffer.write('EZV*[E][ZWEB]^');
    }
    buffer.write('EZT*R^*R~x');
    return buffer.toString();
  }

  Future<void> pullTicketControl(Tickets tickets) async {
    String msg = '';
    for (var i = 0; i < pnrModel.pNR.tickets.tKT.length; i++) {
      if (pnrModel.pNR.tickets.tKT[i].status == 'A') {
        msg = '*${widget.mmbBooking.rloc}^';
        msg += '*t-' +
            pnrModel.pNR.tickets.tKT[i].tktNo.replaceAll(' ', '') +
            '/' +
            pnrModel.pNR.tickets.tKT[i].coupon +
            '=o';
        http.Response reponse = await http
            .get(Uri.parse(
                "${gbl_settings.xmlUrl}${gbl_settings.xmlToken}&command=$msg'"))
            .catchError((resp) {});
      }
    }
  }

  Future ticketBooking() async {
    String msg = '';
    http.Response response;
    msg = '*$rLOC^';
    msg += getTicketingCmd();

    response = await http
        .get(Uri.parse(
            "${gbl_settings.xmlUrl}${gbl_settings.xmlToken}&command=$msg'"))
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

    try {
      String pnrJson = response.body
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', '');

      Map map = json.decode(pnrJson);

      PnrModel pnrModel = new PnrModel.fromJson(map);

      PnrDBCopy pnrDBCopy = new PnrDBCopy(
          rloc: pnrModel.pNR.rLOC, //_rloc,
          data: pnrJson,
          delete: 0,
          nextFlightSinceEpoch: pnrModel.getnextFlightEpoch());
      Repository.get().updatePnr(pnrDBCopy);
      Repository.get()
          .fetchApisStatus(this.pnrModel.pNR.rLOC)
          .then((_) => sendEmailConfirmation())
          .then((_) => getArgs())
          .then((args) => Navigator.of(context).pushNamedAndRemoveUntil(
              '/CompletedPage', (Route<dynamic> route) => false,
              arguments: args
              //[pnrModel.pNR.rLOC, result.toString()]
              ));
      //sendEmailConfirmation();

    } catch (e) {
      _error = response.body; // 'Please check your details';
      _dataLoaded();
      _showDialog();
    }
  }

  getArgs() {
    List<String> args = [];
    // List<String>();
    args.add(this.pnrModel.pNR.rLOC);
    if (pnrModel.pNR.itinerary.itin
            .where((itin) =>
                itin.classBand.toLowerCase() != 'fly' &&
                itin.openSeating != 'True')
            .length >
        0) {
      args.add('true');
    } else {
      args.add('false');
    }
    return args;
  }

  sendEmailConfirmation() async {
    try {
      String msg = '*${pnrModel.pNR.rLOC}^EZRE';
      http.Response response = await http
          .get(Uri.parse(
              "${gbl_settings.xmlUrl}${gbl_settings.xmlToken}&command=$msg'"))
          .catchError((resp) {});

      if (response == null) {
        //return new ParsedResponse(NO_INTERNET, []);
      }

      //If there was an error return an empty list
      if (response.statusCode < 200 || response.statusCode >= 300) {
        //return new ParsedResponse(response.statusCode, []);
      }
      print(response.body
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', ''));
    } catch (e) {
      print(e.toString());
    }
  }

  String getPaymentCmd(bool makeHtmlSafe) {
    var buffer = new StringBuffer();
  /*  if (isLive) {
      buffer.write('MK($creditCardProviderProduction)');
    } else {
      buffer.write('MK($creditCardProviderStaging)');
    }
   */
    buffer.write('MK($gbl_settings.creditCardProvider)');

    //creditCardProviderStaging
    //buffer.write('MK(${gbl_settings.creditCardProvider})');
    // buffer.write('${pnrModel.pNR.basket.outstanding.cur}');
    // buffer.write('${pnrModel.pNR.basket.outstanding.amount}');
    buffer.write('/${this.paymentDetails.cardNumber.trim()}');

    buffer.write(
        '**${this.paymentDetails.expiryDate.substring(0, 2)}${this.paymentDetails.expiryDate.substring(2, 4)}');
    buffer.write(
        ':${this.paymentDetails.cardHolderName.replaceAll(',', ' ').replaceAll('/', ' ').replaceAll('-', ' ').trim()}');
    buffer.write('&${this.paymentDetails.cVV.trim()}');
    buffer.write(
        '/${this.paymentDetails.addressLine1.replaceAll(',', ' ').replaceAll('/', ' ').trim()}');
    buffer.write(
        '/${this.paymentDetails.addressLine2.replaceAll(',', ' ').replaceAll('/', ' ').trim()}');
    buffer.write(
        '/${this.paymentDetails.town.replaceAll(',', ' ').replaceAll('/', ' ').trim()}');
    buffer.write(
        '/${this.paymentDetails.state.replaceAll(',', ' ').replaceAll('/', ' ').trim()}');
    buffer.write(
        '/${this.paymentDetails.postCode.replaceAll(',', ' ').replaceAll('/', ' ').trim()}');
    buffer.write(
        '/${this.paymentDetails.country.replaceAll(',', ' ').replaceAll('/', ' ').trim()}');

    if (makeHtmlSafe) {
      return buffer
          .toString()
          .replaceAll('=', '%3D')
          .replaceAll(',', '%2C')
          .replaceAll('/', '%2F')
          .replaceAll(':', '%3A')
          .replaceAll('[', '%5B')
          .replaceAll(']', '%5D')
          .replaceAll('&', '%26');
    } else {
      return buffer.toString();
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

  bool validate() {
    final form = formKey.currentState;
    if (form.validate()) {
      return true;
    } else {
      return false;
    }
  }

  showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(snackbar(message));
    // final _snackbar = snackbar(message);
    // _key.currentState.showSnackBar(_snackbar);
  }

  void validateAndSubmit() async {
    if (validate()) {
      hasDataConnection().then((result) async {
        if (result == true) {
          makePayment();
        } else {
          setState(() {
            _displayProcessingIndicator = false;
          });
          showSnackBar('Please check your internet connection');
        }
      });
    }
  }

  void formSave() {
    final form = formKey.currentState;
    form.save();
  }

  void _showCountriesDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
            title: new Text('Country'),
            content: new FutureBuilder(
              future: getCountrylist(),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data != null) {
                    return Container(
                      width: double.maxFinite,
                      child: new ListView(
                        children: optionCountryList(snapshot),
                      ),
                    );
                  } else {
                    return null;
                  }
                } else {
                  return Container(
                    width: double.maxFinite,
                    child: new Center(
                      child: new CircularProgressIndicator(),
                    ),
                  );
                }
              },
            ));
      },
    );
  }

  void _updateCountryData(String value) {
    setState(() {
      //widget.newBooking.paymentDetails.country = value;
      paymentDetails.country = value;
      _countryTextEditingController.text = value;
      FocusScope.of(context).requestFocus(new FocusNode());
    });
  }

  List<Widget> optionCountryList(AsyncSnapshot snapshot) {
    List<Widget> widgets = [];
    // new List<Widget>();
    Countrylist countrylist = snapshot.data;
    countrylist.countries.forEach((c) => widgets.add(ListTile(
        title: Text(c.enShortName),
        onTap: () {
          Navigator.pop(context, c.alpha2code);
          _updateCountryData(c.alpha2code);
          //Navigator.pop(context, c.alpha3code);
          //_updateCountryData(c.alpha3code);
        })));
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    if (_displayProcessingIndicator) {
      return Scaffold(
        key: _key,
        appBar: new AppBar(
          brightness: gbl_SystemColors.statusBar,
          backgroundColor:
          gbl_SystemColors.primaryHeaderColor,
          iconTheme: IconThemeData(
              color: gbl_SystemColors.headerTextColor),
          title: new Text('Payment',
              style: TextStyle(
                  color:
                  gbl_SystemColors.headerTextColor)),
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
          floatingActionButton: Padding(
              padding: EdgeInsets.only(left: 35.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new FloatingActionButton.extended(
                      elevation: 0.0,
                      isExtended: true,
                      label: Text(
                        'PAY NOW',
                        style: TextStyle(
                            color: gbl_SystemColors
                                .primaryButtonTextColor),
                      ),
                      icon: Icon(Icons.check,
                          color: gbl_SystemColors
                              .primaryButtonTextColor),
                      backgroundColor:
                      gbl_SystemColors.primaryButtonColor,
                      onPressed: () {
                        validateAndSubmit();
                      }),
                ],
              )),
          appBar: new AppBar(
            brightness: gbl_SystemColors.statusBar,
            backgroundColor:
            gbl_SystemColors.primaryHeaderColor,
            iconTheme: IconThemeData(
                color: gbl_SystemColors.headerTextColor),
            title: new Text('Payment',
                style: TextStyle(
                    color: gbl_SystemColors
                        .headerTextColor)),
          ),
          endDrawer: DrawerMenu(),
          body: SafeArea(
            child: Column(
              children: <Widget>[
                Row(children: <Widget>[
                  Expanded(
                    child: DecoratedBox(
                        decoration: BoxDecoration(color: Colors.black),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'Please complete you payment within ',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w300),
                                ),
                                TimerText(
                                  stopwatch: widget.stopwatch,
                                )
                              ],
                            ),
                          ),
                        )),
                  )
                ]),
                Expanded(
                  child: new SingleChildScrollView(
                      padding: EdgeInsets.all(16.0),
                      child: new Theme(
                        data: new ThemeData(
                          primaryColor: Colors.blueAccent,
                          primaryColorDark: Colors.blue,
                        ),
                        child: new Form(
                            key: formKey,
                            child: new Column(children: [
                              // Padding(
                              //   padding: const EdgeInsets.all(8.0),
                              //   child: FlatButton(
                              //     child: Text('Scan credit card'),
                              //     onPressed: () async {
                              //       Map<String, dynamic> details =
                              //           await CoreCardIo.scanCard({
                              //         "requireExpiry": true,
                              //         "scanExpiry": true,
                              //         "requireCVV": true,
                              //         "requirePostalCode": true,
                              //         "restrictPostalCodeToNumericOnly": true,
                              //         "requireCardHolderName": true,
                              //         "scanInstructions":
                              //             "Fit the card within the box",
                              //       });
                              //     },
                              //   ),
                              // ),
                              Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(0, 8.0, 0, 8),
                                  child: TextFormField(
                                    controller:
                                        _cardNumberTextEditingController,
                                    decoration: InputDecoration(
                                      hintText: 'xxxx xxxx xxxx xxxx',
                                      labelText: 'Card number',
                                      contentPadding: new EdgeInsets.symmetric(
                                          vertical: 15.0, horizontal: 15.0),
                                      fillColor: Colors.white,
                                      border: new OutlineInputBorder(
                                        borderRadius:
                                            new BorderRadius.circular(25.0),
                                        borderSide: new BorderSide(),
                                      ),
                                    ),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      // FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    validator: (value) => value.isEmpty
                                        ? 'Card number can\'t be empty'
                                        : null,
                                    onSaved: (value) => widget
                                        .newBooking
                                        .paymentDetails
                                        .cardNumber = value.trim(),
                                    onFieldSubmitted: (value) {
                                      _cardNumberTextEditingController.text =
                                          value;
                                    },
                                  )),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 8.0, 0, 8),
                                child: new TextFormField(
                                  decoration: InputDecoration(
                                    contentPadding: new EdgeInsets.symmetric(
                                        vertical: 15.0, horizontal: 15.0),
                                    hintText: 'xxx',
                                    labelText: 'Security code ',
                                    fillColor: Colors.white,
                                    border: new OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(25.0),
                                      borderSide: new BorderSide(),
                                    ),
                                  ),
                                  onFieldSubmitted: (value) {
                                    _cvvTextEditingController.text = value;
                                  },
                                  controller: _cvvTextEditingController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4)
                                  ],
                                  validator: (value) => value.isEmpty
                                      ? 'Security code can\'t be empty'
                                      : null,
                                  onSaved: (value) => widget.newBooking
                                      .paymentDetails.cVV = value.trim(),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 8.0, 0, 8),
                                child: new TextFormField(
                                  controller: _expiryDateTextEditingController,
                                  decoration: InputDecoration(
                                    contentPadding: new EdgeInsets.symmetric(
                                        vertical: 15.0, horizontal: 15.0),
                                    hintText: 'mmyy',
                                    labelText: 'Expiry date ',
                                    fillColor: Colors.white,
                                    border: new OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(25.0),
                                      borderSide: new BorderSide(),
                                    ),
                                  ),
                                  onFieldSubmitted: (value) {
                                    _expiryDateTextEditingController.text =
                                        value;
                                    //widget.newBooking.paymentDetails.expiryDate = value;
                                  },
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp("[0-9]")),
                                    LengthLimitingTextInputFormatter(4)
                                  ],
                                  validator: (value) => value.isEmpty
                                      ? 'Expiry date can\'t be empty'
                                      : null,
                                  onSaved: (value) => widget.newBooking
                                      .paymentDetails.expiryDate = value.trim(),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 8.0, 0, 8),
                                child: new TextFormField(
                                  controller:
                                      _cardHolderNameTextEditingController,
                                  decoration: InputDecoration(
                                    contentPadding: new EdgeInsets.symmetric(
                                        vertical: 15.0, horizontal: 15.0),
                                    labelText:
                                        //'Cardholder name (as printed on card)',
                                        'Name on card',
                                    fillColor: Colors.white,
                                    border: new OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(25.0),
                                      borderSide: new BorderSide(),
                                    ),
                                  ),
                                  keyboardType: TextInputType.text,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp("[a-zA-Z- ]"))
                                  ],
                                  onFieldSubmitted: (value) {
                                    _cardHolderNameTextEditingController.text =
                                        value;
                                    //widget.newBooking.paymentDetails.cardHolderName = value;
                                  },
                                  validator: (value) => value.isEmpty
                                      ? 'Cardholder name can\'t be empty'
                                      : null,
                                  onSaved: (value) => widget
                                      .newBooking
                                      .paymentDetails
                                      .cardHolderName = value.trim(),
                                ),
                              ),
                              Divider(),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 8.0, 0, 8),
                                child: new TextFormField(
                                  decoration: InputDecoration(
                                    contentPadding: new EdgeInsets.symmetric(
                                        vertical: 15.0, horizontal: 15.0),
                                    hintText: 'Address line 1',
                                    labelText: 'Address line 1',
                                    fillColor: Colors.white,
                                    border: new OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(25.0),
                                      borderSide: new BorderSide(),
                                    ),
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp("[a-zA-Z0-9- ]"))
                                  ],
                                  onFieldSubmitted: (value) {
                                    _addressLine1TextEditingController.text =
                                        value;
                                    // widget.newBooking.paymentDetails.addressLine1 = value;
                                  },
                                  keyboardType: TextInputType.text,
                                  controller:
                                      _addressLine1TextEditingController,
                                  validator: (value) => value.isEmpty
                                      ? 'Address field required'
                                      : null,
                                  onSaved: (value) => widget
                                      .newBooking
                                      .paymentDetails
                                      .addressLine1 = value.trim(),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 8.0, 0, 8),
                                child: new TextFormField(
                                  decoration: InputDecoration(
                                    contentPadding: new EdgeInsets.symmetric(
                                        vertical: 15.0, horizontal: 15.0),
                                    hintText: 'Town or City',
                                    labelText: 'Town/City',
                                    fillColor: Colors.white,
                                    border: new OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(25.0),
                                      borderSide: new BorderSide(),
                                    ),
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp("[a-zA-Z- ]"))
                                  ],
                                  onFieldSubmitted: (value) {
                                    _townTextEditingController.text = value;
                                    //widget.newBooking.paymentDetails.town = value;
                                  },
                                  controller: _townTextEditingController,
                                  keyboardType: TextInputType.text,
                                  validator: (value) => value.isEmpty
                                      ? 'Address field required'
                                      : null,
                                  onSaved: (value) => widget.newBooking
                                      .paymentDetails.town = value.trim(),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 8.0, 0, 8),
                                child: new TextFormField(
                                  decoration: InputDecoration(
                                    contentPadding: new EdgeInsets.symmetric(
                                        vertical: 15.0, horizontal: 15.0),
                                    hintText: gbl_settings.aircode == 'SI'
                                        ? 'Parish or County'
                                        : 'County or State',
                                    labelText:  gbl_settings.aircode == 'SI'
                                        ? 'Parish / County'
                                        : 'County/State',
                                    fillColor: Colors.white,
                                    border: new OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(25.0),
                                      borderSide: new BorderSide(),
                                    ),
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp("[a-zA-Z ]"))
                                  ],
                                  onFieldSubmitted: (value) {
                                    _stateTextEditingController.text = value;
                                    //widget.newBooking.paymentDetails.state = value;
                                  },
                                  controller: _stateTextEditingController,
                                  keyboardType: TextInputType.text,
                                  validator: (value) => value.isEmpty
                                      ? 'Address field required'
                                      : null,
                                  onSaved: (value) => widget.newBooking
                                      .paymentDetails.state = value.trim(),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 8.0, 0, 8),
                                child: new TextFormField(
                                  decoration: InputDecoration(
                                    contentPadding: new EdgeInsets.symmetric(
                                        vertical: 15.0, horizontal: 15.0),
                                    hintText: 'Post code / Zip Code',
                                    labelText: 'Post code / Zip Code',
                                    fillColor: Colors.white,
                                    border: new OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(25.0),
                                      borderSide: new BorderSide(),
                                    ),
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                        RegExp("[a-zA-Z0-9 ]"))
                                  ],
                                  onFieldSubmitted: (value) {
                                    _postcodeTextEditingController.text = value;
                                    //widget.newBooking.paymentDetails.postCode = value;
                                  },
                                  controller: _postcodeTextEditingController,
                                  keyboardType: TextInputType.text,
                                  // validator: (value) => value.isEmpty
                                  //     ? 'Address field required'
                                  //     : null,
                                  onSaved: (value) => widget.newBooking
                                      .paymentDetails.postCode = value.trim(),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  _showCountriesDialog();
                                },
                                child: IgnorePointer(
                                  child: TextFormField(
                                    decoration: new InputDecoration(
                                      contentPadding: new EdgeInsets.symmetric(
                                          vertical: 15.0, horizontal: 15.0),
                                      labelText: 'Country',
                                      fillColor: Colors.white,
                                      border: new OutlineInputBorder(
                                        borderRadius:
                                            new BorderRadius.circular(25.0),
                                        borderSide: new BorderSide(),
                                      ),
                                    ),
                                    controller: _countryTextEditingController,
                                    validator: (value) => value.isEmpty
                                        ? 'Address field required'
                                        : null,
                                    onSaved: (value) {
                                      if (value != null) {
                                        // widget.newBooking.paymentDetails.country =
                                        //     value.trim();
                                        paymentDetails.country = value.trim();
                                      }
                                    },
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(30.0),
                              )
                              // RaisedButton(
                              //   color: Colors.black,
                              //   shape: RoundedRectangleBorder(
                              //       borderRadius:
                              //           BorderRadius.circular(30.0)),
                              //   onPressed: () => validateAndSubmit(),
                              //   child: Text(
                              //     'PAY NOW',
                              //     style: new TextStyle(color: Colors.white),
                              //   ),
                              // ),
                            ])),
                      )),
                ),
              ],
            ),
          ));
    }
  }
}

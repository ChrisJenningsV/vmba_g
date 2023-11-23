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
import 'package:vmba/controllers/vrsCommands.dart';
import 'package:vmba/utilities/widgets/appBarWidget.dart';
import 'package:vmba/data/repository.dart';

import '../Helpers/networkHelper.dart';
import '../components/vidButtons.dart';
import '../utilities/messagePages.dart';
import '../utilities/widgets/CustomPageRoute.dart';

class ContactDetailsWidget extends StatefulWidget {
  ContactDetailsWidget(
      {Key key= const Key("contact_key"),  this.passengers, required this.newbooking, required this.preLoadDetails, required this.passengerDetailRecord})
      : super(key: key);
  final NewBooking newbooking;
  final Passengers? passengers;
  final bool preLoadDetails;
  final PassengerDetail? passengerDetailRecord;

  _ContactDetailsWidgetState createState() => _ContactDetailsWidgetState();
}

class _ContactDetailsWidgetState extends State<ContactDetailsWidget> {
  //ContactInfomation _contactInfomation = ContactInfomation();
  GlobalKey<ScaffoldState> _key = GlobalKey();
  bool _displayProcessingIndicator= false;
  bool _tooManyUmnr= false;
  String _displayProcessingText = 'Making your Booking...';
  PnrModel pnrModel= PnrModel();
  String _error = '';


  TextEditingController _emailTextEditingController = TextEditingController();
  TextEditingController _phoneTextEditingController = TextEditingController();

  @override
  initState() {
    logit('init contactDetailsWidget');
    super.initState();
    _displayProcessingIndicator = false;
    _tooManyUmnr = false;
    widget.newbooking.contactInfomation = new ContactInfomation();
    //_emailTextEditingController.text = widget.passengerDetail.title;
    //_phoneTextEditingController.text = widget.passengerDetail.firstName;
    if (widget.preLoadDetails && widget.passengerDetailRecord != null )
      {
//      Repository.get().getUserProfile().then((profile) {
        if (widget.passengerDetailRecord!.email.length > 0) {
          _emailTextEditingController.text =
              widget.passengerDetailRecord!.email;
        }

        if (widget.passengerDetailRecord!.phonenumber.length > 0) {
          _phoneTextEditingController.text =
              widget.passengerDetailRecord!.phonenumber;
        }
      }
    if( gblSettings.wantNewEditPax) {
      _displayProcessingIndicator = true;
      makeBooking();
    }
  }

  final formKey = new GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    if (_displayProcessingIndicator && gblInRefreshing == false) {
      if( gblSettings.wantCustomProgress) {
        progressMessagePage(context, _displayProcessingText, title: 'Payment');
        return Container();
      } else {
        return Scaffold(
          key: _key,
          appBar: appBar(context, 'Payment',
            curStep: 5,
            imageName: gblSettings.wantPageImages ? 'paymentPage' : '',),

          endDrawer: DrawerMenu(),
          body: new Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                new CircularProgressIndicator(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: new TrText(_displayProcessingText),
                ),
              ],
            ),
          ),
        );
      }
    } else if (_tooManyUmnr) {
      return new Scaffold(
          key: _key,
          appBar: new AppBar(
            //brightness: gblSystemColors.statusBar,
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
          body: AlertDialog(
            title: new TrText("Too Many UMNR Passengers on flight"),
            content: TrText("Would you like to restart your booking?"),
            actions: <Widget>[
              // usually buttons at the bottom of the dialog
              new TextButton(
                child: new TrText("NO"),
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/HomePage', (Route<dynamic> route) => false);
                },
              ),
              new TextButton(
                child: new TrText("Restart booking"),
                onPressed: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      '/FlightSearchPage', (Route<dynamic> route) => false);
                },
              ),
            ],
          )
      );
    } else if( gblSettings.wantNewEditPax ){
      return new Container();
    } else {
      return new Scaffold(
          key: _key,
          appBar: new AppBar(
            //brightness: gblSystemColors.statusBar,
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
                                labelText: translate('Phone Number'),
                                fillColor: Colors.white,
                                border: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(25.0),
                                  borderSide: new BorderSide(),
                                ),
                              ),
                              controller: _phoneTextEditingController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) => value!.isEmpty
                                  ? translate('Phone number can\'t be empty')
                                  : null,
                              onSaved: (value) => widget.newbooking
                                  .contactInfomation.phonenumber = value!.trim(),
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
                                labelText: translate('Email'),
                                fillColor: Colors.white,
                                border: new OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(25.0),
                                  borderSide: new BorderSide(),
                                ),
                              ),
                              controller: _emailTextEditingController,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                String er = validateEmail(value!.trim());
                                if( er != '') return er;
                                return null;
                              },
                              onSaved: (value) => widget.newbooking
                                  .contactInfomation.email = value!.trim(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Wrap(
                            children: <Widget>[
                              TrText(
                                  'A contact number and email address is required to send you check-in advice, and any updates concerning changes to your flights including flight status updates.')
                            ],
                          ),
                        )
                      ]))),
          floatingActionButton: vidWideTextButton(context, 'PROCEED TO PAYMENT',  validateAndSubmit, icon: Icons.check),
/*
          Padding(
              padding: EdgeInsets.only(left: 35.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new FloatingActionButton.extended(
                      elevation: 0.0,
                      isExtended: true,
                      label: TrText(
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
              ))
*/
      );
    }
  }

  String validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return '';
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form!.validate()) {
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

  void validateAndSubmit({int? p1}) async {
    if (validateAndSave()) {
      setState(() {
        _displayProcessingIndicator = true;
      });
      hasDataConnection().then((result) async {
        if (result == true) {
          makeBooking();
        } else {
          setState(() {
            endProgressMessage();
            _displayProcessingIndicator = false;
          });
//          noInternetSnackBar(context);
        }
      });
    }
  }

  //createPnr() {}

  _gotoPreviousPage() {
    if( gblSettings.wantNewEditPax ){
      // double pop
      var nav = Navigator.of(context);
      nav.pop(_error);
      nav.pop(_error);
    } else {
      Navigator.pop(context, _error);
//      Navigator.of(context).pop();
    }
  }


  Future makeBooking() async {
    String msg = '';
    // if using VRS sessions/AAA clear out temp booking

    print('makeBooking gblSettings.useWebApiforVrs=${gblSettings.useWebApiforVrs}');
    if(gblSettings.useWebApiforVrs ) msg = 'I^';

    msg += buildAddPaxCmd();
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
    if( gblSettings.brandID != null && gblSettings.brandID.isNotEmpty){
      msg += 'zbrandid=${gblSettings.brandID}^';
    }
    msg += addFg(widget.newbooking.currency, true);
    msg += addFareStore(true);
    //msg += 'fg^fs1^8M/20^e*r~x';
    msg += '8M/20^e*r~x';

    logit('makeBooking: $msg');

    if( gblSettings.useWebApiforVrs) {
      print('Calling VRS with Cmd = $msg');
      String data = await runVrsCommand(msg).catchError((e) {
        //noInternetSnackBar(context);
        return null;
      });

      try {
        bool flightsConfirmed = true;
        if (data.contains('ERROR - ') || data.contains('ERROR:')) {
          _error = data
              .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
              .replaceAll('<string xmlns="http://videcom.com/">', '')
              .replaceAll('</string>', '')
              .replaceAll('ERROR - ', '')
              .trim(); // 'Please check your details';

          if (data.contains('TOO MANY UMNR')) {
            setState(() {
              endProgressMessage();
              _displayProcessingIndicator = false;
              _tooManyUmnr = true;
            });
            return null;
          }
          _dataLoaded();
          print('makeBooking $_error');
          //_showDialog();
          _gotoPreviousPage();
          return;
        } else {
          String pnrJson =data
              .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
              .replaceAll('<string xmlns="http://videcom.com/">', '')
              .replaceAll('</string>', '');
          Map<String, dynamic> map = json.decode(pnrJson);

          pnrModel = new PnrModel.fromJson(map);
          print(pnrModel.pNR.rLOC);
          //bool flightsConfirmed = true;
          if (pnrModel.hasNonHostedFlights() && pnrModel.hasPendingCodeShareOrInterlineFlights()) {
            //if external flights aren't confirmed they get removed from the PNR which makes it look like the flights are confirmed
            int noFLts = pnrModel.flightCount();

            flightsConfirmed = false;
            for (var i = 0; i < 10; i++) { // was 4
              msg = '*' + pnrModel.pNR.rLOC + '~x';
              http.Response response = await http.get(Uri.parse(
              "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg"),
              headers: getXmlHeaders())
              .catchError((resp) {});
              if (response == null) {
                setState(() {
                  endProgressMessage();
                  _displayProcessingIndicator = false;
                });
                //showSnackBar(translate('Please, check your internet connection'));
                //noInternetSnackBar(context);
                return null;
              }

              //If there was an error return an empty list
              if (response.statusCode < 200 || response.statusCode >= 300) {
                setState(() {
                  endProgressMessage();
                  _displayProcessingIndicator = false;
                });
                //showSnackBar(translate('Please, check your internet connection'));
                //noInternetSnackBar(context);
                return null;
              } else if (response.body.contains('ERROR - ') || response.body.contains('ERROR:')) {
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
                Map<String, dynamic> map = json.decode(pnrJson);

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
              await new Future.delayed(const Duration(seconds: 4)); // was 2
              //sleep(const Duration(seconds: 2));
            }
          }
        }

        if (flightsConfirmed) {
          _dataLoaded();
          gotoChoosePaymentPage();
        } else {
          setState(() {
            endProgressMessage();
            _displayProcessingIndicator = false;
          });
          _error = translate('Unable to confirm partner airlines flights.');
          //showSnackBar();
          logit('Unable to confirm partner airlines flights.');
          Navigator.pop(context, _error);
          return null;
        }
      } catch (e) {
        logit(e.toString());
        _error = e.toString();
        if( data != null ) {
          _error = data
              .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
              .replaceAll('<string xmlns="http://videcom.com/">', '')
              .replaceAll('</string>', '');
          print(_error);
        }
        _dataLoaded();
        _showDialog();
      }

    } else {
        print("Calling ${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg");

        http.Response response = await http.get(Uri.parse(
            "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg"),
            headers: getXmlHeaders())
        .catchError((resp) {});

        if (response == null) {
          //return new ParsedResponse(NO_INTERNET, []);
          setState(() {
            endProgressMessage();
            _displayProcessingIndicator = false;
          });
          //showSnackBar(translate('Please, check your internet connection'));
          //noInternetSnackBar(context);
          return null;
        }

        //If there was an error return an empty list
        if (response.statusCode < 200 || response.statusCode >= 300) {
          setState(() {
            endProgressMessage();
            _displayProcessingIndicator = false;
          });
          //showSnackBar(translate('Please, check your internet connection'));
          //noInternetSnackBar(context);
          return null;
          // return new ParsedResponse(response.statusCode, []);
        }

        try {
          bool flightsConfirmed = true;
          if (response.body.contains('ERROR - ') || response.body.contains('ERROR:')) {
            _error = response.body
                .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
                .replaceAll('<string xmlns="http://videcom.com/">', '')
                .replaceAll('</string>', '')
                .replaceAll('ERROR - ', '')
                .trim(); // 'Please check your details';

            if (response.body.contains('TOO MANY UMNR')) {
              setState(() {
                endProgressMessage();
                _displayProcessingIndicator = false;
                _tooManyUmnr = true;
              });
              return null;
            }
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
            Map<String, dynamic> map = json.decode(pnrJson);

            pnrModel = new PnrModel.fromJson(map);
            print(pnrModel.pNR.rLOC);
            //bool flightsConfirmed = true;
            if (pnrModel.hasNonHostedFlights() && pnrModel.hasPendingCodeShareOrInterlineFlights()) {
              //if external flights aren't confirmed they get removed from the PNR which makes it look like the flights are confirmed
              int noFLts = pnrModel.flightCount();

              flightsConfirmed = false;
              for (var i = 0; i < 10; i++) { // was 4
                msg = '*' + pnrModel.pNR.rLOC + '~x';
                response = await http
                    .get(Uri.parse(
                    "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=$msg"),
                    headers: getXmlHeaders())
                    .catchError((resp) {});
                if (response == null) {
                  setState(() {
                    endProgressMessage();
                    _displayProcessingIndicator = false;
                  });
                  //showSnackBar(translate('Please, check your internet connection'));
                  //noInternetSnackBar(context);
                  return null;
                }

                //If there was an error return an empty list
                if (response.statusCode < 200 || response.statusCode >= 300) {
                  setState(() {
                    endProgressMessage();
                    _displayProcessingIndicator = false;
                  });
                  //showSnackBar(translate('Please, check your internet connection'));
                  //noInternetSnackBar(context);
                  return null;
                } else if (response.body.contains('ERROR - ') ||
                    response.body.contains('ERROR:')) {
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
                  Map<String, dynamic> map = json.decode(pnrJson);

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
                await new Future.delayed(const Duration(seconds: 4)); // was 2
                //sleep(const Duration(seconds: 2));
              }
            }
          }

          if (flightsConfirmed) {
            _dataLoaded();
            gotoChoosePaymentPage();
          } else {
            setState(() {
              endProgressMessage();
              _displayProcessingIndicator = false;
            });
            _error = translate('Unable to confirm partner airlines flights.');
            //showSnackBar();
            logit('Unable to confirm partner airlines flights.');
            Navigator.pop(context, _error);
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
  }

  void gotoChoosePaymentPage() {
    logit('cdp gotopayopts');
    try {
      gblPaymentMsg = '';
      Navigator.push(
          context,
          //MaterialPageRoute(
          CustomPageRoute(
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
      endProgressMessage();
      gblActionBtnDisabled = false;
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

                if( gblSettings.wantNewEditPax ){
                // double pop
                var nav = Navigator.of(context);
                nav.pop();
                nav.pop();
              } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  String buildAddContactsCmd() {
    StringBuffer sb = new StringBuffer();
  if( gblSettings.wantNewEditPax ) {
    if( widget.newbooking.passengerDetails[0].phonenumber != null && widget.newbooking.passengerDetails[0].phonenumber.isNotEmpty) {
      sb.write('9M*${widget.newbooking.passengerDetails[0].phonenumber}^');
    }
    if(widget.newbooking.passengerDetails[0].email!= null && widget.newbooking.passengerDetails[0].email.isNotEmpty ) {
      sb.write('9E*${widget.newbooking.passengerDetails[0].email}^');
    }

  } else {
    if( widget.newbooking.contactInfomation.phonenumber != null && widget.newbooking.contactInfomation.phonenumber.isNotEmpty) {
      sb.write('9M*${widget.newbooking.contactInfomation.phonenumber}^');
    }
    if(widget.newbooking.contactInfomation.email!= null && widget.newbooking.contactInfomation.email.isNotEmpty ) {
      sb.write('9E*${widget.newbooking.contactInfomation.email}^');
    }
  }

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
        sb.write('4-${index + 1}FADSU${pax.adsNumber}/${this.widget.newbooking.ads.pin}^');
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
    int paxNo = 1;
    widget.newbooking.passengerDetails.forEach((pax) {
      if (pax.lastName != '') {
        if( pax.middleName != null && pax.middleName.isNotEmpty && pax.middleName.toUpperCase() != 'NONE') {
          //sb.write('-${pax.paxNumber}${pax.lastName}/${pax.firstName}${pax.middleName}${pax.title}');
          sb.write('-${pax.lastName}/${pax.firstName}${pax.middleName}${pax.title}');
        } else {
          //sb.write('-${pax.paxNumber}${pax.lastName}/${pax.firstName}${pax.title}');
          sb.write('-${pax.lastName}/${pax.firstName}${pax.title}');
        }
        if (pax.dateOfBirth != null) {
          // get age in years
          Duration td = DateTime.now().difference(pax.dateOfBirth as DateTime);
          int ageYears = (td.inDays / 365).round();
          int ageMonths = (td.inDays / 30).round();
          if( ageMonths == 24) ageMonths = 23;
          String _dob = DateFormat('ddMMMyy').format(pax.dateOfBirth as DateTime).toString();

          bool wantDOB = false;
          if (pax.paxType == PaxType.child) {
            sb.write('.CH${ageYears}($_dob)');
            wantDOB = true;
          } else if (pax.paxType == PaxType.youth) {
            sb.write('.TH${ageYears}');
            wantDOB = true;
          } else if (pax.paxType == PaxType.senior) {
            sb.write('.CD');
            String _dob =
            DateFormat('ddMMMyy').format(pax.dateOfBirth as DateTime).toString();
            sb.write('($_dob)');
            wantDOB = true;
          } else if (pax.paxType == PaxType.infant) {
            sb.write('.IN${ageMonths}($_dob)');
            wantDOB = true;
          }
            if( gblSettings.wantApis && wantDOB) {
              String _dob =
              DateFormat('ddMMMyy').format(pax.dateOfBirth as DateTime).toString();
              sb.write('^3-${pax.paxNumber}FDOB $_dob');
          }
        } else {
           if (pax.paxType == PaxType.student) {
            sb.write('.SD');
            } else if (pax.paxType == PaxType.senior) {
              sb.write('.CD');
            } else if (pax.paxType == PaxType.youth) {
             sb.write('.TH15');
            }
        }

      }
      sb.write('^');
      if( gblSettings.aircode == 'T6') {
        // phlippines specials
        if( pax.country != null && pax.country.toUpperCase() == 'PHILIPPINES'){
          sb.write('3-${pax.paxNumber}FCNTY${pax.country}^');
          // add disability
          if(  pax.disabilityID != null && pax.disabilityID.isNotEmpty ) {
            sb.write('ZDPWD-${pax.paxNumber}/${pax.disabilityID}^');
          }

          // add senior id
          if( pax.paxType == PaxType.senior && pax.seniorID != null && pax.seniorID.isNotEmpty ){
            sb.write('ZDSEN-${pax.paxNumber}/${pax.seniorID}^');
          }
        }

      }

      if( pax.dateOfBirth != null && (pax.paxType == PaxType.adult || pax.paxType == PaxType.senior)){
        String _dob =
        DateFormat('ddMMMyyyy').format(pax.dateOfBirth as DateTime).toString();
        sb.write('3-${paxNo}FDOB $_dob^');

      }
      if( pax.gender != null && pax.gender.isNotEmpty ){
        sb.write('3-${paxNo}FGNDR${pax.gender}^');
      }
      if( pax.redressNo != null && pax.redressNo.isNotEmpty ){
        sb.write('4-${paxNo}FDOCO//R/${pax.redressNo}///USA^');
      }
      if( pax.knowTravellerNo != null && pax.knowTravellerNo.isNotEmpty ){
        sb.write('4-${paxNo}FDOCO//K/${pax.knowTravellerNo}///USA^');
      }
      paxNo +=1 ;
    });
    return sb.toString();
  }
}

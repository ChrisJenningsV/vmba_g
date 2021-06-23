import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/data/models/pnrs.dart';
import 'package:http/http.dart' as http;
import 'package:vmba/data/models/apis_pnr.dart';
import 'package:vmba/menu/menu.dart';
import 'package:vmba/utilities/widgets/appBarWidget.dart';
import 'package:vmba/data/globals.dart';

class AddBooking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context, "My Bookings"),
      // AppBar(
      //   brightness: AppConfig.of(context).systemColors.statusBar,
      //   backgroundColor: AppConfig.of(context).systemColors.primaryHeaderColor,
      //   iconTheme: IconThemeData(color: AppConfig.of(context).systemColors.primaryHeaderOnColor),
      //   title: Text("Add Booking",style: TextStyle(color: AppConfig.of(context).systemColors.primaryHeaderOnColor) ),
      // ),
      endDrawer: DrawerMenu(),
      body: AddBookingForm(),
    );
  }
}

class AddBookingForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _AddBookingFormState();
}

class _AddBookingFormState extends State<AddBookingForm> {
  final formKey = GlobalKey<FormState>();
  bool _loadingInProgress;
  String _rloc;
  String _surname;
  //String _uid;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadingInProgress = false;
  }

  void _loadPnr() async {
    setState(() {
      _loadingInProgress = true;
    });
    validateAndSubmit();
    // _pnrLoaded();
  }

  void _pnrLoaded() {
    setState(() {
      _loadingInProgress = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey we created above
    if (_loadingInProgress) {
      return new Center(
        child: new CircularProgressIndicator(),
      );
    } else {
      return Form(
          key: formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(10.0),
            child: new Theme(
              data: new ThemeData(
                primaryColor: Colors.blueAccent,
                primaryColorDark: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Padding(
                    padding: EdgeInsets.all(10),
                    child: new Text(
                        'Add an existing booking using your booking reference and passenger last name',
                        style: TextStyle(fontSize: 16.0, color: Colors.black)),
                  ),
                  new TextFormField(
                    textCapitalization: TextCapitalization.characters,
                    //maxLength: 6,
                    decoration: InputDecoration(
                      labelText: "Enter your booking reference",
                      fillColor: Colors.white,
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(25.0),
                        borderSide: new BorderSide(),
                      ),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a booking reference';
                      }
                      if (value.trim().length != 6) {
                        return 'Your booking reference is 6 charactors long';
                      }
                      return null;
                    },
                    onSaved: (value) => _rloc = value.trim(),
                  ),
                  new Padding(padding: EdgeInsets.all(10)),
                  TextFormField(
                    textCapitalization: TextCapitalization.characters,
                    decoration: new InputDecoration(
                      labelText: "Enter your surname",
                      fillColor: Colors.white,
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(25.0),
                        borderSide: new BorderSide(),
                      ),
                    ),
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter a surmane';
                      } else {
                        return null;
                      }
                    },
                    onSaved: (value) => _surname = value.trim(),
                  ),
                  Center(
                      child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Material(
                      color:
                      gblSystemColors.primaryButtonColor,
                      borderRadius: BorderRadius.circular(25.0),
                      shadowColor: Colors.grey.shade100,
                      elevation: 5.0,
                      child: new MaterialButton(
                        minWidth: 180,
                        height: 50.0,
                        child: Text(
                          'ADD BOOKING',
                          style: new TextStyle(
                              fontSize: 16.0,
                              color: gblSystemColors
                                  .primaryButtonTextColor),
                        ),
                        onPressed: () {
                          if (formKey.currentState.validate()) {
                            _loadPnr();
                          }
                        },
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ));
    }
  }

  // Widget btnAddBooking() {
  //   return new StoreConnector<SessionState, String>(
  //       converter: (store) => store.state.uidToken,
  //       builder: (context, viewModel) {
  //         return RaisedButton(
  //           color: Colors.black,
  //           onPressed: () {
  //             if (formKey.currentState.validate()) {
  //               print(viewModel);
  //               _loadPnr();
  //             }
  //           },
  //           child: Text(
  //             'ADD BOOKING',
  //             style: new TextStyle(color: Colors.white),
  //           ),
  //         );
  //       });
  // }

  Future<void> fetchBooking() async {
    //AATMRA
    //AATKK7

    http.Response response = await http
        .get(Uri.parse(
            "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=*$_rloc~x'"))
        .catchError((resp) {});

    if (response == null) {
      //return new ParsedResponse(NO_INTERNET, []);
    }

    //If there was an error return an empty list
    if (response.statusCode < 200 || response.statusCode >= 300) {
      //return new ParsedResponse(response.statusCode, []);
    }

    String pnrJson;
    Map pnrMap;
    // await for (String pnrRaw in resStream) {

    if (response.body.contains('ERROR - RECORD NOT FOUND -')) {
      _error = 'Please check your details';
      _pnrLoaded();
      _showDialog();
    } else {
      pnrJson = response.body
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', '');

      pnrMap = json.decode(pnrJson);
      // }

      try {
        pnrMap = json.decode(pnrJson);
        print('Loaded PNR');
        var objPnr = new PnrModel.fromJson(pnrMap);
        if (validate(objPnr)) {
          PnrDBCopy pnrDBCopy = new PnrDBCopy(
              rloc: objPnr.pNR.rLOC,
              data: pnrJson,
              delete: 0,
              nextFlightSinceEpoch: objPnr.getnextFlightEpoch());
          Repository.get().updatePnr(pnrDBCopy).then((w) {
            fetchApisStatus();
            //Navigator.of(context).pop();
          });

          print('matched rloc and name');
          //   Navigator.of(context).pop();
        } else {
          _pnrLoaded();
          _showDialog();
          print('didn\'t matched rloc and name');
        }
      } catch (e) {
        _showDialog();
        print('$e');
      }
    }
  }

  Future<void> fetchApisStatus() async {
    //AATMRA
    //AATKK7

    http.Response response = await http
        .get(Uri.parse(
            "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=DSP/$_rloc'"))
        .catchError((resp) {});

    if (response == null) {
      //return new ParsedResponse(NO_INTERNET, []);
    }

    //If there was an error return an empty list
    if (response.statusCode < 200 || response.statusCode >= 300) {
      //return new ParsedResponse(response.statusCode, []);
    }

    String apisStatusJson;
    //Map map;
    // await for (String pnrRaw in resStream) {
    apisStatusJson = response.body
        .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
        .replaceAll('<string xmlns="http://videcom.com/">', '')
        .replaceAll('</string>', '')
        .trim();
    try {
      Map map = json.decode(apisStatusJson);
      print('Loaded APIS status');
      ApisPnrStatusModel apisPnrStatus = new ApisPnrStatusModel.fromJson(map);
      DatabaseRecord databaseRecord = new DatabaseRecord(
          rloc: apisPnrStatus.xml.pnrApis.pnr, //_rloc,
          data: apisStatusJson,
          delete: 0);
      Repository.get().updatePnrApisStatus(databaseRecord).then(
          (v) => //Navigator.of(context).pop()
              Navigator.of(context).pushNamedAndRemoveUntil(
                  '/MyBookingsPage', (Route<dynamic> route) => false));
    } catch (e) {
      _showDialog();
      print('$e');
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

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        fetchBooking();
        //fetchApisStatus();
        print('Getting PNR');
      } catch (e) {
        print('Error: $e');
      }
    }
  }

  bool validate(PnrModel pnr) {
    if (!validateRlocWithName(pnr.pNR.names.pAX)) {
      return false;
    }

    _error = pnr.validate();
    if (_error.isNotEmpty) {
      return false;
    }
    if( pnr.hasFutureFlightsAddDayOffset(1)) {
      return true;
    }

    _error = 'No furture flights';
    return false;
  }

  bool validateRlocWithName(List<PAX> passengers) {
    for (PAX pAX in passengers) {
      if (pAX.surname == _surname.toUpperCase()) {
        return true;
      }
    }
    return false;
  }

  // bool validateTickets(PNR pnr) {
  //   bool validateTickets = true;
  //   try {
  //     pnr.names.pAX.forEach((pax) {
  //       var tkt = pnr.tickets.tKT.where((tkt) =>
  //           tkt.pax == pax.paxNo &&
  //           (tkt.tKTID == 'ETKT' || tkt.tKTID == 'ELFT') &&
  //           (tkt.status == 'O' || tkt.status == 'C' || tkt.status == 'F') &&
  //           tkt.firstname == pax.firstName &&
  //           tkt.surname == pax.surname &&
  //           tkt.tktFor != 'MPD');

  //       List<TKT> tickets = new List<TKT>();
  //       if (tkt.length > 0) {
  //         pnr.itinerary.itin.forEach((flt) {
  //           if (flt.status == 'HK' || flt.status == 'RR') {
  //             var otkt = tkt.firstWhere(
  //                 (t) =>
  //                     t.tktArrive == flt.arrive &&
  //                     t.tktDepart == flt.depart &&
  //                     t.tktFltDate ==
  //                         DateFormat('ddMMMyyyy')
  //                             .format(DateTime.parse(
  //                                 flt.depDate + ' ' + flt.depTime))
  //                             .toUpperCase() &&
  //                     t.tktFltNo == (flt.airID + flt.fltNo) &&
  //                     t.tktBClass == flt.xclass,
  //                 orElse: () => null);
  //             if (otkt != null) {
  //               tickets.add(otkt);
  //             }
  //           }
  //         });
  //       }
  //       if ((tickets.length !=
  //               pnr.itinerary.itin
  //                   .where((flt) => flt.status == 'HK' || flt.status == 'RR')
  //                   .length) &&
  //           (pnr.payments.fOP.where((p) => p.fOPID == 'III').length > 0)) {
  //         validateTickets = false;
  //         _error =
  //             "Please contact the airline to view this booking on the mobile app";
  //         return validateTickets;
  //       }

  //       if ((tickets.length !=
  //           pnr.itinerary.itin
  //               .where((flt) => flt.status == 'HK' || flt.status == 'RR')
  //               .length)) {
  //         validateTickets = false;
  //         _error =
  //             "Please contact the airline to view this booking on the mobile app";
  //         return validateTickets;
  //       }
  //     });
  //   } catch (ex) {
  //     print(ex.toString());
  //     validateTickets = false;
  //     _error =
  //         "Please contact the airline to view this booking on the mobile app";
  //   }

  //   return validateTickets;
  // }

  // bool hasTickets(Tickets tickets) {
  //   bool hasTickets = false;
  //   if (tickets != null && tickets.tKT != null && tickets.tKT.length > 0) {
  //     hasTickets = true;
  //   } else {
  //     hasTickets = false;
  //     _error =
  //         "Please contact the airline to view this booking on the mobile app";
  //   }

  //   return hasTickets;
  // }

  // bool hasItinerary(Itinerary itinerary) {
  //   bool hasItinerary = false;
  //   if (itinerary != null &&
  //       itinerary.itin != null &&
  //       itinerary.itin.length > 0) {
  //     hasItinerary = true;
  //   } else {
  //     hasItinerary = false;
  //     _error =
  //         "Please contact the airline to view this booking on the mobile app";
  //   }
  //   return hasItinerary;
  // }

  // bool validateItineraryStatus(Itinerary itinerary) {
  //   bool validateItineraryStatus = false;
  //   if (itinerary.itin
  //           .where((itin) =>
  //               itin.status.startsWith('PN') ||
  //               itin.status.startsWith('MM') ||
  //               itin.status.startsWith('SA'))
  //           .length ==
  //       0) {
  //     validateItineraryStatus = true;
  //   } else {
  //     validateItineraryStatus = false;
  //     _error =
  //         "Please contact the airline to view this booking on the mobile app";
  //   }
  //   return validateItineraryStatus;
  // }

  // bool validatePayment(Basket basket) {
  //   bool validatePayment = false;
  //   if (basket.outstanding.amount == '0') {
  //     validatePayment = true;
  //   } else {
  //     validatePayment = false;
  //     _error =
  //         "Please contact the airline to view this booking on the mobile app";
  //   }
  //   return validatePayment;
  // }

  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Cannot Add Booking"),
          content: _error != null && _error != ''
              ? new Text(_error)
              : new Text("Booking not found"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new TextButton(
              child: new Text("Close"),
              onPressed: () {
                _error = '';
                _pnrLoaded();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

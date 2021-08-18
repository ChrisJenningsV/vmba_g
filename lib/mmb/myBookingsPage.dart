import 'package:flutter/material.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/pnrs.dart';
import 'package:vmba/mmb/viewBookingPage.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/models/apis_pnr.dart';
import 'dart:convert';
import 'package:vmba/menu/menu.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/utilities/widgets/appBarWidget.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/calendar/flightPageUtils.dart';
import 'package:vmba/data/globals.dart';
import 'package:http/http.dart' as http;
import 'package:vmba/components/showDialog.dart';


class MyBookingsPage extends StatefulWidget {
  MyBookingsPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> with TickerProviderStateMixin  {
  List<PnrDBCopy> activePnrs = [];
  List<PnrDBCopy> recentPnrs = [];
  // new List<PnrDBCopy>();
  bool _loadingInProgress;
  Offset _tapPosition;
String _error = '';
  TabController _controller;
  final formKey = GlobalKey<FormState>();
  String _rloc;
  String fqtvEmail = '';
  String fqtvNo = '';
  String fqtvPass='';
  String _surname;
  bool _isButtonDisabled ;
  bool _isHidden;
  TextEditingController _fqtvTextEditingController =   TextEditingController();
  TextEditingController _passwordEditingController =   TextEditingController();
  TextEditingController _emailEditingController =   TextEditingController();


  @override
  void initState() {
    super.initState();
    _loadingInProgress = true;
    _isButtonDisabled = false;
    _isHidden = true;

    var tablen = 3;
    if( gblSettings.wantFQTV && gblSettings.wantFindBookings) {
      tablen +=1;
    }
    _controller = TabController(length: tablen, vsync: this);

    getmyookings();
    Repository.get().getAllCities().then((cities) {});
  }

  void getmyookings() {
    Repository.get().getAllPNRs().then((pnrsDBCopy) {
      List<PnrDBCopy> thispnrs = [];
      List<PnrDBCopy> thisOldpnrs = [];
      // new List<PnrDBCopy>();
      for (var item in pnrsDBCopy) {
        Map<String, dynamic> map = jsonDecode(item.data);
        PnrModel _pnr = new PnrModel.fromJson(map);
        PnrDBCopy _pnrs = new PnrDBCopy(
            rloc: item.rloc,
            data: item.data,
            nextFlightSinceEpoch: _pnr.getnextFlightEpoch(),
            delete: item.delete);
        //if (_pnrs.nextFlightSinceEpoch != 0) {
        _error = _pnr.validate();
        if (_error.isEmpty && _pnr.hasFutureFlightsAddDayOffset(1)) {
          thispnrs.add(_pnrs);
        } else if (_error.isEmpty && _pnr.hasFutureFlightsMinusDayOffset(7)) {
          thisOldpnrs.add(_pnrs);
        } else {
          // remove old booking
          try {
            Repository.get().deletePnr(item.rloc);
            Repository.get().deleteApisPnr(item.rloc);
          } catch(e) {
            print(e);
          }
        }

        //}
      }

      thispnrs.sort(
          (a, b) => a.nextFlightSinceEpoch.compareTo(b.nextFlightSinceEpoch));
      setState(() {
        activePnrs = thispnrs;
        recentPnrs = thisOldpnrs;
        _loadingInProgress = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    if (_loadingInProgress) {
      return Scaffold(
          body: new Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            new CircularProgressIndicator(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: new TrText('Loading your bookings...'),
            ),
          ],
        ),
      ));
    } else {
      List <Widget> tabs = [];
      List <Widget> tabeViews = [];
      tabs.add(TrText('Active'));
      tabs.add(TrText('Recent'));
      tabs.add(TrText('Add Booking'));

      tabeViews.add(new Container(child: myTrips(true)));
      tabeViews.add(new Container(child: myTrips(false)));
      tabeViews.add(new Container(child: addBooking()));

      if( gblSettings.wantFQTV && gblSettings.wantFindBookings) {
        tabs.add(TrText('Find All Bookings'));
        tabeViews.add(new Container(child: findAllBookings()));
      }

      return Scaffold(
          appBar: appBar(context, "My Bookings",
          bottom:  new PreferredSize(
          preferredSize: new Size.fromHeight(30.0),
    child: new Container(
    height: 30.0, child:        TabBar(

          indicatorColor: Colors.amberAccent,
          isScrollable: true,
          labelColor: Colors.black,
          tabs: tabs,
          controller: _controller),
          ),
          ),
          ),// translated in appBar
          endDrawer: DrawerMenu(),
          body: TabBarView(
              controller: _controller,
              children: tabeViews,
      ),

    );
    }
  }

  Widget findAllBookings() {
    return AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        titlePadding: EdgeInsets.only(top: 0),
        contentPadding: EdgeInsets.only(left: 15, right: 15, top: 5, bottom: 0),
        title: Column(children: [
          ListTile(
            leading: Icon(
              Icons.person_pin,
              color: Colors.blue,
              size: 40,
            ),
            title: Text(
                translate('${gblSettings.fqtvName} ') + translate('LOGIN')),
          ),
          Divider(
            color: Colors.grey,
            height: 4.0,
          ),
        ]),
        content: Stack(
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TrText( ' Login to load all your future bookings '),
                new TextFormField(
                  decoration: getDecoration(
                      '${gblSettings.fqtvName} ' + translate('number')),
                  controller: _fqtvTextEditingController,
                  keyboardType: TextInputType.phone,
                  onSaved: (value) {
                    if (value != null) {
                      //.contactInfomation.phonenumber = value.trim()
                    }
                  },
                ),
                SizedBox(
                  height: 15,
                ),
                new TextFormField(
                  obscureText: _isHidden,
                  obscuringCharacter: "*",
                  controller: _passwordEditingController,
                  decoration: getDecoration(translate('Password')),
/*                  suffix: InkWell(
                    onTap: _togglePasswordView,
                    child: Icon( Icons.visibility),
                  ),
                ),*/
                  keyboardType: TextInputType.visiblePassword,
                  onSaved: (value) {
                    if (value != null) {
                      //.contactInfomation.phonenumber = value.trim()
                    }
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.grey.shade100),
                      child: TrText(
                        "CANCEL",
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        //Put your code here which you want to execute on Cancel button click.
                        Navigator.of(context).pop();
                      },
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.blue),
                      child: Row(children: <Widget>[
                        (_isButtonDisabled)
                            ? new Transform.scale(
                                scale: 0.5,
                                child: CircularProgressIndicator(),
                              )
                            : Icon(
                                Icons.check,
                                color: Colors.white,
                              ),
                        _isButtonDisabled
                            ? new TrText("Logging in...",
                                style: TextStyle(color: Colors.white))
                            : TrText('CONTINUE',
                                style: TextStyle(color: Colors.white))
                      ]),
                      onPressed: () {
                        if (_isButtonDisabled == false) {
                          if (_fqtvTextEditingController.text.isNotEmpty &&
                              _passwordEditingController.text.isNotEmpty) {
                            _isButtonDisabled = true;
                            _loadingInProgress = true;
                             _fqtvLogin();

                            setState(() {});
                          } else {
                            _error = "Please complete both fields";
                            _loadingInProgress = false;
                            _isButtonDisabled = false;
                            // _actionCompleted();
                            showAlertDialog(context, 'Error', _error);
                          }
                        }
                        //});

                        //Navigator.of(context).pop();
                      },
                    ),
                  ],
                )
              ],
            )
          ],
        ));
  }
      //actions: <Widget>[)    ]


  void _fqtvLogin() async {
    if ( gblSession == null || gblSession.isTimedOut()) {
      await login().then((result) {
        gblSession =
            Session(result.sessionId, result.varsSessionId, result.vrsServerNo);
        print('new session');
      });
    }
    FqtvMemberloginDetail fqtvMsg = FqtvMemberloginDetail(_emailEditingController.text,
        _fqtvTextEditingController.text,
        _passwordEditingController.text);
    String msg = json.encode(FqTvCommand(gblSession, fqtvMsg ).toJson());
    String method = 'GetAirMilesBalance';

    print(msg);
    _sendVRSCommand(msg, method).then((result) {
      if( result == null || result == ''){
        _error = translate('Bad server response logging on');
        _isButtonDisabled = false;
        _loadingInProgress = false;
        _actionCompleted();
        showAlertDialog(context, 'Error', _error);
        return;
      }
      Map map = json.decode(result);
      ApiFqtvMemberAirMilesResp resp = new ApiFqtvMemberAirMilesResp.fromJson(
          map);
      _loadingInProgress = false;
      if (resp.statusCode != 'OK') {
        _error = resp.message;
        _isButtonDisabled = false;
        _actionCompleted();
        showAlertDialog(context, 'Error', _error);
      } else {
        _error ='';
        //widget.passengerDetail.fqtv = _fqtvTextEditingController.text;
        fqtvNo = _fqtvTextEditingController.text;
        gblFqtvNumber = fqtvNo;
        fqtvEmail = _emailEditingController.text;
        fqtvPass = _passwordEditingController.text;
        gblFqtvBalance = resp.balance;

        method = 'GetDetailsByUsername';
        msg = json.encode(
            ApiFqtvGetDetailsRequest(fqtvEmail, fqtvNo, fqtvPass).toJson());

        _sendVRSCommand(msg, method).then((result) {
          Map map = json.decode(result);

          try {
            ApiFqtvMemberDetailsResponse resp = new ApiFqtvMemberDetailsResponse
                .fromJson(map);
            if (resp.statusCode != 'OK') {
              _error = resp.message;
              _actionCompleted();
              _isButtonDisabled = false;
              showAlertDialog(context, 'Error', _error);
            } else {
              _loadingInProgress = true;
              // now load transactions
              _loadTransactions();

              gblPassengerDetail.fqtv = fqtvNo;
              gblPassengerDetail.fqtvPassword = fqtvPass;

              setState(() {});
            }
          } catch(e) {
            _loadingInProgress = false;
            print(e);
          }
        });
      }});
  }

  void _loadTransactions() async {
    ApiFqtvPendingRequest fqtvMsg = ApiFqtvPendingRequest(
        fqtvNo,
        fqtvPass);
    String msg = json.encode(fqtvMsg.toJson());
    String method = 'GetPendingTransactions';

    print(msg);
    _sendVRSCommand(msg, method).then((result){
      Map map = json.decode(result);
      ApiFqtvMemberTransactionsResp resp = new ApiFqtvMemberTransactionsResp.fromJson(map);
      if( resp.statusCode != 'OK') {
        _error = resp.message;
        _actionCompleted();
        showAlertDialog(context, 'Error', _error);

      } else {
        var transactions = resp.transactions;
        _loadingInProgress = true;
        setState(() {
        });
        _bulkLoadPnrs(transactions);
        //showAlertDialog(context, 'Information', 'Found ${transactions.length} PNRs');
      }
    });
  }



  Future _sendVRSCommand(msg, method) async {
    final http.Response response = await http.post(
        Uri.parse(gblSettings.apiUrl + "/FqTvMember/$method"),
        headers: {'Content-Type': 'application/json',
          'Videcom_ApiKey': gblSettings.apiKey
        },
        body: msg);

    if (response.statusCode == 200) {
      print('message send successfully: $msg' );
      return response.body.trim();
    } else {
      print('failed: $msg');
      _error = translate('message failed');
      try{
        print (response.body);
        _error = response.body;
      } catch(e){}

      _actionCompleted();
      showAlertDialog(context, 'Error' , _error);
    }
  }
  void _actionCompleted() {
    setState(() {
//      _loadingInProgress = false;
    });
  }

  Widget addBooking() {
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
                  child: new TrText(
                      'Add an existing booking using your booking reference and passenger last name',
                      style: TextStyle(fontSize: 16.0, color: Colors.black)),
                ),
                new TextFormField(
                  textCapitalization: TextCapitalization.characters,
                  //maxLength: 6,
                  decoration: getDecoration(translate("Enter your booking reference")),
                  validator: (value) {
                    if (value.isEmpty) {
                      return translate('Please enter a booking reference');
                    }
                    if (value.trim().length != 6) {
                      return translate(
                          'Your booking reference is 6 charactors long');
                    }
                    return null;
                  },
                  onSaved: (value) => _rloc = value.trim(),
                ),
                new Padding(padding: EdgeInsets.all(10)),
                TextFormField(
                  textCapitalization: TextCapitalization.characters,
                  decoration: getDecoration(translate("Enter your surname")),
                  validator: (value) {
                    if (value.isEmpty) {
                      return translate('Please enter a surmane');
                    } else {
                      return null;
                    }
                  },
                  onSaved: (value) => _surname = value.trim().toUpperCase(),
                ),
                Center(
                    child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Material(
                    color: gblSystemColors.primaryButtonColor,
                    borderRadius: BorderRadius.circular(25.0),
                    shadowColor: Colors.grey.shade100,
                    elevation: 5.0,
                    child: new MaterialButton(
                      minWidth: 180,
                      height: 50.0,
                      child: TrText(
                        'ADD BOOKING',
                        style: new TextStyle(
                            fontSize: 16.0,
                            color: gblSystemColors.primaryButtonTextColor),
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

  Widget myTrips(bool showActive) {
    List<PnrDBCopy> pnrs = activePnrs;

    Center noFutureBookingsFound =  Center(
        child: TrText('No future bookings found',
            style: TextStyle(fontSize: 26.0), textAlign: TextAlign.center));
    if( showActive == false  ) {
      pnrs = recentPnrs;
      noFutureBookingsFound =  Center(
        child: TrText('No recent bookings found',
            style: TextStyle(fontSize: 26.0), textAlign: TextAlign.center));
    }
    if (pnrs.length == 0) return noFutureBookingsFound;

    ListView listViewOfBookings = ListView.builder(
        itemCount: pnrs.length,
        itemBuilder: (BuildContext context, index) =>
            _buildListItem(context, pnrs[index]));

    return listViewOfBookings.semanticChildCount > 0
        ? new Container(child: listViewOfBookings)
        : noFutureBookingsFound;
  }

  Widget _buildListItem(BuildContext context, PnrDBCopy document) {
    // bool hasFutureFlights(Itin flt) {
    //   DateTime now = DateTime.now();
    //   var fltDate;
    //   fltDate = DateTime.parse(flt.depDate + ' ' + flt.depTime)
    //       .add(Duration(days: 1));
    //   if (now.isAfter(fltDate)) {
    //     return false;
    //   } else {
    //     return true;
    //   }
    // }

    Map<String, dynamic> map = jsonDecode(document.data);
    PnrModel pnr = new PnrModel.fromJson(map);
    //if (hasFutureFlights(pnr.pNR.itinerary.itin.last)) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.0),
      child: TextButton(
        style: TextButton.styleFrom(
            padding:
                EdgeInsets.only(left: 3.0, right: 3.0, bottom: 3.0, top: 3.0)),
        child: new Column(children: [
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              new Text(document.rloc, //document['rloc'],
                  style: new TextStyle(
                      fontSize: 20.0, fontWeight: FontWeight.w700)),
              GestureDetector(
                child: Icon(Icons.more_vert),
                onTapDown: _storePosition,
                onTapUp: (tabUpDetails) => _showPopupMenu(document.rloc),
              ),
            ],
          ),
          new Divider(),
          fltLines(pnr),
        ]),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewBookingPage(
                      rloc: document.rloc,
                    )),
          );
        },
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0x90000000),
            offset: Offset(0.0, 6.0),
            blurRadius: 10.0,
          ),
        ],
      ),
      padding: EdgeInsets.all(10.0),
    );
//     }
//     else {
//       return null;
// return new Padding(
//         padding: EdgeInsets.all(0),
//       );
//    }
  }

  void _storePosition(TapDownDetails details) {
    _tapPosition = details.globalPosition;
  }

  _showPopupMenu(String rloc) async {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    await showMenu(
      context: context,
      position: RelativeRect.fromRect(
          _tapPosition & Size(40, 40), // smaller rect, the touch area
          Offset.zero & overlay.size),
      items: [
        // PopupMenuItem(
        //   child: FlatButton.icon(
        //     icon: Icon(Icons.date_range), //`Icon` to display
        //     label: Text('Add to Calender'), //`Text` to display
        //     onPressed: () {
        //       Navigator.of(context).pop();
        //       //Code to execute when Floating Action Button is clicked
        //       //...
        //     },
        //   ),
        // ),
        // PopupMenuItem(
        //   child: FlatButton.icon(
        //     icon: Icon(Icons.share), //`Icon` to display
        //     label: Text('Share booking details'), //`Text` to display
        //     onPressed: () {
        //       Navigator.of(context).pop();
        //       //Code to execute when Floating Action Button is clicked
        //       //...
        //     },
        //   ),
        // ),
        PopupMenuItem(
          child: TextButton.icon(
            icon: Icon(Icons.delete_outline),
            label: TrText('Remove booking'),
            onPressed: () {
              Repository.get()
                  .deletePnr(rloc)
                  .then((onValue) => Navigator.of(context).pop())
                  .then((onValue) => getmyookings());
            },
          ),
        ),
      ],
      elevation: 8.0,
    );
  }

  Widget fltLines(PnrModel pnr) {
    List<Widget> fltWidgets = [];
    // List<Widget>();
    //List<List<Itin>> journeys  = List<List<Itin>>();
    List<Itin> flt = [];
    // List<Itin>();
    List<List> journeys = [];
    // List<List>();
    //journeys

    bool isFltPassedDate(List<Itin> journey) {
      DateTime now = DateTime.now();
      var fltDate;
      bool result = false;
      journey.forEach((f) {
        fltDate = DateTime.parse(f.depDate + ' ' + f.depTime);
        //f.ddaygmt)
        if (now.isAfter(fltDate)) {
          result = true;
        }
      });

      return result;
    }

    pnr.pNR.itinerary.itin.forEach((f) {
      flt.add(f);
      if (f.nostop != 'X') {
        journeys.add(flt);
        flt = [];
        // List<Itin>();
      }
    });

    if (fltWidgets.length > 1) {
      new Divider();
    }

    journeys.forEach((journey) {
      //can this be moved outside

      fltWidgets.add(
        new Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder(
                future: cityCodeToName(journey.last.arrive),
                initialData: journey.last.arrive.toString(),
                builder: (BuildContext context, AsyncSnapshot<String> text) {
                  return new Text(text.data,
                      style: new TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.w700));
                },
              ),
              FutureBuilder(
                future: cityCodeToName(journey.first.depart),
                initialData: journey.first.depart.toString(),
                builder: (BuildContext context, AsyncSnapshot<String> text) {
                  return new Text(translate('from ') + text.data,
                      style: new TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.w300));
                },
              ),
              new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: (formatFltTimeWidget(journey.first)),
                  ),
                  new Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      new RotatedBox(
                          quarterTurns: 1,
                          child: Icon(
                            Icons.airplanemode_active,
                          )),
                      new Padding(
                        padding: EdgeInsets.only(left: 5.0),
                      ),
                      // new Text(
                      //   journey.first.airID +
                      //       journey.first.fltNo,
                      new Text(
                        isFltPassedDate(journey)
                            ? translate('departed')
                            : journey.length > 1
                                ? '${journey.length - 1} ' + translate('connection')
                                : translate('Direct Flight'),
                        style: new TextStyle(
                            fontSize: 14.0, fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                ],
              )
            ]),
      );
    });

    return new Column(children: fltWidgets.toList());
  }

  List<Widget> formatFltTimeWidget(Itin journey) {
    List<Widget> list = [];
    // List<Widget>();
    if (journey.fltNo != '0000') {
      list.add(Icon(Icons.date_range));
      list.add(Padding(
        padding: EdgeInsets.only(left: 5.0),
      ));
      list.add(Text(
          //(DateFormat('EEE dd MMM h:mm a').format(DateTime.parse(journey.depDate + ' ' + journey.depTime)).toString()).replaceFirst('12:00 AM', '00:00 AM'),
          getIntlDate('EEE dd MMM h:mm a', DateTime.parse(journey.depDate + ' ' + journey.depTime)).replaceFirst('12:00 AM', '00:00 AM'),
          style: new TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300)));
    } else {
      if (journey.status == 'QQ') {
        list.add(TrText('Flight Not Operating',
            style: new TextStyle(fontSize: 16.0,
                color: Colors.red,
                fontWeight: FontWeight.bold)));
      } else {
        list.add(TrText('Flight Problem',
            style: new TextStyle(fontSize: 14.0,
                color: Colors.red,
                fontWeight: FontWeight.bold)));
      }
    }
    return list;
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

  void _bulkLoadPnrs(List<ApiFQTVMemberTransaction> transactions) async {
    setState(() {
      _loadingInProgress = true;
    });
    transactions.forEach((tran) {
      loadBooking(tran.pnr).then((pnrJson) {
        Map pnrMap = json.decode(pnrJson);
        print('Loaded PNR: ${tran.pnr}' );
        var objPnr = new PnrModel.fromJson(pnrMap);
        _rloc = tran.pnr;

        // save
        PnrDBCopy pnrDBCopy = new PnrDBCopy(
            rloc: objPnr.pNR.rLOC,
            data: pnrJson,
            delete: 0,
            nextFlightSinceEpoch: objPnr.getnextFlightEpoch());
        Repository.get().updatePnr(pnrDBCopy).then((w) {
          fetchApisStatus(false);
          //Navigator.of(context).pop();
        });
      });
    });
    Navigator.of(context).pushNamedAndRemoveUntil(
        '/MyBookingsPage', (Route<dynamic> route) => false);

  }

  Future<String> loadBooking(String rloc) async {
    http.Response response = await http
        .get(Uri.parse(
        "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=*$rloc~x'"))
        .catchError((resp) {});

    if (response == null) {
      //return new ParsedResponse(NO_INTERNET, []);
    }

    //If there was an error return an empty list
    if (response.statusCode < 200 || response.statusCode >= 300) {
      //return new ParsedResponse(response.statusCode, []);
    }

    String pnrJson;
    //Map pnrMap;
    // await for (String pnrRaw in resStream) {

    if (response.body.contains('ERROR - RECORD NOT FOUND -')) {
      _error = 'Please check your details';
      //_pnrLoaded();
      showAlertDialog(context, 'Alert', _error);

    } else {
      pnrJson = response.body
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', '');

      //pnrMap = json.decode(pnrJson);
      // }

      try {
        //pnrMap = json.decode(pnrJson);
        print('Loaded PNR');
        //var objPnr = new PnrModel.fromJson(pnrMap);
        return pnrJson;
      } catch (e) {
        print(e);
      }
    }
    return null;
  }


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
      //_showDialog();
      showAlertDialog(context, 'Alert', _error);

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
            fetchApisStatus(true);
            //Navigator.of(context).pop();
          });

          print('matched rloc and name');
          //   Navigator.of(context).pop();
        } else {
          _pnrLoaded();
          //_showDialog();
          showAlertDialog(context, 'Alert', _error);

          print('didn\'t matched rloc and name');
        }
      } catch (e) {

        showAlertDialog(context, 'Alert', _error);
        //_showDialog();
        print('$e');
      }
    }
  }

  Future<void> fetchApisStatus(bool redirect) async {
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
              (v) { //Navigator.of(context).pop()
              if( redirect) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/MyBookingsPage', (Route<dynamic> route) => false);
                }
              });
    } catch (e) {
      showAlertDialog(context, 'Alert', e);
      //_showDialog();
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
    if( pnr.hasFutureFlightsAddDayOffset(1) || pnr.hasFutureFlightsMinusDayOffset(7)) {
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

}

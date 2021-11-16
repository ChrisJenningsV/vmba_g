import 'package:flutter/material.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/pax.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/models/seatplan.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/menu/menu.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:vmba/mmb/widgets/seatPlanPassengers.dart';
import 'package:vmba/payment/choosePaymentMethod.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/utilities/widgets/snackbarWidget.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';

enum SeatType { regular, emergency }

const double cellSize = 28.0;
const double cellFontSize = 13.0;
const double cellPadding = 5.0;
const double aisleCellSize = 20.0;

class SeatPlanWidget extends StatefulWidget {
  SeatPlanWidget(
      {Key key,
      this.paxlist,
      this.seatplan,
      this.rloc,
      this.journeyNo,
      this.selectedpaxNo})
      : super(key: key);

  final List<Pax> paxlist;
  final String seatplan;
  final String rloc;
  final String journeyNo;
  final int selectedpaxNo;
  _SeatPlanWidgetState createState() => _SeatPlanWidgetState();
}

class _SeatPlanWidgetState extends State<SeatPlanWidget> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  bool _loadingInProgress;
  String _displayProcessingText;
  Seatplan objSeatplan;
  List<Pax> paxlist;
  bool showkey;
  String seatplan;
  bool _noInternet;
  bool _noSeats;
  Session session;

  @override
  void initState() {
    super.initState();
    _noInternet = false;
    _noSeats = false;
    _loadingInProgress = true;
    _displayProcessingText = 'Loading seat plan...';
    seatplan = widget.seatplan;
    _loadData(widget.seatplan);
    paxlist = widget.paxlist;
    session = Session('', '', '');

    paxlist.forEach((p) => p.selected = false);
    if (widget.selectedpaxNo == null) {
      paxlist.firstWhere((p) => p.id == 1).selected = true;
    } else {
      paxlist.firstWhere((p) => p.id == widget.selectedpaxNo).selected = true;
    }

    showkey = true;
  }

  void _dataLoaded() {
    setState(() {
      _loadingInProgress = false;
    });
  }

  void _dataLoadedFailed(errorMsg) {
    _showError(errorMsg);
    setState(() {
      _loadingInProgress = false;
    });
    showSnackBar(errorMsg);
  }

  showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(snackbar(message));
    //final _snackbar = snackbar(message);
    //_key.currentState.showSnackBar(_snackbar);
  }

  // Future<Session> login() async {
  //   var body = {"AgentGuid": "${gbl_settings.vrsGuid}"};

  //   final http.Response response = await http.post(
  //       gbl_settings.apiUrl + "/login",
  //       headers: {'Content-Type': 'application/json'},
  //       body: JsonEncoder().convert(body));

  //   if (response.statusCode == 200) {
  //     Map map = json.decode(response.body);
  //     LoginResponse loginResponse = new LoginResponse.fromJson(map);
  //     if (loginResponse.isSuccessful) {
  //       print('successful login');
  //       return loginResponse.getSession();
  //     }
  //   } else {
  //     print('failed');
  //     //return  LoginResponse();
  //   }
  // }

  Future _sendVRSCommand(msg) async {
    final http.Response response = await http.post(
        Uri.parse(gblSettings.apiUrl + "/RunVRSCommand"),
        headers: {'Content-Type': 'application/json',
          'Videcom_ApiKey': gblSettings.apiKey
        },
        body: msg);

    if (response.statusCode == 200) {
      print('message send successfully: $msg' );
      return response.body.trim();
    } else {
      print('failed: $msg');
    }
  }

  Future _sendVRSCommandList(msg) async {
    final http.Response response = await http.post(
        Uri.parse(gblSettings.apiUrl + "/RunVRSCommandList"),
        headers: {'Content-Type': 'application/json',
          'Videcom_ApiKey': gblSettings.apiKey
        },
        body: msg);

    if (response.statusCode == 200) {
      print('message send successfully: $msg');
      return response.body.trim();
    } else {
      print('failed: $msg');
    }
  }

  Future _loadData(String seatPlanCmd) async {
    Repository.get().getSeatPlan(seatPlanCmd).then((rs) {
      if (rs.isOk()) {
        objSeatplan = rs.body;
        if (!objSeatplan.hasSeatsAvailable() && objSeatplan.hasBlockedSeats()) {
          setState(() {
            _loadingInProgress = false;
            _noSeats = true;
          });
        } else {
          _dataLoaded();
        }
      } else {
        setState(() {
          _loadingInProgress = false;
          _noInternet = true;
        });
      }
    });
  }

  void _handleScrollChanged(bool hide) {
    setState(() {
      showkey = hide;
    });
  }

  void _handleSeatChanged(List<Pax> paxValue) {
    print('_handleSeatChanged');
    setState(() {
      paxlist = paxValue;
    });
  }

  void _handleBookSeats(List<Pax> paxValue) {
    _bookSeats();
    setState(() {
      paxlist = paxValue;
      _loadingInProgress = true;
      _displayProcessingText = 'Booking your seat selection...';
    });
  }

  _bookSeats() async {
    StringBuffer cmd = new StringBuffer();
    cmd.write('*${widget.rloc}^');
    gblBookingState = BookingState.bookSeat;
    if (!gblSettings.webCheckinNoSeatCharge) {
      paxlist.forEach((f) {
        if ((f.seat != null && f.seat != '') && f.seat != f.savedSeat) {
          if(f.savedSeat != null && f.savedSeat != '') {
            gblBookingState = BookingState.changeSeat;
          }

            cmd.write(f.savedSeat == null || f.savedSeat == ''
                ? '4-${f.id}S${int.parse(widget.journeyNo) + 1}FRQST${f.seat}^'
                : '4-${f.id}S${int.parse(widget.journeyNo) + 1}FRQST${f
                .seat}[replace=${f.savedSeat}]^');
          }
      });
      cmd.write('FSM^');
    } else {
      paxlist.forEach((f) {
        if ((f.seat != null && f.seat != '') && f.seat != f.savedSeat)
          if(f.savedSeat != null && f.savedSeat != '') {
            gblBookingState = BookingState.changeSeat;
          }

          cmd.write(f.savedSeat == null || f.savedSeat == ''
              ? '4-${f.id}S${int.parse(widget.journeyNo) + 1}FRQST${f.seat}[MmbFreeSeat=${gblSettings.webCheckinNoSeatCharge}]^'
              : '4-${f.id}S${int.parse(widget.journeyNo) + 1}FRQST${f.seat}[replace=${f.savedSeat}][MmbFreeSeat=${gblSettings.webCheckinNoSeatCharge}]^');
      });
    }

    cmd.write('MB');
    //Session session = Session('', '');
    if ( gblSession == null ) {
      await login().then((result) {
        session =
            Session(result.sessionId, result.varsSessionId, result.vrsServerNo);
        gblSession = session;
      });

    } else {
      session = gblSession;
    }
    String msg = json
        .encode(RunVRSCommandList(session, cmd.toString().split('^')).toJson());
    logit(msg);
    _sendVRSCommandList(msg).then((result) {
      logit(result);
      if (result == 'No Amount Outstanding' ) { // zero outstanding
          msg = json.encode(RunVRSCommand(session, "E"));
          _sendVRSCommand(msg).then(
                  (onValue) =>
                  Repository.get().fetchPnr(widget.rloc).then((pnr) {
                    Map map = json.decode(pnr.data);
                    PnrModel pnrModel = new PnrModel.fromJson(map);
                    Navigator.pop(context, pnrModel);
                  }));
        } else if ( result.contains('-')) { // Minus outstanding
          msg = json.encode(RunVRSCommand(session, "EMT*R"));
          _sendVRSCommand(msg).then(
                  (onValue) => Repository.get().fetchPnr(widget.rloc).then((pnr) {
                Map map = json.decode(pnr.data);
                PnrModel pnrModel = new PnrModel.fromJson(map);
                Navigator.pop(context, pnrModel);
              }));
        } else if (result.toString().toLowerCase().startsWith('error')) {
        print(result.toString());

        // _showError('Seating failed');
        _dataLoadedFailed(result);
        //  showSnackBar(result);
      } else {
        msg = json.encode(RunVRSCommand(session, "*R~x"));
        _sendVRSCommand(msg).then((pnrJson) {
          Map map = json.decode(pnrJson);

          PnrModel pnrModel = new PnrModel.fromJson(map);
          _navigate(context, pnrModel, session);
          //  Navigator.push(
          //     context,
          //     MaterialPageRoute(
          //         builder: (context) => ChoosePaymenMethodWidget(
          //             pnrModel: pnrModel, isMmb: true, session: session)));
          _resetloadingProgress();
        });
      }
    });
  }

  _navigate(BuildContext context, PnrModel pnrModel, Session session) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    final result = await Navigator.push(
      context,
      // Create the SelectionScreen in the next step.
      MaterialPageRoute(
          builder: (context) => ChoosePaymenMethodWidget(
              pnrModel: pnrModel, isMmb: true, session: session, mmbAction: 'SEAT',)),
    );
    if (result == true) {
      _cancelSeatSelection();
      setState(() {
        _loadingInProgress = true;
        _displayProcessingText = 'Cancelling your seat selection...';
      });
    }
  }

  _cancelSeatSelection() {
    String msg = json.encode(RunVRSCommand(session, "I"));
    _sendVRSCommand(msg).then((_) {
      _resetloadingProgress();
    });
  }

  _resetloadingProgress() {
    setState(() {
      _loadingInProgress = false;
    });
  }

  _showError(String err) {
    print(err);
    setState(() {
      _loadingInProgress = false;
    });
  }

  retryLoad() {
    setState(() {
      _loadingInProgress = true;
      _noInternet = false;
      _loadData(widget.seatplan);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _key,
        appBar: new AppBar(
          //brightness: gblSystemColors.statusBar,
          backgroundColor:
          gblSystemColors.primaryHeaderColor,
          iconTheme: IconThemeData(
              color: gblSystemColors.headerTextColor),
          title: new Text('Choose a seat',
              style: TextStyle(
                  color:
                  gblSystemColors.headerTextColor)),
        ),
        endDrawer: DrawerMenu(),
        body: body(),
        floatingActionButton: _loadingInProgress || _noInternet || _noSeats
            ? null
            : Padding(
                padding: EdgeInsets.only(left: 35.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new FloatingActionButton.extended(
                        elevation: 0.0,
                        isExtended: true,
                        label: Text(
                          'SELECT SEAT',
                          style: TextStyle(
                              color: gblSystemColors
                                  .primaryButtonTextColor),
                        ),
                        icon: Icon(
                          Icons.check,
                          color: gblSystemColors
                              .primaryButtonTextColor,
                        ),
                        backgroundColor: gblSystemColors
                            .primaryButtonColor,
                        onPressed: () {
                          _handleBookSeats(paxlist);
                        }),
                  ],
                )));
  }

  Widget body() {
    if (_loadingInProgress) {
      return new Center(
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
      );
    } else if (_noInternet) {
      return new Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Please check your internet connection'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  primary: Colors.black),
              onPressed: () => retryLoad(),
              child: Text(
                'Retry',
                style: new TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      );
    } else if (_noSeats) {
      return new Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Due to social distancing measures currently in place, seat allocation for certain flights is unavailable online. Please report to the airport check-in desk to complete check-in. Your flight is still scheduled to operate.',
                  textAlign: TextAlign.justify,
                ),
              ),
//1.	Base text: “Seat allocation for certain flights is unavailable online”
//Translation:  “Seat allocation for certain flights is unavailable online. Please report to the airport check-in desk to complete check-in. Your flight is still scheduled to operate.”
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0)),
                  primary: Colors.black),
              onPressed: () => Navigator.pop(context),
              child: TrText(
                'OK',
                style: new TextStyle(color: Colors.white),
              ),
            )
          ],
        ),
      );
    } else {
      return Column(
        children: <Widget>[
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: showkey ? 70.0 : 0,
            padding:
                EdgeInsets.only(top: 10.0, left: 3.0, right: 3.0, bottom: 10.0),
            child: SingleChildScrollView(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Container(
                        width: cellSize,
                        height: cellSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: gblSystemColors.seatPlanColorSelected,
                          borderRadius:
                              new BorderRadius.all(new Radius.circular(5.0)),
                          boxShadow: [
                            new BoxShadow(
                              color: Colors.grey.shade600,
                              offset: new Offset(1.0, 1.0),
                            )
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text("Selected",
                            style: TextStyle(
                              fontSize: cellFontSize,
                            )),
                      )
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                        width: cellSize,
                        height: cellSize,
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: gblSystemColors.seatPlanColorAvailable,
                            borderRadius:
                                new BorderRadius.all(new Radius.circular(5.0))),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text("Available",
                            style: TextStyle(
                              fontSize: cellFontSize,
                            )),
                      )
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                        width: cellSize,
                        height: cellSize,
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: gblSystemColors.seatPlanColorEmergency,
                            borderRadius:
                                new BorderRadius.all(new Radius.circular(5.0))),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text("Emergency",
                            style: TextStyle(
                              fontSize: cellFontSize,
                            )),
                      )
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                        width: cellSize,
                        height: cellSize,
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: gblSystemColors.seatPlanColorRestricted,
                            borderRadius:
                                new BorderRadius.all(new Radius.circular(5.0))),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text("Restricted",
                            style: TextStyle(
                              fontSize: cellFontSize,
                            )),
                      )
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                        width: cellSize,
                        height: cellSize,
                        decoration: BoxDecoration(
                            shape: BoxShape.rectangle,
                            color: gblSystemColors.seatPlanColorUnavailable,
                            borderRadius:
                                new BorderRadius.all(new Radius.circular(5.0))),
                        child: Center(
                            child: Icon(
                          Icons.person,
                          size: cellSize,
                          color: Colors.white,
                        )),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text("Unavailable",
                            style: TextStyle(
                              fontSize: cellFontSize,
                            )),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
          SeatPlanPassengersWidget(
              paxList: paxlist,
              systemColors: gblSystemColors),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          RenderSeatPlan(
            seatplan: objSeatplan,
            pax: paxlist,
            rloc: widget.rloc,
            onChanged: _handleSeatChanged,
            onScrollCallbackShowKey: _handleScrollChanged,
            displaySeatPrices: true,
          ),
        ],
      );
    }
  }
}

class RenderSeatPlan extends StatefulWidget {
  const RenderSeatPlan(
      {Key key,
      this.seatplan,
      this.pax,
      this.rloc,
      this.displaySeatPrices,
      this.onChanged,
      this.onScrollCallbackShowKey})
      : super(key: key);

  final Seatplan seatplan;
  final List<Pax> pax;
  final ValueChanged<List<Pax>> onChanged;
  final ValueChanged<bool> onScrollCallbackShowKey;
  final String rloc;
  final bool displaySeatPrices;

  _RenderSeatPlanSeatState createState() => _RenderSeatPlanSeatState();
}

class _RenderSeatPlanSeatState extends State<RenderSeatPlan> {
  List<Pax> paxlist;
  List<String> selectedSeats = [];
  // List<String>();
  ScrollController _controller;
  bool showkey;

  _scrollListener() {
    if (!showkey &&
        _controller.position.userScrollDirection.toString() ==
            "ScrollDirection.forward") {
      print('ScrollDirection.up');
      print(_controller.offset);
      showkey = true;
      widget.onScrollCallbackShowKey(showkey);
    } else if (showkey &&
        _controller.offset >= 40 &&
        _controller.position.userScrollDirection.toString() ==
            "ScrollDirection.reverse") {
      print('ScrollDirection.down');
      print(_controller.offset);
      showkey = false;
      widget.onScrollCallbackShowKey(showkey);
    }
  }

  @override
  initState() {
    super.initState();
    _controller = new ScrollController();
    _controller.addListener(_scrollListener);
    showkey = true;
    paxlist = widget.pax;
    paxlist.forEach((f) => selectedSeats.add(f.seat));
  }

  emergencySeatSelection(BuildContext context, String selectedSeat) {
    String acceptTermsText =
        'By selecting this seat you confirm that you are over 16 years old and do not have any physical or vision impairment';
    String notAllowEmergencySeatingText =
        'To select this seat you must be over 16 years old';

    var paxTypesNotAllowed = ['CH', 'IN'];
    Pax selectPax = this.paxlist.firstWhere((p) => p.selected == true);

    bool isAllowEmergencySeating =
        !paxTypesNotAllowed.contains(selectPax.paxType);

    Widget cancelButton = TextButton(
      child: Text('Cancel'),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    Widget continueButton = TextButton(
      child: TrText('OK'),
      onPressed: () {
        Navigator.of(context).pop();
        _seatSelected(selectedSeat);
      },
    );

    Widget okButton = TextButton(
      child: TrText('OK'),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text('Emergency seating'),
      content: Text(isAllowEmergencySeating
          ? acceptTermsText
          : notAllowEmergencySeatingText),
      actions: isAllowEmergencySeating
          ? <Widget>[cancelButton, continueButton]
          : <Widget>[okButton],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void _seatSelected(String _seatNumber) {
    setState(() {
      paxlist.forEach((element) {
        if (element.selected == true) {
          element.seat = _seatNumber;
        }
      });
      selectedSeats.clear();
      paxlist.forEach((f) => selectedSeats.add(f.seat));
    });
    widget.onChanged(paxlist);
  }

  @override
  Widget build(BuildContext context) {
    //Get the number of rows
    this.widget.seatplan.seats.seat.sort((a, b) => a.sRow.compareTo(b.sRow));
    int rows = this.widget.seatplan.seats.seat.last.sRow;

    this.widget.seatplan.seats.seat.sort((a, b) => a.sCol.compareTo(b.sCol));
    List<int> arrayColumn = [];
    //new List<int>();
    this
        .widget
        .seatplan
        .seats
        .seat
        .where((a) => a.sRow == 1)
        .toList()
        .forEach((f) {
      var temp = f.sCol;
      arrayColumn.add(temp);
    });

    return new Expanded(
        child: ListView(
      controller: _controller,
      padding: EdgeInsets.only(left: 5, right: 5),
      children: renderSeats(rows, arrayColumn, widget.rloc),
    ));
  }

  List<Widget> renderSeats(int rows, List<int> columns, String rloc) {
    List<Widget> obj = [];
    // new List<Widget>();
    List<Seat> seats = [];
    // new List<Seat>();
    List<Widget> row = [];
    // new List<Widget>();

    String currentSeatPrice;
    String currencyCode;
    String previousSeatPrice;
    bool selectableSeat = true;
    for (var indexRow = 1; indexRow <= rows; indexRow++) {
      seats = this
          .widget
          .seatplan
          .seats
          .seat
          .where((a) => a.sRow == indexRow)
          .toList();

      seats.sort((a, b) => a.sRow.compareTo(b.sCol));
      row = [];
      // new List<Widget>();
      for (var indexColumn = columns.first;
          indexColumn <= columns.last;
          indexColumn++) {
        var seat =
            seats.firstWhere((f) => f.sCol == indexColumn, orElse: () => null);
        selectableSeat = true;
        if( seat != null ) {
          currentSeatPrice = seat.sScprice;
          currencyCode = seat.sCur;
        }

        //Color color = Colors.grey.shade300;
        if (seat == null && indexRow != 1) {
          row.add(Padding(
            padding: const EdgeInsets.all(cellPadding),
            child: Container(
              child: Text(''),
              width: cellSize,
            ),
          ));
        } else if (seat == null && indexRow == 1 ||
            seat.sCellDescription == 'Aisle') {
          row.add(
            Container(
              child: Text(''),
              width: aisleCellSize,
            ),
          );
        } else if (seat.sCellDescription.length == 1) {
          row.add(
            Padding(
                padding: EdgeInsets.all(cellPadding),
                child: Container(
                  width: cellSize,
                  child: Center(
                      child: Text(seat.sCellDescription != null
                          ? seat.sCellDescription
                          : '')),
                )),
          );
        } else if (seat.sCellDescription == 'SeatPlanWidthMarker' ||
            seat.sCellDescription == 'Wing Start' ||
            seat.sCellDescription == 'Wing Middle' ||
            seat.sCellDescription == 'Wing End' ||
            seat.sCellDescription == 'DoorDown') {
          row.add(Padding(
            padding: const EdgeInsets.all(cellPadding),
            child: Container(
              child: Text(''),
              //width: 10.0,
              width: cellSize,
            ),
          ));
        } else if ((seat.sRLOC != null && seat.sRLOC != rloc) ||
            (seat.sSeatID != '0' && seat.sRLOC == null) ||
            (seat.sCellDescription == 'Block Seat')) {
          row.add(
            Padding(
                padding: EdgeInsets.all(cellPadding),
                child: Container(
                  width: cellSize,
                  height: cellSize,
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: gblSystemColors.seatPlanColorRestricted,
                      borderRadius:
                          new BorderRadius.all(new Radius.circular(5.0))),
                  child: Center(
                      child: Icon(
                    Icons.person,
                    size: cellSize,
                    color: Colors.white,
                  )),
                )),
          );
        } else {
          var color;
          switch (seat.sCellDescription) {
            case 'EmergencySeat':
              color = gblSystemColors.seatPlanColorEmergency;
              break;
            case 'Seat':
              color = gblSystemColors.seatPlanColorAvailable;
              break;
            default:
              color = gblSystemColors.seatPlanColorSelected;
              selectableSeat = false;
          }

          //Is the seat already selected by one of the pax
          if (selectedSeats.contains(seat.sCode)) {
            color = gblSystemColors.seatPlanColorSelected;
            selectableSeat = false;
          }

          row.add(Padding(
              padding: EdgeInsets.all(cellPadding),
              child: GestureDetector(
                child: Container(
                  width: cellSize,
                  height: cellSize,
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: color,
                      borderRadius:
                          new BorderRadius.all(new Radius.circular(5.0))),
                  child: Center(
                      child: Text(seat.sCode != null ? seat.sCode : '',
                          style: TextStyle(
                            fontSize: cellFontSize,
                          ))),
                ),
                onTap: () =>
                    selectableSeat && !selectedSeats.contains(seat.sCode)
                        ? seat.sCellDescription == 'EmergencySeat'
                            ? emergencySeatSelection(context, seat.sCode)
                            : _seatSelected(seat.sCode)
                        : {},
              )));
        }
        selectableSeat = true;
      }
      if (widget.displaySeatPrices &&
          currentSeatPrice != null &&
          currentSeatPrice != "0") {
        //add row price
        if (previousSeatPrice != currentSeatPrice) {
          //TODO: Get currency code from object
          obj.add(
            Container(
              decoration: BoxDecoration(
                  // borderRadius: new BorderRadius.only(
                  //      topLeft: const Radius.circular(1.0),
                  //       topRight: const Radius.circular(1.0)),
                  border: Border(
                top: BorderSide(width: 1.0, color: Color(0xFFFF000000)),
                left: BorderSide(width: 1.0, color: Color(0xFFFF000000)),
                right: BorderSide(width: 1.0, color: Color(0xFFFF000000)),
              )),
              child: Center(
                child: Text(
                  formatPrice(currencyCode, double.parse(currentSeatPrice)) +
/*
                    NumberFormat.simpleCurrency(
                            locale: gblSettings.locale,
                            name: currencyCode)
                        .format(double.parse(currentSeatPrice)) +

 */
                    ' Seat Charge'),
              ),
            ),
          );
        }
        previousSeatPrice = currentSeatPrice;
      }
      obj.add(new Row(
        children: row,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ));
    }
    obj.add(new Padding(
      padding: EdgeInsets.all(30.0),
    ));
    return obj;
  }
}

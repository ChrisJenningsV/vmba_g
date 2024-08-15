
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vmba/components/showDialog.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/pax.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/models/seatplan.dart';
import 'package:vmba/data/models/vrsRequest.dart';
import 'package:vmba/data/repository.dart';
import 'dart:async';
import 'dart:convert';
import 'package:vmba/mmb/widgets/seatPlanPassengers.dart';
import 'package:vmba/payment/choosePaymentMethod.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/utilities/widgets/snackbarWidget.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/v3pages/controls/V3Constants.dart';

import '../../Helpers/settingsHelper.dart';
import '../../calendar/bookingFunctions.dart';
import '../../controllers/vrsCommands.dart';
import '../../data/smartApi.dart';
import '../../utilities/widgets/CustomPageRoute.dart';
import '../../utilities/widgets/colourHelper.dart';
import '../../v3pages/controls/V3AppBar.dart';
import '../../v3pages/fields/typography.dart';

enum SeatType { regular, emergency }

double cellSize = 36.0; //28.0;
double cellFontSize = 13.0;
double cellPadding = 5.0;
double aisleCellSize = 20.0;

class SeatPlanWidget extends StatefulWidget {
  SeatPlanWidget(
      {Key key= const Key("seatplanwi_key"),
      this.paxlist,
      this.seatplan ='',
      this.rloc ='',
      this.journeyNo = '',
      this.cabin = '',
        this.flt='',
      this.selectedpaxNo = 1,
      this.isMmb = false,
      this.ischeckinOpen = false})
      : super(key: key);

  final List<Pax>? paxlist;
  final String seatplan;
  final String cabin;
  final String flt;
  final String rloc;
  final String journeyNo;
  final int selectedpaxNo;
  final bool isMmb;
  final bool ischeckinOpen;
  _SeatPlanWidgetState createState() => _SeatPlanWidgetState();
}

class _SeatPlanWidgetState extends State<SeatPlanWidget> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  bool _loadingInProgress=false;
  String _displayProcessingText = '';
  Seatplan? objSeatplan;
  List<Pax>? paxlist;
  bool showkey = true;
  String seatplan = '';
  //bool _noInternet = false;
  bool _noSeats = false;
  Session? session;

  @override
  void initState() {
    super.initState();
    gblPaymentMsg = '';
    setError( '');
    //_noInternet = false;
    _noSeats = false;
    _loadingInProgress = true;
    _displayProcessingText = translate('Loading seat plan...');
    seatplan = widget.seatplan;
    _loadData(widget.seatplan);
    paxlist = widget.paxlist;
    session = Session('', '', '');

    paxlist!.forEach((p) => p.selected = false);
    if (widget.selectedpaxNo == null) {
      paxlist!.firstWhere((p) => p.id == 1).selected = true;
    } else {
      paxlist!.firstWhere((p) => p.id == widget.selectedpaxNo).selected = true;
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
    showAlertDialog(context, 'Error booking seats', errorMsg);
    //showSnackBar(errorMsg);
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

  Future _sendVRSCommand(String msg) async {
    try {
      if(msg.startsWith('{' )){
        Map map = json.decode(msg);
        msg = map['Commands'];
      }
      String data = await runVrsCommand(msg);
      return data;
    } catch(e){
      return 'error ${e.toString()}';
    }

  }
/*

  Future _sendVRSCommandList(msg) async {
    try {
      if(msg.startsWith('{' )){
        Map map = json.decode(msg);
        msg = map['Commands'];
      }

      String data = await runVrsCommand(msg);
      return data;
    } catch(e){
      return 'error ${e.toString()}';
    }

  }
*/

  Future _loadData(String seatPlanCmd) async {
    Repository.get().getSeatPlan(seatPlanCmd).then((rs) {
      if (rs.isOk()) {
        objSeatplan = rs.body;

        if( objSeatplan != null ) objSeatplan!.simplifyPlan();

        if (!objSeatplan!.hasSeatsAvailable() && objSeatplan!.hasBlockedSeats()) {
          setState(() {
            _loadingInProgress = false;
            _noSeats = true;
          });
        } else {
          _dataLoaded();
        }
      } else {
        setError( rs.error);
        setState(() {
          _loadingInProgress = false;
          //_noInternet = true;
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
   // _bookSeats();
    setError( '');
    // check is any seats selects
    int seatsSelected = 0;
    paxlist!.forEach((seat) {
      if(seat.seat != '' && seat.seat != seat.savedSeat){
        seatsSelected++;
      }
    });
    if( seatsSelected ==  0){
      showAlertDialog(context, 'Error', 'Select Seats First');

    } else {
      smartBookSeats();
      setState(() {
        paxlist = paxValue;
        _loadingInProgress = true;
        _displayProcessingText = translate('Booking your seat selection...');
      });
    }
  }

  smartBookSeats() async {
    gblPayAction = 'BOOKSEAT';
    SeatRequest seat = new SeatRequest();
    gblBookSeatCmd = '';
    seat.paxlist = paxlist!;
    seat.rloc = widget.rloc;
    seat.journeyNo = int.parse(widget.journeyNo);
    if( widget.isMmb && widget.ischeckinOpen) {
      seat.webCheckinNoSeatCharge = gblSettings.webCheckinNoSeatCharge;
    } else {
      seat.webCheckinNoSeatCharge = false;
    }

    String data =  json.encode(seat);

    try{
      String reply = await callSmartApi('BOOKSEAT', data);
      Map<String, dynamic> map = json.decode(reply);
      SeatReply seatRs = new SeatReply.fromJson(map);
      double outstanding = double.parse(seatRs.outstandingAmount);
      gblBookSeatCmd = seatRs.bookSeatCmd;
      if( !widget.isMmb) {
        String msg = json.encode(RunVRSCommand(session!, "E*R~X"));
        gblBookSeatCmd = '';

        _sendVRSCommand(msg).then(
                (onValue) {
                  //Repository.get().fetchPnr(widget.rloc).then((pnr) {
                  Map<String, dynamic> map = json.decode(onValue);
                  PnrModel pnrModel = new PnrModel.fromJson(map);
                  gblPnrModel = pnrModel;
                  refreshStatusBar();
                  //showSnackBar(translate("Seat(s) allocated"));
                  Navigator.pop(context, pnrModel);
                  //            })
                }
            );
      } else {
        if (outstanding == 0) { // zero outstanding
          String msg = json.encode(RunVRSCommand(session!, "E"));
          _sendVRSCommand(msg).then(
                  (onValue) =>
                  Repository.get().fetchPnr(widget.rloc).then((pnr) {
                    Map<String, dynamic> map = json.decode(pnr!.data);
                    PnrModel pnrModel = new PnrModel.fromJson(map);
                    gblPnrModel = pnrModel;
                    refreshStatusBar();
                    showSnackBar(translate("Seat(s) allocated"));
                    Navigator.pop(context, pnrModel);
                  }));
        } else if (outstanding < 0) { // Minus outstanding
          String msg = json.encode(RunVRSCommand(session!, "EMT*R"));
          gblBookSeatCmd = '';
          _sendVRSCommand(msg).then(
                  (onValue) =>
                  Repository.get().fetchPnr(widget.rloc).then((pnr) {
                    Map<String, dynamic> map = json.decode(pnr!.data);
                    PnrModel pnrModel = new PnrModel.fromJson(map);
                    gblPnrModel = pnrModel;
                    showSnackBar(translate("Seat(s) allocated"));
                    Navigator.pop(context, pnrModel);
                  }));
        } else {
          String msg;
          int noSeats = 0;
         // if (gblSettings.wantNewPayment) {
            // build undo
            noSeats = gblPnrModel!.pNR.seatCount();

            // was E*R,
            msg = json.encode(RunVRSCommand(session!, "*R~x"));
 /*         } else {
            msg = json.encode(RunVRSCommand(session!, "*${widget.rloc}~x"));
          }*/
          _sendVRSCommand(msg).then((pnrJson) {
            pnrJson =
                pnrJson.replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
                    .replaceAll('<string xmlns="http://videcom.com/">', '')
                    .replaceAll('</string>', '');

            Map<String, dynamic> map = json.decode(pnrJson);

            PnrModel pnrModel = new PnrModel.fromJson(map);
            gblPnrModel = pnrModel;
            int newSeatCount = gblPnrModel!.pNR.seatCount();
            gblUndoCommand ='';
            for( int i = newSeatCount; i > noSeats; i--){
              if(gblUndoCommand.length > 0 ){
                gblUndoCommand += '^';
              }
              gblUndoCommand += '4X$i';
            }
            if(gblUndoCommand.length > 0 ){
              gblUndoCommand += '^E*R';
            }
            refreshStatusBar();
            _navigate(context, pnrModel, session!);

            _resetloadingProgress();
          });
        }
      }
    } catch(e) {
      print(e.toString());
      _dataLoadedFailed(e);
    }

  }

/*

  _bookSeats() async {
    StringBuffer cmd = new StringBuffer();
    cmd.write('*${widget.rloc}^');
    gblBookingState = BookingState.bookSeat;
    if (!gblSettings.webCheckinNoSeatCharge) {
      paxlist!.forEach((f) {
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
      paxlist!.forEach((f) {
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
    String msg;
    if (gblSettings.useWebApiforVrs) {
      msg = cmd.toString();
    } else {
      msg = json
          .encode(
          RunVRSCommandList(session, cmd.toString().split('^')).toJson());
    }
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
        if( gblSettings.wantNewPayment) {
          msg = json.encode(RunVRSCommand(session, "E*R~x"));
        } else {
          msg = json.encode(RunVRSCommand(session, "*R~x"));
        }
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

*/
  _navigate(BuildContext context, PnrModel pnrModel, Session session) async {
    // Navigator.push returns a Future that completes after calling
    // Navigator.pop on the Selection Screen.
    gblPaymentMsg = '';
    final result = await Navigator.push(
      context,
      // Create the SelectionScreen in the next step.
      //MaterialPageRoute(
      CustomPageRoute(
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
    String msg = json.encode(RunVRSCommand(session!, "I"));
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
    logit(err);
    setState(() {
      _loadingInProgress = false;
    });
  }

  retryLoad() {
    setState(() {
      _loadingInProgress = true;
      //_noInternet = false;
      _loadData(widget.seatplan);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _key,
        appBar: new V3AppBar(
          PageEnum.chooseSeat,
          //brightness: gblSystemColors.statusBar,
/*
          backgroundColor:
          gblSystemColors.primaryHeaderColor,
*/
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context, gblPnrModel);
              }
            )
          ],
          iconTheme: IconThemeData(
              color: gblSystemColors.headerTextColor),
          title: new TrText('Choose a seat',
              style: TextStyle(
                  color:
                  gblSystemColors.headerTextColor)),
        ),
        //endDrawer: DrawerMenu(),

        body: body(),
        floatingActionButton: _loadingInProgress || gblNoNetwork || _noSeats
            ? null
            : Padding(
                padding: EdgeInsets.only(left: 35.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new FloatingActionButton.extended(
                        elevation: 0.0,
                        isExtended: true,
                        label: TrText(
                          'SELECT SEAT',
                          style: TextStyle(
                              color: gblSystemColors.primaryButtonTextColor),
                        ),
                        icon: Icon(
                          Icons.check,
                          color: gblSystemColors
                              .primaryButtonTextColor,
                        ),
                        backgroundColor: actionButtonColor(),
                        onPressed: () {
                          if( gblNoNetwork == false) {
                            _handleBookSeats(paxlist!);
                          }
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
    }
    else if( gblError != '') {
      return new Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
          Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            child: Text(
              gblError,
              textAlign: TextAlign.justify,
            ),
          ),
      )
    ]
    )
    );
    }
    else if (_noSeats) {
      return new Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  'Please report to the airport check-in desk to complete check-in.',
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
                  foregroundColor: Colors.black),
              onPressed: () {
                      Navigator.pop(context);
                      },
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
          Padding(padding: EdgeInsets.fromLTRB(5, 10, 0, 0),
          child:
          Align(alignment: Alignment.centerLeft,
              child: V2Heading2Text(translate('Flight') + ' ' + widget.flt,
/*
                textScaler: v2H2Scale(),
                style: TextStyle(fontWeight: FontWeight.bold),))
*/
          ))),
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: showkey ? 75.0 : 0,
            padding:
                EdgeInsets.only(top: 10.0, left: 3.0, right: 3.0, bottom: 10.0),
            child: SingleChildScrollView(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // selected
                  Column(
                    children: <Widget>[
                      getSeat(null, gblSystemColors.seatPlanColorSelected!),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: TrText("Selected",
                            style: TextStyle(
                              fontSize: cellFontSize,
                            )),
                      )
                    ],
                  ),
                  // end selected
                  Column(
                    children: <Widget>[
                      getSeat(null, gblSystemColors.seatPlanColorAvailable!),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: TrText("Available",
                            style: TextStyle(
                              fontSize: cellFontSize,
                            )),
                      )
                    ],
                  ),
                  Column(
                    children: <Widget>[
                    getSeat(null,gblSystemColors.seatPlanColorEmergency!),
                    Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: TrText("Emergency",
                            style: TextStyle(
                              fontSize: cellFontSize,
                            )),
                      )
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      getSeat(null,gblSystemColors.seatPlanColorRestricted!),
                      Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: TrText("Restricted",
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
                        padding: const EdgeInsets.only(top: 6.0),
                        child: TrText("Unavailable",
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
              paxList: paxlist, segNo: widget.journeyNo,
              loadingData: (msg){
                _displayProcessingText = msg;
                _loadingInProgress = true;
                setState(() {
                });
              },
            dataLoaded: () {
                _loadingInProgress = false;
                setState(() {

                });
            },
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          RenderSeatPlan(
            seatplan: objSeatplan!,
            pax: paxlist!,
            rloc: widget.rloc,
            cabin: widget.cabin,
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
      {Key key= const Key("renderpeatp_key"),
      required this.seatplan,
        required this.pax,
        required this.rloc,
        required this.displaySeatPrices,
        required this.onChanged,
        this.cabin = '',
        required this.onScrollCallbackShowKey})
      : super(key: key);

  final Seatplan seatplan;
  final String cabin;
  final List<Pax> pax;
  final ValueChanged<List<Pax>> onChanged;
  final ValueChanged<bool> onScrollCallbackShowKey;
  final String rloc;
  final bool displaySeatPrices;

  _RenderSeatPlanSeatState createState() => _RenderSeatPlanSeatState();
}

class _RenderSeatPlanSeatState extends State<RenderSeatPlan> {
  List<Pax>? paxlist;
  List<String> selectedSeats = [];
  // List<String>();
  ScrollController? _controller;
  bool showkey = false;

  _scrollListener() {
    if (!showkey &&
        _controller!.position.userScrollDirection.toString() ==
            "ScrollDirection.forward") {
      print('ScrollDirection.up');
      print(_controller!.offset);
      showkey = true;
      widget.onScrollCallbackShowKey(showkey);
    } else if (showkey &&
        _controller!.offset >= 40 &&
        _controller!.position.userScrollDirection.toString() ==
            "ScrollDirection.reverse") {
      print('ScrollDirection.down');
      print(_controller!.offset);
      showkey = false;
      widget.onScrollCallbackShowKey(showkey);
    }
  }

  @override
  initState() {
    super.initState();
    _controller = new ScrollController();
    _controller!.addListener(_scrollListener);
    showkey = true;
    paxlist = widget.pax;
    paxlist!.forEach((f) => selectedSeats.add(f.seat));
  }

  emergencySeatSelection(BuildContext context, String selectedSeat) {
    String acceptTermsText =
        'By selecting this seat you confirm that you are over 16 years old and do not have any physical or vision impairment';
    String notAllowEmergencySeatingText =
        'To select this seat you must be over 16 years old';

    var paxTypesNotAllowed = ['CH', 'IN'];
    Pax selectPax = this.paxlist!.firstWhere((p) => p.selected == true);

    bool isAllowEmergencySeating =
        !paxTypesNotAllowed.contains(selectPax.paxType);

    Widget cancelButton = TextButton(
      child: TrText('Cancel'),
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
      title: TrText('Emergency seating'),
      content: TrText(isAllowEmergencySeating
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

  prmSeatSelection(BuildContext context, Seat selectedSeat) {
    String acceptTermsText =
        'This seat is a priority for customers with reduced mobility. As such you may be moved if this seat is required for that purpose. If moved, your seat charge will be refunded.';
    String notAllowEmergencySeatingText =
        'Infants can not select this seat';
    bool isAllowEmergencySeating = true;
    Pax selectPax = this.paxlist!.firstWhere((p) => p.selected == true);

    if( selectedSeat.noInfantSeat) {
       var paxTypesNotAllowed = ['IN'];

         if( paxTypesNotAllowed.contains(selectPax.paxType)) {
           isAllowEmergencySeating = false;
         }
    }
    if( gblPnrModel!.paxHasInfant(selectPax) ) {
      notAllowEmergencySeatingText = 'You are trying to allocate a restricted seat to a passenger who is accompanying an infant. Please select another seat!.';
      isAllowEmergencySeating = false;
    }

    Widget cancelButton = TextButton(
      child: TrText('Cancel'),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    Widget continueButton = TextButton(
      child: TrText('OK'),
      onPressed: () {
        Navigator.of(context).pop();
        _seatSelected(selectedSeat.sCode);
      },
    );

    Widget okButton = TextButton(
      child: TrText('OK'),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );

    AlertDialog alert = AlertDialog(
      title: TrText('Notice'),
      content: TrText(isAllowEmergencySeating
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
      paxlist!.forEach((element) {
        if (element.selected == true) {
          element.seat = _seatNumber;
        }
      });
      selectedSeats.clear();
      paxlist!.forEach((f) => selectedSeats.add(f.seat));
    });
    widget.onChanged(paxlist!);
  }

  @override
  Widget build(BuildContext context) {

    int minCol = -1;
    int maxCol = -1;
    //new List<int>();

    this.widget.seatplan.seats.seat.forEach((s) {
      if(minCol == -1 || minCol > s.sCol ){
        minCol = s.sCol;
      }
      if(s.sCol > maxCol ) {
        maxCol = s.sCol;
      }
    });
    //Get the number of rows
    this.widget.seatplan.seats.seat.sort((a, b) => a.sRow.compareTo(b.sRow));
    int rows = this.widget.seatplan.seats.seat.last.sRow;


    this.widget.seatplan.seats.seat.sort((a, b) => a.sCol.compareTo(b.sCol));
   // List<int> arrayColumn = [];


    if( rows <= 0 || minCol == -1 || maxCol <2 ){
      return Container( child: buildMessage('SeatPlan error', 'No Columns', onComplete: () {
        gblPaymentMsg = '';
        setState(() {});
      }));
    }

    return new Expanded(
        child: ListView(
      controller: _controller,
      padding: EdgeInsets.only(left: 5, right: 5),
      children: renderSeats(rows, minCol, maxCol, widget.rloc, widget.cabin),
    ));
  }

  List<Widget> renderSeats(int rows, int minCol, int maxCol, String rloc, String cabin) {
    List<Widget> obj = [];
    // new List<Widget>();
    List<Seat> seats = [];
    // new List<Seat>();
    List<Widget> row = [];
    // new List<Widget>();

    String currentSeatPrice = '';
    String currentSeatPriceLabel = '';
    String currencyCode = '';
    String previousSeatPrice = '';
    bool selectableSeat = true;

    // get max no cols
//    int maxCol = 0;



    for (var indexRow = 1; indexRow <= rows; indexRow++) {
      seats = this
          .widget
          .seatplan
          .seats
          .seat
          .where((a) => a.sRow == indexRow)
          .toList();
      if( seats == null ) {
      } else {
        seats.sort((a, b) => a.sRow.compareTo(b.sCol));

/*
        seats.forEach((element) {
          if (element.sCol != null && element.sCol > maxCol) {
            maxCol = element.sCol;
          }
        });
*/
      }
      // check for large plane
      if( maxCol > 8){
        cellSize = 30;
        cellPadding = 1;
        aisleCellSize = 14;
        cellFontSize = 11;
        print('use small seat size');
      }
      row = [];
      // new List<Widget>();
      for (var indexColumn = minCol;
          indexColumn <= maxCol;
          indexColumn++) {
/*
        if( indexRow == 14) {
          var test = 1;
        }
*/

    Seat? seat ;
    bool found = false;
    seats.forEach((element) {
      if( element.sCol == indexColumn){
        seat = element;
        found = true;
      }
    });
/*
        var seat =
            seats.firstWhere((f) => f.sCol == indexColumn, */
/*orElse: () => null*//*
);
*/


        selectableSeat = true;

        // get price for row
        currentSeatPrice = '0';
        seats.forEach((element) {
          if( element != null &&  element.sScprice != null  ) {
            if( double.parse(element.sScprice) > double.parse(currentSeatPrice)) {
            currentSeatPrice = element.sScprice;
            currentSeatPriceLabel = element.sScinfo;
            currencyCode = element.sCur;
            }
          }
        });
        /*if( seat != null ) {
          currentSeatPrice = seat!.sScprice;
          currencyCode = seat!.sCur;
        }*/
        //Color color = Colors.grey.shade300;
        if (seat == null && indexRow != 1) {
          row.add(Padding(
            padding: EdgeInsets.all(cellPadding),
            child: Container(
              child: Text(''),
              width: cellSize,
            ),
          ));
          //logit('r${indexRow} c${indexColumn} null w${cellSize + cellPadding}');
        } else if (seat == null && indexRow == 1 ||
            seat!.sCellDescription == 'Aisle') {
          row.add(
            Container(
              child: Text(''),
              width: aisleCellSize,
            ),
          );
          //logit('r${indexRow} c${indexColumn} aisle w${aisleCellSize}');

        } else if (seat!.sCellDescription.length == 1) {
          row.add(
            Padding(
                padding: EdgeInsets.all(cellPadding),
                child: Container(
                  width: cellSize,
                  child: Center(
                      child: Text(seat!.sCellDescription != null
                          ? seat!.sCellDescription
                          : '')),
                )),
          );
          //logit('r${indexRow} c${indexColumn} desc==1 w${cellPadding + cellSize}');

        } else if (seat!.sCellDescription == 'SeatPlanWidthMarker' ||
            seat!.sCellDescription == 'Wing Start' ||
            seat!.sCellDescription == 'Wing Middle' ||
            seat!.sCellDescription == 'Wing End' ||
            seat!.sCellDescription == 'DoorDown') {
          row.add(Padding(
            padding: EdgeInsets.all(cellPadding),
            child: Container(
              child: Text(''),
              //width: 10.0,
             // width: 18,
               width: cellSize,
            ),
          ));
          //logit('r${indexRow} c${indexColumn} marker w${cellPadding + cellSize}');

        } else if ((seat!.sRLOC != null && seat!.sRLOC != '' && seat!.sRLOC != rloc) ||
            (seat!.sSeatID != '0' && (seat!.sRLOC == null || seat!.sRLOC == '')) ||
            (seat!.sCellDescription == 'Block Seat') ||
            ((seat!.sCabinClass != widget.cabin) && widget.cabin !='')  ) {

          row.add(
            Padding(
                padding: EdgeInsets.all(cellPadding),
                child: Container(
                  width: cellSize,
                  height: cellSize,
                  decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      color: gblSystemColors.seatPlanColorUnavailable, // gblSystemColors.seatPlanColorRestricted,
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
          //logit('r${indexRow} c${indexColumn} block w${cellSize}');

        } else {
          //logit( ' seat r${seat!.sRow} c${seat!.sCol} ${seat!.sCellDescription} s${seat!.sStatus} i${seat!.sSeatID} n${seat!.noInfantSeat}');

          var color;
          switch (seat!.sCellDescription) {
            case 'EmergencySeat':
              color = gblSystemColors.seatPlanColorEmergency;
              break;
            case 'Seat':
              if( seat!.noInfantSeat) {
                color = gblSystemColors.seatPlanColorRestricted;

              } else {
                color = gblSystemColors.seatPlanColorAvailable;
              }
              break;
            default:
              if( seat!.noInfantSeat) {
                color = gblSystemColors.seatPlanColorRestricted;

              } else {
                color = gblSystemColors.seatPlanColorSelected;
              }
              selectableSeat = false;
          }

          //Is the seat already selected by one of the pax
          if (selectedSeats.contains(seat!.sCode)) {
            color = gblSystemColors.seatPlanColorSelected;
            selectableSeat = false;
          }

          row.add(Padding(
              padding: EdgeInsets.all(cellPadding),
              child: GestureDetector(
                child: getSeat(seat,color),
                onTap: () {
                  if( selectableSeat && !selectedSeats.contains(seat!.sCode)) {
                      if( seat!.sCellDescription == 'EmergencySeat' ) {
                        emergencySeatSelection(context, seat!.sCode);
                      } else if( seat!.pRMSeat == true ) {
                        prmSeatSelection(context, seat!);
                      } else {
                        _seatSelected(seat!.sCode);
                      }
                }},
              )));
        }
        selectableSeat = true;
        //logit('r${indexRow} c${indexColumn} Emerg w${cellPadding } + getSeat');

      }
      if( gblLogProducts) logit('price $currentSeatPrice r=$indexRow');
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
                    ' ' + currentSeatPriceLabel), //' Seat Charge'),
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
Widget getSeat(Seat? seat, Color color) {
  return Column(
  children: [
    Row(children: [
      Align( alignment: FractionalOffset.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(top: cellSize / 4),
          child: Container(
        width: (1 * cellSize)/10,
        height:  cellSize / 2,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: color,
          border: Border.all(width: 1, color: Colors.black)      ,
          borderRadius:
          new BorderRadius.only( topLeft: Radius.circular(5.0)              ),
        ),
     ))),

       Container(
    width: (4 * cellSize) / 5,
    height: (3 * cellSize) / 4,
    decoration: BoxDecoration(
      shape: BoxShape.rectangle,
      color: color,
                      borderRadius:
                          new BorderRadius.only(topLeft:  new Radius.circular(5.0), topRight:  new Radius.circular(5.0))
    ),
    child: Center(
        child: Text((seat != null && seat.sCode != null) ? seat.sCode : '',
            style: TextStyle(
              fontSize: cellFontSize,
            ))),
  ),

      Align( alignment: FractionalOffset.bottomCenter,
          child: Padding(
              padding: EdgeInsets.only(top: cellSize / 4),
              child: Container(
                width: (1 * cellSize)/10,
                height:  cellSize / 2,
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: color,
                  border: Border.all(width: 1, color: Colors.black)      ,
                  borderRadius:
                  new BorderRadius.only( topRight: Radius.circular(5.0)              ),
                ),
              ))),

    ]),
  Container(
  width: cellSize,
  height:  cellSize / 4,
  decoration: BoxDecoration(
  shape: BoxShape.rectangle,
  color: color,
     border: Border.all(width: 1, color: Colors.black)      ,
          borderRadius:
              new BorderRadius.only( bottomLeft: Radius.circular(5.0),
              bottomRight: Radius.circular(5.0)),
      ),
    ),

  ]);
}

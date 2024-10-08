


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vmba/mmb/widgets/seatComponents/seat.dart';
import 'package:vmba/mmb/widgets/seatplan.dart';

import '../../../calendar/flightPageUtils.dart';
import '../../../components/showDialog.dart';
import '../../../components/trText.dart';
import '../../../data/globals.dart';
import '../../../data/models/pax.dart';
import '../../../data/models/pnr.dart';
import '../../../data/models/seatplan.dart';
import '../../../utilities/helper.dart';
import '../../../utilities/widgets/snackbarWidget.dart';
import '../../../v3pages/v3Theme.dart';

double cellSize = 36.0; //28.0;
double cellFontSize = 13.0;
double cellPadding = 5.0;
double aisleCellSize = 20.0;

class RenderSeatPlan2 extends StatefulWidget {
  const RenderSeatPlan2(
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

  _RenderSeatPlanSeatState2 createState() => _RenderSeatPlanSeatState2();
}

class _RenderSeatPlanSeatState2 extends State<RenderSeatPlan2> {
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
    loadData();
    logit('got it');
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

  void loadData() {
    paxlist = widget.pax;
    paxlist!.forEach((f) => selectedSeats.add(f.seat));

    gblSeatPlanDef = this.widget.seatplan.getPlanDataTable();
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
    int paxIndex = 0;
    int lastPax = 0;
    setState(() {
      paxlist!.forEach((element) {
        if (element.selected == true) {
          element.seat = _seatNumber;
          lastPax = paxIndex;
          gblCurPax = paxIndex;
          element.selected = false;
        }
        paxIndex++;
      });
      selectedSeats.clear();
      paxlist!.forEach((f) => selectedSeats.add(f.seat));
    });

    String message = '${translate('Seat')} $_seatNumber ${translate('selected')}';
    if( (lastPax+1) < paxlist!.length){
      gblCurPax++;
      paxlist![gblCurPax].selected = true;
      message += ' ${translate('select seat for next passenger')}';
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(snackbar(message));
    } catch(e) {
    }

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


/*
    Column( children: [
        noFlts > 1 ? title : Container(),
*/
    if( gblLoadSeatState == VrsCmdState.loading){
     return Expanded(        child:
      Container(
          margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
          padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
          height: 2000,
          width: 400,
          decoration: BoxDecoration(
            //border: Border.all(color: v2BorderColor(), width: v2BorderWidth()),
            borderRadius: BorderRadius.all(
                Radius.circular(10.0)),
            color: Colors.grey,
          ),
        child: TrText('Loading...'),
      )
      );
    }

    return

      Expanded(        child:
        Container(
          margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
          padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
        height: 2000,
        width: 400,
        decoration: BoxDecoration(
        //border: Border.all(color: v2BorderColor(), width: v2BorderWidth()),
        borderRadius: BorderRadius.all(
        Radius.circular(10.0)),
    color: Colors.black,
    ),
    child: Row(
      children: [
      Expanded(
      flex: 2,
        child: ListView(
          controller: _controller,
          padding: EdgeInsets.only(left: 5, right: 5),
          children: renderSeats(rows, minCol, maxCol, widget.rloc, widget.cabin),
        )),
    Expanded(
    flex: 1,
    child: Text('price', style: TextStyle(color: Colors.red),)
    ),
    ]
//        )
    )
        )
    );
/*
    ],
    ) ;
*/
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


    List<TableRow> tabRows = [];

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

      List<Widget> list = [];
      for(int i=minCol; i <= maxCol; i++){
        Seat? seat = gblSeatPlanDef!.getSeatAt(indexRow, i);
        bool selected = false;
        if( seat == null ){

        } else {
          //logit('r=${seat.sRow} c=${seat.sCol} code=${seat.sCode}');
        }
        if (selectedSeats != null && seat != null  && seat!.sCode!= '' && selectedSeats.contains(seat!.sCode)) {
          //color = gblSystemColors.seatPlanColorSelected;
          selected = true;
         // selectableSeat = false;
        }
        if( seat!= null && cabin != seat.sCabinClass){
          seat = Seat(sCode: seat.sCode, sCellDescription: 'Occupied');
        }
        if( seat!= null && seat.sCode == ''){
          list.add(Container());
        } else {
          //if( seat != null ) logit('hookup ${seat!.sCode}');
          list.add(hookUpSeat(seat, selected, selectableSeat, gblSeatPlanDef!.seatSize));
        }
      }
      TableRow tableRow = TableRow(children:  list);


      if( gblLogProducts) logit('price $currentSeatPrice r=$indexRow');
     /* if (widget.displaySeatPrices &&
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
      }*/
      row.add(VerticalDivider(width: 2,color: Colors.amber,indent: 0,endIndent: 0,thickness: 3,));
      row.add(_getSeatPriceInfo());
      if( seats != null && seats.length > 0) {
        obj.add(new Row(
          children: row,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
        ));
      } else {
        //logit( ' row  empty' );
      }
      row.add(Container()); // space filler (will be price!)
      tabRows.add(tableRow);
    }
    obj.add(new Padding(
      padding: EdgeInsets.all(30.0),
    ));
    //return obj;
    obj = [];
    Map <int, TableColumnWidth> colWidths = Map();

    bool beforSeats = true;

    for(int i = 0; i <= maxCol-minCol; i++){
      if( gblSeatPlanDef!.colTypes == null || gblSeatPlanDef!.colTypes.length < i){
        colWidths[i] = FixedColumnWidth(5);

      } else {
        if (gblSeatPlanDef!.colTypes[i+minCol] == 'A') {
          if( beforSeats ) {
            colWidths[i] = FixedColumnWidth(0);
          } else {
            colWidths[i] = FixedColumnWidth(gblSeatPlanDef!.asileWidth);
          }
        } else {
          colWidths[i] = FixedColumnWidth(gblSeatPlanDef!.seatWidth);
          beforSeats = false;
        }
      }
    }
    colWidths[maxCol-minCol+1] = IntrinsicColumnWidth();


      obj.add(Table(

        columnWidths: colWidths,
        border: TableBorder.all(color: Colors.transparent),
        children:tabRows )
    );
    obj.add(Padding(padding: EdgeInsets.all(20)));
    return obj;
  }
Widget _getSeatPriceInfo(){
    return Container( child: Row(
      //crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VerticalDivider(width: 2, color: Colors.red, thickness: 10,),
      Container(
        margin: EdgeInsets.all(0),
        padding: EdgeInsets.all(0),
        width: 3, height: 40, color: Colors.white,
        child: Padding(padding: EdgeInsets.all(0),),),
      //Padding(padding: EdgeInsets.fromLTRB(40, 0, 20, 0)),
 //     VBodyText('price', color: Colors.white,),
    ],));
}
Widget hookUpSeat(Seat? seat, bool selected, bool selectableSeat, SeatSize seatSize ) {
  return Padding(
      padding: EdgeInsets.all(cellPadding),
      child: GestureDetector(
        child: _getSeat(seat,selected, seatSize),
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
      ));
  }
}
Widget _getSeat(Seat? seat, bool selected, SeatSize seatSize){
  SeatType seatType = SeatType.occupied;
  if( seat == null ){
    return Container();
  }
  switch (seat!.sCellDescription) {
    case 'Occupied':
      seatType = SeatType.occupied;
      break;
    case 'EmergencySeat':
      seatType = SeatType.emergency;
      break;
    case 'Seat':
      if( seat!.noInfantSeat) {
        seatType = SeatType.availableRestricted;

      } else {
        seatType = SeatType.available;
      }
      if( selected ) seatType = SeatType.selected;
      break;
    default:
      if( seat!.noInfantSeat) {
        seatType = SeatType.availableRestricted;
      } else {
        seatType = SeatType.available;
      }
      if( selected ) seatType = SeatType.selected;
      break;
  }
  return seat2( seat!.sCode,  seatType, seatSize );

}

Widget getSeatplanTitle() {
  Itin flt = gblPnrModel!.pNR.itinerary.itin[gblCurJourney];
  int noFlts = gblPnrModel!.pNR.itinerary.itin.length;
  String outLong = '${flt.airID} ${flt.fltNo} ${flt.depart} to ${flt.arrive} ${getIntlDate('EEE dd MMM', DateTime.parse(flt.depDate + ' ' + flt.depTime))}';
  return   Align( alignment: Alignment.topLeft, child: Padding( padding: EdgeInsets.fromLTRB(10,0,0,0), child:VTitleText(outLong, size: TextSize.large,)));

}

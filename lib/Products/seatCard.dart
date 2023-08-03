


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vmba/Products/productFunctions.dart';
import 'package:vmba/calendar/bookingFunctions.dart';
import 'package:vmba/data/globals.dart';

import '../components/trText.dart';
import '../components/vidButtons.dart';
import '../components/vidCards.dart';
import '../components/vidGraphics.dart';
import '../data/models/models.dart';
import '../data/models/pax.dart';
import '../data/models/pnr.dart';
import '../calendar/calendarFunctions.dart';
import '../mmb/widgets/seatplan.dart';

class SeatCard extends StatefulWidget {

  final void Function(PnrModel pnrModel)? onComplete;
  final void Function(String msg)? onError;
  final NewBooking newBooking;



  // ProductCardState appState = new ProductCardState();
  SeatCard({ this.onComplete, this.onError, required this.newBooking, });
  SeatCardState createState() => SeatCardState();

}

class SeatCardState extends State<SeatCard> {
  String title = '';
  int journeyNo = 0;

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int noFlights = 0;
    if( widget.newBooking != null ) {
      noFlights += widget.newBooking.outboundflight.length;
      if (widget.newBooking.returningflight != null) {
        noFlights += widget.newBooking.returningflight.length;
      }
    } else if (gblPnrModel != null  && gblPnrModel!.pNR != null &&  gblPnrModel!.pNR.itinerary != null ){
      noFlights += gblPnrModel!.pNR.itinerary.itin.length;
/*
      gblPnrModel.pNR.itinerary.itin.forEach((flt) {

      });
*/
    }
    if (noFlights > 0) {
      List <Widget> list = [];
      list.add(Padding(
        padding: EdgeInsets.only(left: 5, right: 5, top: 2, bottom: 2,),
        child: TrText('Select Flight'),));

      for (int i = 0; i < noFlights; i++) {
        list.add(vidLineButton(context, getFlight(i), i, onFltPressed));
      }

      return vidExpanderCard(context, 'Seats', true, Icons.event_seat, list);
    } else {
      return vidCard('Seats', Padding(padding: EdgeInsets.only(
          top: 10, left: 20, right: 3, bottom: 3),
          child: TrText('Seats', textScaleFactor: 1.5,)));
    }
  }


  Widget getFlight(int fltNo) {
    // format like 0FN8340U29Jul22JNBHRENN1/14151555(CAB=Y)[CB=Economy] (n.b. may be 3 or 4 digit flt number
    String flt = '';
    if (fltNo == 0) {
      flt = widget.newBooking.outboundflight.first;
    } else if (fltNo < widget.newBooking.outboundflight.length) {
      flt = widget.newBooking.outboundflight[fltNo];
    } else if (fltNo < (widget.newBooking.outboundflight.length +
        widget.newBooking.returningflight.length)) {
      flt = widget.newBooking.returningflight[fltNo -
          widget.newBooking.outboundflight.length];
    } else {
      return Text('getFlight: Error index out of range ' + fltNo.toString());
    }


    int offsetSep = flt.indexOf('/');

    int airCodeLen = 2;
    int dateLen = 7;
    int classLen = 1;
    int fltNoLen = 4;
    if (offsetSep == 23) {
      fltNoLen = 3;
    }
    int offsetDep = 1 + airCodeLen + dateLen + fltNoLen + classLen;
    String dep = flt.substring(offsetDep, offsetDep + 3);
    String arr = flt.substring(offsetDep + 3, offsetDep + 3 + 3);

    List <String> seats = getSeatsForFlt(fltNo);

    List <Widget> seatLine = [];
    if(seats.length > 0){
      seats.forEach((seat) {
        seatLine.add(
          vidSeatIcon(seat));
      });
      seatLine.add(Spacer());
      seatLine.add(TrText('Change seats'),);
    } else {
      seatLine.add(TrText('Choose your seats'),);
    }
    return Padding(
        padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
        child: Container(width: double.infinity,
            decoration: BoxDecoration(
                border: Border.all(
                    color: Colors.grey.shade200, width: 1)),
            child: Column(
                children: [
                  Row(
                    children: [
                      getAirport(
                          dep, ),
                      Icon(Icons.arrow_right_alt),
                      getAirport(
                          arr, ),
                      Spacer(),
                      Icon(Icons.chevron_right, size: 30,
                        color: gblSystemColors.primaryHeaderColor,),
                    ],),
                  Row(children: seatLine                    ,)
                ]
            ))
    );
  }

  onFltPressed(BuildContext context, int journeyNo) {
    if( gblPnrModel != null ) {
      List<Pax> paxlist = getPaxlist(gblPnrModel as PnrModel, journeyNo);

      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SeatPlanWidget(
                  paxlist: paxlist,
                  isMmb: false,
                  ischeckinOpen: false,
                  seatplan:
                  'ls${gblPnrModel!.pNR.itinerary.itin[journeyNo].airID +
                      gblPnrModel!.pNR.itinerary.itin[journeyNo]
                          .fltNo}/${new DateFormat(
                      'ddMMM').format(DateTime.parse(
                      gblPnrModel!.pNR.itinerary.itin[journeyNo].depDate + ' ' +
                          gblPnrModel!.pNR.itinerary.itin[journeyNo]
                              .depTime))}${gblPnrModel!.pNR
                      .itinerary.itin[journeyNo].depart +
                      gblPnrModel!.pNR.itinerary.itin[journeyNo]
                          .arrive}[CB=${gblPnrModel!.pNR
                      .itinerary.itin[journeyNo].classBand}][CUR=${gblPnrModel!
                      .pNR
                      .fareQuote.fQItin[0].cur}][MMB=True]~x',
                  rloc: gblPnrModel!.pNR.rLOC,
                  journeyNo: journeyNo.toString(),
                  selectedpaxNo: 1,
                ),
          )
      ).then((_) =>
          setState(() {}
          ));
      ;
      // Navigator.of(context).pop();
    }
  }
}
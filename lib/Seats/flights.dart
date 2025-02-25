import 'package:flutter/material.dart';
import 'package:vmba/components/vidButtons.dart';
import 'package:vmba/data/globals.dart';

import '../../../calendar/flightPageUtils.dart';
import '../../../data/models/pnr.dart';
import '../../../v3pages/v3Theme.dart';

enum OutboundOrReturn { outbound,  returning }
int outboundOrReturn = 1;


Widget getFlightSelector(BuildContext context, void Function() onChange){
  String out = '';
  String outLong = '';
  String back = '';
  int noFlts = 0;
  if( gblPnrModel!= null && gblPnrModel!.pNR.itinerary != null && gblPnrModel!.pNR.itinerary.itin.length > 0){
    Itin flt = gblPnrModel!.pNR.itinerary.itin[0];
    noFlts = gblPnrModel!.pNR.itinerary.itin.length;
    out = '${flt.depart} to ${flt.arrive}';
    outLong = '${flt.airID} ${flt.fltNo} ${flt.depart} to ${flt.arrive} ${getIntlDate('EEE dd MMM', DateTime.parse(flt.depDate + ' ' + flt.depTime))}';
    if( gblPnrModel!.pNR.itinerary.itin.length > 1){
      flt = gblPnrModel!.pNR.itinerary.itin[1];
      back = '${flt.depart} to ${flt.arrive}';
    }
  }

  if( noFlts > 1 ) {
    List<ButtonSegment<int>> list = [];
    int index = 1;
    gblPnrModel!.pNR.itinerary.itin.forEach((flt) {
      String route = '${flt.depart}:${flt.arrive}';
      list.add(ButtonSegment(
          value: index,
          label: VBodyText(route,
            color: outboundOrReturn == index
                ? Colors.white
                : Colors.black,
          size: noFlts > 2 ? TextSize.large : TextSize.medium),
          icon: Icon(Icons.add, size: 1, color: Colors.transparent,)
      ));
      index ++;
    });
/*
    list.add(
      ButtonSegment<int>(
          value: 2,
          label: VTitleText(back,
            color: outboundOrReturn == 2
                ? Colors.white
                : Colors.black,),
          icon: Icon(Icons.add, size: 1, color: Colors.transparent,)
      ));
*/

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SegmentedButton<int>(
            selectedIcon: Icon(Icons.add, size: 0,),
            segments: list,
            selected: <int>{outboundOrReturn},
            onSelectionChanged: (newSelection) {
//      setState(() {
              // By default there is only a single segment that can be
              // selected at one time, so its value is always the first
              // item in the selected set.
              //calendarView = newSelection.first;
              //    });
              int ab = 1;
              gblLoadSeatState = VrsCmdState.loading;
              gblCurJourney = newSelection.first -1;
              outboundOrReturn = newSelection.first;
              onChange();
            },
            style: SegmentedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black,
              selectedForegroundColor: Colors.white,
              selectedBackgroundColor: Colors.black,
              padding: noFlts > 2 ?  EdgeInsets.fromLTRB(0, 0, 5, 0) :  EdgeInsets.fromLTRB(10, 0, 15, 0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0),)),
            ),
          ),
          vidTextButton(context, 'Skip', ({p1, p2, p3}) {})
        ]
    );
  } else {
    // single
    return  Align( alignment: Alignment.topLeft, child: VTitleText(outLong, size: TextSize.large,));
  }

}
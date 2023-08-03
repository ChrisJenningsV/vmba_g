import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/summary/vidTimeLine.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/data/models/models.dart';

import '../Products/productFunctions.dart';
import '../calendar/flightPageUtils.dart';
import '../components/vidTextFormatting.dart';
import '../data/models/availability.dart';
import '../utilities/helper.dart';


class TimelineDelivery extends StatelessWidget {
  TimelineDelivery({Key key= const Key("timedel_key"), required this.newBooking,required  this.isReturn}) : super(key: key);

  final NewBooking newBooking;
  final bool isReturn;
  Color lineClr = Colors.grey.shade300;

  TextStyle tStyle = TextStyle(
      color: gblSystemColors.headerTextColor, fontWeight: FontWeight.bold);

  @override
  Widget build(BuildContext context) {
    //String code = newBooking.departure;
    //String time = newBooking.outboundflts.first.time.dtimlcl;
/*
    String fltNo = newBooking.outboundflts.first.fltdet.airid +
        newBooking.outboundflts.first.fltdet.fltno;
*/
    String className = newBooking.outboundClass;

    if (isReturn) {
/*
      code = newBooking.arrival;
      time = newBooking.returningflts.first.time.dtimlcl;
      fltNo = newBooking.returningflts.first.fltdet.airid +
          newBooking.returningflts.first.fltdet.fltno;
*/
      className = newBooking.returningClass;
    }
    if (!className.contains(translate('Class'))) {
      className += ' ' + translate('Class');
    }

    List<Widget> tileList = [];
    List <Flt> thisFlts = [];

    if (isReturn == false) {
      thisFlts = newBooking.outboundflts;
    } else {
      thisFlts = newBooking.returningflts;
    }
      int index = 1;
      thisFlts.forEach((flt) {
        tileList.add(startTile(flt, className));
        tileList.add(endTile(flt));

        if( index < thisFlts.length) {
          //DateTime ttime = flt.time.
          DateTime a1 = DateTime.parse(flt.time.adaygmt + ' ' + flt.time.atimgmt);
          DateTime d1 = DateTime.parse(thisFlts[index].time.ddaygmt + ' ' + thisFlts[index].time.dtimgmt);
          int diff = d1.difference(a1).inMinutes;

          tileList.add(transferTile(diff));
        }
        index+=1;
      });

    return Container(
        transform: Matrix4.translationValues(0.0, -10, 0.0),
        decoration: const BoxDecoration(
          color: Color(0xFFF9F9F9),
          border: Border(
            bottom: BorderSide(
              color: Color(0xFFE9E9E9),
              width: 2,
            ),
          ),
        ),
/*
        child: ListView(shrinkWrap: true,

            children: tileList
         ));
*/
        child: Column(
            children: tileList
        ));
  }

  Widget startTile(Flt flt, String className) {
    return VidTimelineTile(
      key: const Key('starttime_key'),
      alignment: VidTimelineAlign.manual,
      lineXY: 0.1,
      isFirst: true,
      indicatorStyle: IndicatorStyle(
        width: 30,
        color: lineClr,
        padding: EdgeInsets.all(1),
        iconStyle: IconStyle(iconData: Icons.flight_takeoff, fontSize: 20),
      ),
      endChild: _RightChild(
        // asset: 'assets/delivery/order_placed.png',
        title: _airportNameTime(flt.time.dtimlcl, flt.dep, tStyle),
        message: getIntlDate('EEE dd MMM yyyy', DateTime.parse(flt.time.ddaylcl)),
        // getIntlDate('EEE dd MMM yyyy',
        message2: flt.fltdet.airid + flt.fltdet.fltno,
        message3: className,

        first: true,
      ),
      beforeLineStyle: LineStyle(
        color: lineClr,
      ),
    );
  }

  Widget transferTile(int tt) {
    String tranTime = getDuration(tt);
    return Row( children: [
        SizedBox(width: 40,),
        Icon(Icons.directions_walk , color: Colors.grey,),
        Text(translate('Transfer time') +': ' + tranTime,)
    ],);


  }

  Widget endTile(Flt flt) {
    return VidTimelineTile(
      alignment: VidTimelineAlign.manual,
      lineXY: 0.1,
      isLast: true,
      height: 35,
      indicatorStyle: IndicatorStyle(
        width: 30,
        color: lineClr,
        iconStyle: IconStyle(iconData: Icons.flight_land, fontSize: 20),
        padding: EdgeInsets.all(1),
      ),
      endChild: _RightChild(
        disabled: true,
        //  asset: 'assets/delivery/ready_to_pickup.png',
        title: _airportNameTime(flt.time.atimlcl, flt.arr , tStyle),
        // message: 'Your order is ready for pickup.',
      ),
      beforeLineStyle: LineStyle(
        color: lineClr,
      ),
    );
  }

  Widget _airportNameTime(String time, String code, TextStyle tStyle) {
    //  return Text(code);
    return getH2Text(time.substring(0, 5) + ' ' + cityCodetoAirport(code));
   /* return FutureBuilder(
      future: cityCodeToName(
        code,
      ),
      initialData: code.toString(),
      builder: (BuildContext context, AsyncSnapshot<String> text) {
        String longName = code;
        if (text.data != null && text.data!.length > 0) {
          longName = text.data!;
        }
        return getH2Text(time.substring(0, 5) + ' ' + longName);

      },
    );*/
  }
}

class _RightChild extends StatelessWidget {
  const _RightChild({
    Key key= const Key("right_key"),
//    this.asset,
    required this.title,
    this.message = '',
    this.message2 = '',
    this.message3 = '',
    this.first = true,
    this.disabled = false,
  }) : super(key: key);

//  final String asset;
  final Widget title;
  final String message;
  final String message2;
  final String message3;
  final bool disabled;
  final bool first;

  @override
  Widget build(BuildContext context) {
    List<Widget> list = [];

    list.add(title);
    list.add(const SizedBox(height: 6));
    if (message != null) {
      list.add(Text(
        message,
      ));
    }

    if (message2 != null) {
      list.add(Text(message2));
    }
    if (message3 != null) {
      list.add(Text(message3));
    }
    EdgeInsetsGeometry pad =
        EdgeInsets.only(left: 16, right: 16, top: 2, bottom: 1);
    if (first != null && first) {
      // fiddle to line
      pad = EdgeInsets.only(left: 16, right: 5, top: 25, bottom: 1);
    }

    return Padding(
      padding: pad,
      child: Row(
        children: <Widget>[
          //         const SizedBox(width: 16),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                title,
                (message == null) ? Container() : Text(message),
                (message2 == null) ? Container() : Text(message2),
                (message3 == null) ? Container() : Text(message3),
              ]),
        ],
      ),
    );
  }
}

class TimelineHeader extends StatelessWidget {
  final String title;
  final String duration;

  TimelineHeader({this.title = '', this.duration = ''});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      decoration: const BoxDecoration(
        color: Color(0xFFF9F9F9),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE9E9E9),
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: <Widget>[
            Column(
              children: <Widget>[
                Text(
                  title,
                  textScaleFactor: 1.5,
                ),
                Text( translate('Travel time') + ' ' +
                  duration,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

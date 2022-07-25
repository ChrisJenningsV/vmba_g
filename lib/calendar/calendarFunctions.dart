
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vmba/data/globals.dart';

import '../components/trText.dart';
import '../data/models/availability.dart';
import '../utilities/helper.dart';
import 'flightPageUtils.dart';


Widget flightRow(Itin item) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          getDate(item.flt[0].time.ddaylcl),
          getTime(item.flt.first.time.dtimlcl),
          getAirport(item.flt.first.dep),
 /*         FutureBuilder(
            future: cityCodeToName(
              item.flt.first.dep,
            ),
            initialData: item.flt.first.dep.toString(),
            builder: (BuildContext context,
                AsyncSnapshot<String> text) {
              return TrText(text.data,
                  style: new TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w300),
                  variety: 'airport', noTrans: true);
            },
          ),
*/        ],
      ),
      Column(children: [
        new RotatedBox(
            quarterTurns: 1,
            child: new Icon(
              Icons.airplanemode_active,
              size: 60.0,
            ))
      ]),
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          getDate(item.flt.last.time.adaylcl),
          getTime(item.flt.last.time.atimlcl),
          getAirport(item.flt.last.arr),
/*
          new Text(
              item.flt.last.time.atimlcl
                  .substring(0, 5)
                  .replaceAll(':', ''),
              style: new TextStyle(
                  fontSize: 30.0,
                  fontWeight: FontWeight.w700)),
*/
/*          FutureBuilder(
            future: cityCodeToName(
              item.flt.last.arr,
            ),
            initialData: item.flt.last.arr.toString(),
            builder: (BuildContext context,
                AsyncSnapshot<String> text) {
              return new TrText(text.data,
                style: new TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w300),
                variety: 'airport', noTrans: true,);
            },
          ),*/
        ],
      )
    ],
  );
}

Widget getDate(String dt){
  return Text(getIntlDate(
      'EEE dd MMM', DateTime.parse(dt)),

      style: new TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w300));
}

Widget getTime(String tm) {
  String formattedTm = tm.substring(0, 5);
  if( gblSettings.avTimeFormat.contains(':'))
    {

    } else {
    formattedTm = formattedTm.replaceAll(':', '');
  }
  return  Text( formattedTm          ,
      style: new TextStyle(
          fontSize: 36.0,
          fontWeight: FontWeight.w700));
}

Widget getAirport(String code) {
  return FutureBuilder(
    future: cityCodeToName(
      code,
    ),
    initialData: code.toString(),
    builder: (BuildContext context,
        AsyncSnapshot<String> text) {
      return TrText(text.data,
          style: new TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w300),
          variety: 'airport', noTrans: true);
    },
  );

}

Widget infoRow(BuildContext context, Itin item ) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Column(children: [
        Row(
          children: <Widget>[
            Icon(Icons.timer),
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(item.journeyDuration()),
            )
          ],
        )
      ]),
      Column(children: [
        Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(item.flt[0].fltdet.airid + item.flt[0].fltdet.fltno),
            )
          ],
        )
      ]),
      Column(
        children: <Widget>[
          item.flt.length > 1
              ? GestureDetector(
            onTap: () => showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                    actions: <Widget>[
                      new TextButton(
                        child: new Text("OK"),
                        onPressed: () {
                          Navigator.of(context)
                              .pop();
                        },
                      ),
                    ],
                    title: new TrText('Connections'),
                    content: Column(
                        mainAxisSize:
                        MainAxisSize.min,
                        children: (item.flt.map(
                              (f) => Container(
                            child: Row(
                              children: <Widget>[
                                Text(f.dep),
                                Padding(
                                  padding:
                                  const EdgeInsets
                                      .all(4.0),
                                  child: Text(DateFormat(
                                      'kk:mm')
                                      .format(DateTime.parse(f
                                      .time
                                      .ddaylcl +
                                      ' ' +
                                      f.time
                                          .dtimlcl))
                                      .toString()),
                                ),
                                Padding(
                                  padding:
                                  const EdgeInsets
                                      .all(4.0),
                                  child:
                                  new RotatedBox(
                                      quarterTurns:
                                      1,
                                      child:
                                      new Icon(
                                        Icons
                                            .airplanemode_active,
                                        size:
                                        20.0,
                                      )),
                                ),
                                Padding(
                                  padding:
                                  const EdgeInsets
                                      .all(4.0),
                                  child:
                                  Text(f.arr),
                                ),
                                Text(DateFormat(
                                    'kk:mm')
                                    .format(DateTime.parse(f
                                    .time
                                    .ddaylcl +
                                    ' ' +
                                    f.time
                                        .atimlcl))
                                    .toString()),
                              ],
                            ),
                          ),
                        )).toList()));
              },
            ),
            child: Row(
              children: <Widget>[
                new Text(
                  item.flt.length == 2
                      ? '${item.flt.length - 1} connection'
                      : '${item.flt.length - 1} connections',
                  style: new TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w300),
                ),
                new Icon(Icons.expand_more),
              ],
            ),
          )
              : TrText('Direct Flight'),
        ],
      )
    ],
  );

}
Widget noFlightsFound(){
  return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Sorry no flights found',
            style: TextStyle(fontSize: 14.0),
          ),
          Text(
            'Try search for a different date',
            style: TextStyle(fontSize: 14.0),
          ),
        ],
      ));
}
Widget getCalDay(Day item, String action, DateTime date, {void Function() onPressed} ) {
  return Container(
    decoration: new BoxDecoration(
        border: new Border.all(color: Colors.black12),
        color: !isSearchDate(DateTime.parse(item.daylcl),
            date)
            ? Colors.white
            : gblSystemColors.accentButtonColor //Colors.red,
    ),
    width: DateTime.parse(item.daylcl).isBefore(DateTime.parse(DateFormat('y-MM-dd').format(DateTime.now().toUtc())))
        ? 0
        : 120.0,
    child: new TextButton(
        onPressed: onPressed,
        child: new Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Text( getIntlDate('EEE dd', DateTime.parse(item.daylcl)),
                //new DateFormat('EEE dd').format(DateTime.parse(item.daylcl)),
                style: TextStyle(
                    fontSize: 14,
                    color: isSearchDate(
                        DateTime.parse(item.daylcl),
                        date)
                        ? Colors.white
                        : Colors.black),
              ),
              new TrText(
                'from',
                //textScaleFactor: 1.0,
                style: TextStyle(
                    fontSize: 14,
                    color: isSearchDate(
                        DateTime.parse(item.daylcl),
                        date)
                        ? Colors.white
                        : Colors.black),
              ),
              //new Text(item.cur + item.amt)
              new Text(
                calenderPrice(item.cur, item.amt, item.miles),
                //textScaleFactor: 1.0,
                style: TextStyle(
                    fontSize: 14,
                    color: isSearchDate(
                        DateTime.parse(item.daylcl),
                        date)
                        ? Colors.white
                        : Colors.black),
              ),
            ])),
  );

}
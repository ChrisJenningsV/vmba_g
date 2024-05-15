import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vmba/Helpers/settingsHelper.dart';
import 'package:vmba/calendar/widgets/cannedFact.dart';
import 'package:vmba/components/vidGraphics.dart';
import 'package:vmba/data/globals.dart';

import '../chooseFlight/chooseFlightPage.dart';
import '../components/pageStyleV2.dart';
import '../components/trText.dart';
import '../data/models/availability.dart';
import '../data/models/models.dart';
import '../utilities/helper.dart';
import '../v3pages/v3CalendarObects.dart';
import 'flightPageUtils.dart';

class CalFlightItemWidget extends StatefulWidget {
  final void Function(BuildContext context,AvItin? avItem, List<String> flt, List<Flt> outboundflts, String className)? flightSelected;

  CalFlightItemWidget({Key key= const Key("cal_key"),this.newBooking, this.objAv, this.item, this.flightSelected, this.seatCount = 0})
      : super(key: key);
  final NewBooking? newBooking;
  final AvailabilityModel? objAv;
  final AvItin? item;
  final int seatCount;
  //void flightSelected(List<String> list, List<Flt> flts, String class);


  _CalFlightItemWidgetState createState() => _CalFlightItemWidgetState();
}

class _CalFlightItemWidgetState extends State<CalFlightItemWidget> {

  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return calFlightItem(context, widget.newBooking, widget.objAv, widget.item);
  }

  void goToClassScreen(BuildContext context,NewBooking newBooking, AvailabilityModel objAv, int index, List<Flt> flts,AvItin? avItem) async {
    gblActionBtnDisabled = false;
    double pri = 0.0;
    String currency='';
    flts.forEach((element) {
      if(element.fltav.discprice != null  && element.fltav.discprice!.length > index &&
          element.fltav.discprice![index].isNotEmpty && element.fltav.discprice![index] != '0'){
        pri += double.tryParse(element.fltav.discprice![index]) as double;
      } else {
        pri += double.tryParse(element.fltav.pri![index] ) as double;
      }
      currency = element.fltav.cur![index];
    });

    Band? b;
    String cbName ='';
    if( objAv.availability.classbands != null ){
      Classbands cb = objAv.availability.classbands as Classbands;
      if( cb.band != null ){
        b = cb.band![index];
        cbName = b.cbname;
      }

    }
    var selectedFlt = await Navigator.push(
        context,
        SlideTopRoute(
            page: ChooseFlight(
              classband: b,
              flts: flts, //objAv.availability.itin[0].flt,
              price: pri,
              currency: currency,
              seats: widget.seatCount,
            )));
    widget.flightSelected!(context,avItem,  selectedFlt, flts, cbName);
  }



  Widget pricebuttons(BuildContext context, NewBooking newBooking,AvailabilityModel objAv, List<Flt> item,AvItin? avItem) {
    EdgeInsets pad = EdgeInsets.symmetric(vertical: 5,horizontal: 15);
    if( wantRtl()){
      pad = EdgeInsets.symmetric(vertical: 5,horizontal: 10);
    }
    if (item[0].fltav.pri!.length > 3) {

      return Container(
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            //color: Colors.grey,
              border: Border(top: BorderSide(color: v2BorderColor(), width: v2BorderWidth()),
              )),
          child: Wrap(

              spacing: 8.0, //gap between adjacent chips
              runSpacing: 4.0, // gap between lines
              children: new List.generate(
                  item[0].fltav.pri!.length,
                      (index) => GestureDetector(
                      onTap: () => {
                        isJourneyAvailableForCb(item, index)
                            ? goToClassScreen(context, newBooking, objAv, index, item, avItem)
                            : print('No av')
                      },
                      child: wantPageV2() ?
                          Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                            color: index.floor().isOdd ? gblSystemColors.accentColor :gblSystemColors.primaryButtonColor,
                            child: Container(
                              width: 100,
                              padding: EdgeInsets.all(5),
                             child: Column(
                              children: getPriceButtonList(objAv.availability.classbands?.band![index].cbdisplayname, item, index, inRow: false),

                            )),
                          )
                          :
                       Chip(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))),
                        padding: pad,
                        backgroundColor:
                        index.floor().isOdd ? gblSystemColors.accentColor :gblSystemColors.primaryButtonColor,
                        label: Column(
                          children: getPriceButtonList(objAv.availability.classbands?.band![index].cbdisplayname, item, index, inRow: false),

                        ),
                      )))
          )
      );
    } else {
      MainAxisAlignment _mainAxisAlignment = MainAxisAlignment.spaceAround;
      if (item[0].fltav.pri?.length == 2) {
        _mainAxisAlignment = MainAxisAlignment.spaceAround;
      } else if (item[0].fltav.pri?.length == 3) {
        _mainAxisAlignment = MainAxisAlignment.spaceBetween;
      }
      return Container(
          padding: EdgeInsets.only(left: 10, right: 10, top: 5),
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            //color: Colors.grey,
              border: Border(top: BorderSide(color: v2BorderColor(), width: v2BorderWidth()),
              )),

          child: Row(
              mainAxisAlignment: _mainAxisAlignment,
              children: new List.generate(
                item[0].fltav.pri!.length,
                    (index) => ElevatedButton(
                    onPressed: () {
                      isJourneyAvailableForCb(item, index)
                          ? goToClassScreen(context,newBooking,objAv, index, item, avItem)
                          : print('No av');
                    },
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(5.0))), //RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                        foregroundColor:
                        gblSystemColors.primaryButtonColor,
                        padding: pad ), //new EdgeInsets.all(5.0)),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: new Column(
//                        children: _getPriceButtonList(objAv.availability.classbands.band[index].cbdisplayname, item, index)
                          children: getPriceButtonList(objAv.availability.classbands?.band![index].cbdisplayname, item, index, inRow: false),

                      ),
                    )),
              )
          )
      );
    }
  }
/*


  List<Widget> _getPriceButtonList(String cbName, List<Flt> flts, int index){
    String cur = flts[0].fltav.cur[index];
    String miles = flts[0].fltav.miles[index];
    List<Widget> list = [];

//    if( cbName == 'Fly Flex Plus') cbName = 'Fly Flex +';


    list.add(getClassNameRow(cbName));
*/
/*
      new Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children:
        <Widget>[
        new TrText(cbName,
        style: new TextStyle(
          color: gblSystemColors
              .primaryButtonTextColor,
          fontSize: 16.0,
        ),
      )
      ])
    );
*/
/*


    if( flts[0].fltav.fav[index] == '0') {
      list.add(getNoSeatsRow());
    } else {
      list.add(new Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              calenderPrice(
                  cur,
                  flts.fold(0.0,
                          (previous, current) =>
                      previous +
                          (double.tryParse(current
                              .fltav.pri[index]) ??
                              0.0) +
                          (double.tryParse(current
                              .fltav.tax[index]) ??
                              0.0))
                      .toStringAsFixed(2),
                  miles),
              style: new TextStyle(
                color: gblSystemColors.primaryButtonTextColor, fontSize: 12.0,),
            )
          ]
      )
      );
    }

    return list;
  }

*/

  Widget calFlightItem(BuildContext context,NewBooking? newBooking, AvailabilityModel? objAv, AvItin? item) {
    List <Widget> topList = [];
    List <Widget> innerList = [];

    innerList.add(flightRow(context, item));

    if(gblSettings.wantCanFacs && item!.flt.first.fltdet.canfac?.fac.isNotEmpty != null) {
      innerList.add(Divider());
      innerList.add(CannedFactWidget(flt: item.flt));
    }
    if(! wantPageV2()){
      innerList.add(infoRow(context, item!));
    }

    if(! wantPageV2()) {
      topList.add(flightTopRow(item!));
    }
    topList.add(Container(
      // margin: EdgeInsets.only(top: 10, bottom: 10.0, left: 5, right: 5),
        padding: EdgeInsets.all(10),
        child: Column(
          children: innerList,
        )
    ));
    //new Divider(),

    topList.add(pricebuttons(context, newBooking as NewBooking,objAv as AvailabilityModel, item!.flt, item));

    if(! wantPageV2()) {
      return Container(
        decoration: BoxDecoration(
            border: Border.all(color: v2BorderColor(), width: v2BorderWidth()),
            borderRadius: BorderRadius.all(
                Radius.circular(15.0)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 3,
                blurRadius: 3,
                offset: Offset(0, 4), // changes position of shadow
              ),
            ]

        ),

        margin: EdgeInsets.only(top: 10, bottom: 10.0, left: 5, right: 5),
        padding: EdgeInsets.only(
            left: 0, right: 0, bottom: 8.0, top: 8.0),
        child: Column(
            children: topList
        ),
      );
    }
    return Padding(padding: EdgeInsets.only(top:2, left: 3, right: 3, bottom: 0),
    child: Card(
      child: Column(
          children: [
            // add title
            flightTopRowV2(item!),
            // add content
        Card(
            color: Colors.white,
            elevation: 0,
            child: Column(children:topList,),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)))

        )
            ,
          ]
      ),
      color: Colors.grey.shade200,
      elevation: 3,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)))
      ),

    );
  }

}


















Widget flightTopRow(AvItin item)
{
  return Container(
    padding: EdgeInsets.only(top: 2, bottom: 2, left: 10, right: 0),
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: v2BorderColor(), width: v2BorderWidth()),
    )
    ),
      child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(translate('Flight No:') + ' ' + item.flt[0].fltdet.airid + item.flt[0].fltdet.fltno),
        Padding(padding: EdgeInsets.all(2)),
        (item.flt[0].fltdet.airid == gblSettings.aircode) ?
        Padding(padding: EdgeInsets.only(right: 4), child: Image.asset('lib/assets/$gblAppTitle/images/logo.png', height: 30,))
            :Container(),
        ]
    ),
  );
}
Widget flightTopRowV2(AvItin item)
{
  return Container(
    padding: EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 0),
    child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(translate('Flight No:') + ' ' + item.flt[0].fltdet.airid + item.flt[0].fltdet.fltno, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),),
          Padding(padding: EdgeInsets.all(2)),
          (item.flt[0].fltdet.airid == gblSettings.aircode) ?
          Padding(padding: EdgeInsets.only(right: 4), child: Image.asset('lib/assets/$gblAppTitle/images/logo.png', height: 30,))
              :Container(),
        ]
    ),
  );
}

Widget v2FlightRow(String dDay,String  dTime,String  departs,String dTerm, String aDay,String  aTime,String  arrives,String aTerm, String journeyDuration,
    BuildContext context, AvItin item) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: <Widget>[
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          getDate(dDay),
          getTime(dTime),
          getAirport(departs),
          getTerminal(dTerm, true),
        ],
      ),
      Column(children: [
        new Stack( children:
        [
          FlightLine(),
          Container(
              color: Colors.white,
              margin: EdgeInsets.only(left: 40),
              width: 40,
              child: Padding(
                  padding: EdgeInsets.only(left: 40, right: 10),
                  child: RotatedBox(
                      quarterTurns: 1,
                      child: new Icon(
                        Icons.airplanemode_active,
                        size: 40.0,
                      ))
              )),
        ]),
        Text(journeyDuration),
        getConnections(context, item),
      ]),
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          getDate(aDay),
          getTime(aTime),
          getAirport(arrives),
          getTerminal(aTerm, false),
        ],
      )
    ],
  );
}


Widget flightRow(BuildContext context, AvItin? item) {
  if( wantPageV2()){
    return v2FlightRow(item!.flt[0].time.ddaylcl, item.flt.first.time.dtimlcl, item.flt.first.dep, getTerminalString(item.flt.first, true),
        item.flt.last.time.adaylcl, item.flt.last.time.atimlcl, item.flt.last.arr, getTerminalString(item.flt.last, false),
        item.journeyDuration(), context, item);

  } else {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            getDate(item?.flt[0].time.ddaylcl as String),
            getTime(item?.flt.first.time.dtimlcl as String),
            getAirport(item?.flt.first.dep as String),
            getTerminal(getTerminalString(item?.flt.first  as Flt, true), true),
          ],
        ),
        Column(children: [
          new RotatedBox(
              quarterTurns: 1,
              child: new Icon(
                Icons.airplanemode_active,
                size: 60.0,
              )),
        ]),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            getDate(item?.flt.last.time.adaylcl  as String),
            getTime(item?.flt.last.time.atimlcl as String),
            getAirport(item?.flt.last.arr as String),
            getTerminal(getTerminalString(item?.flt.first as Flt, false), false),
          ],
        )
      ],
    );
  }
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
  if( wantRtl()) {

    return Text(getIntlDate('HHmm', DateTime.parse('2022-11-12 ' + tm)),
        style: new TextStyle(
            fontSize: 36.0,
            fontWeight: FontWeight.w700));

  } else {
    return Text(formattedTm,
        style: new TextStyle(
            fontSize: 36.0,
            fontWeight: FontWeight.w700));
  }
}

Widget getAirport(String code, {double fontSize=16, FontWeight fontWeight=FontWeight.normal}) {
  if( fontSize == null ) fontSize = 16;
  if( fontWeight == null ) fontWeight =  FontWeight.w300;

  return Text(cityCodetoAirport(code),
      style: new TextStyle(fontSize: fontSize,fontWeight: fontWeight)
  );

/*

  return FutureBuilder(
    future: cityCodeToName(
      code,
    ),
    initialData: code.toString(),
    builder: (BuildContext context,
        AsyncSnapshot<String> text) {
      logit('getairport $code');
      String acode = code;
      if( text.data != null ) {
        logit('getairport text ${text.data}');
        acode = text.data!;
        }
      logit('getairport T ${translate(acode )}');
        return TrText(translate(acode ),
            style: new TextStyle(
                fontSize: fontSize,
                fontWeight: fontWeight),
            variety: 'airport', noTrans: true);
      }
  );
*/

}

String getTerminalString(Flt flt, bool depart){
  if( gblSettings.wantTerminal == false ) return '';
  if( depart == true &&  (flt.fltdet.depterm == null || flt.fltdet.depterm.isEmpty) ) return '';
  if( depart == false &&  (flt.fltdet.arrterm == null || flt.fltdet.arrterm.isEmpty)) return '';

  return  depart ? flt.fltdet.depterm : flt.fltdet.arrterm;
}


Widget getTerminal(String term, bool depart){
/*
  if( gblSettings.wantTerminal == false ) return Container();
  if( depart == true &&  (flt.fltdet.depterm == null || flt.fltdet.depterm.isEmpty) ) return Container();
  if( depart == false &&  (flt.fltdet.arrterm == null || flt.fltdet.arrterm.isEmpty)) return Container();
*/
  if( term == ''){
    return Container();
  }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
          TrText('Terminal'),
          Padding(padding: EdgeInsets.only(left: 10)),
          Text( term, textScaleFactor: 1.5,),
        ]);
}


Widget infoRow(BuildContext context, AvItin item ) {
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
          getConnections(context, item),
        ],
      )
    ],
  );
}
Widget getConnections(BuildContext context, AvItin item) {
  if( item == null || context == null ) return Container();
  if (item.flt.length > 1) {
    return GestureDetector(
      onTap: () =>
          showDialog(
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
                            (f) =>
                            Container(
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
    );
  } else {
    return   TrText(  'Direct Flight' );
}

}


Widget noFlightsFound(){
  return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          TrText(
            'Sorry no flights found',
            style: TextStyle(fontSize: 14.0),
          ),
          TrText(
            'Try search for a different date',
            style: TextStyle(fontSize: 14.0),
          ),
        ],
      ));
}
Widget getCalDay(Day item, String action, DateTime selectedDate, DateTime hideBeforeDate, {void Function()? onPressed} ) {
  List <Widget> list = [];
  bool showNoFlightIcon = false;
  if( gblRedeemingAirmiles== false && item.amt.length == 0 ){
    if( wantPageV2()) {
      showNoFlightIcon = true;
    }
  }
  Color? txtColor = Colors.black;
  if( isSearchDate(
      DateTime.parse(item.daylcl),
      selectedDate)){
    txtColor = Colors.white;
  }
  if( wantPageV2()) {
    txtColor = Colors.black;
      if( isSearchDate(DateTime.parse(item.daylcl),
          selectedDate)) {
        txtColor = gblSystemColors.headerTextColor;

      }
  }

    list.add( getCalDate(item.daylcl, txtColor),
      //new DateFormat('EEE dd').format(DateTime.parse(item.daylcl)),
    );

    if( wantPageV2()) {
      txtColor = Colors.grey;
      if(isSearchDate(DateTime.parse(item.daylcl),
          selectedDate)) {
        txtColor = Colors.black;
      }
    }
      if( showNoFlightIcon ){
        list.add(vidNoFlights());
      } else {
        list.add(TrText('from', style: TextStyle(fontSize: 14,
            color: txtColor),
        ));

        list.add(Text(
          calenderPrice(item.cur, item.amt, item.miles),
          //textScaleFactor: 1.0,
          textScaler: TextScaler.linear(1.2),
          style: TextStyle(
              //fontSize: 14,
              color: txtColor),
        ));
      }
      if( wantPageV2()){
        if( showNoFlightIcon ) {
          return v3CalendarDay(item,selectedDate,vidNoFlights(), null, onPressed);

        } else {
          return v3CalendarDay(item,selectedDate,
              TrText('from', style: TextStyle(fontSize: 14,color: txtColor)),
              Text(
                calenderPrice(item.cur, item.amt, item.miles),
                //textScaleFactor: 1.0,
                style: TextStyle(
                    fontSize: 14,
                    color: txtColor),
              ),
              onPressed
          );
        }
      }

      if( wantRtl()) {
        return SingleChildScrollView(
            child: Container(
              decoration: new BoxDecoration(
                  border: new Border.all(color: Colors.black12),
                  color: !isSearchDate(DateTime.parse(item.daylcl),
                      selectedDate)
                      ? Colors.white
                      : gblSystemColors.accentButtonColor //Colors.red,
              ),
              width: DateTime.parse(item.daylcl).isBefore(hideBeforeDate)
                  ? 0
                  : 120.0,
              child: new TextButton(
                  onPressed: onPressed,
                  child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: list)),
            ));
      } else {
        Decoration dec = new BoxDecoration(
            border: new Border.all(color: Colors.black12),
            color: !isSearchDate(DateTime.parse(item.daylcl),
                selectedDate)
                ? Colors.white
                : gblSystemColors.accentButtonColor //Colors.red,
        );
        EdgeInsets marg = EdgeInsets.all(0);
        if( wantPageV2()) {
          if( isSearchDate(DateTime.parse(item.daylcl),
              selectedDate)) {
            dec = containerDecoration(location: 'selected') as Decoration;
          } else {
            dec = containerDecoration(location: 'day') as Decoration;
          }
          marg = containerMargins(location: 'day') ;
        }


        return Container(
          decoration: dec,
          margin: marg,
          width: DateTime.parse(item.daylcl).isBefore(hideBeforeDate)
              ? 0
              : 120.0,
          child: new TextButton(
              onPressed: onPressed,
              child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: list)),
        );
      }
    }





/*

void flightSelected(BuildContext context, NewBooking newBooking, List<String> flt, List<Flt> outboundflts, String className) {
  if (flt != null) {
    print(flt);
    if (flt != null && flt.length > 0) {
      newBooking.outboundflight = flt;
      newBooking.outboundflts = outboundflts;
      newBooking.outboundClass = className;
    }

    hasDataConnection().then((result) async {
      if (result == true) {
        if (newBooking.isReturn &&
            newBooking.outboundflight[0] != null) {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ReturnFlightSeletionPage(
                    newBooking: newBooking,
                    outboundFlight: outboundflts.last,
                  )));
        } else if (newBooking.outboundflight[0] != null) {

          if( gblSettings.wantProducts) {
            // first save new booking
            gblError = '';
            PnrModel pnrModel = await searchSaveBooking(
                newBooking);
            gblPnrModel = pnrModel;
            refreshStatusBar();
            // go to options page
            if (gblError != '') {

            } else {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => PassengerDetailsWidget(
                        newBooking: newBooking,
                        pnrModel:  pnrModel,)));


            }

          } else {

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        FlightSelectionSummaryWidget(
                            newBooking: newBooking)));
          }
        }
      } else {
        //showSnackBar(translate('Please, check your internet connection'));
        noInternetSnackBar(context);
      }
    });
  }
}

*/
Widget getClassNameRow( String cbName, {bool inRow = true}){
  if( cbName == 'Fly Flex Plus') cbName = 'Fly Flex +';
  if( inRow ) {
    return new Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children:
        <Widget>[
          new TrText(cbName,
            style: new TextStyle(
              color: gblSystemColors
                  .primaryButtonTextColor,
              fontSize: 16.0,
            ),
          )
        ]);
  } else {
    return TrText(cbName,
      style: new TextStyle(
        color: gblSystemColors
            .primaryButtonTextColor,
        fontSize: 16.0,
      ),
    );
  }
}
Widget getNoSeatsRow() {
  return TrText('No Seats',
      style: new TextStyle(
        color: gblSystemColors
            .primaryButtonTextColor,
        fontSize: 12.0,
      ));
}
Widget getPriceRow(List<Flt> item, int index){
  double val = 0.0;

  item.forEach((element) {
    String newStr = element.fltav.pri![index];
    double? newVal = double.tryParse(newStr)  ;
    if( newVal != null )    val +=  newVal as double;
    newVal = double.tryParse(element.fltav.tax![index]);
    if( newVal != null )    val +=  newVal as double;
  });

  return new Text(calenderPrice(item[0].fltav.cur![index], val.toStringAsFixed(2), item[0].fltav.miles![index]),
    style: new TextStyle(
      color: gblSystemColors
          .primaryButtonTextColor,
      fontSize: 12.0,
    ),);

 /* return  new Text(
    calenderPrice(
        item[0].fltav.cur[index],
        item
            .fold(
            0.0,
                (previous , current) =>
            previous  +
                (double.tryParse(current
                    .fltav.pri[index]) ??
                    '0.0')  +
                (double.tryParse(current
                    .fltav.tax[index]) ??
                    '0.0')  )
            .toStringAsFixed(2),
        item[0].fltav.miles[index]),
    style: new TextStyle(
      color: gblSystemColors
          .primaryButtonTextColor,
      fontSize: 12.0,
    ),
  );*/
}

Widget getPromoPriceRow(List<Flt> item, int index){
  double pri = 0.0;
  item.forEach((element) {
    if(element.fltav.discprice != null  && (element.fltav.discprice?.length as int) > index &&
        (element.fltav.discprice?[index].isNotEmpty != null) && element.fltav.discprice![index] != '0'){
      pri += double.tryParse(element.fltav.discprice![index]) as double;
    } else {
      pri += double.tryParse(element.fltav.pri![index] ) as double;
    }
  });

  // logit('promo pri = $pri');
  return  new Text(
    calenderPrice(
        item[0].fltav.cur![index],
        pri.toStringAsFixed(2),
        item[0].fltav.miles![index]),
    style: new TextStyle(
      color: gblSystemColors
          .primaryButtonTextColor,
      fontSize: 12.0,
    ),
  );

 /* return  new Text(
    calenderPrice(
        item[0].fltav.cur[index],
        item
            .fold(
            0.0,
                (previous, current) =>
            previous +
                (double.tryParse(current
                    .fltav.discprice[index]) ??
                    0.0) )
            .toStringAsFixed(2),
        item[0].fltav.miles[index]),
    style: new TextStyle(
      color: gblSystemColors
          .primaryButtonTextColor,
      fontSize: 12.0,
    ),
  );*/
}
Widget getWasPriceRow(List<Flt> item, int index){

  double val = 0.0;

  item.forEach((element) {
    String newStr = element.fltav.pri![index];
    double? newVal = double.tryParse(newStr)  ;
    if( newVal != null )    val +=  newVal as double;
    newVal = double.tryParse(element.fltav.tax![index]);
    if( newVal != null )    val +=  newVal as double;
  });

  return new Text(calenderPrice(item[0].fltav.cur![index], val.toStringAsFixed(2), item[0].fltav.miles![index]),
    style: new TextStyle(
      color: gblSystemColors.oldPriceColor,
      decoration: TextDecoration.lineThrough,
      fontSize: 12.0,
    ),);

 /* return  new Text(
    calenderPrice(
        item[0].fltav.cur[index],
        item
            .fold(
            0.0,
                (previous, current) =>
            previous! +
                (double.tryParse(current
                    .fltav.pri[index]) ??
                    0.0) +
                (double.tryParse(current
                    .fltav.tax[index]) ??
                    0.0))
            .toStringAsFixed(2),
        item[0].fltav.miles[index]),
    style: new TextStyle(
      color: gblSystemColors.oldPriceColor,
      decoration: TextDecoration.lineThrough,
      fontSize: 12.0,
    ),
  );*/
}
List<Widget> getPriceButtonList(String? cbNameIn, List<Flt> item, int index, {bool inRow = true}) {

  List<Widget> list = [];
  List<Widget> rlist = [];
  String cbName = cbNameIn as String;

  int noAv = int.parse(item[0].fltav.fav![index]);
  item.forEach((element) {
    if( element.fltav.fav![index] == '0'){
      noAv = 0;
    }
    });


      if( cbName.length > 15) cbName = cbName.substring(0,10);
      list.add(getClassNameRow(cbName, inRow: inRow));

  logit('$cbName: $noAv');

  if(noAv > 0) {
    if( item[0].fltav.discprice!.length > index &&
        item[0].fltav.discprice![index] != null &&  item[0].fltav.discprice![index] != '')
    {
      list.add(getWasPriceRow(item, index));
      if( inRow) {
        rlist.add(getPromoPriceRow(item, index));
      } else {
        list.add(getPromoPriceRow(item, index));
      }
    } else {
      if( inRow) {
        rlist.add(getPriceRow(item, index));
      } else {
        list.add(getPriceRow(item, index));
      }
    }
  } else {
    if( inRow) {
      rlist.add(getNoSeatsRow());
    } else {
      list.add(getNoSeatsRow());
    }
  }
if( inRow) {
  list.add(Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: rlist,
  ));

  return list;
} else {
  return list;
}


}

class FlightLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint( //                       <-- CustomPaint widget
        size: Size(120, 40),
        painter: LinePainter(),
      ),
    );
  }
}
  class LinePainter extends CustomPainter {
    //         <-- CustomPainter class
    @override
    void paint(Canvas canvas, Size size) {
      //final pointMode = ui.PointMode.polygon;
      final points = [
        Offset(5, 20),
        Offset(115, 20),
      ];
      final paint = Paint()
        ..color = Colors.grey
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawPoints(PointMode.lines, points, paint);
      canvas.drawCircle(
          Offset(5,20),
          4,
          paint);
      canvas.drawCircle(
          Offset(115,20),
          4,
          paint);
    }

    @override
    bool shouldRepaint(CustomPainter old) {
      return false;
    }
  }
bool isJourneyAvailableForCb(List<Flt> flts, int cbIndex) {
  bool hasAV = true;
  flts.forEach((element) {
    if(element.fltav.fav![cbIndex] == '0'){
      hasAV = false;
    }
  });
  return hasAV;
}
Widget getCalDate(String sDate, Color? txtColor){

  if( gblSettings.wantMonthOnCalendar == true) {
   return Text(getIntlDate('EEE dd MMM', DateTime.parse(sDate)),
       textScaler: TextScaler.linear(1.2),
       style: TextStyle(
       //fontSize: 14,
       fontWeight: wantPageV2() ? FontWeight.bold : FontWeight.normal,
       color: txtColor)
  );
  } else {
    return Text(getIntlDate('EEE dd', DateTime.parse(sDate)),
        textScaler: TextScaler.linear(1.2),
        style: TextStyle(
        //fontSize: 14,
        fontWeight: wantPageV2() ? FontWeight.bold : FontWeight.normal,
        color: txtColor)
    );
  }

}

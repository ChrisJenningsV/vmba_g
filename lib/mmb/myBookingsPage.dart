import 'package:flutter/material.dart';
import 'package:vmba/data/models/pnrs.dart';
import 'package:vmba/mmb/viewBookingPage.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/data/models/pnr.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:vmba/menu/menu.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/utilities/widgets/appBarWidget.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/calendar/flightPageUtils.dart';


class MyBookingsPage extends StatefulWidget {
  MyBookingsPage({Key key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  List<PnrDBCopy> pnrs = [];
  // new List<PnrDBCopy>();
  bool _loadingInProgress;
  Offset _tapPosition;
String _error = '';

  @override
  void initState() {
    super.initState();
    _loadingInProgress = true;
    getmyookings();
    Repository.get().getAllCities().then((cities) {});
  }

  void getmyookings() {
    Repository.get().getAllPNRs().then((pnrsDBCopy) {
      List<PnrDBCopy> thispnrs = [];
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
        pnrs = thispnrs;
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
      return Scaffold(
          appBar: appBar(context, "My Bookings") // translated in appBar
          //AppBar(
          //     brightness: AppConfig.of(context).systemColors.statusBar,
          //     backgroundColor: AppConfig.of(context).systemColors.primaryHeaderColor,
          // iconTheme: IconThemeData(color: AppConfig.of(context).systemColors.primaryHeaderOnColor),
          //     title: Text("My Bookings" ,style: TextStyle(color: AppConfig.of(context).systemColors.primaryHeaderOnColor)),)
          ,
          endDrawer: DrawerMenu(),
          body: new Container(child: myTrips()));
    }
  }

  Widget myTrips() {
    Center noFutureBookingsFound =  Center(
        child: TrText('No future bookings found',
            style: TextStyle(fontSize: 26.0), textAlign: TextAlign.center));

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
}

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:vmba/data/models/boardingpass.dart';
import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/menu/menu.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:vmba/mmb/iosAddBoardingPassToWallet.dart';
import 'package:http/http.dart' as http;

//lsLM0032/18MARABZKOI[CB=FLY][CUR=GBP]~x
class BoardingPassWidget extends StatefulWidget {
  BoardingPassWidget({Key key, this.pnr, this.journeyNo, this.paxNo})
      : super(key: key);
  final int journeyNo;
  final int paxNo;
  final PnrModel pnr;
  @override
  State<StatefulWidget> createState() => BoardingPassWidgetState();
}

class BoardingPassWidgetState extends State<BoardingPassWidget> {
  bool _loadingInProgress;
  int _currentBarcode = 1;
  bool _barCodeScanError = false;
  GlobalKey globalKey = new GlobalKey();

  String barCodeData;
  //String cmd = "BPPLM0037:10Apr2019:KOI:ABZ:AATPCR1";

  BoardingPass _boardingPass;
  @override
  void initState() {
    super.initState();
    _loadingInProgress = true;
    // BoardingPass savedRecord;
    TKT tkt = widget.pnr.pNR.tickets.tKT.firstWhere((t) =>
        t.pax == (widget.paxNo + 1).toString() &&
        t.segNo == (widget.journeyNo + 1).toString().padLeft(2, '0') &&
        t.tktFor == '');

    //load();

    // .then((value) {
    //   if (value != null) {
    //   } else {
    //     final df = new DateFormat('ddMMMyyyy');
    //         String cmd = "BPP" +
    //     fltno +
    //     ":" +
    //     df.format(DateTime.parse(
    //         widget.pnr.pNR.itinerary.itin[widget.journeyNo].depDate)) +
    //     ":" +
    //     widget.pnr.pNR.itinerary.itin[widget.journeyNo].depart +
    //     ":" +
    //     widget.pnr.pNR.itinerary.itin[widget.journeyNo].arrive +
    //     ":" +
    //     widget.pnr.pNR.rLOC +
    //     (widget.paxNo + 1).toString() +
    //     "[MOBILE]";
    // //getVRSMobileBP(cmd, _boardingPass);
    //   }
    // }).then((completed) => _boardingPassLoaded());

    String fltno = widget.pnr.pNR.itinerary.itin[widget.journeyNo].airID +
        widget.pnr.pNR.itinerary.itin[widget.journeyNo].fltNo;

    Repository.get()
        .getBoardingPass(
            widget.pnr.pNR.itinerary.itin[widget.journeyNo].airID +
                widget.pnr.pNR.itinerary.itin[widget.journeyNo].fltNo,
            widget.pnr.pNR.rLOC,
            widget.paxNo)
        .then((value) => _boardingPass = new BoardingPass(
            rloc: widget.pnr.pNR.rLOC,
            fltno: fltno,
            depdate: DateTime.parse(
                widget.pnr.pNR.itinerary.itin[widget.journeyNo].depDate +
                    ' ' +
                    widget.pnr.pNR.itinerary.itin[widget.journeyNo].depTime),
            depart: widget.pnr.pNR.itinerary.itin[widget.journeyNo].depart,
            arrive: widget.pnr.pNR.itinerary.itin[widget.journeyNo].arrive,
            paxname: widget.pnr.pNR.names.pAX[widget.paxNo].firstName +
                ' ' +
                widget.pnr.pNR.names.pAX[widget.paxNo].surname,
            barcodedata: getBarCodeData(),
            paxno: widget.paxNo,
            seat: widget.pnr.pNR.aPFAX == null
                ? new AFX(seat: '- ').seat
                : widget.pnr.pNR.aPFAX.aFX
                    .firstWhere(
                        (s) =>
                            s.pax == (widget.paxNo + 1).toString() &&
                            s.seg == (widget.journeyNo + 1).toString() &&
                            s.aFXID == 'SEAT',
                        orElse: () => new AFX(seat: '- '))
                    .seat,
            gate: value.gate,
            boarding: value.boarding,
            classBand: widget.pnr.pNR.itinerary.itin[widget.journeyNo].classBand,
            loungeAccess: tkt.loungeAccess == null ? '-' : tkt.loungeAccess,
            fastTrack: tkt.fastTrack == null ? '-' : tkt.fastTrack))
        .then((completed) => _boardingPassLoaded());
    dcsStatus();
    // final df = new DateFormat('ddMMMyyyy');

    // String cmd = "BPP" +
    //     fltno +
    //     ":" +
    //     df.format(DateTime.parse(
    //         widget.pnr.pNR.itinerary.itin[widget.journeyNo].depDate)) +
    //     ":" +
    //     widget.pnr.pNR.itinerary.itin[widget.journeyNo].depart +
    //     ":" +
    //     widget.pnr.pNR.itinerary.itin[widget.journeyNo].arrive +
    //     ":" +
    //     widget.pnr.pNR.rLOC +
    //     (widget.paxNo + 1).toString() +
    //     "[MOBILE]";
    // Repository.get().getVRSMobileBP(cmd);
  }

  load() {
    String fltno = widget.pnr.pNR.itinerary.itin[widget.journeyNo].airID +
        widget.pnr.pNR.itinerary.itin[widget.journeyNo].fltNo;
    final df = new DateFormat('ddMMMyyyy');
    String cmd = "BPP" +
        fltno +
        ":" +
        df.format(DateTime.parse(
            widget.pnr.pNR.itinerary.itin[widget.journeyNo].depDate)) +
        ":" +
        widget.pnr.pNR.itinerary.itin[widget.journeyNo].depart +
        ":" +
        widget.pnr.pNR.itinerary.itin[widget.journeyNo].arrive +
        ":" +
        widget.pnr.pNR.rLOC +
        (widget.paxNo + 1).toString() +
        "[MOBILE]";
    //bool refreshBP = false;
    // bool hasDownloadedBoardingPass =
    Repository.get()
        .hasDownloadedBoardingPass(
            widget.pnr.pNR.itinerary.itin[widget.journeyNo].airID +
                widget.pnr.pNR.itinerary.itin[widget.journeyNo].fltNo,
            widget.pnr.pNR.rLOC,
            widget.paxNo)
        .then((hasDownloadedBoardingPass) {
      if (hasDownloadedBoardingPass) {
        Repository.get()
            .getBoardingPass(
                widget.pnr.pNR.itinerary.itin[widget.journeyNo].airID +
                    widget.pnr.pNR.itinerary.itin[widget.journeyNo].fltNo,
                widget.pnr.pNR.rLOC,
                widget.paxNo)
            .then((value) => _boardingPass = value)
            .then((value) => _boardingPassLoaded())
            .then((value) => getVRSMobileBP(cmd));
      } else {
        Repository.get()
            .getVRSMobileBP(cmd)
            .then((value) => _boardingPass = value)
            .then((value) => _boardingPassLoaded());
      }
    });

    // Repository.get()
    //     .getBoardingPass(
    //         widget.pnr.pNR.itinerary.itin[widget.journeyNo].airID +
    //             widget.pnr.pNR.itinerary.itin[widget.journeyNo].fltNo,
    //         widget.pnr.pNR.rLOC,
    //         widget.paxNo)
    //     .then((boardingPass) {
    //   if (boardingPass == null) {
    //     _boardingPass = Repository.get().getVRSMobileBP(cmd) as BoardingPass;
    //   } else {
    //     _boardingPass = boardingPass;
    //   //  refreshBP = false;
    //   }
    //   _boardingPassLoaded();
    //   if (refreshBP) {
    //     getVRSMobileBP(cmd);
    //   }
    // });
    //return boardingPass;
  }

  void _boardingPassLoaded() {
    setState(() {
      _loadingInProgress = false;
    });
  }

  void getVRSMobileBP(String cmd) {
    Repository.get().getVRSMobileBP(cmd).then((value) => setState(() {
          _boardingPass = value;
          //_boardingPass.gate = gateNo.isNotEmpty ? gateNo : '-';
          //_boardingPass.boarding = boardingTime != null ? boardingTime : 60;
          // Repository.get().updateBoardingPass(_boardingPass);
        }));
    // setState(() {
    //   _boardingPass
    //   //_boardingPass.gate = gateNo.isNotEmpty ? gateNo : '-';
    //   //_boardingPass.boarding = boardingTime != null ? boardingTime : 60;
    //   Repository.get().updateBoardingPass(_boardingPass);
    // });
  }

  Future<void> dcsStatus() async {
    //DF/LM0038/10may/ABZ
    String _fltNo = widget.pnr.pNR.itinerary.itin[widget.journeyNo].airID +
        widget.pnr.pNR.itinerary.itin[widget.journeyNo].fltNo;
    String _date = DateFormat('ddMMM').format(DateTime.parse(
        widget.pnr.pNR.itinerary.itin[widget.journeyNo].depDate));

    String _depart = widget.pnr.pNR.itinerary.itin[widget.journeyNo].depart;

    String cmd = '&Command=DF/$_fltNo/$_date/$_depart';
    String message = gblSettings.xmlUrl +
        gblSettings.xmlToken +
        cmd;
    print(message);
    String data;

    Uri apiUrl = Uri.parse(message);

    HttpClientRequest request = await new HttpClient().getUrl(apiUrl);
    HttpClientResponse response = await request.close();

    Stream resStream = response.transform(Utf8Decoder());
    // Map pnrMap;
    await for (String rs in resStream) {
      data = rs
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', '');
    }

    print(data);
    int indexOfGate = data.indexOf('Gate:'); //data.allMatches('Gate:');
    int indexOfIn = data.indexOf('IN:');
    String gateNo = data.substring(indexOfGate + 5, indexOfIn).trim();
    int indexOfBoardingTime = data.indexOf('Boarding Time:');
    int indexOfPUB1 = data.indexOf('PUB1:');
    int boardingTime = 0;
    var btStr = data.substring(indexOfBoardingTime + 14, indexOfPUB1).trim();
    if ( btStr.isNotEmpty){
      boardingTime = int.parse(btStr);
    }

    //DF/LM0038/10may/ABZ

    setState(() {
      _boardingPass.gate = gateNo.isNotEmpty ? gateNo : '-';
      _boardingPass.boarding = boardingTime != null ? boardingTime : 60;
      Repository.get().updateBoardingPass(_boardingPass);
    });
  }

  String getBarCodeData() {
    var buffer = new StringBuffer();

    //Format code = M
    buffer.write('M');

    //Legs supplied
    buffer.write('1');

    //Passenger Name 20 chars (Must have at least 1 initial)
    buffer.write((widget.pnr.pNR.names.pAX[widget.paxNo].surname
                .padRight(18, ' ')
                .substring(0, 18)
                .trim() +
            '/' +
            widget.pnr.pNR.names.pAX[widget.paxNo].firstName)
        .padRight(20, ' ')
        .substring(0, 20));

    //Electronic Ticket Indicator (E for ETKT else Space)
    buffer.write('E');

    //PNR Code 7 chars
    buffer.write(widget.pnr.pNR.rLOC.padRight(7, ' '));

    //Depart City Code 3 chars
    buffer.write(widget.pnr.pNR.itinerary.itin[widget.journeyNo].depart);

    //Arrive City Code 3 chars
    buffer.write(widget.pnr.pNR.itinerary.itin[widget.journeyNo].arrive);

    //Carrier 3 chars
    buffer.write(
        widget.pnr.pNR.itinerary.itin[widget.journeyNo].airID.padRight(3, ' '));

    //Flight number 5 chars
    buffer.write(
        widget.pnr.pNR.itinerary.itin[widget.journeyNo].fltNo.padRight(5, ' '));

    int dayOfYear = int.parse(DateFormat('D').format(DateTime.parse(
        widget.pnr.pNR.itinerary.itin[widget.journeyNo].depDate)));

    buffer.write(dayOfYear.toString().padLeft(3, "0"));

    buffer.write(widget.pnr.pNR.itinerary.itin[widget.journeyNo].cabin);
    var aFXSeat;
    widget.pnr.pNR.aPFAX == null
        ? aFXSeat = new AFX(seat: '')
        : aFXSeat = widget.pnr.pNR.aPFAX.aFX.firstWhere(
            (a) =>
                a.aFXID == 'SEAT' &&
                a.pax == (widget.paxNo + 1).toString() &&
                a.seg == (widget.journeyNo + 1).toString(),
            orElse: () => new AFX(seat: ''));
    buffer.write(aFXSeat.seat.padLeft(4, '0'));

    var sequenceNo = widget.pnr.pNR.tickets.tKT
        .firstWhere(
            (tkt) =>
                tkt.pax == (widget.paxNo + 1).toString() &&
                tkt.segNo == (widget.journeyNo + 1).toString().padLeft(2, '0'),
            orElse: () => new TKT(sequenceNo: ''))
        .sequenceNo;

    if (sequenceNo != '') {
      buffer.write(sequenceNo.padLeft(4, '0'));
      buffer.write(' ');
    } else {
      buffer.write('     ');
    }

    buffer.write('1');

    var strOptionalHeader = '>2';
    var strOptionalSection1 = '00';
    var strOptionalSection2 = '00';
    var strOptionalAirlineSection = 'T';

    TKT tkt = widget.pnr.pNR.tickets.tKT
        .where((t) =>
            t.tktFor != 'MPD' &&
            t.pax == (widget.paxNo + 1).toString() &&
            t.segNo == (widget.journeyNo + 1).toString().padLeft(2, '0'))
        .single;

    strOptionalAirlineSection += tkt.tktNo.split(' ')[1] + tkt.coupon;

    var intOptionalSectionLength = strOptionalHeader.length +
        strOptionalSection1.length +
        strOptionalSection2.length +
        strOptionalAirlineSection.length;

    buffer.write(intOptionalSectionLength.toRadixString(16).padLeft(2, '0'));
    buffer.write(strOptionalHeader);
    buffer.write(strOptionalSection1);
    buffer.write(strOptionalSection2);
    buffer.write(strOptionalAirlineSection);

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingInProgress) {
      return Scaffold(
        appBar: AppBar(
          //brightness: gblSystemColors.statusBar,
          backgroundColor:
          gblSystemColors.primaryHeaderColor,
          iconTheme: IconThemeData(
              color: gblSystemColors.headerTextColor),
          title: TrText('Boarding Pass',
              style: TextStyle(
                  color:
                  gblSystemColors.headerTextColor)),
        ),
        endDrawer: DrawerMenu(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              new CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new TrText('Loading your boarding pass...'),
              ),
            ],
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          //brightness: gblSystemColors.statusBar,
          backgroundColor:
          gblSystemColors.primaryHeaderColor,
          iconTheme: IconThemeData(
              color: gblSystemColors.headerTextColor),
          title: TrText('Boarding Pass',
              style: TextStyle(
                  color:
                  gblSystemColors.headerTextColor)),
        ),
        endDrawer: DrawerMenu(),
        body: _contentWidget(),
      );
    }
  }

  _contentWidget() {
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10), //EdgeInsets.all(20.0),
      color: const Color(0xFFFFFFFF),
      child: Column(
        //children: <Widget>[
        //  Column(
        children: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text(
                          gblSettings.airlineName, //"Loganair", //snapshot.data['arrivalCodes'][journey],
                          style: new TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.w700)),
                    )
                  ],
                ),
                Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(right: 10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                TrText("FLIGHT", //snapshot.data['passengers'][i],
                                    style: new TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w200)),
                                Text(_boardingPass.fltno,
                                    style: new TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w700))
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              TrText("DATE", //snapshot.data['passengers'][i],
                                  style: new TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.w200)),
                              Text(
                                  DateFormat('dd MMM')
                                      .format(_boardingPass.depdate)
                                      .toString(),
                                  //"18 Feb", //snapshot.data['passengers'][i],
                                  style: new TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w700))
                            ],
                          )
                        ]),
                  ],
                ),
              ]),
          Divider(),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Text(_boardingPass.depart,
                  style: new TextStyle(
                      fontSize: 32.0, fontWeight: FontWeight.w700)),
              new RotatedBox(
                  quarterTurns: 1,
                  child: new Icon(
                    Icons.airplanemode_active,
                    size: 32.0,
                  )),
              new Text(_boardingPass.arrive,
                  style: new TextStyle(
                      fontSize: 32.0, fontWeight: FontWeight.w700))
            ],
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              FutureBuilder(
                future: cityCodeToName(
                  _boardingPass.depart,
                ),
                initialData: _boardingPass.depart,
                builder: (BuildContext context, AsyncSnapshot<String> text) {
                  return new Text(text.data,
                      style: new TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.w300));
                },
              ),
              FutureBuilder(
                future: cityCodeToName(
                  _boardingPass.arrive,
                ),
                initialData: _boardingPass.arrive,
                builder: (BuildContext context, AsyncSnapshot<String> text) {
                  return new Text(text.data,
                      style: new TextStyle(
                          fontSize: 14.0, fontWeight: FontWeight.w300));
                },
              ),
            ],
          ),
          Divider(),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new TrText("PASSENGER",
                  style: new TextStyle(
                      fontSize: 12.0, fontWeight: FontWeight.w200)),
              new TrText('CLASS',
                  style: new TextStyle(
                      fontSize: 12.0, fontWeight: FontWeight.w200))
            ],
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: new Text(_boardingPass.paxname,
                    style: new TextStyle(
                        fontSize: 16.0, fontWeight: FontWeight.w700)),
              ),
              new Text(
                  _boardingPass.classBand.toUpperCase() == 'BLUE FLEX'
                      ? 'BLUE PLUS'
                      : _boardingPass.classBand.toUpperCase(),
                  style: new TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.w700))
            ],
          ),
          Padding(
            padding: EdgeInsets.all(5.0),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new TrText('SEAT',
                      style: new TextStyle(
                          fontSize: 12.0, fontWeight: FontWeight.w200)),
                  new Text(_boardingPass.seat,
                      style: new TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w700))
                ],
              ),
              new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new TrText("GATE ",
                      style: new TextStyle(
                          fontSize: 12.0, fontWeight: FontWeight.w200)),
                  new Text(_boardingPass.gate,
                      style: new TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w700)),
                ],
              ),
              new Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  new TrText("BOARDING TIME", //snapshot.data['passengers'][i],
                      style: new TextStyle(
                          fontSize: 12.0, fontWeight: FontWeight.w200)),
                  new Text(
                      DateFormat('HH:mm')
                          .format(_boardingPass.depdate.subtract(
                              new Duration(minutes: _boardingPass.boarding)))
                          .toString(),
                      style: new TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w700)),
                ],
              ),
              new Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  new TrText("DEPARTS", //snapshot.data['passengers'][i],
                      style: new TextStyle(
                          fontSize: 12.0, fontWeight: FontWeight.w200)),
                  new Text(
                      DateFormat('HH:mm')
                          .format(_boardingPass.depdate)
                          .toString(),
                      style: new TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                //                 gbl_settings.bpShowFastTrack                    ? ... : Text('')
                children: <Widget>[ new TrText('FAST TRACK',
                              style: new TextStyle(
                                  fontSize: 12.0, fontWeight: FontWeight.w200)),
                          new Text(
                              _boardingPass.fastTrack.toLowerCase() == 'true'
                                  ? translate("YES")
                                  : translate("NO"),
                              style: new TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.w700))
//                      : Text('')
                ],
              ),
              // new Column(
              //   crossAxisAlignment: CrossAxisAlignment.end,
              //   children: <Widget>[
              //     //gbl_settings.bpShowLoungeAccess
              //     //    ? [
              //             new TrText("LOUNGE ACCESS",
              //                 style: new TextStyle(
              //                     fontSize: 12.0, fontWeight: FontWeight.w200)),
              //             new Text(
              //                 _boardingPass.loungeAccess.toLowerCase() == 'true'
              //                     ? translate("YES")
              //                     : translate("NO"),
              //                 style: new TextStyle(
              //                     fontSize: 16.0, fontWeight: FontWeight.w700))
              //       //    ]
              //       //  : Text(''),
              //   ],
              // ),
            ],
          ),
          _barCodeScanError
              ? Container(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        CarouselSlider(
                          options: CarouselOptions(
                          height: 0.25 * bodyHeight,
                          initialPage: 1,
                          enlargeCenterPage: false,
                          autoPlay: false,
                          reverse: false,
                          enableInfiniteScroll: false,
                          scrollDirection: Axis.horizontal,
                          onPageChanged: (index, reason) {
                            setState(() {
                              _currentBarcode = index;
                            });
                          }),
                          items: <Widget>[
                            Container(
                              //width: MediaQuery.of(context).size.width,
                              child: RepaintBoundary(
                                key: globalKey,
                                child: QrImage(
                                  data: _boardingPass.barcodedata,
                                  size: 0.25 * bodyHeight,
                                  version: 5,
                                  // onError: (ex) {
                                  //   print("[QR] ERROR - $ex");
                                  //   setState(() {
                                  //     _inputErrorText =
                                  //         "Error! Maybe your input value is too long?";
                                  //   });
                                  // },
                                ),
                              ),
                            ),
                            /* old 2d barcode */
                             Container(
                               child: Center(
                                 child:
                                 BarcodeWidget(
                                   barcode: Barcode.pdf417(), // Barcode type and settings
                                   data: _boardingPass.barcodedata, // Content
                                   width: _currentBarcode == 1 ? 300 : 1,
                                   height: 0.15 * bodyHeight,
                                 ),
/*                                 BarcodeGenerator(
                                   witdth: _currentBarcode == 1 ? 300 : 1,
                                   height: 0.15 * bodyHeight,
                                   //backgroundColor: Colors.red,
                                   fromString: _boardingPass.barcodedata,
                                   codeType: BarCodeType.kBarcodeFormatPDF417,
                                 ),

 */
                               ),
                             ),
                            /* end 2d barcode */
                          ],
                        ),
                        Column(
                          children: <Widget>[
                            Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 10.0,
                                    height: 10.0,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 2.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _currentBarcode == 0
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  ),
                                  Container(
                                    width: 10.0,
                                    height: 10.0,
                                    margin: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 2.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _currentBarcode == 1
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  )
                                ]),
                            drawAddPassToWalletButton(_boardingPass),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                    width: 275,
                                    child: _currentBarcode == 1
                                        ? TrText(
                                            'If alternate barcode will still not scan, we apologise for the inconvenience. Please present this boading pass to a member of the gate staff.',
                                            style: TextStyle(
                                              fontSize: 12.0,
                                            ),
                                            textAlign: TextAlign.center,
                                          )
                                        : null)
                              ],
                            ),
                          ],
                        )
                      ]),
                )
              : Expanded(
                  child: Column(
                    children: <Widget>[
                      Center(
                        child: RepaintBoundary(
                          key: globalKey,
                          child: QrImage(
                            data: _boardingPass.barcodedata,
                            size: 0.25 * bodyHeight,
                            version: 5,
                            // onError: (ex) {
                            //   print("[QR] ERROR - $ex");
                            //   setState(() {
                            //     _inputErrorText =
                            //         "Error! Maybe your input value is too long?";
                            //   });
                            // },
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          (gblSettings.want2Dbarcode ) // gblSettings.aircode == 'LM'
                              ? TextButton(
                                  child: TrText(
                                    "This barcode did not scan",
                                    style: TextStyle(
                                      color: gblSystemColors.textButtonTextColor,
                                      fontSize: 12.0,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _barCodeScanError = true;
                                    });
                                  },
                                )
                              : Text('')
                        ],
                      ),
                      drawAddPassToWalletButton(_boardingPass),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget drawAddPassToWalletButton(BoardingPass pass) {
    if (canShowAddBoardingPassToWalletButton() == false) {
      //Do not render save pass to wallet button
      return SizedBox.shrink();
    }

    if (Platform.isAndroid) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 20),
          InkWell(
            onTap: () {
              _savePassToGoogleWallet(pass);
            },
            child: Image(
              image: AssetImage('lib/assets/images/googleWallet.png'),
            ),
          ),
        ],
      );
    }
    else {
      //iOS or Apple
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const SizedBox(height: 20),
          InkWell(
            onTap: () {
              _savePassToAppleWallet(pass);
            },
            child: Image(
              image: AssetImage('lib/assets/images/appleWallet.png'),
            ),
          ),
        ],
      );
    }
  }

  bool canShowAddBoardingPassToWalletButton() {
    return gblSettings.bpShowAddPassToWalletButton == true;
  }

  void _savePassToAppleWallet(BoardingPass pass) async {
    try {
      //print("Fetching Boarding Pass for " + gblSettings.airlineName);
      String departCityName = await cityCodeToName(pass.depart);
      String arrivalCityName = await cityCodeToName(pass.arrive);

      var qParams = new StringBuffer();
      qParams.write('?AirCode=${gblSettings.aircode}');
      qParams.write('?LogoText=${gblSettings.airlineName}');
      qParams.write('&Rloc=${pass.rloc}');
      qParams.write('&Gate=${pass.gate}');
      qParams.write('&BoardingTime=${pass.boarding}');
      qParams.write('&FltNo=${pass.fltno}');
      qParams.write('&DepDate=${pass.depdate}');
      qParams.write('&Depart=$departCityName');
      qParams.write('&DepartCityCode=${pass.depart}');
      qParams.write('&Arrive=$arrivalCityName');
      qParams.write('&ArriveCityCode=${pass.arrive}');
      qParams.write('&PaxNo=${pass.paxno}');
      qParams.write('&PaxName=${pass.paxname}');
      qParams.write('&ClassBand=${pass.classBand}');
      qParams.write('&Seat=${pass.seat}');
      qParams.write('&FastTrack=${pass.fastTrack}');
      qParams.write('&LoungeAccess=${pass.loungeAccess}');
      qParams.write('&BarcodeData=${pass.barcodedata}');
      qParams.write('&BarcodeType=QR');

      //String webApiUrl = 'https://customertest.videcom.com/videcomair/VARS/webApiV2/api/PassGeneratorApple/createboardingpass';
      //String webApiUrl = 'http://10.0.2.2:5000/api/PassGeneratorApple/createboardingpass';  //Android Dev
      String webApiUrl = gblSettings.apiUrl + 'PassGeneratorApple/createboardingpass'; //Live

      String url = webApiUrl + qParams.toString();
      url = Uri.encodeFull(url);
      //print('url=' + url);
      //print('_currentBarcode=' + this._currentBarcode.toString());

      //Invoke web API call with query params appended to download an Apple Boarding Pass representation
      //NOTE: Using url_launcher to get its webview element to run the iOS native Wallet App for the application/vnd.apple.pkpass mime type.
      //      Also forcing the browser element utilised for this to Safari.
      AppleBoardingPassHandler passHandler = new AppleBoardingPassHandler();
      passHandler.launchPass(url, gblSettings.apiKey);
    }
    catch(e) {
      print(e);
    }
  }

  void _savePassToGoogleWallet(BoardingPass pass) async {
    try {
      //print("Fetching Boarding Pass for " + gblSettings.airlineName);
      String departCityName = await cityCodeToName(pass.depart);
      String arrivalCityName = await cityCodeToName(pass.arrive);

      var qParams = new StringBuffer();
      qParams.write('?AirCode=${gblSettings.aircode}');
      qParams.write('?LogoText=${gblSettings.airlineName}');
      qParams.write('&Rloc=${pass.rloc}');
      qParams.write('&Gate=${pass.gate}');
      qParams.write('&BoardingTime=${pass.boarding}');
      qParams.write('&FltNo=${pass.fltno}');
      qParams.write('&DepDate=${pass.depdate}');
      qParams.write('&Depart=$departCityName');
      qParams.write('&DepartCityCode=${pass.depart}');
      qParams.write('&Arrive=$arrivalCityName');
      qParams.write('&ArriveCityCode=${pass.arrive}');
      qParams.write('&PaxNo=${pass.paxno}');
      qParams.write('&PaxName=${pass.paxname}');
      qParams.write('&ClassBand=${pass.classBand}');
      qParams.write('&Seat=${pass.seat}');
      qParams.write('&FastTrack=${pass.fastTrack}');
      qParams.write('&LoungeAccess=${pass.loungeAccess}');
      qParams.write('&BarcodeData=${pass.barcodedata}');
      qParams.write('&BarcodeType=QR');

      //String webApiUrl = 'https://customertest.videcom.com/videcomair/VARS/webApiV2/api/PassGeneratorGoogle/createboardingpass';
      //String webApiUrl = 'http://10.0.2.2:5000/api/PassGeneratorGoogle/createboardingpass';  //Android Dev
      String webApiUrl = gblSettings.apiUrl + 'PassGeneratorGoogle/createboardingpass'; //Live

      String url = webApiUrl + qParams.toString();
      url = Uri.encodeFull(url);
      //print('url=' + url);

      //Invoke web API call with query params appended to create a JWT Google Boarding Pass representation
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        try {
          String skinnyPassJwtUrl = response.body;

          //NOTE: Using url_launcher to get its webview element to load the JWT url which should invoke a Save to Wallet on an Android device.
          AppleBoardingPassHandler passHandler = new AppleBoardingPassHandler();
          passHandler.launchPass(skinnyPassJwtUrl, gblSettings.apiKey);
        } catch (e) {
          print(e.toString());
        }
      }
    }
    catch(e) {
      print(e);
    }
  }


}

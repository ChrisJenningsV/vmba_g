import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
//import 'package:simpleprogressdialog/builders/material_dialog_builder.dart';
//import 'package:simpleprogressdialog/builders/cupertino_dialog_builder.dart';
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


import '../../Helpers/networkHelper.dart';
import 'package:vmba/data/models/vrsRequest.dart';

//lsLM0032/18MARABZKOI[CB=FLY][CUR=GBP]~x
class BoardingPassWidget extends StatefulWidget {
  BoardingPassWidget({Key key= const Key("bpasswid_key"), required this.pnr, this.journeyNo=1, this.paxNo=1})
      : super(key: key);
  final int journeyNo;
  final int paxNo;
  final PnrModel pnr;
  @override
  State<StatefulWidget> createState() => BoardingPassWidgetState();
}

class BoardingPassWidgetState extends State<BoardingPassWidget> {
  bool _loadingInProgress=false;
  int _currentBarcode = 1;
  bool _barCodeScanError = false;
  GlobalKey globalKey = new GlobalKey();
  bool _dataReady = false;

  String barCodeData='';
  //String cmd = "BPPLM0037:10Apr2019:KOI:ABZ:AATPCR1";

  BoardingPass? _boardingPass;
  @override
  void initState() {
    super.initState();
    _loadingInProgress = true;
    // BoardingPass savedRecord;
    TKT tkt = widget.pnr.pNR.tickets.tKT.firstWhere((t) =>
        t.pax == (widget.paxNo + 1).toString() &&
        t.segNo == (widget.journeyNo + 1).toString().padLeft(2, '0') &&
        t.tktFor == '');

    load();

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
            barcodedata: (_boardingPass != null ) ?_boardingPass!.barcodedata : '', //getBarCodeData(),
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
    setBarcodeToDisplayAsDefault();


  }

  load() {
    logit('loading boardingpass for pax ${widget.paxNo + 1}');
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


  }

  void _boardingPassLoaded() {
    setState(() {
      logit('boardingpass loaded');
      _loadingInProgress = false;
      if(_boardingPass!.boarding != null && _boardingPass!.boarding != '' && _boardingPass!.departTime != null && _boardingPass!.departTime != ''){
        _dataReady = true;
      }
    });
  }

  void getVRSMobileBP(String cmd) {
    Repository.get().getVRSMobileBP(cmd).then((value) => setState(() {
          _boardingPass = value;
          logit('got data');
          if(_boardingPass!.boarding != null && _boardingPass!.boarding != '' && _boardingPass!.departTime != null && _boardingPass!.departTime != ''){
            _dataReady = true;
          }


      //_boardingPass!.gate = gateNo.isNotEmpty ? gateNo : '-';
          //_boardingPass!.boarding = boardingTime != null ? boardingTime : 60;
          // Repository.get().updateBoardingPass(_boardingPass);
        }));
    // setState(() {
    //   _boardingPass
    //   //_boardingPass!.gate = gateNo.isNotEmpty ? gateNo : '-';
    //   //_boardingPass!.boarding = boardingTime != null ? boardingTime : 60;
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
    String data = '';

  //  if( gblSettings.useWebApiforVrs) {
      String cmd = 'DF/$_fltNo/$_date/$_depart';
      String msg =  json.encode(VrsApiRequest(gblSession!, cmd,
          gblSettings.xmlToken.replaceFirst('token=', ''),
          vrsGuid: gblSettings.vrsGuid,
          notifyToken: gblNotifyToken,
          rloc: gblCurrentRloc,
          language: gblLanguage,
          phoneId: gblDeviceId
      )); // '{VrsApiRequest: ' + + '}' ;
      http.Response response = await http
          .get(Uri.parse(
          "${gblSettings.xmlUrl.replaceFirst('?', '')}?VarsSessionID=${gblSession!.varsSessionId}&req=$msg"),
          headers: getXmlHeaders())
          .catchError((resp) {
            logit(resp);
/*
      var error = '';
*/
      });
      if(response == null ){
        return null;
      }
/*
      if( response.body.toUpperCase().contains('ERROR')) {
        return null;
      }
*/
      Map<String, dynamic> map = jsonDecode(response.body
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', ''));

      VrsApiResponse rs = VrsApiResponse.fromJson(map);
      logit('Server IP ${map['serverIP']}');
      if( rs.data == null  || rs.data == '') {
        throw 'no data returned';
      }
      data = rs.data;

//    }
    /*else {
      String cmd = '&Command=DF/$_fltNo/$_date/$_depart';
      String message = gblSettings.xmlUrl +
          gblSettings.xmlToken +
          cmd;
      //print(message);

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
    }*/

    //print(data);
    int indexOfGate = data.indexOf('Gate:'); //data.allMatches('Gate:');
    int indexOfIn = data.indexOf('IN:');

    String gateNo = '';
    if( data != null && data != '' ) gateNo = data.substring(indexOfGate + 5, indexOfIn).trim();
    int indexOfBoardingTime = -1;
    if( data != null && data != '' ) indexOfBoardingTime= data.indexOf('Boarding Time:');
    int indexOfPUB1 = -1;
    if( data != null && data != '' ) indexOfPUB1 = data.indexOf('PUB1:');
    int boardingTime = 0;
    var btStr = '';
    if( data != null && data != '' ) btStr = data.substring(indexOfBoardingTime + 14, indexOfPUB1).trim();
    if ( btStr.isNotEmpty){
      boardingTime = int.parse(btStr);
    }

    //DF/LM0038/10may/ABZ

    setState(() {
      if( _boardingPass != null ) {
        if (gateNo != null && gateNo != '') {
          _boardingPass!.gate = gateNo;
        } else {
          _boardingPass!.gate = '-';
        }
        //_boardingPass!.gate = gateNo.isNotEmpty ? gateNo : '-';
        _boardingPass!.boarding = 60;
        if( boardingTime != null && boardingTime != '') {
          _boardingPass!.boarding = boardingTime ;
        }
        if(_boardingPass!.boarding != null && _boardingPass!.boarding != '' && _boardingPass!.departTime != null && _boardingPass!.departTime != ''){
          _dataReady = true;
        }


      }
      Repository.get().updateBoardingPass(_boardingPass!);
    });
  }

  Future<void> setBarcodeToDisplayAsDefault() async {
    String departCity = widget.pnr.pNR.itinerary.itin[widget.journeyNo].depart;
    String barcodeType = await mobileBarcodeTypeForCity(departCity);
    if (barcodeType == 'PDF_417'){
      setState(() {
        //Switch to displaying the PDF_417 barcode
        _barCodeScanError = true;
        if(_boardingPass!.boarding != null && _boardingPass!.boarding != '' && _boardingPass!.departTime != null && _boardingPass!.departTime != ''){
          _dataReady = true;
        }


      });
    }
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
//    logit('_content Widget barcode data=${_boardingPass!.barcodedata}');
//    logit('_barCodeScanError = $_barCodeScanError');
    logit('gate ${_boardingPass!.gate}');

    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 10, 20, 10), //EdgeInsets.all(20.0),
      color: const Color(0xFFFFFFFF),
      child: SingleChildScrollView(
        child: Column(
          //children: <Widget>[
          //  Column(
          children: <Widget>[
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      _airlineName(),
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
                                      style: Theme.of(context).textTheme.labelSmall),
                                  Text(_boardingPass!.fltno,
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
                                    style: Theme.of(context).textTheme.labelSmall),
                                Text(
                                    DateFormat('dd MMM')
                                        .format(_boardingPass!.depdate!)
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
                new Text(_boardingPass!.depart,
                    style: new TextStyle(
                        fontSize: 32.0, fontWeight: FontWeight.w700)),
                new RotatedBox(
                    quarterTurns: 1,
                    child: new Icon(
                      Icons.airplanemode_active,
                      size: 32.0,
                    )),
                new Text(_boardingPass!.arrive,
                    style: new TextStyle(
                        fontSize: 32.0, fontWeight: FontWeight.w700))
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(cityCodetoAirport(_boardingPass!.depart),
                    style:TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w300)),
                /*FutureBuilder(
                  future: cityCodeToName(
                    _boardingPass!.depart,
                  ),
                  initialData: _boardingPass!.depart,
                  builder: (BuildContext context, AsyncSnapshot<String> text) {
                    return new Text(text.data!,
                        style: new TextStyle(
                            fontSize: 14.0, fontWeight: FontWeight.w300));
                  },
                ),*/
   /*             FutureBuilder(
                  future: cityCodeToName(
                    _boardingPass!.arrive,
                  ),
                  initialData: _boardingPass!.arrive,
                  builder: (BuildContext context, AsyncSnapshot<String> text) {
                    return new Text(text.data!,
                        style: new TextStyle(
                            fontSize: 14.0, fontWeight: FontWeight.w300));
                  },
                ),*/
                Text(cityCodetoAirport(_boardingPass!.arrive),
                    style:TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w300)),

              ],
            ),
            Divider(),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new TrText("PASSENGER",
                    style: Theme.of(context).textTheme.labelSmall/* new TextStyle(
                        fontSize: 12.0, fontWeight: FontWeight.w200)*/),
                new TrText('CLASS',
                    style: Theme.of(context).textTheme.labelSmall)
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: new Text(_boardingPass!.paxname,
                      style: new TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w700)),
                ),
                new Text(
                    _boardingPass!.classBand.toUpperCase() == 'BLUE FLEX'
                        ? 'BLUE PLUS'
                        : _boardingPass!.classBand.toUpperCase(),
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
                        style: Theme.of(context).textTheme.labelSmall),
                    new Text(_boardingPass!.seat,
                        style: new TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w700))
                  ],
                ),
                new Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new TrText("GATE ",
                        style: Theme.of(context).textTheme.labelSmall),
                    new Text((_boardingPass!.gate==null) ?'':_boardingPass!.gate,
                        style: new TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w700)),
                  ],
                ),
                new Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    new TrText("BOARDING TIME", //snapshot.data['passengers'][i],
                        style: Theme.of(context).textTheme.labelSmall),
                    new Text((_boardingPass!.boardingTime == null ) ? '' : _boardingPass!.boardingTime
                        /*DateFormat('HH:mm')
                            .format(_boardingPass!.depdate.subtract(
                                new Duration(minutes: _boardingPass!.boarding)))
                            .toString()*/,
                        style: new TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w700)),
                  ],
                ),
                new Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    new TrText("DEPARTS", //snapshot.data['passengers'][i],
                        style: Theme.of(context).textTheme.labelSmall),
                    new Text((_boardingPass!.departTime == null ) ? '' : _boardingPass!.departTime
                        /*DateFormat('HH:mm')
                            .format(_boardingPass!.depdate)
                            .toString()*/,
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
                                style: Theme.of(context).textTheme.labelSmall),
                            new Text(
                                _boardingPass!.fastTrack.toLowerCase() == 'true'
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
                //                 _boardingPass!.loungeAccess.toLowerCase() == 'true'
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
                            enlargeCenterPage: true,
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
                                  child: QrImageView(
                                    data: _boardingPass!.barcodedata,
                                    size: 0.25 * bodyHeight,
                                    //size: 0.5 * bodyHeight,
                                    //version: 5,
                                  ),
                                ),
                              ),
                              /* old 2d barcode */
                               Container(
                                 child: Center(
                                   child:
                                   BarcodeWidget(
                                     barcode: Barcode.pdf417(), // Barcode type and settings
                                     data: _boardingPass!.barcodedata, // Content
                                     width: _currentBarcode == 1 ? 300 : 1,
                                     height: 0.15 * bodyHeight,
                                   ),
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
                              drawAddPassToWalletButton(_boardingPass!),
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
                : Container(
                    child: Column(
                      children: <Widget>[
                        Center(
                          child: RepaintBoundary(
                            key: globalKey,
                            child: QrImageView(
                              data: _boardingPass!.barcodedata,
                              size: 0.25 * bodyHeight,
                              //size: 0.5 * bodyHeight,
                              //version: 5,
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
                        drawAddPassToWalletButton(_boardingPass!),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _airlineName() {
    if( gblSettings.wantBpLogo == null || gblSettings.wantBpLogo == true  ) {
      if( gblSettings.useAppBarImeonBP) {
        return Image.asset('lib/assets/$gblAppTitle/images/appBar.png', width: 160);
      } else {
        return Image.asset(
            'lib/assets/$gblAppTitle/images/logo.png', width: 160);
      }
    }
    return Padding(
      padding: EdgeInsets.only(top: 10),
      child: Text(
          gblSettings.airlineName, //"Loganair", //snapshot.data['arrivalCodes'][journey],
          style: new TextStyle(
              fontSize: 18.0, fontWeight: FontWeight.w700)),
    );
  }



  Widget drawAddPassToWalletButton(BoardingPass pass) {
    if (canShowAddBoardingPassToWalletButton() == false || _dataReady == false) {
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
              _savePassToWallet(pass);
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
              _savePassToWallet(pass);
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

  void _savePassToWallet(BoardingPass pass) async {
    //NOTE: Loading the JWT url which should invoke a Save to Wallet on an Android device.
    //      On an iOS device the native Wallet App for the application/vnd.apple.pkpass mime type will load.
    String url = "";
  //  ProgressDialog progressDialog = ProgressDialog(context: context, barrierDismissible: true);
    try {
      if (Platform.isAndroid) {
 //       progressDialog.showMaterial(message:"Fetching pass..", layout: MaterialProgressDialogLayout.columnWithCircularProgressIndicator);
        String queryStringParams = await getQueryStringParameters(pass) ;
        url = await getUrlForGooglePass(queryStringParams);
      }
      else {
  //      progressDialog.showCupertino(message:"Fetching pass..", layout: CupertinoProgressDialogLayout.columnWithCircularActivityIndicator);
        String queryStringParams = await getQueryStringParameters(pass);
        url = await getUrlForApplePass(queryStringParams);
      }
      if ( url != null && url.isNotEmpty) {  // ?? true
        AppleBoardingPassHandler passHandler = new AppleBoardingPassHandler();
        passHandler.launchPass(url, gblSettings.apiKey);
      }
    }
    catch(e) {
      print(e);
    }
 //   progressDialog.dismiss();
  }

  Future<String> getUrlForApplePass(String queryStringParams) async {
    //String webApiUrl = 'https://customertest.videcom.com/videcomair/VARS/webApiV2/api/PassGeneratorApple/createboardingpass';
    //String webApiUrl = 'http://10.0.2.2:5000/api/PassGeneratorApple/createboardingpass';  //Android Dev
    String webApiUrl = gblSettings.apiUrl + 'PassGeneratorApple/createboardingpass'; //Live
    String url = webApiUrl + queryStringParams + '&dummyKey=ab5d1591-6c39-4de6-b776-084f8a09a6bf';
    url = Uri.encodeFull(url);
    return url;
  }

  Future<String> getUrlForGooglePass(String queryStringParams) async {
    String skinnyPassJwtUrl = "";
    //String webApiUrl = 'https://customertest.videcom.com/videcomair/VARS/webApiV2/api/PassGeneratorGoogle/createboardingpass';
    //String webApiUrl = 'http://10.0.2.2:5000/api/PassGeneratorGoogle/createboardingpass';  //Android Dev
    String webApiUrl = gblSettings.apiUrl + 'PassGeneratorGoogle/createboardingpass'; //Live
    String url = webApiUrl + queryStringParams + '&dummyKey=ab5d1591-6c39-4de6-b776-084f8a09a6bf';
    url = Uri.encodeFull(url);

    //Invoke web API call with query params appended to create a JWT Google Boarding Pass representation
    final response = await http.get(Uri.parse(url), headers: getApiHeaders());
    if (response.statusCode == 200) {
      skinnyPassJwtUrl = response.body;
    }
    return skinnyPassJwtUrl;
  }

  Future<String> getQueryStringParameters(BoardingPass pass) async {
    String departCityName = cityCodetoAirport(pass.depart);
    String arrivalCityName = cityCodetoAirport(pass.arrive);
    var qParams = new StringBuffer();
    qParams.write('?AirCode=${gblSettings.aircode}');
    qParams.write('&LogoText=${gblSettings.airlineName}');
    qParams.write('&Rloc=${pass.rloc}');
    qParams.write('&Gate=${pass.gate}');
    qParams.write('&BoardingTime=${pass.boardingTime}');
    qParams.write('&FltNo=${pass.fltno}');
    qParams.write('&DepDate=${pass.depdate.toString().substring(0, 11) + pass.departTime}');
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
    return qParams.toString();
  }
}
void reloadBoardingPass(String rloc) {
  print('relaod boarding pass');
}
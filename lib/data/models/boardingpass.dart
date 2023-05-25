import 'dart:core';
import 'package:meta/meta.dart';

class BoardingPass {
  static final dbRloc = "rloc";
  static final dbFltno = "fltno";
  static final dbDepart = "depart";
  static final dbArrive = "arrive";
  static final dbDepdate = "depdate";
  static final dbPaxname = "paxname";
  static final dbPaxno = "paxno";
  static final dbBarcodedata = "barcodedata";
  static final dbSeat = "seat";
  static final dbGate = "gate";
  static final dbBoarding = "boarding";
  static final dbClassBand = "classBand";
  static final dbLoungeAccess = "loungeAccess";
  static final dbFastTrack = "fastTrack";
  static final dbDepartTime = "departtime";
  static final dbArriveTime = "arrivetime";
  static final dbBoardingTime = "boardtime";

  String rloc,
      fltno,
      depart,
      arrive,
      paxname,
      barcodedata,
      seat,
      gate,
      classBand,
      departTime,
      arriveTime;
  DateTime depdate;
  int paxno, boarding;
  String boardingTime;
  String fastTrack, loungeAccess;

  BoardingPass({
    @required this.rloc,
    @required this.fltno,
    @required this.depart,
    @required this.arrive,
    @required this.paxname,
    @required this.barcodedata,
    @required this.paxno,
    @required this.classBand,
    this.depdate,
    this.seat = '',
    @required this.gate = '',
    this.boarding = 0,
    this.fastTrack = 'false',
    this.loungeAccess = 'false',
    this.departTime,
    this.arriveTime,
    this.boardingTime,
  });

  BoardingPass.fromMap(Map<String, dynamic> map)
      : this(
          rloc: map[dbRloc],
          fltno: map[dbFltno],
          depart: map[dbDepart],
          arrive: map[dbArrive],
          departTime: map[dbDepartTime],
          arriveTime: map[dbArriveTime],
          boardingTime: map[dbBoardingTime],
          depdate: DateTime.parse(map[dbDepdate]),
          paxname: map[dbPaxname],
          paxno: map[dbPaxno],
          barcodedata: map[dbBarcodedata],
          seat: map[dbSeat] != null ? map[dbSeat] : '', //map[dbSeat],
          gate: (map[dbGate] != 'null' && map[dbGate] != null) ? map[dbGate] : '',
          boarding: map[dbBoarding] != 'null'
              ? map[dbBoarding]
              : 60, // map[dbBoarding],
          classBand: map[dbClassBand],
          loungeAccess:
              map[dbLoungeAccess] != null ? map[dbLoungeAccess] : '',
          fastTrack: map[dbFastTrack] != null ? map[dbFastTrack] : '',
        );

}

class VrsBoardingPass {
  Mobileboardingpass mobileboardingpass;

  VrsBoardingPass({this.mobileboardingpass});

  VrsBoardingPass.fromJson(Map<String, dynamic> json) {
    mobileboardingpass = json['mobileboardingpass'] != null
        ? new Mobileboardingpass.fromJson(json['mobileboardingpass'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.mobileboardingpass != null) {
      data['mobileboardingpass'] = this.mobileboardingpass.toJson();
    }
    return data;
  }
}

class Mobileboardingpass {
  String flight;
  String flightdate;
  String departcitycode;
  String departcityname;
  String arrivecitycode;
  String arrivecityname;
  String rloc;
  String passengername;
  String departtime;
  String arrivetime;
  String seat;
  String boardtime;
  String xclass;
  String sequence;
  String gate;
  String pieces;
  String weight;
  String ticketnumber;
  String selectee;
  String tsaprechk;
  String classband;
  String fareextras;
  String phbppcode;
  String barcode;
  String barcodeimage;

  Mobileboardingpass({
    this.flight,
    this.flightdate,
    this.departcityname,
    this.arrivecitycode,
    this.arrivecityname,
    this.rloc,
    this.passengername,
    this.departtime,
    this.arrivetime,
    this.seat,
    this.boardtime,
    this.xclass,
    this.sequence,
    this.gate,
    this.pieces,
    this.weight,
    this.ticketnumber,
    this.selectee,
    this.tsaprechk,
    this.classband,
    this.fareextras,
    this.phbppcode,
    this.barcode,
    this.barcodeimage,
  });

  Mobileboardingpass.fromJson(Map<String, dynamic> json) {
    flight = json['flight'];
    flightdate = json['flightdate'];
    departcitycode = json['departcitycode'];
    departcityname = json['departcityname'];
    arrivecitycode = json['arrivecitycode'];
    arrivecityname = json['arrivecityname'];
    rloc = json['rloc'];
    passengername = json['passengername'];
    departtime = json['departtime'];
    arrivetime = json['arrivetime'];
    seat = json['seat'];
    boardtime = json['boardtime'];
    xclass = json['class'];
    sequence = json['sequence'];
    gate = json['gate'];
    pieces = json['pieces'];
    weight = json['weight'];
    ticketnumber = json['ticketnumber'];
    selectee = json['selectee'];
    tsaprechk = json['tsaprechk'];
    classband = json['classband'];
    fareextras = json['fareextras'];
    phbppcode = json['phbppcode'];
    barcode = json['barcode'];
    barcodeimage = json['barcodeimage'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['flight'] = this.flight;
    data['flightdate'] = this.flightdate;
    data['departcitycode'] = this.departcitycode;
    data['departcityname'] = this.departcityname;
    data['arrivecitycode'] = this.arrivecitycode;
    data['arrivecityname'] = this.arrivecityname;
    data['rloc'] = this.rloc;
    data['passengername'] = this.passengername;
    data['departtime'] = this.departtime;
    data['arrivetime'] = this.arrivetime;
    data['seat'] = this.seat;
    data['boardtime'] = this.boardtime;
    data['class'] = this.xclass;
    data['sequence'] = this.sequence;
    data['gate'] = this.gate;
    data['pieces'] = this.pieces;
    data['weight'] = this.weight;
    data['ticketnumber'] = this.ticketnumber;
    data['selectee'] = this.selectee;
    data['tsaprechk'] = this.tsaprechk;
    data['classband'] = this.classband;
    data['fareextras'] = this.fareextras;
    data['phbppcode'] = this.phbppcode;
    data['barcode'] = this.barcode;
    data['barcodeimage'] = this.barcodeimage;
    return data;
  }
}

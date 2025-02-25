
import 'dart:core';

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
  DateTime? depdate;
  int paxno, boarding;
  String boardingTime;
  String fastTrack, loungeAccess;

  BoardingPass({
    required this.rloc,
    required this.fltno,
    required this.depart,
    required this.arrive,
    required this.paxname,
    required this.barcodedata,
    required this.paxno,
    required this.classBand,
    this.depdate,
    this.seat = '',
    this.gate = '',
    this.boarding = 0,
    this.fastTrack = 'false',
    this.loungeAccess = 'false',
    this.departTime ='',
    this.arriveTime ='',
    this.boardingTime ='',
  });

  BoardingPass.fromMap(Map<String, dynamic> map)
      : this(
          rloc: map[dbRloc],
          fltno: map[dbFltno],
          depart: map[dbDepart],
          arrive: map[dbArrive],
          departTime: (map[dbDepartTime]!= null ) ?map[dbDepartTime]: '',
          arriveTime: (map[dbArriveTime]!= null ) ?map[dbArriveTime]:'',
          boardingTime: (map[dbBoardingTime]!= null ) ? map[dbBoardingTime] :'',
          depdate: (map[dbDepdate]!= null || map[dbDepdate]!='')?DateTime.parse(map[dbDepdate]): DateTime.now(),
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
  Mobileboardingpass? mobileboardingpass;

  VrsBoardingPass();

  VrsBoardingPass.fromJson(Map<String, dynamic> json) {
    mobileboardingpass = json['mobileboardingpass'] != null
        ? new Mobileboardingpass.fromJson(json['mobileboardingpass'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    final mobileboardingpass = this.mobileboardingpass;
    if (mobileboardingpass != null) {
      data['mobileboardingpass'] = mobileboardingpass.toJson();
    }
    return data;
  }
}

class Mobileboardingpass {
  String flight='';
  String flightdate='';
  String departcitycode='';
  String departcityname='';
  String arrivecitycode='';
  String arrivecityname='';
  String rloc='';
  String passengername='';
  String departtime='';
  String arrivetime='';
  String seat='';
  String boardtime='';
  String xclass='';
  String sequence='';
  String gate='';
  String pieces='';
  String weight='';
  String ticketnumber='';
  String selectee='';
  String tsaprechk='';
  String classband='';
  String fareextras='';
  String phbppcode='';
  String barcode='';
  String barcodeimage='';

  Mobileboardingpass({
    this.flight='',
    this.flightdate='',
    this.departcityname='',
    this.arrivecitycode='',
    this.arrivecityname='',
    this.rloc='',
    this.passengername='',
    this.departtime='',
    this.arrivetime='',
    this.seat='',
    this.boardtime='',
    this.xclass='',
    this.sequence='',
    this.gate='',
    this.pieces='',
    this.weight='',
    this.ticketnumber='',
    this.selectee='',
    this.tsaprechk='',
    this.classband='',
    this.fareextras='',
    this.phbppcode='',
    this.barcode='',
    this.barcodeimage='',
  });

  Mobileboardingpass.fromJson(Map<String, dynamic> json) {
    if(json['flight']!= null)flight = json['flight'];
    if(json['flightdate']!= null)flightdate = json['flightdate'];
    if(json['departcitycode']!= null)departcitycode = json['departcitycode'];
    if(json['departcityname']!=null)departcityname = json['departcityname'];
    if(json['arrivecitycode']!= null)arrivecitycode = json['arrivecitycode'];
    if(json['arrivecityname']!= null)arrivecityname = json['arrivecityname'];
    if(json['rloc']!= null)rloc = json['rloc'];
    if(json['passengername']!= null)passengername = json['passengername'];
    if(json['departtime']!= null)departtime = json['departtime'];
    if(json['arrivetime']!= null)arrivetime = json['arrivetime'];
    if(json['seat']!= null)seat = json['seat'];
    if(json['boardtime']!=null)boardtime = json['boardtime'];
    if(json['class']!= null)xclass = json['class'];
    if(json['sequence']!=null)sequence = json['sequence'];
    if(json['gate']!= null)gate = json['gate'];
    if(json['pieces']!= null)pieces = json['pieces'];
    if(json['weight']!=null)weight = json['weight'];
    if(json['ticketnumber']!= null)ticketnumber = json['ticketnumber'];
    if(json['selectee']!= null)selectee = json['selectee'];
    if(json['tsaprechk']!= null)tsaprechk = json['tsaprechk'];
    if( json['classband']!= null)classband = json['classband'];
    if(json['fareextras']!= null)fareextras = json['fareextras'];
    if(json['phbppcode']!= null)phbppcode = json['phbppcode'];
    if(json['barcode']!= null)barcode = json['barcode'];
    if(json['barcodeimage']!= null)barcodeimage = json['barcodeimage'];
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

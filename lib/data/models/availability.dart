import 'package:vmba/Helpers/settingsHelper.dart';
import 'package:vmba/Helpers/stringHelpers.dart';

import '../../components/trText.dart';

class AvailabilityModel {
  Availability availability;

  AvailabilityModel({this.availability});

  AvailabilityModel.fromJson(Map<String, dynamic> json) {
    availability =
        json['xml'] != null ? new Availability.fromJson(json['xml']) : null;
  }
}

class Availability {
  Classbands classbands;
  List<avItin> itin;
  Cal cal;

  Availability({this.classbands, this.itin, this.cal});

  Availability.fromJson(Map<String, dynamic> json) {
    classbands = json['classbands'] != null
        ? new Classbands.fromJson(json['classbands'])
        : null;

    /*if (json['itin'] != null) {
      itin = new List<Itin>();
      json['itin'].forEach((v) {
        itin.add(new Itin.fromJson(v));
      });
    }*/

    if (json['itin'] != null) {
      itin = [];
      //new List<Itin>();
      if (json['itin'] is List) {
        json['itin'].forEach((v) {
          itin.add(new avItin.fromJson(v));
        });
      } else {
        itin.add(new avItin.fromJson(json['itin']));
      }
    }

    cal = json['cal'] != null ? new Cal.fromJson(json['cal']) : null;
  }
}

class Classbands {
  List<Band> band;

  Classbands({this.band});

  Classbands.fromJson(Map<String, dynamic> json) {
    if (json['band'] != null) {
      band = [];
      //new List<Band>();
      if (json['band'] is List) {
        json['band'].forEach((v) {
          band.add(new Band.fromJson(v));
        });
      } else {
        band.add(new Band.fromJson(json['band']));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.band != null) {
      data['band'] = this.band.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Band {
  String cb;
  String cbname;
  String cbclasses;
  String cabin;
  String shortcbname;
  String product;
  String cbdisplayname;
  Cbnotvalidwith cbnotvalidwith;
  Cbtextrecords cbtextrecords;

  Band(
      {this.cb,
      this.cbname,
      this.cbclasses,
      this.cbdisplayname,
      this.cabin,
      this.shortcbname,
      this.product,
      this.cbnotvalidwith,
      this.cbtextrecords});

  Band.fromJson(Map<String, dynamic> json) {
    cb = json['cb'];
    cbname = json['cbname'];
    cbclasses = json['cbclasses'];
    cabin = json['cabin'];
    shortcbname = json['shortcbname'];
    product = json['product'];
    cbnotvalidwith = json['cbnotvalidwith'] != null
        ? new Cbnotvalidwith.fromJson(json['cbnotvalidwith'])
        : null;
    cbtextrecords = json['cbtextrecords'] != null
        ? new Cbtextrecords.fromJson(json['cbtextrecords'])
        : null;
    cbdisplayname = json['cbdisplayname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cb'] = this.cb;
    data['cbname'] = this.cbname;
    data['cbclasses'] = this.cbclasses;
    data['cabin'] = this.cabin;
    data['shortcbname'] = this.shortcbname;
    data['product'] = this.product;
    data['cbdisplayname'] = this.cbdisplayname;
    if (this.cbnotvalidwith != null) {
      data['cbnotvalidwith'] = this.cbnotvalidwith.toJson();
    }
    if (this.cbtextrecords != null) {
      data['cbtextrecords'] = this.cbtextrecords.toJson();
    }
    return data;
  }
}

class Cbnotvalidwith {
  String cbname;

  Cbnotvalidwith({this.cbname});

  Cbnotvalidwith.fromJson(Map<String, dynamic> json) {
    cbname = '';
    if (json['cbname'] is List){
      json['cbname'].forEach((v) {
        //   cbtext.add(new Cbtext.fromJson(v));
        cbname += v + ',';
      });
    } else {
      cbname = json['cbname'];
    }
    //cbname = json['cbname'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cbname'] = this.cbname;
    return data;
  }
}

class Cbtextrecords {
  List<Cbtext> cbtext;

  Cbtextrecords({this.cbtext});

  Cbtextrecords.fromJson(Map<String, dynamic> json) {
    if (json['cbtext'] != null) {
      cbtext = [];
      //new List<Cbtext>();
      if (json['cbtext'] is Map) {
        //json['cbtext'] .toList().forEach((v) {
        cbtext.add(new Cbtext.fromJson(json['cbtext']));
        // });
      } else {
        json['cbtext'].forEach((v) {
          cbtext.add(new Cbtext.fromJson(v));
        });
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.cbtext != null) {
      data['cbtext'] = this.cbtext.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Cbtext {
  String text;
  String id;

  Cbtext({this.text, this.id});

  Cbtext.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    id = json['id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['text'] = this.text;
    data['id'] = this.id;
    return data;
  }
}

class avItin {
  String line;
  String dep;
  String arr;
  String international;
  String depmctdd;
  String depmctdi;
  String depmctid;
  String depmctii;
  String arrmctdd;
  String arrmctdi;
  String arrmctid;
  String arrmctii;
  List<Flt> flt;

  avItin(
      {this.line,
      this.dep,
      this.arr,
      this.international,
      this.depmctdd,
      this.depmctdi,
      this.depmctid,
      this.depmctii,
        this.arrmctdd,
        this.arrmctdi,
        this.arrmctid,
        this.arrmctii,
      this.flt});

  avItin.fromJson(Map<String, dynamic> json) {
    line = json['line'];
    dep = json['dep'];
    arr = json['arr'];
    international = json['international'];
    depmctdd = json['depmctdd'];
    depmctdi = json['depmctdi'];
    depmctid = json['depmctid'];
    depmctii = json['depmctii'];
    arrmctdd = json['arrmctdd'];
    arrmctdi = json['arrmctdi'];
    arrmctid = json['arrmctid'];
    arrmctii = json['arrmctii'];

    if (json['flt'] != null) {
      flt = [];
      //new List<Flt>();
      if (json['flt'] is List) {
        json['flt'].forEach((v) {
          flt.add(new Flt.fromJson(v));
        });
      } else {
        flt.add(new Flt.fromJson(json['flt']));
      }
    } else {
      flt = null;
    }
  }

  String journeyDuration() {
    DateTime firstDeparture = DateTime.parse(
        this.flt.first.time.ddaygmt + ' ' + this.flt.first.time.dtimgmt);
    DateTime lastArival = DateTime.parse(
        this.flt.last.time.adaygmt + ' ' + this.flt.last.time.atimgmt);

//Add offset???

    int hours = lastArival.difference(firstDeparture).inHours;
    int min = lastArival.difference(firstDeparture).inMinutes;
    min = min % 60;

//'${DateTime.parse(pnr.pNR.itinerary.itin[journey].depDate + ' ' + pnr.pNR.itinerary.itin[journey].arrTime.trim()).add(Duration(days: int.tryParse(pnr.pNR.itinerary.itin[journey].arrOfst.trim()) ?? (0))).difference(DateTime.parse(pnr.pNR.itinerary.itin[journey].depDate + ' ' + pnr.pNR.itinerary.itin[journey].depTime)).inHours.toString()}h.
//${(DateTime.parse(pnr.pNR.itinerary.itin[journey].depDate + ' ' + pnr.pNR.itinerary.itin[journey].arrTime).add(Duration(days: int.tryParse(pnr.pNR.itinerary.itin[journey].arrOfst.trim()) ?? (0))).difference(DateTime.parse(pnr.pNR.itinerary.itin[journey].depDate + ' ' + pnr.pNR.itinerary.itin[journey].depTime)).inMinutes % 60).toString()}min',

    // translate duration
    if( wantRtl()) {
      return translateNo('${hours}') + translate('h.') + ' ' + translateNo('${min}') + translate('min');
    }
    return '${hours}h. ${min}min';
  }
}

class Flt {
  String dep;
  String arr;
  Time time;
  Fltdet fltdet;
  Fltav fltav;

  Flt({this.dep, this.arr, this.time, this.fltdet, this.fltav});

  Flt.fromJson(Map<String, dynamic> json) {
    dep = json['dep'];
    arr = json['arr'];
    time = json['time'] != null ? new Time.fromJson(json['time']) : null;
    fltdet =
        json['fltdet'] != null ? new Fltdet.fromJson(json['fltdet']) : null;
    fltav = json['fltav'] != null ? new Fltav.fromJson(json['fltav']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['dep'] = this.dep;
    data['arr'] = this.arr;
    if (this.time != null) {
      data['time'] = this.time.toJson();
    }
    if (this.fltdet != null) {
      data['fltdet'] = this.fltdet.toJson();
    }
    if (this.fltav != null) {
      data['fltav'] = this.fltav.toJson();
    }
    return data;
  }

  String journeyDuration() {
    return '1hrs 30min';
  }
}

class Time {
  String ddaylcl;
  String ddaygmt;
  String dofst;
  String dtimlcl;
  String dtimgmt;
  String adaylcl;
  String adaygmt;
  String aofst;
  String atimlcl;
  String atimgmt;
  String duration;

  Time(
      {this.ddaylcl,
      this.ddaygmt,
      this.dofst,
      this.dtimlcl,
      this.dtimgmt,
      this.adaylcl,
      this.adaygmt,
      this.aofst,
      this.atimlcl,
      this.atimgmt,
      this.duration});

  Time.fromJson(Map<String, dynamic> json) {
    ddaylcl = json['ddaylcl'];
    ddaygmt = json['ddaygmt'];
    dofst = json['dofst'];
    dtimlcl = json['dtimlcl'];
    dtimgmt = json['dtimgmt'];
    adaylcl = json['adaylcl'];
    adaygmt = json['adaygmt'];
    aofst = json['aofst'];
    atimlcl = json['atimlcl'];
    atimgmt = json['atimgmt'];
    duration = json['duration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ddaylcl'] = this.ddaylcl;
    data['ddaygmt'] = this.ddaygmt;
    data['dofst'] = this.dofst;
    data['dtimlcl'] = this.dtimlcl;
    data['dtimgmt'] = this.dtimgmt;
    data['adaylcl'] = this.adaylcl;
    data['adaygmt'] = this.adaygmt;
    data['aofst'] = this.aofst;
    data['atimlcl'] = this.atimlcl;
    data['atimgmt'] = this.atimgmt;
    data['duration'] = this.duration;
    return data;
  }
}

class Fltdet {
  String airid;
  String fltno;
  String seq;
  String eqp;
  String stp;
  Canfac canfac;
  String depterm;
  String arrterm;

  Fltdet({this.airid, this.fltno, this.seq, this.eqp, this.stp, this.canfac, this.depterm, this.arrterm});

  Fltdet.fromJson(Map<String, dynamic> json) {
    airid = json['airid'];
    fltno = json['fltno'];
    seq = json['seq'];
    eqp = json['eqp'];
    stp = json['stp'];
    depterm = json['depterm'];
    arrterm = json['arrterm'];
    canfac =
        json['canfac'] != null ? new Canfac.fromJson(json['canfac']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['airid'] = this.airid;
    data['fltno'] = this.fltno;
    data['seq'] = this.seq;
    data['eqp'] = this.eqp;
    data['stp'] = this.stp;
    data['depterm'] = this.depterm;
    data['arrterm'] = this.arrterm;
    if (this.canfac != null) {
      data['canfac'] = this.canfac.toJson();
    }
    return data;
  }
}

class Canfac {
  String fac;

  Canfac({this.fac});

  Canfac.fromJson(Map<String, dynamic> json) {
    fac = json['fac'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['fac'] = this.fac;
    return data;
  }
}

class Fltav {
  List<String> cb;
  List<String> id;
  List<String> av;
  List<String> cur;
  List<String> curInf;
  List<String> pri;
  List<String> tax;
  List<String> fav;
  List<String> miles;
  List<String> awards;
  List<String> fid;
  List<String> finf;
  List<String> discprice;

  Fltav(
      {this.cb,
      this.id,
      this.av,
      this.cur,
      this.curInf,
      this.pri,
      this.tax,
      this.fav,
      this.miles,
      this.awards,
      this.fid,
      this.finf,
      this.discprice});

  Fltav.fromJson(Map<String, dynamic> json) {
    if (json['cb'] is List) {
      cb = json['cb'].cast<String>();
    } else {
      cb = [];
      //new List<String>();
      cb.add(json['cb']);
    }

    if (json['id'] is List) {
      id = json['id'].cast<String>();
    } else {
      id = [];
      //new List<String>();
      id.add(json['id']);
    }

    if (json['av'] is List) {
      av = json['av'].cast<String>();
    } else {
      av = [];
      //new List<String>();
      av.add(json['av']);
    }

    if (json['cur'] is List) {
      cur = json['cur'].cast<String>();
    } else {
      cur = [];
      //new List<String>();
      cur.add(json['cur']);
    }

    if (json['CurInf'] is List) {
      curInf = json['CurInf'].cast<String>();
    } else {
      curInf = [];
      //new List<String>();
      curInf.add(json['CurInf']);
    }

    if (json['pri'] is List) {
      pri = json['pri'].cast<String>();
    } else {
      pri = [];
      //new List<String>();
      pri.add(json['pri']);
    }

    if (json['tax'] is List) {
      tax = json['tax'].cast<String>();
    } else {
      tax = [];
      //new List<String>();
      tax.add(json['tax']);
    }

    if (json['fav'] is List) {
      fav = json['fav'].cast<String>();
    } else {
      fav = [];
      //new List<String>();
      fav.add(json['fav']);
    }

    if (json['miles'] is List) {
      miles = json['miles'].cast<String>();
    } else {
      miles = [];
      // new List<String>();
      miles.add(json['miles']);
    }

    if (json['awards'] is List) {
      awards = json['awards'].cast<String>();
    } else {
      awards = [];
      //new List<String>();
      awards.add(json['awards']);
    }

    if (json['fid'] is List) {
      fid = json['fid'].cast<String>();
    } else {
      fid = [];
      //new List<String>();
      fid.add(json['fid']);
    }

    if (json['finf'] is List) {
      finf = json['finf'].cast<String>();
    } else {
      finf = [];
      //new List<String>();
      finf.add(json['finf']);
    }
    if (json['discprice'] is List) {
      discprice = json['discprice'].cast<String>();
    } else {
      discprice = [];
      //new List<String>();
      discprice.add(json['discprice']);
    }

    //av = json['av'].cast<String>();
    //cur = json['cur'].cast<String>();
    //curInf = json['CurInf'].cast<String>();
    //pri = json['pri'].cast<String>();
    //tax = json['tax'].cast<String>();
    //fav = json['fav'].cast<String>();
    //miles = json['miles'].cast<String>();
    //awards = json['awards'].cast<String>();
    //fid = json['fid'].cast<String>();
    //finf = json['finf'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cb'] = this.cb;
    data['id'] = this.id;
    data['av'] = this.av;
    data['cur'] = this.cur;
    data['CurInf'] = this.curInf;
    data['pri'] = this.pri;
    data['tax'] = this.tax;
    data['fav'] = this.fav;
    data['miles'] = this.miles;
    data['awards'] = this.awards;
    data['fid'] = this.fid;
    data['finf'] = this.finf;
    data['discprice'] = this.discprice;
    return data;
  }
}

class Cal {
  List<Day> day;

  Cal({this.day});

  Cal.fromJson(Map<String, dynamic> json) {
    if (json['day'] != null) {
      day = [];
      //new List<Day>();
      json['day'].forEach((v) {
        day.add(new Day.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.day != null) {
      data['day'] = this.day.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Day {
  String daylcl;
  String cur;
  String curinf;
  String amt;
  String miles;
  String awards;

  Day({this.daylcl, this.cur, this.curinf, this.amt, this.miles, this.awards});

  Day.fromJson(Map<String, dynamic> json) {
    daylcl = json['daylcl'];
    cur = json['cur'];
    curinf = json['curinf'];
    amt = json['amt'];
    miles = json['miles'];
    awards = json['awards'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['daylcl'] = this.daylcl;
    data['cur'] = this.cur;
    data['curinf'] = this.curinf;
    data['amt'] = this.amt;
    data['miles'] = this.miles;
    data['awards'] = this.awards;
    return data;
  }
}

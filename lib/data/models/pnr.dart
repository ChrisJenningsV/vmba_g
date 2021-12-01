import 'package:intl/intl.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/utilities/helper.dart';
import 'models.dart';

class PnrModel {
  bool success;
  PNR pNR;

  PnrModel({this.pNR, this.success});

  PnrModel.fromJson(Map<String, dynamic> json) {
    pNR = json['PNR'] != null ? new PNR.fromJson(json['PNR']) : null;
    success = json['PNR'] != null ? true : false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.pNR != null) {
      data['PNR'] = this.pNR.toJson();
    }
    return data;
  }

  bool hasPendingCodeShareOrInterlineFlights() {
    bool result = false;
    if (this.pNR != null &&
        this.pNR.itinerary != null &&
        this.pNR.itinerary.itin.length != 0) {
      for (Itin _flight in this.pNR.itinerary.itin) {
        loop:
        if (_flight.hosted == '0' &&
            (_flight.status == 'PN' || _flight.status == 'HN')) {
          result = true;
          logit('has pending interline');
          break loop;
        }
      }
    }
    return result;
  }

  bool hasNonHostedFlights() {
    bool result = false;
    if (this.pNR != null &&
        this.pNR.itinerary != null &&
        this.pNR.itinerary.itin.length != 0) {
      for (Itin _flight in this.pNR.itinerary.itin) {
        loop:
        if (_flight.hosted == '0') {
          result = true;
          break loop;
        }
      }
    }
    return result;
  }

  int flightCount() {
    return this.pNR.itinerary.itin.length;
  }

  bool hasFutureFlights() {
    DateTime now = DateTime.now();
    var fltDate;
    fltDate = DateTime.parse(this.pNR.itinerary.itin.last.depDate +
        ' ' +
        this.pNR.itinerary.itin.last.depTime);
    if (now.isAfter(fltDate)) {
      return false;
    } else {
      return true;
    }
  }

  bool hasFutureFlightsAddDayOffset(int days) {
    DateTime now = DateTime.now();
    var fltDate;
    fltDate = DateTime.parse(this.pNR.itinerary.itin.last.depDate +
            ' ' +
            this.pNR.itinerary.itin.last.depTime)
        .add(Duration(days: days));
    if (now.isAfter(fltDate)) {
      return false;
    } else {
      return true;
    }
  }
  bool hasFutureFlightsMinusDayOffset(int days) {
    DateTime now = DateTime.now();
    var fltDate;
    fltDate = DateTime.parse(this.pNR.itinerary.itin.last.depDate +
        ' ' +
        this.pNR.itinerary.itin.last.depTime)
        .add(Duration(days: days));
    if (now.isAfter(fltDate)) {
      return false;
    } else {
      return true;
    }
  }

  int getnextFlightEpoch() {
    Itin flt = getNextFlight();
    int _millisecondsSinceEpoch = 0;
    if (flt.depDate != null || flt.depTime != null) {
      _millisecondsSinceEpoch = DateTime.parse(flt.depDate + ' ' + flt.depTime)
          .millisecondsSinceEpoch;
    }

    return _millisecondsSinceEpoch;
  }

  Itin getNextFlight() {
    Itin flight = new Itin();
    if (this.pNR != null) {
      for (Itin _flight in this.pNR.itinerary.itin) {
        loop:
        if (DateTime.now().isBefore(
            DateTime.parse(_flight.depDate + ' ' + _flight.depTime))) {
          flight = _flight;
          break loop;
        }
      }
    }
    return flight;
  }

  String validate() {

    if (!hasItinerary(this.pNR.itinerary)) {
      return 'No Flights';

    }

    if (!validateItineraryStatus(this.pNR.itinerary)) {
      return 'Bad flight status';
    }

    if (!validatePayment(this.pNR.basket)) {
      return 'Please contact ${gblSettings.airlineName} to complete booking';
      //return 'Payment invalid';
    }

    if (!hasTickets(this.pNR.tickets)) {
      return 'No Tickets';
    }
    if (!validateTickets(this.pNR)) {
      return 'Please contact ${gblSettings.airlineName} to complete booking: tickets not valid';

//      return 'Tickets invalid';
    }

    return '';
  }

  bool validateTickets(PNR pnr) {
    bool validateTickets = true;
    try {
      pnr.names.pAX.forEach((pax) {
        var tkt = pnr.tickets.tKT.where((tkt) =>
            tkt.pax == pax.paxNo &&
            (tkt.tKTID == 'ETKT' || tkt.tKTID == 'ELFT') &&
            (tkt.status == 'O' ||
                tkt.status == 'C' ||
                tkt.status == 'F' ||
                tkt.status == 'A') &&
            tkt.firstname == pax.firstName &&
            tkt.surname == pax.surname &&
            tkt.tktFor != 'MPD');

        List<TKT> tickets = [];
        //new List<TKT>();
        if (tkt.length > 0) {
          pnr.itinerary.itin.forEach((flt) {
            if (flt.status == 'HK' || flt.status == 'RR') {
              var otkt = tkt.firstWhere(
                  (t) =>
                      t.tktArrive == flt.arrive &&
                      t.tktDepart == flt.depart &&
                      t.tktFltDate ==
                          DateFormat('ddMMMyyyy')
                              .format(DateTime.parse(
                                  flt.depDate + ' ' + flt.depTime))
                              .toUpperCase() &&
                      t.tktFltNo == (flt.airID + flt.fltNo) &&
                      t.tktBClass == flt.xclass,
                  orElse: () => null);
              if (otkt != null) {
                tickets.add(otkt);
              }
            }
          });
        }
        if ((tickets.length !=
                pnr.itinerary.itin
                    .where((flt) => flt.status == 'HK' || flt.status == 'RR')
                    .length) &&
            (pnr.payments.fOP.where((p) => p.fOPID == 'III').length > 0)) {
          validateTickets = false;
          print('validateTickets = false;');
          return validateTickets;
        }

        if ((tickets.length !=
            pnr.itinerary.itin
                .where((flt) => flt.status == 'HK' || flt.status == 'RR')
                .length)) {
          validateTickets = false;
          print('validateTickets = false;');
          return validateTickets;
        }
        return validateTickets;
      });
    } catch (ex) {
      print(ex.toString());
      validateTickets = false;
      print('validateTickets = false;');
    }
    return validateTickets;
  }

  bool hasTickets(Tickets tickets) {
    bool hasTickets = false;
    if (tickets != null && tickets.tKT != null && tickets.tKT.length > 0) {
      hasTickets = true;
    } else {
      hasTickets = false;
      print('hasTickets = false');
    }

    return hasTickets;
  }

  bool hasItinerary(Itinerary itinerary) {
    bool hasItinerary = false;
    if (itinerary != null &&
        itinerary.itin != null &&
        itinerary.itin.length > 0) {
      hasItinerary = true;
    } else {
      hasItinerary = false;
      print('hasItinerary = false');
    }
    return hasItinerary;
  }

  bool validateItineraryStatus(Itinerary itinerary) {
    bool validateItineraryStatus = false;
    if (itinerary.itin
            .where((itin) =>
                itin.status.startsWith('PN') ||
                itin.status.startsWith('MM') ||
                itin.status.startsWith('SA'))
            .length ==
        0) {
      validateItineraryStatus = true;
    } else {
      validateItineraryStatus = false;
      print('validateItineraryStatus = false');
    }
    return validateItineraryStatus;
  }

  bool validatePayment(Basket basket) {
    bool validatePayment = false;
    if (basket.outstanding.amount == '0') {
      validatePayment = true;
    } else {
      if( double.parse(basket.outstanding.amount) <= 0 ){
        print('validatePayment less than 0;');
        validatePayment = true;
      } else {
        validatePayment = false;
        print('validatePayment = false;');
      }
    }
    return validatePayment;
  }
}

class PNR {
  String rLOC;
  String aDS;
  String pNRLocked;
  String pNRLockedReason;
  String secureFlight;
  String sfpddob;
  String sfpdgndr;
  String showFares;
  bool editFlights;
  String editProducts;
  Names names;
  Itinerary itinerary;
  Disruptions disruptions;
  //Null mPS;
  MPS mPS;
  Contacts contacts;
  APFAX aPFAX;
  //Null genFax;
  GenFax genFax;
  FareQuote fareQuote;
  Payments payments;
  //Null timeLimits;
  TimeLimits timeLimits;
  Tickets tickets;
  Remarks remarks;
  //Null tourOp;
  //TourOp tourOp;
  RLE rLE;
  Basket basket;
  //Null zpay;
  Zpay zpay;
  Pnrfields pnrfields;
  Fqfields fqfields;

  PNR(
      {this.rLOC,
      this.aDS,
      this.pNRLocked,
      this.pNRLockedReason,
      this.secureFlight,
      this.sfpddob,
      this.sfpdgndr,
      this.showFares,
      this.editFlights,
      this.editProducts,
      this.names,
      this.itinerary,
      this.disruptions,
      this.mPS,
      this.contacts,
      this.aPFAX,
      this.genFax,
      this.fareQuote,
      this.payments,
      this.timeLimits,
      this.tickets,
      this.remarks,
      //this.tourOp,
      this.rLE,
      this.basket,
      this.zpay,
      this.pnrfields,
      this.fqfields});

  PNR.fromJson(Map<String, dynamic> json) {
    rLOC = json['RLOC'];
    aDS = json['ADS'];
    pNRLocked = json['PNRLocked'];
    pNRLockedReason = json['PNRLockedReason'];
    secureFlight = json['SecureFlight'];
    sfpddob = json['sfpddob'];
    sfpdgndr = json['sfpdgndr'];
    showFares = json['showFares'];
    editFlights = json['editFlights'].toString().toLowerCase() == 'true';
    editProducts = json['editProducts'];
    names = json['Names'] != null ? new Names.fromJson(json['Names']) : null;
    itinerary = json['Itinerary'] != null
        ? new Itinerary.fromJson(json['Itinerary'])
        : null;
    disruptions = json['Disruptions'] != null
        ? new Disruptions.fromJson(json['Disruptions'])
        : null;
    mPS = json['MPS'] != null ? new MPS.fromJson(json['MPS']) : null;
    //mPS = json['MPS']!= null ? new MPS.fromJson(json['MPS']) : null;
    contacts = json['Contacts'] != null
        ? new Contacts.fromJson(json['Contacts'])
        : null;
    aPFAX = json['APFAX'] != null ? new APFAX.fromJson(json['APFAX']) : null;
    genFax =
        json['GenFax'] != null ? new GenFax.fromJson(json['GenFax']) : null;
    //genFax = json['GenFax']!= null ? new GenFax.fromJson(json['GenFax']) : null;
    fareQuote = json['FareQuote'] != null
        ? new FareQuote.fromJson(json['FareQuote'])
        : null;
    payments = json['Payments'] != null
        ? new Payments.fromJson(json['Payments'])
        : null;
    //timeLimits = json['TimeLimits'];
    timeLimits = json['TimeLimits'] != null
        ? new TimeLimits.fromJson(json['TimeLimits'])
        : null;
    tickets =
        json['Tickets'] != null ? new Tickets.fromJson(json['Tickets']) : null;
    remarks =
        json['Remarks'] != null ? new Remarks.fromJson(json['Remarks']) : null;
    //tourOp = json['TourOp'];
    //tourOp = json['TourOp'] != null ? new TourOp.fromJson(json['TourOp']) : null;
    rLE = json['RLE'] != null ? new RLE.fromJson(json['RLE']) : null;
    basket =
        json['Basket'] != null ? new Basket.fromJson(json['Basket']) : null;
    //zpay = json['zpay'];
    zpay = json['zpay'] != null ? new Zpay.fromJson(json['zpay']) : null;
    pnrfields = json['pnrfields'] != null
        ? new Pnrfields.fromJson(json['pnrfields'])
        : null;
    fqfields = json['fqfields'] != null
        ? new Fqfields.fromJson(json['fqfields'])
        : null;
  }
  int productCount(String productCode ){
    if( mPS == null || mPS.mP == null ) {
      return 0;
    }
    int cnt = 0;
    mPS.mP.forEach((p) {
      if(p.mPID == productCode) {
        cnt+=1;
      }
    }
    );
    return cnt;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['RLOC'] = this.rLOC;
    data['ADS'] = this.aDS;
    data['PNRLocked'] = this.pNRLocked;
    data['PNRLockedReason'] = this.pNRLockedReason;
    data['SecureFlight'] = this.secureFlight;
    data['sfpddob'] = this.sfpddob;
    data['sfpdgndr'] = this.sfpdgndr;
    data['showFares'] = this.showFares;
    data['editFlights'] = this.editFlights.toString();
    data['editProducts'] = this.editProducts;
    if (this.names != null) {
      data['Names'] = this.names.toJson();
    }
    if (this.itinerary != null) {
      data['Itinerary'] = this.itinerary.toJson();
    }
    //if (this.disruptions != null) {
    // data['Disruptions'] = this.disruptions.toJson();
    //}
    //data['MPS'] = this.mPS;
    if (this.mPS != null) {
      data['MPS'] = this.mPS.toJson();
    }

    if (this.contacts != null) {
      data['Contacts'] = this.contacts.toJson();
    }
    if (this.aPFAX != null) {
      data['APFAX'] = this.aPFAX.toJson();
    }
    data['GenFax'] = this.genFax;
    if (this.fareQuote != null) {
      data['FareQuote'] = this.fareQuote.toJson();
    }
    if (this.payments != null) {
      data['Payments'] = this.payments.toJson();
    }
    data['TimeLimits'] = this.timeLimits;
    if (this.tickets != null) {
      data['Tickets'] = this.tickets.toJson();
    }
    if (this.remarks != null) {
      data['Remarks'] = this.remarks.toJson();
    }
    //data['TourOp'] = this.tourOp;
    if (this.rLE != null) {
      data['RLE'] = this.rLE.toJson();
    }
    if (this.basket != null) {
      data['Basket'] = this.basket.toJson();
    }
    data['zpay'] = this.zpay;
    if (this.pnrfields != null) {
      data['pnrfields'] = this.pnrfields.toJson();
    }
    if (this.fqfields != null) {
      data['fqfields'] = this.fqfields.toJson();
    }
    return data;
  }
}

class Names {
  List<PAX> pAX;

  Passengers getPassengerTypeCounts() {
    return Passengers(
      pAX.where((p) => p.paxType == 'AD').length,
      pAX.where((p) => p.paxType == 'CH').length,
      pAX.where((p) => p.paxType == 'IN').length,
      pAX.where((p) => p.paxType == 'TH').length,
      pAX.where((p) => p.paxType == 'CD').length,
      pAX.where((p) => p.paxType == 'SD').length,
      pAX.where((p) => p.paxType == 'TD').length
    );
  }

  Names({this.pAX});

  Names.fromJson(Map<String, dynamic> json) {
    if (json['PAX'] != null) {
      pAX = [];
      //new List<PAX>();
      if (json['PAX'] is List) {
        json['PAX'].forEach((v) {
          pAX.add(new PAX.fromJson(v));
        });
      } else {
        pAX.add(new PAX.fromJson(json['PAX']));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.pAX != null) {
      data['PAX'] = this.pAX.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PAX {
  String grpNo;
  String grpPaxNo;
  String paxNo;
  String title;
  String firstName;
  String surname;
  String paxType;
  String age;
  String awards;

  PAX(
      {this.grpNo,
      this.grpPaxNo,
      this.paxNo,
      this.title,
      this.firstName,
      this.surname,
      this.paxType,
      this.age,
      this.awards});

  PAX.fromJson(Map<String, dynamic> json) {
    grpNo = json['GrpNo'];
    grpPaxNo = json['GrpPaxNo'];
    paxNo = json['PaxNo'];
    title = json['Title'];
    firstName = json['FirstName'];
    surname = json['Surname'];
    paxType = json['PaxType'];
    age = json['Age'];
    awards = json['awards'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['GrpNo'] = this.grpNo;
    data['GrpPaxNo'] = this.grpPaxNo;
    data['PaxNo'] = this.paxNo;
    data['Title'] = this.title;
    data['FirstName'] = this.firstName;
    data['Surname'] = this.surname;
    data['PaxType'] = this.paxType;
    data['Age'] = this.age;
    data['awards'] = this.awards;
    return data;
  }
}

class Itinerary {
  List<Itin> itin;

  Itinerary({this.itin});

  Itinerary.fromJson(Map<String, dynamic> json) {
    if (json['Itin'] != null) {
      itin = [];
      // new List<Itin>();
      if (json['Itin'] is List) {
        json['Itin'].forEach((v) {
          itin.add(new Itin.fromJson(v));
        });
      } else {
        itin.add(new Itin.fromJson(json['Itin']));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.itin != null) {
      data['Itin'] = this.itin.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Itin {
  String line;
  String airID;
  String fltNo;
  String xclass;
  String depDate;
  String depart;
  String arrive;
  String status;
  String paxQty;
  String depTime;
  String arrTime;
  String arrOfst;
  String ddaygmt;
  String dtimgmt;
  String adaygmt;
  String atimgmt;
  String stops;
  String cabin;
  String gDSID;
  String gDSRLoc;
  String dMap;
  String aMap;
  String secID;
  String secRLoc;
  String mSL;
  String hosted;
  String nostop;
  String cnx;
  String classBand;
  String classBandDisplayName;
  String onlineCheckin;
  String operatedBy;
  String oAWebsite;
  String selectSeat;
  String mMBSelectSeat;
  String openSeating;

  Itin.getJounrey(
      // this.
      );

  Itin(
      {this.line,
      this.airID,
      this.fltNo,
      this.xclass,
      this.depDate,
      this.depart,
      this.arrive,
      this.status,
      this.paxQty,
      this.depTime,
      this.arrTime,
      this.arrOfst,
      this.ddaygmt,
      this.dtimgmt,
      this.adaygmt,
      this.atimgmt,
      this.stops,
      this.cabin,
      this.gDSID,
      this.gDSRLoc,
      this.dMap,
      this.aMap,
      this.secID,
      this.secRLoc,
      this.mSL,
      this.hosted,
      this.nostop,
      this.cnx,
      this.classBand,
      this.classBandDisplayName,
      this.onlineCheckin,
      this.operatedBy,
      this.oAWebsite,
      this.selectSeat,
      this.mMBSelectSeat,
      this.openSeating});

  Itin.fromJson(Map<String, dynamic> json) {
    line = json['Line'];
    airID = json['AirID'];
    fltNo = json['FltNo'];
    xclass = json['Class'];
    depDate = json['DepDate'];
    depart = json['Depart'];
    arrive = json['Arrive'];
    status = json['Status'];
    paxQty = json['PaxQty'];
    depTime = json['DepTime'];
    arrTime = json['ArrTime'];
    arrOfst = json['ArrOfst'];
    ddaygmt = json['ddaygmt'];
    dtimgmt = json['dtimgmt'];
    adaygmt = json['adaygmt'];
    atimgmt = json['atimgmt'];
    stops = json['Stops'];
    cabin = json['Cabin'];
    gDSID = json['GDSID'];
    gDSRLoc = json['GDSRLoc'];
    dMap = json['DMap'];
    aMap = json['AMap'];
    secID = json['SecID'];
    secRLoc = json['SecRLoc'];
    mSL = json['MSL'];
    hosted = json['Hosted'];
    nostop = json['nostop'];
    cnx = json['cnx'];
    classBand = json['ClassBand'];
    classBandDisplayName = json['ClassBandDisplayName'];
    onlineCheckin = json['onlineCheckin'];
    operatedBy = json['OperatedBy'];
    oAWebsite = json['OAWebsite'];
    selectSeat = json['SelectSeat'];
    mMBSelectSeat = json['MMBSelectSeat'];
    openSeating = json['OpenSeating'];
  }

  Object get cityPair => this.depart + this.arrive;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Line'] = this.line;
    data['AirID'] = this.airID;
    data['FltNo'] = this.fltNo;
    data['Class'] = this.xclass;
    data['DepDate'] = this.depDate;
    data['Depart'] = this.depart;
    data['Arrive'] = this.arrive;
    data['Status'] = this.status;
    data['PaxQty'] = this.paxQty;
    data['DepTime'] = this.depTime;
    data['ArrTime'] = this.arrTime;
    data['ArrOfst'] = this.arrOfst;
    data['ddaygmt'] = this.ddaygmt;
    data['dtimgmt'] = this.dtimgmt;
    data['adaygmt'] = this.adaygmt;
    data['atimgmt'] = this.atimgmt;
    data['Stops'] = this.stops;
    data['Cabin'] = this.cabin;
    data['GDSID'] = this.gDSID;
    data['GDSRLoc'] = this.gDSRLoc;
    data['DMap'] = this.dMap;
    data['AMap'] = this.aMap;
    data['SecID'] = this.secID;
    data['SecRLoc'] = this.secRLoc;
    data['MSL'] = this.mSL;
    data['Hosted'] = this.hosted;
    data['nostop'] = this.nostop;
    data['cnx'] = this.cnx;
    data['ClassBand'] = this.classBand;
    data['ClassBandDisplayName'] = this.classBandDisplayName;
    data['onlineCheckin'] = this.onlineCheckin;
    data['OperatedBy'] = this.operatedBy;
    data['OAWebsite'] = this.oAWebsite;
    data['SelectSeat'] = this.selectSeat;
    data['MMBSelectSeat'] = this.mMBSelectSeat;
    data['OpenSeating'] = this.openSeating;
    return data;
  }

  String getFlightDuration() {
    DateTime depart = DateTime.parse(this.ddaygmt + ' ' + this.dtimgmt);
    DateTime arrive = DateTime.parse(this.adaygmt + ' ' + this.atimgmt);
    int hours = arrive.difference(depart).inHours;
    int minutes = arrive.difference(depart).inMinutes % 60;
    String durationHours;
    String durationMinutes;
    durationHours = hours != 0 ? hours.toString() + 'h. ' : '';
    durationMinutes = minutes != 0 ? minutes.toString() + 'min. ' : '';
    return durationHours + durationMinutes;
  }
}

class Disruptions {
  List<Disruption> disruption;

  Disruptions({this.disruption});

  Disruptions.fromJson(Map<String, dynamic> json) {
    if (json['Disruption'] != null) {
      disruption = [];
      //new List<Disruption>();
      if (json['Disruption'] is List) {
        json['Disruption'].forEach((v) {
          disruption.add(new Disruption.fromJson(v));
        });
      } else {
        disruption.add(new Disruption.fromJson(json['Disruption']));
      }
    } else {
      disruption = null;
    }
  }
}

class Disruption {
  String flight;
  String flightDate;
  String departCity;
  String arriveCity;
  String xclass;
  String iD;

  Disruption(
      {this.flight,
      this.flightDate,
      this.departCity,
      this.arriveCity,
      this.xclass,
      this.iD});

  Disruption.fromJson(Map<String, dynamic> json) {
    flight = json['Flight'];
    flightDate = json['FlightDate'];
    departCity = json['DepartCity'];
    arriveCity = json['ArriveCity'];
    xclass = json['Class'];
    iD = json['ID'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Flight'] = this.flight;
    data['FlightDate'] = this.flightDate;
    data['DepartCity'] = this.departCity;
    data['ArriveCity'] = this.arriveCity;
    data['Class'] = this.xclass;
    data['ID'] = this.iD;
    return data;
  }
}

class MPS {
  // MP mP;

  //MPS({this.mP});

  // MPS.fromJson(Map<String, dynamic> json) {
  //   mP = json['MP'] != null ? new MP.fromJson(json['MP']) : null;
  // }

  List<MP> mP;
  MPS({this.mP});

  MPS.fromJson(Map<String, dynamic> json) {
    if (json['MP'] != null) {
      mP = [];
      //List<MP>();
      if (json['MP'] is List) {
        json['MP'].forEach((v) {
          mP.add(new MP.fromJson(v));
        });
      } else {
        mP.add(new MP.fromJson(json['MP']));
      }
    }
  }

  //Map<String, dynamic> toJson() {
  //  fg, dynamic>();
  //  if (this.mP != null) {
  //    data['MP'] = this.mP.toJson();
  //  }
  //  return data;
  //}

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.mP != null) {
      data['MP'] = this.mP.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MP {
  String line;
  String mPID;
  String pax;
  String seg;
  String mPSCur;
  String mPSAmt;
  String mPSID;
  String text;

  MP(
      {this.line,
      this.mPID,
      this.pax,
      this.seg,
      this.mPSCur,
      this.mPSAmt,
      this.mPSID,
      this.text});

  MP.fromJson(Map<String, dynamic> json) {
    line = json['Line'];
    mPID = json['MPID'];
    pax = json['Pax'];
    seg = json['Seg'];
    mPSCur = json['MPSCur'];
    mPSAmt = json['MPSAmt'];
    mPSID = json['MPSID'];
    text = json['#text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Line'] = this.line;
    data['MPID'] = this.mPID;
    data['Pax'] = this.pax;
    data['Seg'] = this.seg;
    data['MPSCur'] = this.mPSCur;
    data['MPSAmt'] = this.mPSAmt;
    data['MPSID'] = this.mPSID;
    data['#text'] = this.text;
    return data;
  }
}

class Contacts {
  List<CTC> cTC;

  Contacts({this.cTC});

  Contacts.fromJson(Map<String, dynamic> json) {
    if (json['CTC'] != null) {
      cTC = [];
      // new List<CTC>();
      if (json['CTC'] is List) {
        json['CTC'].forEach((v) {
          cTC.add(new CTC.fromJson(v));
        });
      } else {
        cTC.add(new CTC.fromJson(json['CTC']));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.cTC != null) {
      data['CTC'] = this.cTC.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class CTC {
  String line;
  String cTCID;
  String pax;
  String text;

  CTC({this.line, this.cTCID, this.pax, this.text});

  CTC.fromJson(Map<String, dynamic> json) {
    line = json['Line'];
    cTCID = json['CTCID'];
    pax = json['Pax'];
    text = json['#text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Line'] = this.line;
    data['CTCID'] = this.cTCID;
    data['Pax'] = this.pax;
    data['#text'] = this.text;
    return data;
  }
}

class APFAX {
  List<AFX> aFX;
  APFAX({this.aFX});

  APFAX.fromJson(Map<String, dynamic> json) {
    if (json['AFX'] != null) {
      aFX = [];
      // new List<AFX>();
      if (json['AFX'] is List) {
        json['AFX'].forEach((v) {
          aFX.add(new AFX.fromJson(v));
        });
      } else {
        aFX.add(new AFX.fromJson(json['AFX']));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.aFX != null) {
      data['AFX'] = this.aFX.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class AFX {
  String line;
  String aFXID;
  String pax;
  String seg;
  String seat;
  String text;
  String cur;
  String amt;
  String name;

  AFX(
      {this.line,
      this.aFXID,
      this.pax,
      this.seg,
      this.seat,
      this.text,
      this.cur,
      this.amt,
      this.name});

  AFX.fromJson(Map<String, dynamic> json) {
    line = json['Line'];
    aFXID = json['AFXID'];
    pax = json['Pax'];
    seg = json['Seg'];
    seat = json['seat'];
    text = json['#text'] == null ? '' : json['#text'];
    cur = json['cur'];
    amt = json['amt'] == null ? '0.0' : json['amt'];
    name = json['name'] == null ? '' : json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Line'] = this.line;
    data['AFXID'] = this.aFXID;
    data['Pax'] = this.pax;
    data['Seg'] = this.seg;
    data['Seat'] = this.seat;
    data['#text'] = this.text;
    data['cur'] = this.cur;
    data['amt'] = this.amt;
    data['name'] = this.name;
    return data;
  }
}

class GenFax {
  String line;
  String genFaxID;
  String pax;
  String seg;
  String text;

  GenFax({this.line, this.genFaxID, this.pax, this.seg, this.text});

  GenFax.fromJson(Map<String, dynamic> json) {
    line = json['Line'];
    genFaxID = json['GenFaxID'];
    pax = json['Pax'];
    seg = json['Seg'];
    text = json['text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Line'] = this.line;
    data['GenFaxID'] = this.genFaxID;
    data['Pax'] = this.pax;
    data['Seg'] = this.seg;
    data['text'] = this.text;
    return data;
  }
}

class FareQuote {
  List<FQItin> fQItin;
  List<FareStore> fareStore;
  List<FareTax> fareTax;

  FareQuote({this.fQItin, this.fareStore, this.fareTax});

  FareQuote.fromJson(Map<String, dynamic> json) {
    if (json['FQItin'] != null) {
      fQItin = [];
      //new List<FQItin>();
      if (json['FQItin'] is List) {
        json['FQItin'].forEach((v) {
          fQItin.add(new FQItin.fromJson(v));
        });
      } else {
        fQItin.add(new FQItin.fromJson(json['FQItin']));
      }
    }
    if (json['FareStore'] != null) {
      fareStore = [];
      // new List<FareStore>();
      if (json['FareStore'] is List) {
        json['FareStore'].forEach((v) {
          fareStore.add(new FareStore.fromJson(v));
        });
      } else {
        fareStore.add(new FareStore.fromJson(json['FareStore']));
      }
    }
    if (json['FareTax'] != null) {
      fareTax = [];
      // new List<FareTax>();
      if (json['FareTax'] is List) {
        json['FareTax'].forEach((v) {
          fareTax.add(new FareTax.fromJson(v));
        });
      } else {
        fareTax.add(new FareTax.fromJson(json['FareTax']));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.fQItin != null) {
      data['FQItin'] = this.fQItin.map((v) => v.toJson()).toList();
    }
    if (this.fareStore != null) {
      data['FareStore'] = this.fareStore.map((v) => v.toJson()).toList();
    }
    if (this.fareTax != null) {
      data['FareTax'] = this.fareTax.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FQItin {
  String seg;
  String cur;
  String curInf;
  String fQI;
  String fQB;
  String total;
  String fare;
  String tax1;
  String tax2;
  String tax3;
  String miles;

  FQItin(
      {this.seg,
      this.cur,
      this.curInf,
      this.fQI,
      this.fQB,
      this.total,
      this.fare,
      this.tax1,
      this.tax2,
      this.tax3,
      this.miles});

  FQItin.fromJson(Map<String, dynamic> json) {
    seg = json['Seg'];
    cur = json['Cur'];
    curInf = json['CurInf'];
    fQI = json['FQI'];
    fQB = json['FQB'];
    total = json['Total'];
    fare = json['Fare'];
    tax1 = json['Tax1'];
    tax2 = json['Tax2'];
    tax3 = json['Tax3'];
    miles = json['miles'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Seg'] = this.seg;
    data['Cur'] = this.cur;
    data['CurInf'] = this.curInf;
    data['FQI'] = this.fQI;
    data['FQB'] = this.fQB;
    data['Total'] = this.total;
    data['Fare'] = this.fare;
    data['Tax1'] = this.tax1;
    data['Tax2'] = this.tax2;
    data['Tax3'] = this.tax3;
    data['miles'] = this.miles;
    return data;
  }
}

class FareStore {
  String fSID;
  String pax;
  String cur;
  String curInf;
  String total;
  List<SegmentFS> segmentFS;

  FareStore(
      {this.fSID, this.pax, this.cur, this.curInf, this.total, this.segmentFS});

  FareStore.fromJson(Map<String, dynamic> json) {
    fSID = json['FSID'];
    pax = json['Pax'];
    cur = json['Cur'];
    curInf = json['CurInf'];
    total = json['Total'];
    if (json['SegmentFS'] != null) {
      segmentFS = [];
      // new List<SegmentFS>();
      if (json['SegmentFS'] is List) {
        json['SegmentFS'].forEach((v) {
          segmentFS.add(new SegmentFS.fromJson(v));
        });
      } else {
        segmentFS.add(new SegmentFS.fromJson(json['SegmentFS']));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FSID'] = this.fSID;
    data['Pax'] = this.pax;
    data['Cur'] = this.cur;
    data['CurInf'] = this.curInf;
    data['Total'] = this.total;
    if (this.segmentFS != null) {
      data['SegmentFS'] = this.segmentFS.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SegmentFS {
  String segFSID;
  String seg;
  String fare;
  String tax1;
  String tax2;
  String tax3;
  String miles;
  String disc;
  String holdPcs;
  String holdWt;
  String handWt;

  SegmentFS(
      {this.segFSID,
      this.seg,
      this.fare,
      this.tax1,
      this.tax2,
      this.tax3,
      this.miles,
      this.disc,
      this.handWt,
      this.holdPcs,
      this.holdWt});

  SegmentFS.fromJson(Map<String, dynamic> json) {
    segFSID = json['SegFSID'];
    seg = json['Seg'];
    fare = json['Fare'];
    tax1 = json['Tax1'];
    tax2 = json['Tax2'];
    tax3 = json['Tax3'];
    miles = json['miles'];
    handWt = json['HandWt'];
    holdPcs = json['HoldPcs'];
    holdWt = json['HoldWt'];

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SegFSID'] = this.segFSID;
    data['Seg'] = this.seg;
    data['Fare'] = this.fare;
    data['Tax1'] = this.tax1;
    data['Tax2'] = this.tax2;
    data['Tax3'] = this.tax3;
    data['miles'] = this.miles;
    data['disc'] = this.disc;
    data['HandWt'] = this.handWt;
    data['HoldWt'] = this.holdWt;
    data['HoldPcs'] = this.holdPcs;
    return data;
  }
}

class FareTax {
  List<PaxTax> paxTax;

  FareTax({this.paxTax});

  FareTax.fromJson(Map<String, dynamic> json) {
    if (json['PaxTax'] != null) {
      paxTax = [];
      //new List<PaxTax>();
      if (json['PaxTax'] is List) {
        json['PaxTax'].forEach((v) {
          paxTax.add(new PaxTax.fromJson(v));
        });
      } else {
        paxTax.add(new PaxTax.fromJson(json['PaxTax']));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.paxTax != null) {
      data['PaxTax'] = this.paxTax.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PaxTax {
  String seg;
  String pax;
  String code;
  String cur;
  String amnt;
  String curInf;
  String desc;
  String separate;

  PaxTax({this.seg, this.pax, this.code, this.cur, this.amnt, this.curInf, this.desc, this.separate});

  PaxTax.fromJson(Map<String, dynamic> json) {
    seg = json['Seg'];
    pax = json['Pax'];
    code = json['Code'];
    cur = json['Cur'];
    amnt = json['Amnt'];
    curInf = json['CurInf'];
    desc = json['desc'];
    separate = json['separate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Seg'] = this.seg;
    data['Pax'] = this.pax;
    data['Code'] = this.code;
    data['Cur'] = this.cur;
    data['Amnt'] = this.amnt;
    data['CurInf'] = this.curInf;
    data['desc'] = this.desc;
    data['separate'] = this.separate;
    return data;
  }
}

class Payments {
  //FOP fOP;

  //Payments({this.fOP});

  // Payments.fromJson(Map<String, dynamic> json) {
  //   fOP = json['FOP'] != null ? new FOP.fromJson(json['FOP']) : null;
  // }

  //Map<String, dynamic> toJson() {
  //  final Map<String, dynamic> data = new Map<String, dynamic>();
  ///  if (this.fOP != null) {
  //    data['FOP'] = this.fOP.toJson();
  //  }
  //  return data;
  //}

  List<FOP> fOP;

  Payments({this.fOP});

  Payments.fromJson(Map<String, dynamic> json) {
    if (json['FOP'] != null) {
      fOP = [];
      // new List<FOP>();
      if (json['FOP'] is List) {
        json['FOP'].forEach((v) {
          fOP.add(new FOP.fromJson(v));
        });
      } else {
        fOP.add(new FOP.fromJson(json['FOP']));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.fOP != null) {
      data['FOP'] = this.fOP.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class FOP {
  String line;
  String fOPID;
  String payCur;
  String payAmt;
  String pNRCur;
  String pNRAmt;
  String pNRExRate;
  String payDate;

  FOP(
      {this.line,
      this.fOPID,
      this.payCur,
      this.payAmt,
      this.pNRCur,
      this.pNRAmt,
      this.pNRExRate,
      this.payDate});

  FOP.fromJson(Map<String, dynamic> json) {
    line = json['Line'];
    fOPID = json['FOPID'];
    payCur = json['PayCur'];
    payAmt = json['PayAmt'];
    pNRCur = json['PNRCur'];
    pNRAmt = json['PNRAmt'];
    pNRExRate = json['PNRExRate'];
    payDate = json['PayDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Line'] = this.line;
    data['FOPID'] = this.fOPID;
    data['PayCur'] = this.payCur;
    data['PayAmt'] = this.payAmt;
    data['PNRCur'] = this.pNRCur;
    data['PNRAmt'] = this.pNRAmt;
    data['PNRExRate'] = this.pNRExRate;
    data['PayDate'] = this.payDate;
    return data;
  }
}

class TimeLimits {
  TTL tTL;

  TimeLimits({this.tTL});

  TimeLimits.fromJson(Map<String, dynamic> json) {
    tTL = json['TTL'] != null ? new TTL.fromJson(json['TTL']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.tTL != null) {
      data['TTL'] = this.tTL.toJson();
    }
    return data;
  }
}

class TTL {
  String tTLID;
  String tTLCity;
  String tTLQNo;
  String tTLTime;
  String tTLDate;
  String agCity;
  String sineCode;
  String sineType;
  String resDate;

  TTL(
      {this.tTLID,
      this.tTLCity,
      this.tTLQNo,
      this.tTLTime,
      this.tTLDate,
      this.agCity,
      this.sineCode,
      this.sineType,
      this.resDate});

  TTL.fromJson(Map<String, dynamic> json) {
    tTLID = json['TTLID'];
    tTLCity = json['TTLCity'];
    tTLQNo = json['TTLQNo'];
    tTLTime = json['TTLTime'];
    tTLDate = json['TTLDate'];
    agCity = json['AgCity'];
    sineCode = json['SineCode'];
    sineType = json['SineType'];
    resDate = json['ResDate'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['TTLID'] = this.tTLID;
    data['TTLCity'] = this.tTLCity;
    data['TTLQNo'] = this.tTLQNo;
    data['TTLTime'] = this.tTLTime;
    data['TTLDate'] = this.tTLDate;
    data['AgCity'] = this.agCity;
    data['SineCode'] = this.sineCode;
    data['SineType'] = this.sineType;
    data['ResDate'] = this.resDate;
    return data;
  }
}

class Tickets {
  List<TKT> tKT;

  Tickets({this.tKT});

  Tickets.fromJson(Map<String, dynamic> json) {
    if (json['TKT'] != null) {
      tKT = [];
      // new List<TKT>();
      if (json['TKT'] is List) {
        json['TKT'].forEach((v) {
          tKT.add(new TKT.fromJson(v));
        });
      } else {
        tKT.add(new TKT.fromJson(json['TKT']));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.tKT != null) {
      data['TKT'] = this.tKT.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class TKT {
  String pax;
  String tKTID;
  String tktNo;
  String coupon;
  String tktFltDate;
  String tktFltNo;
  String tktDepart;
  String tktArrive;
  String tktBClass;
  String issueDate;
  String status;
  String segNo;
  String title;
  String firstname;
  String surname;
  String tktFor;
  String sequenceNo;
  String loungeAccess;
  String fastTrack;

  TKT(
      {this.pax,
      this.tKTID,
      this.tktNo,
      this.coupon,
      this.tktFltDate,
      this.tktFltNo,
      this.tktDepart,
      this.tktArrive,
      this.tktBClass,
      this.issueDate,
      this.status,
      this.segNo,
      this.title,
      this.firstname,
      this.surname,
      this.tktFor,
      this.sequenceNo,
      this.loungeAccess,
      this.fastTrack});

  TKT.fromJson(Map<String, dynamic> json) {
    pax = json['Pax'];
    tKTID = json['TKTID'];
    tktNo = json['TktNo'];
    coupon = json['Coupon'];
    tktFltDate = json['TktFltDate'];
    tktFltNo = json['TktFltNo'];
    tktDepart = json['TktDepart'];
    tktArrive = json['TktArrive'];
    tktBClass = json['TktBClass'];
    issueDate = json['IssueDate'];
    status = json['Status'];
    segNo = json['SegNo'];
    title = json['Title'];
    firstname = json['Firstname'];
    surname = json['Surname'];
    tktFor = json['TktFor'];
    sequenceNo = json['SequenceNo'];
    loungeAccess = json['LoungeAccess'];
    fastTrack = json['FastTrack'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Pax'] = this.pax;
    data['TKTID'] = this.tKTID;
    data['TktNo'] = this.tktNo;
    data['Coupon'] = this.coupon;
    data['TktFltDate'] = this.tktFltDate;
    data['TktFltNo'] = this.tktFltNo;
    data['TktDepart'] = this.tktDepart;
    data['TktArrive'] = this.tktArrive;
    data['TktBClass'] = this.tktBClass;
    data['IssueDate'] = this.issueDate;
    data['Status'] = this.status;
    data['SegNo'] = this.segNo;
    data['Title'] = this.title;
    data['Firstname'] = this.firstname;
    data['Surname'] = this.surname;
    data['TktFor'] = this.tktFor;
    data['SequenceNo'] = this.sequenceNo;
    data['LoungeAccess'] = this.loungeAccess;
    data['FastTrack'] = this.fastTrack;
    return data;
  }
}

class Remarks {
  List<RMK> rMK;

  Remarks({this.rMK});

  Remarks.fromJson(Map<String, dynamic> json) {
    if (json['RMK'] != null) {
      rMK = [];
      // new List<RMK>();
      if (json['RMK'] is List) {
        json['RMK'].forEach((v) {
          rMK.add(new RMK.fromJson(v));
        });
      } else {
        rMK.add(new RMK.fromJson(json['RMK']));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.rMK != null) {
      data['RMK'] = this.rMK.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class RMK {
  String line;
  String rMKID;
  String text;

  RMK({this.line, this.rMKID, this.text});

  RMK.fromJson(Map<String, dynamic> json) {
    line = json['Line'];
    rMKID = json['RMKID'];
    text = json['#text'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Line'] = this.line;
    data['RMKID'] = this.rMKID;
    data['#text'] = this.text;
    return data;
  }
}

class RLE {
  String rLOC;
  String airID;
  String issOffCode;
  String city;
  String agType;
  String cur;
  String curInf;
  String sineCode;
  String rLEDate;
  String issagtidpnr;
  String issagtidtkt;

  RLE(
      {this.rLOC,
      this.airID,
      this.issOffCode,
      this.city,
      this.agType,
      this.cur,
      this.curInf,
      this.sineCode,
      this.rLEDate,
      this.issagtidpnr,
      this.issagtidtkt});

  RLE.fromJson(Map<String, dynamic> json) {
    rLOC = json['RLOC'];
    airID = json['AirID'];
    issOffCode = json['IssOffCode'];
    city = json['City'];
    agType = json['AgType'];
    cur = json['Cur'];
    curInf = json['CurInf'];
    sineCode = json['SineCode'];
    rLEDate = json['RLEDate'];
    issagtidpnr = json['issagtidpnr'];
    issagtidtkt = json['issagtidtkt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['RLOC'] = this.rLOC;
    data['AirID'] = this.airID;
    data['IssOffCode'] = this.issOffCode;
    data['City'] = this.city;
    data['AgType'] = this.agType;
    data['Cur'] = this.cur;
    data['CurInf'] = this.curInf;
    data['SineCode'] = this.sineCode;
    data['RLEDate'] = this.rLEDate;
    data['issagtidpnr'] = this.issagtidpnr;
    data['issagtidtkt'] = this.issagtidtkt;
    return data;
  }
}

class Basket {
  Outstanding outstanding;
  Outstandingairmiles outstandingairmiles;

  Basket({this.outstanding, this.outstandingairmiles});

  Basket.fromJson(Map<String, dynamic> json) {
    outstanding = json['Outstanding'] != null
        ? new Outstanding.fromJson(json['Outstanding'])
        : null;
    outstandingairmiles = json['Outstandingairmiles'] != null
        ? new Outstandingairmiles.fromJson(json['Outstandingairmiles'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.outstanding != null) {
      data['Outstanding'] = this.outstanding.toJson();
    }
    if (this.outstandingairmiles != null) {
      data['Outstandingairmiles'] = this.outstandingairmiles.toJson();
    }
    return data;
  }
}

class Outstanding {
  String cur;
  String curInf;
  String amount;
  String info;

  Outstanding({this.cur, this.curInf, this.amount, this.info});

  Outstanding.fromJson(Map<String, dynamic> json) {
    cur = json['cur'];
    curInf = json['CurInf'];
    amount = json['amount'];
    info = json['info'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cur'] = this.cur;
    data['CurInf'] = this.curInf;
    data['amount'] = this.amount;
    data['info'] = this.info;
    return data;
  }
}

class Outstandingairmiles {
  String cur;
  String curInf;
  String amount;
  String info;
  String airmiles;

  Outstandingairmiles(
      {this.cur, this.curInf, this.amount, this.info, this.airmiles});

  Outstandingairmiles.fromJson(Map<String, dynamic> json) {
    cur = json['cur'];
    curInf = json['CurInf'];
    amount = json['amount'];
    info = json['info'];
    airmiles = json['airmiles'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cur'] = this.cur;
    data['CurInf'] = this.curInf;
    data['amount'] = this.amount;
    data['info'] = this.info;
    data['airmiles'] = this.airmiles;
    return data;
  }
}

class Zpay {
  String scheme;
  String reference;
  String info;
  String mbamount;
  String mbcurrency;
  String mbtotalfare;
  String mbtotaltax;
  String ttl;

  Zpay(
      {this.scheme,
      this.reference,
      this.info,
      this.mbamount,
      this.mbcurrency,
      this.mbtotalfare,
      this.mbtotaltax,
      this.ttl});

  Zpay.fromJson(Map<String, dynamic> json) {
    scheme = json['scheme'];
    reference = json['reference'];
    info = json['info'];
    mbamount = json['mbamount'];
    mbcurrency = json['mbcurrency'];
    mbtotalfare = json['mbtotalfare'];
    mbtotaltax = json['mbtotaltax'];
    ttl = json['ttl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['scheme'] = this.scheme;
    data['reference'] = this.reference;
    data['info'] = this.info;
    data['mbamount'] = this.mbamount;
    data['mbcurrency'] = this.mbcurrency;
    data['mbtotalfare'] = this.mbtotalfare;
    data['mbtotaltax'] = this.mbtotaltax;
    data['ttl'] = this.ttl;
    return data;
  }
}

class Pnrfields {
  String originissoffcode;

  Pnrfields({this.originissoffcode});

  Pnrfields.fromJson(Map<String, dynamic> json) {
    originissoffcode = json['originissoffcode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['originissoffcode'] = this.originissoffcode;
    return data;
  }
}

class Fqfields {
  List<Fqfield> fqfield;

  Fqfields({this.fqfield});

  Fqfields.fromJson(Map<String, dynamic> json) {
    if (json['fqfield'] != null) {
      fqfield = [];
      // new List<Fqfield>();
      if (json['fqfield'] is List) {
        json['fqfield'].forEach((v) {
          fqfield.add(new Fqfield.fromJson(v));
        });
      } else {
        fqfield.add(new Fqfield.fromJson(json['fqfield']));
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.fqfield != null) {
      data['fqfield'] = this.fqfield.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Fqfield {
  String line;
  String fareid;
  String finf;

  Fqfield({this.line, this.fareid, this.finf});

  Fqfield.fromJson(Map<String, dynamic> json) {
    line = json['line'];
    fareid = json['fareid'];
    finf = json['finf'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['line'] = this.line;
    data['fareid'] = this.fareid;
    data['finf'] = this.finf;
    return data;
  }
}


import 'package:intl/intl.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/data/models/pax.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/utilities/timeHelper.dart';
import '../../Helpers/settingsHelper.dart';
import '../../Helpers/stringHelpers.dart';
import '../../components/trText.dart';
import 'models.dart';


bool logPnrErrors = false;
class PnrModel {
  bool success=true;
  PNR pNR = PNR();

  PnrModel();

  PnrModel.fromJson(Map<String, dynamic> json) {
    if( json['PNR'] != null) {
      pNR =  PNR.fromJson(json['PNR']);
    }
    success = json['PNR'] != null ? true : false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.pNR != null) {
      data['PNR'] = this.pNR.toJson();
    }
    return data;
  }

  String getBookingCurrency() {
    if( this.pNR.payments != null && this.pNR.payments.fOP != null &&
        this.pNR.payments.fOP.length > 0  ) {
      return this.pNR.payments.fOP[0].payCur;
    }

    return gblSettings.currency;
  }

  List<Pax> getBookedPaxList(int journey) {
    List<Pax> paxlist = [];
    for (var pax = 0; pax <= pNR.names.pAX.length - 1; pax++) {
      if (pNR.names.pAX[pax].paxType != 'IN') {
        paxlist.add(Pax(
            pNR.names.pAX[pax].firstName +
                ' ' +
                pNR.names.pAX[pax].surname,
            pNR.aPFAX != null
                ? pNR.aPFAX.aFX
                .firstWhere(
                    (aFX) =>
                aFX.aFXID == "SEAT" &&
                    aFX.pax == pNR.names.pAX[pax].paxNo &&
                    aFX.seg == (journey + 1).toString(),
                orElse: () => new AFX())
                .seat
                : '',
            pax == 0 ? true : false,
            pax + 1,
            pNR.aPFAX != null
                ? pNR.aPFAX.aFX
                .firstWhere(
                    (aFX) =>
                aFX.aFXID == "SEAT" &&
                    aFX.pax == pNR.names.pAX[pax].paxNo &&
                    aFX.seg == (journey + 1).toString(),
                orElse: () => new AFX())
                .seat
                : '',
            pNR.names.pAX[pax].paxType));
      }
    }
    return paxlist;
  }

  bool isSeatInPnr(String savedMsg) {
    if( savedMsg == '' || savedMsg.length < 10 ){
      return false;
    }
    bool bFound = false;
    // 4-1S1FRQST7C
    // 4- <paxno> S <segNo> FRQT <seatno>
    String paxNo = savedMsg.substring(2,3);
    String segNo = savedMsg.substring(4,5);
    try{
      this.pNR.mPS.mP.forEach((element){
        if( element.mPID == 'SSSS' &&
          element.seg == segNo &&
          element.pax == paxNo ){
          bFound =  true;
          logit('seat found');
        }
      });
    } catch(e) {
      logit('isSeatInPnt ${e.toString()}');
    }
        return bFound;
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

  bool allPaxCheckedIn() {
    if (this.pNR != null &&
        this.pNR.tickets != null   ) {
      bool checkedIn = true;
      this.pNR.tickets.tKT.forEach((element) {
        if( element.tKTID != 'ELFT' && element.tktFor != 'MPD') {
          checkedIn = false;
        }
      });
      return checkedIn;
    }
    return false;
  }

  bool isFundTransferPayment() {
    if (this.pNR != null &&
        this.pNR.zpay != null &&
        this.pNR.timeLimits != null &&
        this.pNR.basket.outstanding != null &&
        this.pNR.basket.outstanding.amount.isNotEmpty &&
        double.parse(this.pNR.basket.outstanding.amount) > 0  ) {
      // &&
      //         this.pNR.tickets ==null

      return true;
    }
    return false;
  }

  bool hasContactDetails() {
    bool bFound = false;
    if (this.pNR != null &&
        this.pNR.contacts != null &&
        this.pNR.contacts.cTC != null &&
        this.pNR.contacts.cTC.length >= 1  ) {
      this.pNR.contacts.cTC.forEach((element) {
        if( element.cTCID == 'E') {
          bFound =  true;
        }
      });
      return bFound;
    }
    return false;
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

  bool paxHasInfant(Pax pax) {
    if( gblPnrModel == null ) return false;

    bool found = false;
    gblPnrModel!.pNR.aPFAX.aFX.forEach((element) {
      if( element.text.contains('P${pax.id}')){
        found =  true;
      }
    });
    return found ;
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
    if(this.pNR == null || this.pNR.itinerary == null || this.pNR.itinerary.itin == null ){
      return false;
    }
    DateTime now = DateTime.now();
/*
    var fltDate;
    fltDate = DateTime.parse(this.pNR.itinerary.itin.last.depDate +
        ' ' +
        this.pNR.itinerary.itin.last.depTime)
        .add(Duration(days: days));
*/
    DateTime fltDate = DateTime.parse(this.pNR.itinerary.itin.last.ddaygmt + ' ' + this.pNR.itinerary.itin.last.dtimgmt);
    fltDate = fltDate.add(Duration(days: days));
    if (getGmtTime().isAfter(fltDate)) {
      return false;
    } else {
      return true;
    }
  }
  bool hasFutureFlightsMinusDayOffset(int days) {
    if(this.pNR == null || this.pNR.itinerary == null || this.pNR.itinerary.itin == null ){
      return false;
    }
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
    if (flt.depDate != null && flt.depTime != null && flt.depDate != '' && flt.depTime != '') {
      _millisecondsSinceEpoch = DateTime.parse(flt.depDate + ' ' + flt.depTime)
          .millisecondsSinceEpoch;
    }

    return _millisecondsSinceEpoch;
  }

  Itin getNextFlight() {
    Itin flight = new Itin();
    if (this.pNR != null && this.pNR.itinerary != null && this.pNR.itinerary.itin != null &&
        this.pNR.itinerary.itin.length != 0 && this.pNR.itinerary.itin[0].airID != '') {
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

    if (!hasTickets(this.pNR.tickets) && gblSettings.needTicketsToImport ) {
      if( gblSettings.displayErrorPnr) {
        gblError += '   No Tickets';
        return '';
      } else {
        return 'No Tickets';
      }
    }
    if (!validateTickets(this.pNR)  && gblSettings.needTicketsToImport) {
      return 'Please contact ${gblSettings.airlineName} to complete booking: tickets not valid';

//      return 'Tickets invalid';
    }

    return '';
  }

  // must has tickets with status OPEN ('O') to be refundable
  bool canRefund(int journeyToChange) {
    if( this.pNR.itinerary == null || this.pNR.itinerary.itin == null || this.pNR.itinerary.itin.length == 0 || this.pNR.itinerary.itin.length < journeyToChange-1){
      return false;
    }

    if( this.pNR.tickets == null || this.pNR.tickets.tKT == null || this.pNR.tickets.tKT.length == 0){
      return false;
    }
    bool bcanRefund = false;
    this.pNR.tickets.tKT.forEach((ticket) {
      if( ticket.segNo.isNotEmpty && int.parse(ticket.segNo) == (journeyToChange)){
        if( ticket.tKTID == 'ETKT' && ticket.status=='O') {
          bcanRefund =  true;
        }
      }
    });
    return bcanRefund;
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
            tkt.surname == pax.surname
            &&            tkt.tktFor != 'MPD'); // chargable seats get MPD !!!

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
                    t.tktFltNo == (flt.airID + flt.fltNo)
                    &&                      t.tktBClass == flt.xclass,
                //  orElse: () => null
              );
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
          if( logPnrErrors) print('validateTickets = false;');
//         return validateTickets;
        }

        if ((tickets.length !=
            pnr.itinerary.itin
                .where((flt) => flt.status == 'HK' || flt.status == 'RR')
                .length)) {
          validateTickets = false;
          if( logPnrErrors) print('validateTickets = false;');
//          return validateTickets;
        }
//        return validateTickets;
      });
    } catch (ex) {
      if( logPnrErrors) print(ex.toString());
      validateTickets = false;
      if( logPnrErrors) print('validateTickets = false;');
    }
    return validateTickets;
  }

  double amountOutstanding() {
    if( pNR != null && pNR.basket != null ){
      if( pNR.basket.outstanding != null ){
        if( pNR.basket.outstanding.amount != null && pNR.basket.outstanding.amount != '' && pNR.basket.outstanding.amount != '0')
          {
            return double.parse(pNR.basket.outstanding.amount);
          }
        if( pNR.basket.outstandingairmiles.amount != null && pNR.basket.outstandingairmiles.amount != '' && pNR.basket.outstandingairmiles.amount != '0')
        {
          return double.parse(pNR.basket.outstandingairmiles.amount);
        }
      }
    }
    return 0;
  }

  bool hasTickets(Tickets tickets) {
    bool hasTickets = false;
    if (tickets != null && tickets.tKT != null && tickets.tKT.length > 0 && tickets.tKT[0].tKTID != '') {
      hasTickets = true;
    } else {
      hasTickets = false;
      if( logPnrErrors) print('hasTickets = false');
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
      if( logPnrErrors)  print('hasItinerary = false');
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
      if( logPnrErrors) print('validateItineraryStatus = false');
    }
    return validateItineraryStatus;
  }

  bool validatePayment(Basket basket) {
    bool validatePayment = false;
    if (basket.outstanding.amount == '0') {
      validatePayment = true;
    } else {
      if( double.parse(basket.outstanding.amount) <= 0 ){
        if( logPnrErrors) print('validatePayment less than 0;');
        validatePayment = true;
      } else {
        // allow payment outstanding
        validatePayment = true;
      }
    }
    return validatePayment;
  }
}

class PNR {
  String appVersion='';
  String rLOC='';
  String aDS='';
  String pNRLocked='';
  String pNRLockedReason='';
  String secureFlight='';
  String sfpddob='';
  String sfpdgndr='';
  String showFares='';
  String needFG='';
  String needFSM='';
  bool editFlights=false;
  String editProducts='';
  bool editPNR=true;
  Names names = Names();
  Itinerary itinerary = Itinerary();
  Disruptions disruptions=Disruptions();
  //Null mPS;
  MPS mPS=MPS();
  Contacts contacts=Contacts();
  APFAX aPFAX=APFAX();
  //Null genFax;
  GenFax genFax=GenFax();
  FareQuote fareQuote=FareQuote();
  Payments payments=Payments();
  //Null timeLimits;
  TimeLimits timeLimits=TimeLimits();
  Tickets tickets=Tickets();
  Remarks remarks=Remarks();
  //Null tourOp;
  //TourOp tourOp;
  RLE rLE=RLE();
  Basket basket=Basket();
  //Null zpay;
  Zpay zpay=Zpay();
  Pnrfields pnrfields=Pnrfields();
  Fqfields fqfields=Fqfields();

  PNR(      );

  PNR.fromJson(Map<String, dynamic> json) {

    if( json['APPVERSION'] != null)appVersion = json['APPVERSION'];
    if( json['RLOC'] != null )rLOC = json['RLOC'];
  //  rLOC = json['nullsa']; //force error
    if( json['ADS'] != null )aDS = json['ADS'];
    if(  json['PNRLocked'] != null )pNRLocked = json['PNRLocked'];
    if( json['PNRLockedReason'] != null )pNRLockedReason = json['PNRLockedReason'];
    if(  json['SecureFlight'] != null )secureFlight = json['SecureFlight'];
    if( json['sfpddob'] != null )sfpddob = json['sfpddob'];
    if( json['sfpdgndr'] != null )sfpdgndr = json['sfpdgndr'];
    if(  json['showFares'] != null )showFares = json['showFares'];
    if( json['NeedFG']!= null )needFG = json['NeedFG'];
    if( json['NeedFSM'] != null )needFSM = json['NeedFSM'];
    if( json['editFlights'] != null )editFlights = json['editFlights'].toString().toLowerCase() == 'true';
    if( json['editProducts'] != null )editProducts = json['editProducts'];
    if( json['editPNR'] != null )editPNR = json['editPNR'].toString().toLowerCase() == 'true';
    if( json['Names'] != null ) names =  Names.fromJson(json['Names']) ;
    if(json['Itinerary'] != null) itinerary = Itinerary.fromJson(json['Itinerary']);
    if( json['Disruptions'] != null) disruptions = Disruptions.fromJson(json['Disruptions']);
    if(json['MPS'] != null ) mPS =MPS.fromJson(json['MPS']) ;
    if(json['Contacts'] != null) contacts =Contacts.fromJson(json['Contacts']);
    if(json['APFAX'] != null ) aPFAX =APFAX.fromJson(json['APFAX']) ;
    if(json['GenFax'] != null ) genFax =GenFax.fromJson(json['GenFax']) ;
    if(json['FareQuote'] != null) fareQuote =FareQuote.fromJson(json['FareQuote']);
    if(json['Payments'] != null) payments =Payments.fromJson(json['Payments']);
    //timeLimits = json['TimeLimits'];
    if(json['TimeLimits'] != null) timeLimits =TimeLimits.fromJson(json['TimeLimits']);
    if(json['Tickets'] != null) tickets =Tickets.fromJson(json['Tickets']) ;
    if(json['Remarks'] != null) remarks =  Remarks.fromJson(json['Remarks']) ;
    if(json['RLE'] != null) rLE =  RLE.fromJson(json['RLE']) ;
    if(json['Basket'] != null ) basket = Basket.fromJson(json['Basket']) ;
    //zpay = json['zpay'];
    if(json['zpay'] != null) zpay = Zpay.fromJson(json['zpay']) ;
    if(json['pnrfields'] != null) pnrfields = Pnrfields.fromJson(json['pnrfields']);
    if(json['fqfields'] != null) fqfields =  Fqfields.fromJson(json['fqfields']);
  }

  bool isFQTVBooking(){
    bool retVal = false;
    if( this.payments != null && this.payments.fOP != null &&
        this.payments.fOP.length > 0  ) {
      this.payments.fOP.forEach((fop) {
        if(fop.fOPID == 'FFF'){
          retVal =  true;
        }
      });
    }

    return retVal;
  }


  int seatCount() {
    if( aPFAX == null || aPFAX.aFX == null ) {
      return 0;
    }
    int noSeats = 0;
    aPFAX.aFX.forEach((element) {
      if( element.aFXID =='SEAT'){
        noSeats ++;
      }
    });
    return noSeats;
  }
  int paxCount() {
    if( names == null || names.pAX == null ) {
      return 0;
    }
    int noSeats = 0;
    names.pAX.forEach((element) {
      noSeats ++;
    });
    return noSeats;
  }

  void dumpProducts(String from ) {
    if( gblLogProducts ) { logit('Products dump: $from');}
    if( mPS == null || mPS.mP == null ) {
      if( gblLogProducts ) { logit('None');}
      return ;
    }
/*   mPS.mP.forEach((p) {
      if( gblLogProducts ) {
        logit('${p.line} ${p.mPID} P=${p.pax} S=${p.seg} ${p.text}');
      };
    }
    );*/
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
    data['APPVERSION'] = this.appVersion;
    data['RLOC'] = this.rLOC;
    data['ADS'] = this.aDS;
    data['PNRLocked'] = this.pNRLocked;
    data['PNRLockedReason'] = this.pNRLockedReason;
    data['SecureFlight'] = this.secureFlight;
    data['sfpddob'] = this.sfpddob;
    data['sfpdgndr'] = this.sfpdgndr;
    data['showFares'] = this.showFares;
    data['NeedFG'] = this.needFG;
    data['NeedFSM'] = this.needFSM;
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
  List<PAX> pAX = List.from([PAX()]);

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

  Names();

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
  String grpNo='';
  String grpPaxNo='';
  String paxNo='';
  String title='';
  String firstName='';
  String surname='';
  String paxType='';
  String age='';
  String awards='';

  PAX();

  PAX.fromJson(Map<String, dynamic> json) {
    if(json['GrpNo'] != null )grpNo = json['GrpNo'];
    if(json['GrpPaxNo'] != null )grpPaxNo = json['GrpPaxNo'];
    if(json['PaxNo'] != null )paxNo = json['PaxNo'];
    if(json['Title'] != null )title = json['Title'];
    if(json['FirstName'] != null )firstName = json['FirstName'];
    if(json['Surname'] != null )surname = json['Surname'];
    if(json['PaxType'] != null )paxType = json['PaxType'];
    if(json['Age'] != null )age = json['Age'];
    if(json['awards'] != null )awards = json['awards'];
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
  List<Itin> itin = List.from([Itin()]);

  Itinerary();

  Itinerary.fromJson(Map<String, dynamic> json) {
    if (json['ItinMsg'] != null) {
      //throw(json['ItinMsg']);
    }

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
    } else {
      itin = [];
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
  String line='';
  String airID='';
  String fltNo='';
  String xclass='';
  String depDate='';
  String depart='';
  String arrive='';
  String status='';
  String paxQty='';
  String depTime='';
  String arrTime='';
  String arrOfst='';
  String ddaygmt='';
  String dtimgmt='';
  String adaygmt='';
  String atimgmt='';
  String stops='';
  String cabin='';
  String gDSID='';
  String gDSRLoc='';
  String dMap='';
  String aMap='';
  String secID='';
  String secRLoc='';
  String mSL='';
  String hosted='';
  String nostop='';
  String cnx='';
  String classBand='';
  String classBandDisplayName='';
  String onlineCheckin='';
  String operatedBy='';
  String oAWebsite='';
  String selectSeat='';
  String mMBSelectSeat='';
  String openSeating='';
  String mMBCheckinAllowed='';
  String onlineCheckinTimeStartGMT='';
  String onlineCheckinTimeEndGMT='';
  String onlineCheckinTimeStartLocal='';
  String onlineCheckinTimeEndLocal='';
  bool editFlight= true;

  Itin.getJounrey(
      // this.
      );

  Itin();

  Itin.fromJson(Map<String, dynamic> json) {
    if(json['Line'] != null )line = json['Line'];
    if(json['AirID'] != null )airID = json['AirID'];
    if(json['FltNo'] != null )fltNo = json['FltNo'];
    if(json['Class'] != null )xclass = json['Class'];
    if(json['DepDate'] != null )depDate = json['DepDate'];
    if(json['Depart'] != null )depart = json['Depart'];
    if(json['Arrive'] != null )arrive = json['Arrive'];
    if(json['Status'] != null )status = json['Status'];
    if(json['PaxQty'] != null )paxQty = json['PaxQty'];
    if(json['DepTime'] != null )depTime = json['DepTime'];
    if(json['ArrTime'] != null )arrTime = json['ArrTime'];
    if(json['ArrOfst'] != null )arrOfst = json['ArrOfst'];
    if(json['ddaygmt'] != null )ddaygmt = json['ddaygmt'];
    if(json['dtimgmt'] != null )dtimgmt = json['dtimgmt'];
    if(json['adaygmt'] != null )adaygmt = json['adaygmt'];
    if(json['atimgmt'] != null )atimgmt = json['atimgmt'];
    if(json['Stops'] != null )stops = json['Stops'];
    if(json['Cabin'] != null )cabin = json['Cabin'];
    if(json['GDSID'] != null )gDSID = json['GDSID'];
    if(json['GDSRLoc'] != null )gDSRLoc = json['GDSRLoc'];
    if(json['DMap'] != null )dMap = json['DMap'];
    if(json['AMap'] != null )aMap = json['AMap'];
    if(json['SecID'] != null )secID = json['SecID'];
    if(json['SecRLoc'] != null )secRLoc = json['SecRLoc'];
    if(json['MSL'] != null )mSL = json['MSL'];
    if(json['Hosted'] != null )hosted = json['Hosted'];
    if(json['nostop'] != null )nostop = json['nostop'];
    if(json['cnx'] != null )cnx = json['cnx'];
    if(json['ClassBand'] != null )classBand = json['ClassBand'];
    if(json['ClassBandDisplayName'] != null )classBandDisplayName = json['ClassBandDisplayName'];
    if(json['onlineCheckin'] != null )onlineCheckin = json['onlineCheckin'];
    if(json['OperatedBy'] != null )operatedBy = json['OperatedBy'];
    if(json['OAWebsite'] != null )oAWebsite = json['OAWebsite'];
    if(json['SelectSeat'] != null )selectSeat = json['SelectSeat'];
    if(json['MMBSelectSeat'] != null )mMBSelectSeat = json['MMBSelectSeat'];
    if(json['OpenSeating'] != null )openSeating = json['OpenSeating'];
    if(json['MMBCheckinAllowed'] != null )mMBCheckinAllowed = json['MMBCheckinAllowed'];
    if(json['OnlineCheckinTimeEndGMT'] != null )onlineCheckinTimeEndGMT = json['OnlineCheckinTimeEndGMT'];
    if(json['OnlineCheckinTimeStartGMT'] != null )onlineCheckinTimeStartGMT = json['OnlineCheckinTimeStartGMT'];
    if(json['OnlineCheckinTimeEndLocal'] != null )onlineCheckinTimeEndLocal = json['OnlineCheckinTimeEndLocal'];
    if(json['OnlineCheckinTimeStartLocal'] != null )onlineCheckinTimeStartLocal = json['OnlineCheckinTimeStartLocal'];
    if( json['editFlight'] != null ) editFlight = json['editFlight'].toString().toLowerCase() == 'true';
    logit('edit flight = $editFlight');
  }

  String get cityPair => this.depart + this.arrive;

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
    data['MMBCheckinAllowed'] = mMBCheckinAllowed;
    data['OnlineCheckinTimeEndGMT'] = onlineCheckinTimeEndGMT ;
    data['OnlineCheckinTimeStartGMT'] = onlineCheckinTimeStartGMT;
    data['editFlight'] = editFlight.toString();

    return data;
  }

  DateTime getDepartureDateTime(){
    return DateTime.parse(depDate + ' ' + depTime);
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
    if( wantRtl()) {
      return translateNo('$hours') + translate('h.') + ' ' + translateNo('$minutes') + translate('min');
    }

    return durationHours + durationMinutes;
  }
}

class Disruptions {
  List<Disruption> disruption = List.from([Disruption()]);

  Disruptions();

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
    }
  }
}

class Disruption {
  String flight='';
  String flightDate='';
  String departCity='';
  String arriveCity='';
  String xclass='';
  String iD='';

  Disruption();

  Disruption.fromJson(Map<String, dynamic> json) {
    if(json['Flight'] != null )flight = json['Flight'];
    if( json['FlightDate'] != null )flightDate = json['FlightDate'];
    if( json['DepartCity'] != null )departCity = json['DepartCity'];
    if( json['ArriveCity']!= null )arriveCity = json['ArriveCity'];
    if( json['Class'] != null )xclass = json['Class'];
    if( json['ID'] != null)iD = json['ID'];
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

  List<MP> mP = List.from([MP()]);
  MPS();

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
  String line='';
  String mPID='';
  String pax='';
  String seg='';
  String mPSCur='';
  String mPSAmt='';
  String mPSID='';
  String text='';

  MP();

  MP.fromJson(Map<String, dynamic> json) {
    if( json['Line'] != null)line = json['Line'];
    if( json['MPID'] != null )mPID = json['MPID'];
    if( json['Pax'] != null)pax = json['Pax'];
    if( json['Seg'] != null )seg = json['Seg'];
    if( json['MPSCur'] != null )mPSCur = json['MPSCur'];
    if( json['MPSAmt'] != null )mPSAmt = json['MPSAmt'];
    if( json['MPSID'] != null )mPSID = json['MPSID'];
    if( json['#text'] != null )text = json['#text'];
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
  List<CTC> cTC = List.from([CTC()]);

  Contacts();

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
  String line='';
  String cTCID='';
  String pax='';
  String text='';

  CTC();

  CTC.fromJson(Map<String, dynamic> json) {
    if( json['Line'] != null)line = json['Line'];
    if( json['CTCID'] != null)cTCID = json['CTCID'];
    if( json['Pax']!= null)pax = json['Pax'];
    if( json['#text']!= null )text = json['#text'];
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
  List<AFX> aFX = List.from([AFX()]);
  APFAX();

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
  String line='';
  String aFXID='';
  String pax='';
  String seg='';
  String seat='';
  String text='';
  String cur='';
  String amt='';
  String name='';

  AFX({this.seat=''});

  AFX.fromJson(Map<String, dynamic> json) {
    if(json['Line'] != null )line = json['Line'];
    if( json['AFXID']!= null )aFXID = json['AFXID'];
    if( json['Pax']!= null)pax = json['Pax'];
    if( json['Seg']!= null)seg = json['Seg'];
    if( json['seat']!= null )seat = json['seat'];
    if(  json['#text']!= null )text = json['#text'];
    if( json['cur']!= null)cur = json['cur'];
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
  List<GFX> gFX = List.from([GFX()]);
  GenFax();

  GenFax.fromJson(Map<String, dynamic> json) {
    if (json['AFX'] != null) {
      gFX = [];
      // new List<AFX>();
      if (json['GFX'] is List) {
        json['GFX'].forEach((v) {
          gFX.add(new GFX.fromJson(v));
        });
      } else {
        gFX.add(new GFX.fromJson(json['GFX']));
      }
    }
  }

}



class GFX {
  String line='';
  String genFaxID='';
  String pax='';
  String seg='';
  String text='';

  GFX();

  GFX.fromJson(Map<String, dynamic> json) {
    if( json['Line']!= '') line = json['Line'];
    if(json['GenFaxID'] != '' ) genFaxID = json['GenFaxID'];
    if( json['Pax'] != '' ) pax = json['Pax'];
    if( json['Seg'] != '') seg = json['Seg'];
    if( json['text'] != '') text = json['text'];
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
  List<FQItin> fQItin = List.from([FQItin()]);
  List<FareStore> fareStore =List.from([FareStore()]);
  List<FareTax> fareTax = List.from([FareTax()]);

  FareQuote();

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
  String seg='';
  String cur='';
  String curInf='';
  String fQI='';
  String fQB='';
  String total='';
  String fare='';
  String tax1='';
  String tax2='';
  String tax3='';
  String miles='';

  FQItin();

  FQItin.fromJson(Map<String, dynamic> json) {
    if( json['Seg']!= null)seg = json['Seg'];
    if(json['Cur']!= null)cur = json['Cur'];
    if( json['CurInf']!= null )curInf = json['CurInf'];
    if(json['FQI']!= null )fQI = json['FQI'];
    if(json['FQB']!= null)fQB = json['FQB'];
    if(json['Total']!= null )total = json['Total'];
    if(json['Fare']!= null)fare = json['Fare'];
    if(json['Tax1']!= null)tax1 = json['Tax1'];
    if(json['Tax2']!= null)tax2 = json['Tax2'];
    if(json['Tax3']!= null)tax3 = json['Tax3'];
    if(json['miles']!= null)miles = json['miles'];
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
  String fSID='';
  String pax='';
  String cur='';
  String curInf='';
  String total='';
  List<SegmentFS> segmentFS = List.from([SegmentFS()]);

  FareStore();

  FareStore.fromJson(Map<String, dynamic> json) {
    if( json['FSID']!= null)fSID = json['FSID'];
    if(json['Pax']!= null)pax = json['Pax'];
    if(json['Cur']!= null)cur = json['Cur'];
    if(json['CurInf']!= null)curInf = json['CurInf'];
    if(json['Total']!= null)total = json['Total'];
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
  String segFSID='';
  String seg='';
  String fare='';
  String tax1='';
  String tax2='';
  String tax3='';
  String miles='';
  String disc='';
  String holdPcs='';
  String holdWt='';
  String handWt='';

  SegmentFS();

  SegmentFS.fromJson(Map<String, dynamic> json) {
    if( json['SegFSID'] != null )segFSID = json['SegFSID'];
    if( json['Seg'] != null )seg = json['Seg'];
    if( json['Fare'] != null )fare = json['Fare'];
    if( json['Tax1'] != null )tax1 = json['Tax1'];
    if( json['Tax2'] != null )tax2 = json['Tax2'];
    if( json['Tax3'] != null )tax3 = json['Tax3'];
    if( json['iles'] != null )miles = json['miles'];
    if( json['HandWt'] != null )handWt = json['HandWt'];
    if( json['HoldPcs'] != null )holdPcs = json['HoldPcs'];
    if( json['HoldWt'] != null )holdWt = json['HoldWt'];

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
  List<PaxTax> paxTax =List.from([PaxTax()]);

  FareTax();

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
  String seg='';
  String pax='';
  String code='';
  String cur='';
  String amnt='';
  String curInf='';
  String desc='';
  String separate='';

  PaxTax();

  PaxTax.fromJson(Map<String, dynamic> json) {
    if(json['Seg']!= null)seg = json['Seg'];
    if(json['Pax']!= null)pax = json['Pax'];
    if(json['Code']!= null)code = json['Code'];
    if(json['Cur']!= null)cur = json['Cur'];
    if(json['Amnt']!=null)amnt = json['Amnt'];
    if(json['CurInf']!= null)curInf = json['CurInf'];
    if(json['desc']!=null)desc = json['desc'];
    if(json['separate']!=null)separate = json['separate'];
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

  List<FOP> fOP = List.from([FOP()]);

  Payments();

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
  String line='';
  String fOPID='';
  String payCur='';
  String payAmt='';
  String pNRCur='';
  String pNRAmt='';
  String pNRExRate='';
  String payDate='';

  FOP();

  FOP.fromJson(Map<String, dynamic> json) {
    if(json['Line']!=null)line = json['Line'];
    if(json['FOPID']!= null)fOPID = json['FOPID'];
    if(json['PayCur']!= null)payCur = json['PayCur'];
    if(json['PayAmt']!= null)payAmt = json['PayAmt'];
    if(json['PNRCur']!= null)pNRCur = json['PNRCur'];
    if(json['PNRAmt']!= null)pNRAmt = json['PNRAmt'];
    if(json['PNRExRate']!= null)pNRExRate = json['PNRExRate'];
    if(json['PayDate']!= null)payDate = json['PayDate'];
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
  TTL tTL = TTL();

  TimeLimits();

  TimeLimits.fromJson(Map<String, dynamic> json) {
    if( json['TTL'] != null ) tTL = TTL.fromJson(json['TTL']) ;
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
  String tTLID = '';
  String tTLCity = '';
  String tTLQNo = '';
  String tTLTime = '';
  String tTLDate = '';
  String agCity = '';
  String sineCode = '';
  String sineType = '';
  String resDate = '';

  TTL();

  TTL.fromJson(Map<String, dynamic> json) {
    if(json['TTLID']!= null)tTLID = json['TTLID'];
    if(json['TTLCity']!=null)tTLCity = json['TTLCity'];
    if(json['TTLQNo']!=null)tTLQNo = json['TTLQNo'];
    if(json['TTLTime']!= null)tTLTime = json['TTLTime'];
    if(json['TTLDate']!= null)tTLDate = json['TTLDate'];
    if(json['AgCity']!= null)agCity = json['AgCity'];
    if(json['SineCode']!= null)sineCode = json['SineCode'];
    if(json['SineType']!= null)sineType = json['SineType'];
    if(json['ResDate']!= null)resDate = json['ResDate'];
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
  List<TKT> tKT = List.from([TKT()]);

  Tickets();

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
  String pax = '';
  String tKTID = '';
  String tktNo = '';
  String coupon = '';
  String tktFltDate = '';
  String tktFltNo = '';
  String tktDepart = '';
  String tktArrive = '';
  String tktBClass = '';
  String issueDate = '';
  String status = '';
  String segNo = '';
  String title = '';
  String firstname = '';
  String surname = '';
  String tktFor = '';
  String sequenceNo = '';
  String loungeAccess = '';
  String fastTrack = '';
  bool WebCheckOut = false;

  TKT({this.sequenceNo=''});

  TKT.fromJson(Map<String, dynamic> json) {
    if( json['Pax']!= null)  pax = json['Pax'];
    if(json['TKTID']!= null)tKTID = json['TKTID'];
    if(json['TktNo']!= null)tktNo = json['TktNo'];
    if(json['Coupon']!= null)coupon = json['Coupon'];
    if(json['TktFltDate']!= null)tktFltDate = json['TktFltDate'];
    if(json['TktFltNo']!= null)tktFltNo = json['TktFltNo'];
    if(json['TktDepart']!= null)tktDepart = json['TktDepart'];
    if(json['TktArrive']!= null)tktArrive = json['TktArrive'];
    if(json['TktBClass']!= null)tktBClass = json['TktBClass'];
    if(json['IssueDate']!= null)issueDate = json['IssueDate'];
    if(json['Status']!= null)status = json['Status'];
    if(json['SegNo']!= null)segNo = json['SegNo'];
    if(json['Title']!= null)title = json['Title'];
    if(json['Firstname']!= null)firstname = json['Firstname'];
    if(json['Surname']!= null)surname = json['Surname'];
    if(json['TktFor']!= null)tktFor = json['TktFor'];
    if(json['SequenceNo']!= null)sequenceNo = json['SequenceNo'];
    if(json['LoungeAccess']!= null)loungeAccess = json['LoungeAccess'];
    if(json['FastTrack']!= null)fastTrack = json['FastTrack'];
    if(json['WebCheckOut']!= null) WebCheckOut = parseBool(json['WebCheckOut']);
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
    data['WebCheckOut'] = this.WebCheckOut;

    return data;
  }
}

class Remarks {
  List<RMK> rMK = List.from([RMK()]);

  Remarks();

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
  String line = '';
  String rMKID = '';
  String text = '';

  RMK();

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
  String rLOC = '';
  String airID = '';
  String issOffCode = '';
  String city = '';
  String agType = '';
  String cur = '';
  String curInf = '';
  String sineCode = '';
  String rLEDate = '';
  String issagtidpnr = '';
  String issagtidtkt = '';

  RLE();

  RLE.fromJson(Map<String, dynamic> json) {
    if(json['RLOC']!= null)rLOC = json['RLOC'];
    if(json['AirID']!=null)airID = json['AirID'];
    if(json['IssOffCode']!= null)issOffCode = json['IssOffCode'];
    if(json['City']!= null)city = json['City'];
    if(json['AgType']!=null)agType = json['AgType'];
    if(json['Cur']!= null)cur = json['Cur'];
    if(json['CurInf']!= null)curInf = json['CurInf'];
    if(json['SineCode']!= null)sineCode = json['SineCode'];
    if(json['RLEDate']!= null)rLEDate = json['RLEDate'];
    if(json['issagtidpnr']!= null)issagtidpnr = json['issagtidpnr'];
    if(json['issagtidtkt']!= null)issagtidtkt = json['issagtidtkt'];
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
  Outstanding outstanding =Outstanding();
  Outstandingairmiles outstandingairmiles=Outstandingairmiles();

  Basket();

  Basket.fromJson(Map<String, dynamic> json) {
    if(json['Outstanding'] != null)outstanding =  Outstanding.fromJson(json['Outstanding']);
    if(json['Outstandingairmiles'] != null)outstandingairmiles = Outstandingairmiles.fromJson(json['Outstandingairmiles']);
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
  String cur = '';
  String curInf = '';
  String amount = '';
  String info = '';

  Outstanding();

  Outstanding.fromJson(Map<String, dynamic> json) {
    if(json['cur']!= null)cur = json['cur'];
    if(json['CurInf']!= null)curInf = json['CurInf'];
    if(json['amount']!= null)amount = json['amount'];
    if(json['info']!= null)info = json['info'];
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
  String cur = '';
  String curInf = '';
  String amount = '';
  String info = '';
  String airmiles = '';

  Outstandingairmiles();

  Outstandingairmiles.fromJson(Map<String, dynamic> json) {
    if(json['cur']!= null)cur = json['cur'];
    if(json['CurInf']!= null)curInf = json['CurInf'];
    if(json['amount']!= null)amount = json['amount'];
    if(json['info']!= null)info = json['info'];
    if(json['airmiles']!=null)airmiles = json['airmiles'];
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
  String scheme = '';
  String reference = '';
  String info = '';
  String mbamount = '';
  String mbcurrency = '';
  String mbtotalfare = '';
  String mbtotaltax = '';
  String ttl = '';

  Zpay();

  Zpay.fromJson(Map<String, dynamic> json) {
    if(json['scheme']!= null)scheme = json['scheme'];
    if(json['reference']!= null)reference = json['reference'];
    if(json['info']!= null)info = json['info'];
    if(json['mbamount']!=null)mbamount = json['mbamount'];
    if(json['mbcurrency']!= null)mbcurrency = json['mbcurrency'];
    if(json['mbtotalfare']!= null)mbtotalfare = json['mbtotalfare'];
    if(json['mbtotaltax']!=null)mbtotaltax = json['mbtotaltax'];
    if(json['ttl']!= null)ttl = json['ttl'];
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
  String originissoffcode = '';

  Pnrfields();

  Pnrfields.fromJson(Map<String, dynamic> json) {
    if(json['originissoffcode']!= null)originissoffcode = json['originissoffcode'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['originissoffcode'] = this.originissoffcode;
    return data;
  }
}

class Fqfields {
  List<Fqfield> fqfield = List.from([Fqfield()]);

  Fqfields();

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
  String line = '';
  String fareid = '';
  String finf = '';

  Fqfield();

  Fqfield.fromJson(Map<String, dynamic> json) {
    if(json['line']!= null)line = json['line'];
    if(json['fareid']!= null)fareid = json['fareid'];
    if(json['finf']!= null)finf = json['finf'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['line'] = this.line;
    data['fareid'] = this.fareid;
    data['finf'] = this.finf;
    return data;
  }
}


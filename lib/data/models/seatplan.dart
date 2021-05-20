class Seatplan {
  Seats seats;

  Seatplan({this.seats});

  Seatplan.fromJson(Map<String, dynamic> json) {
    seats = json['Seats'] != null ? new Seats.fromJson(json['Seats']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.seats != null) {
      data['Seats'] = this.seats.toJson();
    }
    return data;
  }

  bool hasSeatsAvailable() {
    if (this
            .seats
            .seat
            .where((seat) =>
                seat.sSeatID == '0' &&
                seat.sCode != '' &&
                !seat.sCellDescription.contains('Block'))
            .toList()
            .length >
        0) {
      return true;
    } else {
      return false;
    }
  }

  bool hasBlockedSeats() {
    if (this
            .seats
            .seat
            .where((seat) =>
                (seat.sSeatID == '0' &&
                    seat.sCode != '' &&
                    seat.sCellDescription.contains('Block')) ||
                (seat.sSeatID != '0' &&
                    seat.sLastName == '' &&
                    seat.sCellDescription.contains('Seat')))
            .toList()
            .length >
        0) {
      return true;
    } else {
      return false;
    }
  }
}

class Seats {
  SeatsFlt seatsFlt;
  CabinCount cabinCount;
  List<Seat> seat;

  Seats({this.seatsFlt, this.cabinCount, this.seat});

  Seats.fromJson(Map<String, dynamic> json) {
    seatsFlt = json['SeatsFlt'] != null
        ? new SeatsFlt.fromJson(json['SeatsFlt'])
        : null;
    cabinCount = json['CabinCount'] != null
        ? new CabinCount.fromJson(json['CabinCount'])
        : null;
    if (json['Seat'] != null) {
      seat = [];
      // new List<Seat>();
      json['Seat'].forEach((v) {
        seat.add(new Seat.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.seatsFlt != null) {
      data['SeatsFlt'] = this.seatsFlt.toJson();
    }
    if (this.cabinCount != null) {
      data['CabinCount'] = this.cabinCount.toJson();
    }
    if (this.seat != null) {
      data['Seat'] = this.seat.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SeatsFlt {
  String sFltNo;
  String sFltDate;
  String sDepart;
  String sDestin;
  String sFltID;
  String sRef;

  SeatsFlt(
      {this.sFltNo,
      this.sFltDate,
      this.sDepart,
      this.sDestin,
      this.sFltID,
      this.sRef});

  SeatsFlt.fromJson(Map<String, dynamic> json) {
    sFltNo = json['FltNo'];
    sFltDate = json['Flt_Date'];
    sDepart = json['Depart'];
    sDestin = json['Destin'];
    sFltID = json['FltID'];
    sRef = json['Ref'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FltNo'] = this.sFltNo;
    data['Flt_Date'] = this.sFltDate;
    data['Depart'] = this.sDepart;
    data['Destin'] = this.sDestin;
    data['FltID'] = this.sFltID;
    data['Ref'] = this.sRef;
    return data;
  }
}

class CabinCount {
  Cabin cabin;

  CabinCount({this.cabin});

  CabinCount.fromJson(Map<String, dynamic> json) {
    cabin = json['Cabin'] != null ? new Cabin.fromJson(json['Cabin']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.cabin != null) {
      data['Cabin'] = this.cabin.toJson();
    }
    return data;
  }
}

class Cabin {
  String sCabinClass;
  String sSeats;

  Cabin({this.sCabinClass, this.sSeats});

  Cabin.fromJson(Map<String, dynamic> json) {
    sCabinClass = json['CabinClass'];
    sSeats = json['Seats'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CabinClass'] = this.sCabinClass;
    data['Seats'] = this.sSeats;
    return data;
  }
}

class Seat {
  String sSeatID;
  int sRow;
  int sCol;
  String sCode;
  String sCabinClass;
  String sCellDescription;
  String sSccode;
  String sScinfo;
  String sCur;
  String sScprice;
  String sSeatdescription;
  String sFirstName;
  String sLastName;
  String sMFCI;
  String sStatus;
  String sRLOC;
  String sPAXNumber;
  String sTktStatus;
  String sDCSStatus;
  String sSequence;

  Seat(
      {this.sSeatID,
      this.sRow,
      this.sCol,
      this.sCode,
      this.sCabinClass,
      this.sCellDescription,
      this.sSccode,
      this.sScinfo,
      this.sCur,
      this.sScprice,
      this.sSeatdescription,
      this.sFirstName,
      this.sLastName,
      this.sMFCI,
      this.sStatus,
      this.sRLOC,
      this.sPAXNumber,
      this.sTktStatus,
      this.sDCSStatus,
      this.sSequence});

  Seat.fromJson(Map<String, dynamic> json) {
    sSeatID = json['SeatID'];
    sRow = int.parse(json['Row']);
    sCol = int.parse(json['Col']);
    sCode = json['Code'];
    sCabinClass = json['CabinClass'];
    sCellDescription = json['CellDescription'];
    sSccode = json['sccode'];
    sScinfo = json['scinfo'];
    sCur = json['cur'];
    sScprice = json['scprice'];
    sSeatdescription = json['seatdescription'];
    sFirstName = json['FirstName'];
    sLastName = json['LastName'];
    sMFCI = json['MFCI'];
    sStatus = json['Status'];
    sRLOC = json['RLOC'];
    sPAXNumber = json['PAXNumber'];
    sTktStatus = json['TktStatus'];
    sDCSStatus = json['DCSStatus'];
    sSequence = json['Sequence'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SeatID'] = this.sSeatID;
    data['Row'] = this.sRow;
    data['Col'] = this.sCol;
    data['Code'] = this.sCode;
    data['CabinClass'] = this.sCabinClass;
    data['CellDescription'] = this.sCellDescription;
    data['sccode'] = this.sSccode;
    data['scinfo'] = this.sScinfo;
    data['cur'] = this.sCur;
    data['scprice'] = this.sScprice;
    data['seatdescription'] = this.sSeatdescription;
    return data;
  }
}

import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/settings.dart';

class Passengers {
  int adults; // = 1;
  int children; // = 0;
  int infants; // = 0;
  int youths;

  Passengers(this.adults, this.children, this.infants, this.youths);
  int totalSeated() {
    return this.adults + this.children + this.youths;
  }

  int totalPassengers() {
    return this.adults + this.children + this.youths + this.infants;
  }
}

class ContactInfomation {
  String email = '';
  String phonenumber = '';
}

class NewBooking {
  bool isReturn = true;
  String departure;
  String arrival;
  DateTime departureDate;
  DateTime returnDate;
  Passengers passengers = new Passengers(1, 0, 0, 0);
  List<String> outboundflight = [];
  // List<String>();
  List<String> returningflight = [];
  // List<String>();
  List<PassengerDetail> passengerDetails = [];
  // List<PassengerDetail>();
  PaymentDetails paymentDetails;
  ContactInfomation contactInfomation;
  ADS ads = ADS('', '');
  String eVoucherCode;
  //List<ContactInfomation> contactInfomation = List<ContactInfomation>();
  NewBooking();
}

class MmbBooking {
  String rloc;
  bool isReturn = true;
  //String voidOrExchange;
  //String departure;
  //String arrival;
  //DateTime departureDate;
  //DateTime returnDate;
  Passengers passengers = new Passengers(1, 0, 0, 0);
  int journeyToChange;
  List<String> oldFlights = [];
  // List<String>();
  List<String> newFlights = [];
  // List<String>();
  Journeys journeys = Journeys([]);
  //List<Journey>());
  String currency;
  String amount;
  AFX eVoucher;
  //List<String> outboundflight = List<String>();
  //List<String> returningflight = List<String>();
  //List<PassengerDetail> passengerDetails = List<PassengerDetail>();

  MmbBooking();
}

class Journeys {
  List<Journey> journey;
  Journeys(this.journey) {
    // this.journey = new List<Journey>();
  }
}

class Journey {
  List<Itin> itin; // = new List<Itin>();
  Journey(this.itin) {
    //this.itin = new List<Itin>();
  }
}

enum PaxType { adult, child, infant, youth }

class PassengerDetail {
  String title = '';
  String firstName = '';
  String lastName = '';
  PaxType paxType = PaxType.adult;
  DateTime dateOfBirth;
  String phonenumber = '';
  String email = '';
  String adsNumber = '';
  String adsPin = '';
  String fqtv = '';

  PassengerDetail( {this.title,
    this.firstName,
    this.lastName,
    this.paxType,
    this.dateOfBirth,
    this.phonenumber,
    this.email,
    this.adsNumber,
    this.adsPin,
    this.fqtv  });

  Map<String, dynamic> toJson() {
      final Map<String, dynamic> data = new Map<String, dynamic>();

      data['title'] = this.title;
      data['firstName'] = this.firstName;
      data['lastName'] = this.lastName;
      switch (paxType) {
        case PaxType.infant:
          data['paxType'] = 'IN';
          break;
        case PaxType.child:
          data['paxType'] = 'CH';
          break;
        case PaxType.youth:
          data['paxType'] = 'TH';
          break;
        case PaxType.adult:
          data['paxType'] = 'AD';
          break;
          default:
            data['paxType'] = 'AD';
            break;
      }
/*
      if( this.dateOfBirth == null ) {
        data['dateOfBirth'] = new DateTime.now() ;
      } else {
        data['dateOfBirth'] = this.dateOfBirth;
      }

 */
      data['phonenumber'] = this.phonenumber;
      data['email'] = this.email;
      data['adsNumber'] = this.adsNumber;
      data['adsPin'] = this.adsPin;
      data['fqtv'] = this.fqtv;

      return data;
    }

  PassengerDetail.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    firstName = json['firstName'];
    lastName = json['lastName'];

    switch (json['paxType']) {
      case 'IN':
        paxType = PaxType.infant;
        break;
      case 'CH':
        paxType =PaxType.child;
        break;
      case 'TH':
        paxType = PaxType.youth;
        break;
      case 'AD':
        paxType = PaxType.adult;
        break;
      default:
        paxType = PaxType.adult;
        break;
    }

    // dateOfBirth = json['dateOfBirth'];

    phonenumber = (json['phonenumber'] == null) ?'' : json['phonenumber'];
    email = (json['email'] == null ) ? '' : json['email'];
    adsNumber =  (json['adsNumber'] == null) ? '' :json['adsNumber'];
    adsPin =  json['adsPin'];
    fqtv =  json['fqtv'];
      }
  }


class PaymentDetails {
  String cardNumber = '';
  String cVV = '';
  String expiryDate = '';
  String addressLine1 = '';
  String addressLine2 = '';
  String town = '';
  String state = '';
  String postCode = '';
  String country = '';
  String cardHolderName = '';
  String expiryMonth = '';
  String expiryYear = '';
}

class ADS {
  String number = '';
  String pin = '';
  ADS(this.pin, this.number);

  bool isAdsBooking() {
    if (this.number.length > 1 && this.pin.length > 1) {
      return true;
    } else {
      return false;
    }
  }
}

class LoginResponse extends Session {
//body:"{"sessionId":"2","varsSessionId":"9f70d986-e5d9-4b50-aa4f-ee1baf92ee4e","isSuccessful":true,"errorCode":null,"errorMessage":null…"

  LoginResponse.fromJson(Map<String, dynamic> json) : super('', '', '') {
    sessionId = json['sessionId'];
    varsSessionId = json['varsSessionId'];
   // settings = Settings.fromJson(json['settings']);
    isSuccessful = json['isSuccessful'].toString().toLowerCase() == 'true';
    errorCode = json['errorCode'];
    errorMessage = json['errorCode'];
  }

  //String sessionId;
  //String varsSessionId;
  bool isSuccessful;
  String errorCode;
  String errorMessage;
  Settings settings;

  LoginResponse({
    String sessionId,
    String varsSessionId,
    String vrsServerNo,
    this.settings,
    this.isSuccessful,
    this.errorCode,
    this.errorMessage,
  }) : super(sessionId, varsSessionId, vrsServerNo);

  Session getSession() {
    return Session(sessionId, varsSessionId, vrsServerNo);
  }
}

class Session {
  String sessionId;
  String varsSessionId;
  String vrsServerNo;
  Session(
    this.sessionId,
    this.varsSessionId,
    this.vrsServerNo,
  );
}

class RunVRSCommand extends Session {
  String cmd;

  RunVRSCommand(
    Session session,
    this.cmd,
  ) : super(session.sessionId, session.varsSessionId, session.vrsServerNo);

  Map toJson() {
    Map map = new Map();
    map['sessionID'] = sessionId;
    map['VARSSessionID'] = varsSessionId;
    map['vrsServerNo'] = vrsServerNo == "" ? '0' : vrsServerNo;
    map['Commands'] = cmd;
    return map;
  }
}

class RunVRSCommandList extends Session {
  List<String> commandList;

  RunVRSCommandList(
    Session session,
    this.commandList,
  ) : super(session.sessionId, session.varsSessionId, session.vrsServerNo);

  Map toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['sessionID'] = sessionId;
    data['VARSSessionID'] = varsSessionId;
    data['vrsServerNo'] = vrsServerNo == "" ? '0' : vrsServerNo;
    data['CommandList'] = commandList;
    return data;
  }
}

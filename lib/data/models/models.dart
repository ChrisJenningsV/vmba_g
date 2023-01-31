import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/models/availability.dart';
import 'package:vmba/data/settings.dart';
import 'package:vmba/data/globals.dart';


class Passengers {
  int adults; // = 1;
  int children; // = 0;
  int smallChildren; // = 0;
  int infants; // = 0;
  int seatedInfants; // = 0;
  int youths;
  int students;
  int teachers;
  int seniors;


  Passengers(this.adults, this.children, this.infants, this.youths, this.seniors, this.students, this.teachers);
  int totalSeated() {
    return this.adults + this.children + this.youths + this.students + this.seniors + this.teachers;
  }

  int totalPassengers() {
    return this.adults + this.children + this.youths + this.infants  + this.students + this.seniors + this.teachers;
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
  String currency;
  DateTime departureDate;
  DateTime returnDate;
  Passengers passengers = new Passengers(1, 0, 0, 0, 0, 0, 0);
  List<String> outboundflight = [];
  List<Flt> outboundflts = [];
  String outboundClass;
  // List<String>();
  List<String> returningflight = [];
  List<Flt> returningflts = [];
  String returningClass;
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
  Passengers passengers = new Passengers(1, 0, 0, 0, 0,0,0);
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

enum PaxType { adult, child, smallChild, infant, seatedInfant,  youth, student, senior, teacher }

class PassengerDetail {
  String paxNumber;
  String title = '';
  String firstName = '';
  String middleName = '';
  String lastName = '';
  PaxType paxType = PaxType.adult;
  DateTime dateOfBirth;
  String phonenumber = '';
  String email = '';
  String adsNumber = '';
  String adsPin = '';
  String fqtv = '';
  String fqtvPassword = '';
  String country = '';
  String gender = '';
  String seniorID = '';
  String disabilityID = '';
  String redressNo = '';
  String knowTravellerNo = '';
  bool wantNotifications;

  PassengerDetail({this.title,
    this.firstName,
    this.middleName,
    this.lastName,
    this.paxType,
    this.dateOfBirth,
    this.phonenumber,
    this.email,
    this.adsNumber,
    this.adsPin,
    this.fqtv,
    this.fqtvPassword,
    this.gender,
    this.redressNo,
    this.knowTravellerNo,
    this.wantNotifications,
  });

  bool isComplete() {
    if (title == '' || title == null) {
      return false;
    }
    if (firstName == '' || firstName == null) {
      return false;
    }

    if (gblSettings.wantMiddleName &&
        (middleName == null || middleName.isEmpty)) {
      return false;
    }

    if (lastName == '' || lastName == null) {
      return false;
    }

    if (gblSettings.wantGender && (gender == null || gender.isEmpty)) {
      return false;
    }


    return true;
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['title'] = this.title;
    data['firstName'] = this.firstName;
    data['middleName'] = this.middleName;
    data['lastName'] = this.lastName;
    data['wantNotifications'] = this.wantNotifications;
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
      case PaxType.seatedInfant:
        data['paxType'] = 'IS';
        break;
      case PaxType.senior:
        data['paxType'] = 'CD';
        break;
      case PaxType.smallChild:
        data['paxType'] = 'CS';
        break;
      case PaxType.student:
        data['paxType'] = 'SD';
        break;
      case PaxType.teacher:
        data['paxType'] = 'TD';
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
    data['fqtvPassword'] = this.fqtvPassword;
    data['redressNo'] = this.redressNo;
    data['knowTravellerNo'] = this.knowTravellerNo;
    data['gender'] = this.gender;
    data['dateOfBirth'] = this.dateOfBirth.toString();

    return data;
  }

  PassengerDetail.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    firstName = json['firstName'];
    middleName = json['middleName'];
    lastName = json['lastName'];
    wantNotifications = json['wantNotifications'];
    if( wantNotifications == null ) {
      wantNotifications = false;
    }

    switch (json['paxType']) {
      case 'IN':
        paxType = PaxType.infant;
        break;
      case 'IS':
        paxType = PaxType.seatedInfant;
        break;
      case 'CH':
        paxType = PaxType.child;
        break;
      case 'CS':
        paxType = PaxType.smallChild;
        break;
      case 'CD':
        paxType = PaxType.senior;
        break;
      case 'TD':
        paxType = PaxType.teacher;
        break;
      case 'SD':
        paxType = PaxType.student;
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

    phonenumber = (json['phonenumber'] == null) ? '' : json['phonenumber'];
    email = (json['email'] == null) ? '' : json['email'];
    adsNumber = (json['adsNumber'] == null) ? '' : json['adsNumber'];
    adsPin = json['adsPin'];
    fqtv = json['fqtv'];
    fqtvPassword = json['fqtvPassword'];
    redressNo = json['redressNo'];
    knowTravellerNo = json['knowTravellerNo'];
    gender = json['gender'];
    if (json['dateOfBirth'] != null &&  json['dateOfBirth'] != 'null') {

      dateOfBirth = DateTime.parse(json['dateOfBirth']);
    }
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
  DateTime createTime = DateTime.now();
  Session(
    this.sessionId,
    this.varsSessionId,
    this.vrsServerNo,
  );

  bool isTimedOut() {
    var currentTime = DateTime.now();
    if( currentTime.difference(createTime).inMinutes > 20  ) {
      return true;
    }
    return false;
  }
}

class ApiFqtvResetPasswordRequest {
  String email;

  ApiFqtvResetPasswordRequest( this.email);

  Map toJson() {
    Map map = new Map();
    map['email'] = email;
    return map;
  }
}

class ApiFqtvChangePasswordRequest {
  String username;
  String existingPassword;
  String newPassword;

  ApiFqtvChangePasswordRequest( this.username, this.existingPassword, this.newPassword);

  Map toJson() {
    Map map = new Map();
    map['username'] = username;
    map['existingPassword'] = existingPassword;
    map['newPassword'] = newPassword;
    return map;
  }
}

class ApiFqtvGetDetailsRequest {
  String email;
  String username;
  String password;

  ApiFqtvGetDetailsRequest( this.email, this.username, this.password);

  Map toJson() {
    Map map = new Map();
    map['email'] = email;
    map['username'] = username;
    map['password'] = password;
    return map;
  }

}

class ApiFqtvPendingRequest {
  String username;
  String password;

  ApiFqtvPendingRequest(  this.username, this.password);

  Map toJson() {
    Map map = new Map();
    map['Username'] = username;
    map['Password'] = password;
    return map;
  }

}



class FqTvCommand extends Session {
  FqtvMemberloginDetail cmd;

  FqTvCommand(
      Session session,
      this.cmd,
      ) : super(session.sessionId, session.varsSessionId, session.vrsServerNo);

  Map toJson() {
    Map map = new Map();
    map['sessionID'] = sessionId;
    map['VARSSessionID'] = varsSessionId;
    map['vrsServerNo'] = vrsServerNo == "" ? '0' : vrsServerNo;
    map['fqtvMemberloginDetail'] = cmd;
    return map;
  }
}

class FqtvMemberloginDetail {
  String email;
  String username;
  String password;

  FqtvMemberloginDetail( this.email, this.username, this.password);

  Map toJson() {
    Map map = new Map();
    map['email'] = email;
    map['username'] = username;
    map['password'] = password;
    return map;
  }
}


class ApiResponseStatus {
  String statusCode;
  String message;

  ApiResponseStatus(
      this.statusCode,
      this.message      ) ;

  ApiResponseStatus.fromJson(Map<String, dynamic> strJson) {
    try {
      statusCode = strJson['statusCode'];
      message = strJson['message'];
    } catch(e) {
      print(e);
    }
  }
}

class ApiFQTVMemberTransaction {
  String pnr;
  String flightNumber;
  String flightDate;
  String transactionDateTime;
  String departureCityCode;
  String arrivalCityCode;
  String airMiles;
  String description;

  ApiFQTVMemberTransaction(this.pnr, this.flightNumber,
      this.flightDate,
      this.transactionDateTime,
      this.departureCityCode, this.arrivalCityCode,
       this.airMiles, this.description);
}

class ApiFqtvMemberTransactionsResp extends ApiResponseStatus {
  List<ApiFQTVMemberTransaction> transactions;

  ApiFqtvMemberTransactionsResp(ApiResponseStatus status, this.transactions)
      : super(status.statusCode, status.message);

  ApiFqtvMemberTransactionsResp.fromJson(Map<String, dynamic> strJson)
      : super('', '') {
    try {
      Map status = strJson['status'];
      statusCode = status['statusCode'];
      message = status['message'];
      transactions = [];
      for( Map tran in strJson['transactions']) {
        transactions.add( new ApiFQTVMemberTransaction(_getString(tran['pnr']),
            _getString(tran['flightNumber']),
            _getString(tran['flightDate']),
            _getString(tran['transactionDateTime']),
            _getString(tran['departureCityCode']),
            _getString(tran['arrivalCityCode']),
            _getNumber(tran['airMiles']),
            _getString(tran['description'])) );
      }
    } catch (e) {
      print(e);
    }
  }
}
String _getString(String inStr) {
  if( inStr != null ) {
    return inStr;
  }
  return '';
}

String _getNumber(double inNo) {
  if( inNo == null ) {
    return '0';
  }
  return '$inNo';
}

class ApiFqtvMemberAirMilesResp extends ApiResponseStatus {
  int balance;

  ApiFqtvMemberAirMilesResp( ApiResponseStatus status, this.balance)  : super(status.statusCode, status.message);

  ApiFqtvMemberAirMilesResp.fromJson(Map<String, dynamic> strJson) : super('', '')  {
    balance = strJson['balance'];
    try {
      Map status = strJson['status'];
      statusCode = status['statusCode'];
      message = status['message'];
    } catch(e) {
      print(e);
    }
  }
}
class ApiFqtvMemberDetails {
  String username;
  String password;
  String title;
  String firstname;
  String surname;
  String address1;
  String address2;
  String address3;
  String address4;
  String postcode;
  String country;
  String email;
  String phoneHome;
  String phoneWork;
  String phoneMobile;
  String phoneMobile2;
  String phoneHomeCountryCode;
  String phoneWorkCountryCode;
  String phoneMobileCountryCode;
  String phoneMobileCountryCode2;
  String dob;
  String securityQuestion;
  String securityQuestionAnswer;
  String issueDate;

  ApiFqtvMemberDetails(this.username,  this.password,  this.title,
        this.firstname,  this.surname,  this.address1,
        this.address2,  this.address3,  this.address4,
        this.postcode,  this.country,  this.email,
        this.phoneHome,  this.phoneWork,  this.phoneMobile,
        this.phoneMobile2,  this.phoneHomeCountryCode,  this.phoneWorkCountryCode,
        this.phoneMobileCountryCode,  this.phoneMobileCountryCode2,  this.dob,
        this.securityQuestion,  this.securityQuestionAnswer,  this.issueDate);

  ApiFqtvMemberDetails.fromJson(Map<String, dynamic> strJson)   {
    username = strJson['username'];
    password = strJson['password'];
    title = strJson['title'];
    firstname = strJson['firstname'];
    surname = strJson['surname'];
    address1 = strJson['address1'];
    address2 = strJson['address2'];
    address3 = strJson['address3'];
    address4 = strJson['address4'];
    postcode = strJson['postcode'];
    country = strJson['country'];
    email = strJson['email'];
    phoneHome = strJson['phoneHome'];
    phoneWork = strJson['phoneWork'];
    phoneMobile = strJson['phoneMobile'];
    phoneMobile2 = strJson['phoneMobile2'];
    phoneHomeCountryCode = strJson['phoneHomeCountryCode'];
    phoneWorkCountryCode = strJson['phoneWorkCountryCode'];
    phoneMobileCountryCode = strJson['phoneMobileCountryCode'];
    phoneMobileCountryCode2 = strJson['phoneMobileCountryCode2'];
    dob = strJson['dob'];
    securityQuestion = strJson['securityQuestion'];
    securityQuestionAnswer = strJson['securityQuestionAnswer'];
    issueDate = strJson['issueDate'];
  }
}

class ApiFqtvMemberDetailsResponse extends ApiResponseStatus {
  ApiFqtvMemberDetails member;

  ApiFqtvMemberDetailsResponse( ApiResponseStatus status, this.member)  : super(status.statusCode, status.message);

  ApiFqtvMemberDetailsResponse.fromJson(Map<String, dynamic> strJson) : super('', '')  {
    member = ApiFqtvMemberDetails.fromJson(strJson['member']);
    try {
      Map status = strJson['status'];
      statusCode = status['statusCode'];
      message = status['message'];
    } catch(e) {
      print(e);
    }
  }
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

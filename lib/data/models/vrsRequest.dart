import 'package:vmba/data/models/pax.dart';

import 'models.dart';

class VrsApiRequest extends Session {
  String cmd ='';
  String brandId ='';
  String appFile ='';
  String token ='';
  String vrsGuid ='';
  String phoneId ='';
  String notifyToken ='';
  String rloc ='';
  String data ='';
  String language ='';
  String appVersion ='';
  String undoCmd ='';
  String smartApiVersion = '';
  String email = '';
  String? country = '';
  String? countryCode = '';
  String? city = '';

  VrsApiRequest(
      Session session,
      this.cmd,
      this.token,
  {this.appFile='',this.vrsGuid='', this.appVersion='', this.brandId='',
    this.notifyToken='', this.rloc='', this.language='',this.phoneId='', this.undoCmd='',
    this.data='',
    this.smartApiVersion='1.2',
    this.email='',
    this.country='',
    this.countryCode='',
    this.city='',
  }
      ) : super(session.sessionId, session.varsSessionId, session.vrsServerNo);

  Map toJson() {
    Map map = new Map();
    map['sessionID'] = sessionId;
    map['VARSSessionID'] = varsSessionId;
    map['vrsServerNo'] = vrsServerNo == "" ? '0' : vrsServerNo;
    map['cmd'] = cmd;
    map['brandId'] = brandId;
    map['Token'] = token;
    map['appFile'] = appFile;
    map['vrsGuid'] = vrsGuid;
    map['notifyToken'] = notifyToken;
    map['phoneId'] = phoneId;
    map['rloc'] = rloc;
    map['data'] = data;
    map['language'] = language;
    map['undoCmd'] = undoCmd;
    map['appVersion'] = appVersion;
    map['smartApiVersion'] = smartApiVersion;
    map['email'] = email;

    return map;
  }
}

class VrsApiResponse  {
  String data ='';
  String encrypted='';
  String errorMsg ='';
  String sessionId ='';
  String varsSessionId ='';
  String vrsServerNo ='';
  String serverIP ='';
  bool isSuccessful = true;

  VrsApiResponse( this.data, this.varsSessionId, this.sessionId, this.vrsServerNo, this.errorMsg, this.isSuccessful) ;

  VrsApiResponse.fromJson(Map<String, dynamic> json) {
    if( json['data'] != null )data = json['data'];
    if(json['errorMsg']!= null )errorMsg = json['errorMsg'];
    if(json['sessionID'] != null )sessionId = json['sessionID'];
    if(json['VARSSessionID'] != null )varsSessionId = json['VARSSessionID'];
    if( json['vrsServerNo'] != null )vrsServerNo = json['vrsServerNo'];
    if( json['isSuccessful'] != null )isSuccessful = json['isSuccessful'];
    if( json['serverIP'] != null )serverIP = json['serverIP'];
  }
}

class SeatRequest{
  bool webCheckinNoSeatCharge=false;
  String rloc ='';
  int journeyNo=1;
  bool? pnrLoaded=false;
  String afxNo = "0";

  List<Pax>? paxlist; // = List.from([Pax]);

  SeatRequest();

Map  toJson() {
    Map map = new Map();
    map['webCheckinNoSeatCharge'] = webCheckinNoSeatCharge;
    map['rloc'] = rloc;
    map['pnrLoaded'] = pnrLoaded;
    map['journeyNo'] = journeyNo;
    map['afxNo'] = afxNo;

    if (this.paxlist != null) {
      map['paxlist'] = this.paxlist!.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class SeatReply {
  String reply ='';
  String seats ='';
  String outstandingAmount ='';
  String bookSeatCmd = '';

  SeatReply(this.reply, this.seats, this.outstandingAmount);


  SeatReply.fromJson(Map<String, dynamic> json) {
    if( json['reply'] != null )reply = json['reply'];
    if( json["seats"] != null )seats = json["seats"];
    if( json["outstandingAmount"] != null )outstandingAmount = json["outstandingAmount"];
    if( json['bookSeatCmd'] != null ) bookSeatCmd = json['bookSeatCmd'];
  }
}

class CheckinRequest{
  String rloc ='';
  String ticketNo = '';
  String couponNo = '';

  CheckinRequest();

  Map  toJson() {
    Map map = new Map();
    map['rloc'] = rloc;
    map['ticketNo'] = ticketNo;
    map['couponNo'] = couponNo;

    return map;
  }
}

class CheckinReply {
  String reply ='';

  CheckinReply(this.reply);


  CheckinReply.fromJson(Map<String, dynamic> json) {
    if( json['reply'] != null )reply = json['reply'];
  }
}



class AddProductRequest{
  String rloc ='';
  int journeyNo=1;
  List<Pax> paxlist =List.from([Pax]);

  AddProductRequest();

  Map  toJson() {
    Map map = new Map();
    map['rloc'] = rloc;
    map['journeyNo'] = journeyNo;

    if (this.paxlist != null) {
      map['paxlist'] = this.paxlist.map((v) => v.toJson()).toList();
    }
    return map;
  }
}
class DeleteProductRequest{
  String rloc ='';
  int journeyNo = 1;
  List<Pax> paxlist = List.from([Pax]);

  DeleteProductRequest();

  Map  toJson() {
    Map map = new Map();
    map['rloc'] = rloc;
    map['journeyNo'] = journeyNo;

    if (this.paxlist != null) {
      map['paxlist'] = this.paxlist.map((v) => v.toJson()).toList();
    }
    return map;
  }
}


class ProductReply {
  String reply ='';
  bool success=true;

  ProductReply(this.reply, this.success);


  ProductReply.fromJson(Map<String, dynamic> json) {
    reply = json['reply'];
    success = json["success"];
  }
}

class RefundRequest{
  String rloc ='';
  int journeyNo =1;

  RefundRequest({ this.rloc='', this.journeyNo=1});

  Map  toJson() {
    Map map = new Map();
    map['rloc'] = rloc;
    map['journeyNo'] = journeyNo;

    return map;
  }
}

class RefundReply {
  String reply ='';
  bool success = true;

  RefundReply(this.reply, this.success);


  RefundReply.fromJson(Map<String, dynamic> json) {
    reply = json['reply'];
    success = json["success"];
  }
}


class PaymentRequest{
  String rloc ='';
  String paymentType ='';
  String paymentName ='';
  String amount ='';
  String currency ='';
  String confirmation ='';
  String cmd ='';

  PaymentRequest({ this.rloc='', this.paymentType=''});

  Map  toJson() {
    Map map = new Map();
    map['rloc'] = rloc;
    map['paymentType'] = paymentType;
    map['paymentName'] = paymentName;
    map['amount'] = amount;
    map['currency'] = currency;
    map['confirmation'] = confirmation;
    return map;
  }
}

class PaymentReply {
  String reply ='';

  PaymentReply(this.reply);


  PaymentReply.fromJson(Map<String, dynamic> json) {
    reply = json['reply'];
  }
}

class GetProvidersRequest {
  String user = '';
  String currency = '';

  Map  toJson() {
    Map map = new Map();
    map['user'] = user;
    map['currency'] = currency;
    return map;
  }
}


class FqtvLoginRequest{
  String user ='';
  String password ='';

  FqtvLoginRequest({ this.user='', this.password=''});

  Map  toJson() {
    Map map = new Map();
    map['user'] = user;
    map['password'] = password;
    return map;
  }
}


class FqtvLoginReply {
  String reply ='';
  String title ='';
  String firstname ='';
  String surname ='';
  String phoneMobile ='';
  String phoneHome ='';
  String email ='';
  String balance ='';
  String joiningDate ='';
  String dOB ='';
  FQTVMember? member;
  FQTVMemberTransactions? transactions;
  FqtvLoginReply(this.reply);

  FqtvLoginReply.fromJson(Map<String, dynamic> json) {
    //reply = json['reply'];
     if( json['title'] != null )title = json['title'];
     if( json['firstname'] != null )firstname = json['firstname'];
     if( json['surname'] != null )surname = json['surname'];
     if(json['phoneMobile'] != null )phoneMobile = json['phoneMobile'];
     if( json['phoneHome'] != null )phoneHome = json['phoneHome'];
     if( json['email']!= null )email = json['email'];
     if( json['balance'] != null )balance = json['balance'];
     if( json['joiningDate'] != null ) joiningDate = json['joiningDate'];
     if( json['dob'] != null ) dOB = json['dob'];

     if( json['member'] != null ) member = FQTVMember.fromJson(json['member']);
     if( json['Transactions'] != null ) transactions = FQTVMemberTransactions.fromJson(json['Transactions']);
  }
}



class FQTVMember {
  String username ='';
  String password ='';
  String title ='';
  String firstname ='';
  String surname ='';
  String address1 ='';
  String address2 ='';
  String address3 ='';
  String address4 ='';
  String postcode ='';
  String country ='';
  String email ='';
  String phoneHome ='';
  String phoneWork ='';
  String phoneMobile ='';
  String phoneMobile2 ='';
  String phoneHomeCountryCode ='';
  String phoneWorkCountryCode ='';
  String phoneMobileCountryCode ='';
  String phoneMobileCountryCode2 ='';
  String dOB ='';
  String securityQuestion ='';
  String securityQuestionAnswer ='';
  String issueDate ='';

  FQTVMember();

FQTVMember.fromJson(Map<String, dynamic> json) {
//reply = json['reply'];
  if( json['Title'] != null ) title = json['Title'];
  if( json['Firstname'] != null ) firstname = json['Firstname'];
  if( json['Surname'] != null ) surname = json['Surname'];
  if(json['PhoneMobile'] != null ) phoneMobile = json['PhoneMobile'];
  if( json['PhoneHome'] != null ) phoneHome = json['PhoneHome'];
  if( json['Email']!= null ) email = json['Email'];
  if( json['IssueDate'] != null ) issueDate = json['IssueDate'];
  if( json['Country']!= null ) country = json['Country'];
  if( json['PhoneWork']!= null ) phoneWork = json['PhoneWork'];
  if( json['PhoneMobile2']!= null ) phoneMobile2 = json['PhoneMobile2'];
  if( json['PhoneHomeCountryCode']!= null ) phoneHomeCountryCode = json['PhoneHomeCountryCode'];
  if( json['PhoneWorkCountryCode']!= null ) phoneWorkCountryCode = json['PhoneWorkCountryCode'];
  if( json['PhoneMobileCountryCode']!= null ) phoneMobileCountryCode = json['PhoneMobileCountryCode'];
  if( json['PhoneMobileCountryCode2']!= null ) phoneMobileCountryCode2 = json['PhoneMobileCountryCode2'];
  if( json['DOB']!= null ) dOB  = json['DOB'];
}

}



class FareRuleRequest {
  FareRuleRequest(this.IDs);
  String IDs;

  Map  toJson() {
    Map map = new Map();
    map['IDs'] = IDs;
     return map;
  }
}

class ValidateEmailRequest{
  String email ='';
  String pin ='';

  ValidateEmailRequest({ this.email='', this.pin=''});

  Map  toJson() {
    Map map = new Map();
    map['email'] = email;
    map['pin'] = pin;
    return map;
  }
}
class LoadHomePageRequest{
  String country ='';
  String countryCode ='';
  String county ='';
  String city ='';

  LoadHomePageRequest({ this.country='', this.countryCode='', this.city='',this.county=''});

  Map  toJson() {
    Map map = new Map();
    map['country'] = country;
    map['countryCode'] = countryCode;
    map['city'] = city;
    return map;
  }
}






import 'package:vmba/data/models/pax.dart';

import 'models.dart';

class VrsApiRequest extends Session {
  String cmd;
  String brandId;
  String appFile;
  String token;
  String vrsGuid;
  String phoneId;
  String notifyToken;
  String rloc;
  String data;
  String language;

  VrsApiRequest(
      Session session,
      this.cmd,
      this.token,
  {this.brandId,
    this.appFile,
    this.vrsGuid,
    this.phoneId,
    this.rloc,
    this.data,
    this.notifyToken,
    this.language}
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
    return map;
  }
}

class VrsApiResponse  {
  String data;
  String errorMsg;
  String sessionId;
  String varsSessionId;
  String vrsServerNo;
  String serverIP;
  bool isSuccessful;

  VrsApiResponse( this.data, this.varsSessionId, this.sessionId, this.vrsServerNo, this.errorMsg, this.isSuccessful) ;

  VrsApiResponse.fromJson(Map<String, dynamic> json) {
    data = json['data'];
    errorMsg = json['errorMsg'];
    sessionId = json['sessionID'];
    varsSessionId = json['VARSSessionID'];
    vrsServerNo = json['vrsServerNo'];
    isSuccessful = json['isSuccessful'];
    serverIP = json['serverIP'];
  }
}

class SeatRequest{
  bool webCheckinNoSeatCharge;
  String rloc;
  int journeyNo;
  List<Pax> paxlist;

  SeatRequest({this.webCheckinNoSeatCharge, this.paxlist, this.rloc, this.journeyNo});

Map  toJson() {
    Map map = new Map();
    map['webCheckinNoSeatCharge'] = webCheckinNoSeatCharge;
    map['rloc'] = rloc;
    map['journeyNo'] = journeyNo;

    if (this.paxlist != null) {
      map['paxlist'] = this.paxlist.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class SeatReply {
  String reply;
  String seats;
  String outstandingAmount;

  SeatReply(this.reply, this.seats, this.outstandingAmount);


  SeatReply.fromJson(Map<String, dynamic> json) {
    reply = json['reply'];
    seats = json["seats"];
    outstandingAmount = json["outstandingAmount"];
  }
}


class AddProductRequest{
  String rloc;
  int journeyNo;
  List<Pax> paxlist;

  AddProductRequest({ this.paxlist, this.rloc, this.journeyNo});

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
  String rloc;
  int journeyNo;
  List<Pax> paxlist;

  DeleteProductRequest({ this.paxlist, this.rloc, this.journeyNo});

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
  String reply;
  bool success;

  ProductReply(this.reply, this.success);


  ProductReply.fromJson(Map<String, dynamic> json) {
    reply = json['reply'];
    success = json["success"];
  }
}

class RefundRequest{
  String rloc;
  int journeyNo;

  RefundRequest({ this.rloc, this.journeyNo});

  Map  toJson() {
    Map map = new Map();
    map['rloc'] = rloc;
    map['journeyNo'] = journeyNo;

    return map;
  }
}

class RefundReply {
  String reply;
  bool success;

  RefundReply(this.reply, this.success);


  RefundReply.fromJson(Map<String, dynamic> json) {
    reply = json['reply'];
    success = json["success"];
  }
}


class PaymentRequest{
  String rloc;
  String paymentType;
  String paymentName;
  String amount;
  String currency;
  String confirmation;
  String cmd;

  PaymentRequest({ this.rloc, this.paymentType});

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
  String reply;

  PaymentReply(this.reply);


  PaymentReply.fromJson(Map<String, dynamic> json) {
    reply = json['reply'];
  }
}

class FqtvLoginRequest{
  String user;
  String password;

  FqtvLoginRequest({ this.user, this.password});

  Map  toJson() {
    Map map = new Map();
    map['user'] = user;
    map['password'] = password;
    return map;
  }
}


class FqtvLoginReply {
  String reply;
  String title;
  String firstname;
  String surname;
  String phoneMobile;
  String phoneHome;
  String email;
  String balance;

  FqtvLoginReply(this.reply);

  FqtvLoginReply.fromJson(Map<String, dynamic> json) {
    //reply = json['reply'];
     title = json['title'];
     firstname = json['firstname'];
     surname = json['surname'];
     phoneMobile = json['phoneMobile'];
     phoneHome = json['phoneHome'];
     email = json['email'];
     balance = json['balance'];
  }
}





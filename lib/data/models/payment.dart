
import 'dart:core';
import 'package:vmba/data/models/models.dart';

class InitPaymentRequest {
  String paymentProviderName = '';
  String rloc ='';
  Transaction transaction=Transaction();
  Payee? payee;
  Session session = Session('','','');

  InitPaymentRequest({
    required this.rloc,
    required this.session,
    required this.paymentProviderName,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Rloc'] = this.rloc;
    data['sessionId'] = this.session.sessionId;
    data['varsSessionId'] = this.session.varsSessionId;
    data['vrsServerNo'] =
        this.session.vrsServerNo == "" ? '0' : this.session.vrsServerNo;
    data['paymentProviderName'] = this.paymentProviderName;
    data['Transaction'] = this.transaction;

    return data;
  }
}

class PaymentStatusRequest {
  String transactionReference;
  Session session;

  PaymentStatusRequest({
    required this.session,
    required this.transactionReference,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    //data['sessionId'] = this.session.sessionId;
    //data['varsSessionId'] = this.session.varsSessionId;
    //data['vrsServerNo'] =
    //    this.session.vrsServerNo == "" ? '0' : this.session.vrsServerNo;
    data['TransactionReference'] = this.transactionReference;
    return data;
  }
}

class Payee {}

class Transaction {
  double amount=0;
  String currency='';

  Transaction();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Amount'] = this.amount;
    data['Currency'] = this.currency;

    return data;
  }
}

class InitPaymentResponse {
  String transactionReference='';
  List<DataPairs>? dataPairs;
  Null externalPaymentProviderURL;
  String httpMethod='';
  Status? status;

  InitPaymentResponse(
      {this.transactionReference='',
      this.dataPairs,
      this.externalPaymentProviderURL,
      this.httpMethod='',
      this.status});

  InitPaymentResponse.fromJson(Map<String, dynamic> json) {
    transactionReference = json['transactionReference'];
    if (json['dataPairs'] != null) {
      dataPairs = [];
      //new List<DataPairs>();
      json['dataPairs'].forEach((v) {
        dataPairs!.add(new DataPairs.fromJson(v));
      });
    }
    //externalPaymentProviderURL = json['externalPaymentProviderURL'];
    httpMethod = json['httpMethod'];
    status =
        json['status'] != null ? new Status.fromJson(json['status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['transactionReference'] = this.transactionReference;
    if (this.dataPairs != null) {
      data['dataPairs'] = this.dataPairs!.map((v) => v.toJson()).toList();
    }
    data['externalPaymentProviderURL'] = this.externalPaymentProviderURL;
    data['httpMethod'] = this.httpMethod;
    if (this.status != null) {
      data['status'] = this.status!.toJson();
    }
    return data;
  }
}

class PaymentStatusResponse {
  String transactionStatus ='';
  Status? status;

  PaymentStatusResponse({required this.transactionStatus, this.status});

  PaymentStatusResponse.fromJson(Map<String, dynamic> json) {
    transactionStatus = json['transactionStatus'];
    status =
        json['status'] != null ? new Status.fromJson(json['status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['transactionStatus'] = this.transactionStatus;
    if (this.status != null) {
      data['status'] = this.status!.toJson();
    }
    return data;
  }
}

class DataPairs {
  String key='';
  String value='';

  DataPairs({this.key='', this.value=''});

  DataPairs.fromJson(Map<String, dynamic> json) {
    key = json['key'];
    value = json['value'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['key'] = this.key;
    data['value'] = this.value;
    return data;
  }
}

class Status {
  String statusCode='';
  String message='';

  Status({this.statusCode='', this.message=''});

  Status.fromJson(Map<String, dynamic> json) {
    statusCode = json['statusCode'];
    message = json['message'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['statusCode'] = this.statusCode;
    data['message'] = this.message;
    return data;
  }
}

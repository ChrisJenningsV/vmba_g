
import 'dart:convert';

import 'package:vmba/utilities/helper.dart';

class Providers {
  List<Provider> providers = List.from([Provider()]);

  Providers();

  Providers.fromJson(String str) {
    try {
      Map j = json.decode(str);

      List<Provider> provs = List<Provider>.from(
          json.decode(j['paymentProviderList']).map((x) => Provider.fromJson(x)));
      providers = provs;
    } catch (e) {
      logit(e.toString());
    }
  }
}


class Provider {
  bool pUserSessionLogging=false;
  String paymentType='';
  String paymentSchemeName='';
  String paymentSchemeDisplayName='';
  String paymentSchemeID='';
  String displayOrder='';
  MerchantDetails? merchantDetails;
  PaymentFields fields = PaymentFields();

  Provider();

  Provider.fromJson(Map<String, dynamic> json) {
    try {
      if( json['pUserSessionLogging'] != null )pUserSessionLogging = json['pUserSessionLogging'];
      if( json['PaymentType'] != null )paymentType = json['PaymentType'];
      if( json['PaymentSchemeName'] != null )paymentSchemeName = json['PaymentSchemeName'];
      if( json['PaymentSchemeDisplayName'] != null )paymentSchemeDisplayName = json['PaymentSchemeDisplayName'];
      if( json['PaymentSchemeID'] != null )paymentSchemeID = json['PaymentSchemeID'];
      if( json['DisplayOrder'] != null )displayOrder = json['DisplayOrder'];
      if( json['MerchantDetails'] != null ) merchantDetails = MerchantDetails.fromJson( json['MerchantDetails']);
      if( json['Fields'] != null ) fields = PaymentFields.fromJson(json['Fields']);
    } catch(e) {
      logit(e.toString());
    }
  }
}

class MerchantDetails {
  String currency = '';
  String merchantName = '';
  String configJsonData = '';

  MerchantDetails.fromJson(Map<String, dynamic> json) {
    try {
      if( json['Currency'] != null ) currency = json['Currency'];
      if( json['MerchantName'] != null ) merchantName = json['MerchantName'];
      if( json['ConfigJsonData'] != null ) configJsonData = json['ConfigJsonData'];
    } catch(e) {
      logit(e.toString());
    }
  }
}

class PaymentFields {
  List<PaymentField> paymentFields = List.from([PaymentField()]);

  PaymentFields();

  PaymentFields.fromJson(List<dynamic> json) {
    try {
      paymentFields = [];
      //new List<PAX>();
        json.forEach((v) {
          paymentFields.add(new PaymentField.fromJson(v));
        });

/*
      List<PaymentField>.from(
          json.decode(str).map((x) => PaymentField.fromJson(x)));
*/
    } catch (e) {
      logit(e.toString());
    }
    //  choice.add( new Choice(value: 'e',description: 'end'));

  }
}


class PaymentField {
  String paymentFieldName='';
  String paymentFieldGroup='';
  String defaultLabel='';
  String defaultValue='';
  String fieldOptions='';
  String helpText='';
  String helpIcon='';
  String fieldIcon='';
  int minLen=0;
  int maxLen=0;
  String validationType='';
  String regEx='';
  bool requiredField=false;

  PaymentField();

  PaymentField.fromJson(Map<String, dynamic> json) {
    try {
      if( json['PaymentField'] != null ) paymentFieldName = json['PaymentField'];
      if(json['PaymentFieldGroup']  != null ) paymentFieldGroup = json['PaymentFieldGroup'];
      if(json['DefaultLabel']  != null ) defaultLabel = json['DefaultLabel'];
      if(json['DefaultValue']  != null ) defaultValue = json['DefaultValue'];
      if(json['FieldOptions']  != null ) fieldOptions = json['FieldOptions'];
      if(json['HelpText']  != null ) helpText = json['HelpText'];
      if(json['HelpIcon']  != null ) helpIcon  = json['HelpIcon'];
      if(json['FieldIcon']  != null ) fieldIcon = json['FieldIcon'];
      if(json['MinLen']  != null ) minLen = json['MinLen'];
      if(json['MaxLen']  != null ) maxLen = json['MaxLen'];
      if( json['ValidationType'] != null ) validationType = json['ValidationType'];
      if(json['RegEx']  != null ) regEx = json['RegEx'];
      if(json['RequiredField']  != null ) requiredField = json['RequiredField'];
    } catch (e) {
      logit(e.toString());
    }
  }
}

class GetProvidersMsg {
  String agentSine;
  String currencyCode;

  GetProvidersMsg(this.agentSine,
       this.currencyCode
      );

  Map toJson() {
    Map map = new Map();
    map['AgentSine'] = agentSine;
    map['CurrencyCode'] = currencyCode;
    return map;
  }
}
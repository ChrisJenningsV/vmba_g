
import 'dart:convert';

import 'package:vmba/utilities/helper.dart';

class Providers {
  List<Provider> providers;

  Providers({this.providers});

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
  bool pUserSessionLogging;
  String paymentType;
  String paymentSchemeName;
  String paymentSchemeDisplayName;
  String paymentSchemeID;
  String displayOrder;
  PaymentFields fields;


  Provider.fromJson(Map<String, dynamic> json) {
    try {
      pUserSessionLogging = json['pUserSessionLogging'];
      paymentType = json['PaymentType'];
      paymentSchemeName = json['PaymentSchemeName'];
      paymentSchemeDisplayName = json['PaymentSchemeDisplayName'];
      paymentSchemeID = json['PaymentSchemeID'];
      displayOrder = json['DisplayOrder'];
      fields = PaymentFields.fromJson(json['Fields']);
    } catch(e) {
      logit(e.toString());
    }
  }
}


class PaymentFields {
  List<PaymentField> paymentFields;

  PaymentFields({this.paymentFields});

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
  String paymentFieldName;
  String paymentFieldGroup;
  String defaultLabel;
  String defaultValue;
  String fieldOptions;
  String helpText;
  String helpIcon;
  String fieldIcon;
  int minLen;
  int maxLen;
  String validationType;
  String regEx;
  bool requiredField;


  PaymentField.fromJson(Map<String, dynamic> json) {
    try {
      paymentFieldName = json['PaymentField'];
      paymentFieldGroup = json['PaymentFieldGroup'];
      defaultLabel = json['DefaultLabel'];
      defaultValue = json['DefaultValue'];
      fieldOptions = json['FieldOptions'];
      helpText = json['HelpText'];
      helpIcon  = json['HelpIcon'];
      fieldIcon = json['FieldIcon'];
      minLen = json['MinLen'];
      maxLen = json['MaxLen'];
      validationType = json['ValidationType'];
      regEx = json['RegEx'];
      requiredField = json['RequiredField'];
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
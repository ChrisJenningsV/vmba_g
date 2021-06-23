import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paystack/flutter_paystack.dart';
import 'package:http/http.dart' as http;
import 'package:vmba/completed/ProcessCommandsPage.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/payment.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/globals.dart';

// To get started quickly, change this to your heroku deployment of
// https://github.com/PaystackHQ/sample-charge-card-backend
// Step 1. Visit https://github.com/PaystackHQ/sample-charge-card-backend
// Step 2. Click "Deploy to heroku"
// Step 3. Login with your heroku credentials or create a free heroku account
// Step 4. Provide your secret key and an email with which to start all test transactions
// Step 5. Replace {YOUR_BACKEND_URL} below with the url generated by heroku (format https://some-url.herokuapp.com)
String backendUrl = '{YOUR_BACKEND_URL}';
// Set this to a public key that matches the secret key you supplied while creating the heroku instance
//String paystackPublicKey; // = 'pk_test_658f4811018a32c282bd169182f4f22046963aac';
const String appName = 'Paystack';

class Paystack {
  BuildContext context;
  Session session;
  PnrModel pnr;
  String _accessCode;
  String _paystackPublicKey;
  int _amount;
  String _email;
  String _transactionReference;
  Paystack(BuildContext context, PnrModel pnr, Session session) {
    this.context = context;
    this.pnr = pnr;
    this.session = session;
  }

  load() {
    InitPaymentRequest payment = new InitPaymentRequest(
      rloc: pnr.pNR.rLOC,
      session: session,
      paymentProviderName: 'PayStack',
      //paymentProviderName: 'VideCard',
    );
    initPayment(payment.toJson()).then((value) {
      _transactionReference = value.transactionReference;

      _accessCode = value.dataPairs
          .where((element) => element.key == 'accessCode')
          .first
          .value;
      _paystackPublicKey = value.dataPairs
          .where((element) => element.key == 'publicKey')
          .first
          .value;
      _amount = int.parse(value.dataPairs
          .where((element) => element.key == 'amount')
          .first
          .value);
      _email = value.dataPairs
          .where((element) => element.key == 'email')
          .first
          .value;

      final plugin = PaystackPlugin();
      //PaystackPlugin.initialize(publicKey: _paystackPublicKey).then((_) async {
      plugin.initialize(publicKey: _paystackPublicKey).then((_) async {
        await renderWidget();
      });
    });
  }

  Future initPayment(msg) async {
    final http.Response response = await http.post(
        //'http://192.168.0.79:53792/api/Payment/InitPayment',
        Uri.parse(
            gblSettings.apiUrl + "/Payment/InitPayment"),
        headers: {
          'Content-Type': 'application/json',
          'Videcom_ApiKey': gblSettings.apiKey
        },
        body: JsonEncoder().convert(msg));
    if (response.statusCode == 200) {
      print('message send successfully: $msg');
      InitPaymentResponse initPaymentResponse =
          new InitPaymentResponse.fromJson(json.decode(response.body));

      return initPaymentResponse;
    } else {
      print('failed');
    }
  }

  Future getPaymentStatus(msg) async {
    final http.Response response = await http.post(
        //'http://192.168.0.79:53792/api/Payment/GetPaymentStatus',
        Uri.parse(
            gblSettings.apiUrl + "/Payment/GetPaymentStatus"),
        headers: {
          'Content-Type': 'application/json',
          'Videcom_ApiKey': gblSettings.apiKey
        },
        body: JsonEncoder().convert(msg));
    if (response.statusCode == 200) {
      print('message send successfully: $msg');

      PaymentStatusResponse paymentStatusResponse =
          new PaymentStatusResponse.fromJson(json.decode(response.body));
      return paymentStatusResponse.transactionStatus;
    } else {
      print('failed');
    }
  }

  Future renderWidget() async {
    bool ticketingCompleted = false;
    Charge charge = Charge()
      ..amount = _amount
      ..accessCode = _accessCode //_getAccessCodeFrmInitialization()
      ..email = _email;
    //CheckoutResponse response = await PaystackPlugin.checkout(context,
    //
    final plugin = PaystackPlugin();
    CheckoutResponse response = await plugin.checkout(context,
        method:
            CheckoutMethod.selectable, // Defaults to CheckoutMethod.selectable
        charge: charge,
        fullscreen: false);
    print(response.message.toString());
    switch (response.message) {
      case 'Success':
        {
          PaymentStatusRequest paymentStatusRequest = new PaymentStatusRequest(
            session: session,
            transactionReference: _transactionReference,
          );

          while (ticketingCompleted == false) {
            getPaymentStatus(paymentStatusRequest.toJson()).then((value) {
              if (value == "BookingCompleted") {
                RunVRSCommand runVRSCommandArgs =
                    new RunVRSCommand(session, '*${pnr.pNR.rLOC}~x');
                ticketingCompleted = true;
                Navigator.pushAndRemoveUntil<dynamic>(
                  context,
                  MaterialPageRoute<dynamic>(
                    builder: (BuildContext context) => ProcessCommandsPage(
                        runVRSCommandArgs: runVRSCommandArgs),
                  ),
                  (route) =>
                      false, //if you want to disable back feature set to false
                );
                //Navigator.of(context).pushNamedAndRemoveUntil(
                //    '/ProcessCommandsPage', (Route<dynamic> route) => false,
                //    arguments: runVRSCommandArgs);

              }
            });
            //wait 5 seconds before re checking payment status
            await Future.delayed(Duration(milliseconds: 5000));
          }
          break;
        }
      default:
        {
          break;
          //return false;
        }
    }
  }
}

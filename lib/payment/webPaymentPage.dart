import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/models/pnrs.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/utilities/widgets/appBarWidget.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'choosePaymentMethod.dart';

class WebPayPage extends StatefulWidget {
  final NewBooking newBooking;
  PnrModel pnrModel;
  final bool isMmb ;

  String  url = gblSettings.payPage;
  String provider;
  //final title;
  bool canNotClose;
  WebPayPage(this.provider, {
    this.newBooking,
    this.pnrModel,
    this.isMmb,
  });

  @override
  _WebViewWidgetState createState() => _WebViewWidgetState();
}

class _WebViewWidgetState extends State<WebPayPage> {
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();


  num _stackToView = 1;
  Timer _timer;

  @override void initState() {
    _timer = Timer(Duration(minutes : gblSettings.payTimeout), () {
      logit('Payment timed out');
      _timer.cancel();
      _timer = null;
      gblPayBtnDisabled = false;
      gblPaymentMsg = 'Payment Timeout';
      //Navigator.pop(context, 'fail');
      Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ChoosePaymenMethodWidget(newBooking: widget.newBooking, pnrModel: widget.pnrModel, isMmb: false,),
      ),
    );
    });
    super.initState();
    //_controller.data.clearCache();
    //validateBooking();
  }
  @override
  void dispose() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
    super.dispose();
  }

  void _handleLoad() {
    setState(() {
      _stackToView = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(context,  'Payment Page', automaticallyImplyLeading: false,
          actions:<Widget> [ new IconButton(
      icon:  new Icon(Icons.close),
      onPressed: () async {
        if( gblPaySuccess == true ) {
          print('payment success page close');
          _successfulPayment();
          return NavigationDecision.prevent;
        } else {
          gblPayBtnDisabled = false;
          Navigator.pop(context);
        }
      },
    )]),


/*
      AppBar(
        backgroundColor:
        gblSystemColors.primaryHeaderColor,
        title: TrText('Payment Page'),
        automaticallyImplyLeading: false,

        actions: (widget.canNotClose != null) ? <Widget>[Text(' ')] :  <Widget>[
          IconButton(icon: Icon(Icons.close
          ),
            onPressed: () {
              if( gblPaySuccess == true ) {
                print('payment success page close');
                _successfulPayment();
                return NavigationDecision.prevent;
              } else {
                gblPayBtnDisabled = false;
                Navigator.pop(context);
              }
            },
          )
        ],
      ),
*/
      // We're using a Builder here so we have a context that is below the Scaffold
      // to allow calling Scaffold.of(context) so we can show a snackbar.
      body: Builder(builder: (BuildContext context) {
        return IndexedStack(
          index: _stackToView,
          children: <Widget>[
            WebView(
              initialUrl: _getPayUrl(),
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller.complete(webViewController);
              },


              navigationDelegate: (NavigationRequest request) {
                logit('Web Payment Page change url to ${request.url}');
                if (request.url.contains(gblSettings.payFailUrl)) {
                  // FAILED
                  print('payment failed $request}');
                  gblPayBtnDisabled = false;
                  if( request.url.contains('?')) {
                    String err = request.url.split('?')[1];
                    err = err.split('=')[1];
                    gblPaymentMsg = Uri.decodeFull(err);
                  } else {
                    gblPaymentMsg = 'Payment Declined';
                  }
                  //Navigator.pop(context, 'fail');
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChoosePaymenMethodWidget(newBooking: widget.newBooking, pnrModel: widget.pnrModel, isMmb: false,),
                    ),
                  );

                  return NavigationDecision.prevent;
                }
                if (request.url.contains('returnfromexternalpayment') && request.url.contains('success')) {
                  // may need this if page closed
                  gblPaySuccess = true;
                }
                if (request.url.contains(gblSettings.paySuccessUrl)) {
                  // SUCCESS
                  print('payment success $request}');
                  _successfulPayment();
                  return NavigationDecision.prevent;
                }
                if (request.url.startsWith('https://www.youtube.com/')) {
                  print('blocking navigation to $request}');
                  return NavigationDecision.prevent;
                }
                print('allowing navigation to $request');
                return NavigationDecision.navigate;
              },
              onPageFinished: (String url) {
                _handleLoad();
                print('Page finished loading: $url');
                if (url.contains('returnfromexternalpayment') && url.contains('success')) {
                  // may need this if page closed
                  gblPaySuccess = true;
                }
              },
            ),

            new Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),

                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:  Text(translate('Loading') + ' '  + translate('${'Payment page'}')),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
      //  floatingActionButton: favoriteButton(),
    );
  }

/*

  Future<void> validateBooking() async {
    //AATMRA
    //AATKK7
    String rq = '{"CompleteBookingRequest":{"Passengers":[{"PaxNo":1,"PaxType":"0","PaxTypeNo":"1","Title":"Mr","FirstName":"chris","Surname":"james","ContactEmailAddress":{"ContactType":5,"PaxNumber":1,"EmailAddress":"chrisj@videcom.com"},"EmailAddressVerification":null,"EmailMessageFormat":null,"ContactPhoneNumbers":[{"ContactType":"0","PaxNumber":1,"PhoneNumber":"454543534534534","InternationalDialCode":"234"}],"CountryOfResidence":null,"FrequentFlyerInfo":null,"Gender":{"Pax":"1","Seg":null,"Value":"Male","GenFaxID":"GNDR"},"MealRequest":[],"SpecialServiceRequests":[],"Passport":null,"Document":{"PaxNo":1,"DocumentType":null,"DocumentNumber":null,"CountryOfIssue":null,"CountryOfBirth":null},"CountryOfBirth":null,"Weight":null,"OtherInformation":null,"ConnectingFlight":null,"ReceiveNewsletter":false,"RememberDetailsInCookie":false,"MarketingOptIn":false,"MarketingCountry":null,"MarketingPostCode":null,"MarketingCity":null,"PaxExtraField":null,"IsPWD":false,"DisabilitySeniorDiscountCode":null,"MiddleName":null,"RedressNo":null,"KnownTravellerno":null,"AdsNo":null,"AdsPin":null,"ADSChecked":null,"FQTVno":null,"FQTVpw":null}],"Payments":null,"PaxRelatedProducts":null,"BookingRemarks":null,"AdditionalBookingInfo":{"VatNumber":null,"VatCompany":null,"PurchaseOrderNumber":null,"Remark":null},"formData":[],"paymentFormData":[{"name":"optpaymentformofpayment","value":"ExternalPayment"},{"name":"PAYMENTNAME","value":"Paystack"}]}}"';

    http.Response response = await http
        .get(Uri.parse(
        "${gblSettings.payUrl}ValidateBooking?CompleteBookingRequest=$rq'"))
        .catchError((resp) {});

    if (response == null) {
      //return new ParsedResponse(NO_INTERNET, []);
    }

    //If there was an error return an empty list
    if (response.statusCode < 200 || response.statusCode >= 300) {
      //return new ParsedResponse(response.statusCode, []);
    }
  }
*/


    String _getPayUrl(){
    String provider = widget.provider.replaceFirst('3DS_', '');
    String action = 'NEWBOOKING';
    String url = '${widget.url}?gateway=$provider&rloc=$gblCurrentRloc&action=$action';

    if( gblPayFormVals != null) {
      gblPayFormVals.forEach((key, value) {
          url += '&$key=$value';
      });
    }

    return url;
  }

  Future<void> _successfulPayment() async {
    logit('Load booking  $gblCurrentRloc');

    http.Response response = await http
        .get(Uri.parse(
        "${gblSettings.xmlUrl}${gblSettings.xmlToken}&command=*$gblCurrentRloc~x'"))
        .catchError((resp) {});

    if (response == null) {
      // error
      logit('Load booking no data');
      return ;
    }

    //If there was an error return an empty list
    if (response.statusCode < 200 || response.statusCode >= 300) {
      // error
      logit('Load booking network error ${response.statusCode}');
      return ;
    }

    try {
      // Server Exception ?
      String pnrJson = response.body
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', '');
      Map map = json.decode(pnrJson);
      PnrModel pnrModel = new PnrModel.fromJson(map);
      PnrDBCopy pnrDBCopy = new PnrDBCopy(
          rloc: pnrModel.pNR.rLOC, //_rloc,
          data: pnrJson,
          delete: 0,
          nextFlightSinceEpoch: pnrModel.getnextFlightEpoch());
      logit('Load booking update pnr ${pnrModel.pNR.rLOC}');

      Repository.get()
          .updatePnr(pnrDBCopy);
      Repository.get()
          .fetchApisStatus(pnrModel.pNR.rLOC)
          .then((n) => getArgs(pnrModel.pNR))
          .then((arg) {
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/CompletedPage', (Route<dynamic> route) => false,
            arguments: arg);
      });
    } catch (e) {
      logit(e.toString());
    }
  }

getArgs(PNR pNR) {
  List<String> args = [];
  // List<String>();
  args.add(pNR.rLOC);
  if (pNR.itinerary.itin
      .where((itin) =>
  itin.classBand.toLowerCase() != 'fly' &&
      itin.openSeating != 'True')
      .length >
      0) {
    args.add('true');
  } else {
    args.add('false');
  }
  return args;
}
}


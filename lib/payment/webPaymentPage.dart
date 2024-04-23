import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/pnr.dart';
import 'package:vmba/data/models/pnrs.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/payment/paymentCmds.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/utilities/widgets/appBarWidget.dart';
import 'package:webview_flutter/webview_flutter.dart';
//import 'package:flutter_inappwebview/flutter_inappwebview.dart' as inapp;

import '../Helpers/bookingHelper.dart';
import '../data/smartApi.dart';
import '../utilities/widgets/CustomPageRoute.dart';
import 'choosePaymentMethod.dart';

class WebPayPage extends StatefulWidget {
  final NewBooking newBooking;
  PnrModel pnrModel;
  MmbBooking? mmbBooking;
  final bool isMmb ;

  String  url = gblSettings.payPage;
  String provider = '';
  //final title;
  bool canNotClose = false;
  WebPayPage(this.provider, {
    required this.newBooking,
    required this.pnrModel,
    this.mmbBooking,
    required this.isMmb,
  });

  @override
  _WebViewWidgetState createState() => _WebViewWidgetState();
}

class _WebViewWidgetState extends State<WebPayPage> {
  // new bits
  final GlobalKey webViewKey = GlobalKey();
  late final WebViewController controller;

  int _percentLoaded = 0;
  String _url = '';

  int _stackToView = 1;
  late Timer _timer;
  bool _endDetected = false;

  @override void initState() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%) url $_url');
            setState(() {
              _percentLoaded = progress;
            });
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            _url = url;
            _handleLoad();
            debugPrint('Page finished loading: $url');
            if (url.contains(gblSettings.paySuccessUrl)) {
              // SUCCESS
              print('payment success ');
              gblPaymentState = PaymentState.success;
              //_successfulPayment();
              _gotoSuccessPage(widget.pnrModel);
              //return NavigationDecision.prevent;
            }
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');

          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            if (request.url.contains(gblSettings.payFailUrl)) {
              // FAILED
              print('payment failed $request}');
              gblPayBtnDisabled = false;
              gblPaymentState = PaymentState.declined;
              if (request.url.contains('?')) {
                String err = request.url.split('?')[1];
                err = err.split('=')[1];
                gblPaymentMsg = Uri.decodeFull(err);
              } else {
                gblPaymentMsg = 'Payment Declined';
              }
              _endDetected = true;
              //   getAlertDialog( context, 'Payment Error', gblPaymentMsg, onComplete: onComplete );

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ChoosePaymenMethodWidget(newBooking: widget.newBooking,
                        pnrModel: widget.pnrModel,
                        isMmb: widget.isMmb,),
                ),
              );

              return NavigationDecision.prevent;
            }

            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
          onUrlChange: (UrlChange change) {
            _url = change.url!;
            debugPrint('url change to ${change.url}');
          },
        ),
      )
      ..loadRequest(Uri.parse(_getPayUrl()));

    _timer = Timer(Duration(minutes : gblSettings.payTimeout), () {
      logit('Payment timed out');
      _timer.cancel();
      //_timer = null;
      _endDetected = false;
      gblPayBtnDisabled = false;
      gblPaymentMsg = 'Payment Timeout';
      //Navigator.pop(context, 'fail');
      Navigator.pushReplacement(
      context,
      //MaterialPageRoute(
        CustomPageRoute(
        builder: (context) => ChoosePaymenMethodWidget(newBooking: widget.newBooking, pnrModel: widget.pnrModel, isMmb: widget.isMmb,),
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
      //_timer = null;
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
/*
    return WillPopScope(
      onWillPop: _onWillPop,
*/
    return
      /*CustomWillPopScope(
          action: () {

            print('pop');
            onWillPop(context);
          },
          onWillPop: true,
        child:*/
        Scaffold(
      appBar: appBar(context,  'Payment Page', automaticallyImplyLeading: false,
          actions:<Widget> [ new IconButton(
      icon:  new Icon(Icons.close),
      onPressed: () async {
        if( gblPaySuccess == true ) {
          gblPaymentState = PaymentState.success;
          print('payment success page close');
        //  _successfulPayment();
          _gotoSuccessPage(widget.pnrModel);
          //return NavigationDecision.prevent;
        } else {
          gblPayBtnDisabled = false;
          gblPaymentState = PaymentState.needCheck;
          gblPaymentMsg = 'Payment aborted';
          try {
            await callSmartApi('CANCELPAYMENT', "");
          } catch(e) {
          }

          Navigator.pop(context);
        }
      },
    )]),


      body: Builder(builder: (BuildContext context) {
        return IndexedStack(
          index: _stackToView,
          children: <Widget>[
            _getView(),
            new Center(
                child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                CircularProgressIndicator(),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child:  Text(translate('Loading Payment Page' ) )
            ),
            ])),
          ],
        );
      }),
      //  floatingActionButton: favoriteButton(),
    );
  }


  Widget _getWebView() {



    return WebViewWidget(
      controller: controller,
      //initialUrl: _getPayUrl(),
      //javascriptMode: JavascriptMode.unrestricted,
      //debuggingEnabled: true,
  /*    onWebViewCreated: (WebViewController webViewController) {
        _controller.complete(webViewController);
        print('on created');
      },*/
/*
      onWebResourceError: (WebResourceError e) {
        print('resource error $e');
      },
*/


   /*   navigationDelegate: (NavigationRequest request) {
        logit('Web Payment Page change url to ${request.url}');
        if (request.url.contains(gblSettings.payFailUrl)) {
          // FAILED
          print('payment failed $request}');
          gblPayBtnDisabled = false;
          gblPaymentState = PaymentState.declined;
          if (request.url.contains('?')) {
            String err = request.url.split('?')[1];
            err = err.split('=')[1];
            gblPaymentMsg = Uri.decodeFull(err);
          } else {
            gblPaymentMsg = 'Payment Declined';
          }
          _endDetected = true;
          //   getAlertDialog( context, 'Payment Error', gblPaymentMsg, onComplete: onComplete );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ChoosePaymenMethodWidget(newBooking: widget.newBooking,
                    pnrModel: widget.pnrModel,
                    isMmb: widget.isMmb,),
            ),
          );

          return NavigationDecision.prevent;
        }
        if (request.url.contains('returnfromexternalpayment') &&
            request.url.contains('success')) {
          // may need this if page closed
          gblPaySuccess = true;
        }
        if (request.url.contains(gblSettings.paySuccessUrl)) {
          // SUCCESS
          print('payment success $request}');
          gblPaymentState = PaymentState.success;
          //_successfulPayment();
          _gotoSuccessPage(widget.pnrModel);
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
        if (url.contains('returnfromexternalpayment') &&
            url.contains('success')) {
          // may need this if page closed
          gblPaySuccess = true;
        }
      },*/
    );
  }

  Widget _getView() {
    if( gblSettings.useScrollWebViewiOS && gblIsIos  ) { // gblSettings.useScrollWebViewiOS && gblIsIos
      final ScrollController controller = ScrollController();
      final ScrollController controller2 = ScrollController();
      print('go wide');


      double addWidth = 0;
      if(gblSettings.aircode == 'T6'){
        addWidth = 10;
      }

      return Scrollbar(
          controller: controller2,
          child: SingleChildScrollView(
              controller: controller2,
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                  controller: controller,
                  child: Container(
                    height: MediaQuery.of(context).size.height +200,
                    width: MediaQuery.of(context).size.width + addWidth,
                    child: _getWebView(),

                  )
              )
          )
      );
    } else {
      return _getWebView();

    }
  }

  void onComplete() {
    gblPaymentMsg = '';
    Navigator.pushReplacement(
      context,
      //MaterialPageRoute(
      CustomPageRoute(
        builder: (context) => ChoosePaymenMethodWidget(newBooking: widget.newBooking, pnrModel: widget.pnrModel, isMmb: widget.isMmb,),
      ),
    );

  }

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new TrText('Are you sure?'),
        content: new TrText('Do you want to abandon your booking '),
        actions: <Widget>[
          TextButton(
            onPressed: () {
    gblPayBtnDisabled = false;
    Navigator.of(context).pop(false);
    } ,
            child: new TrText('No'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await callSmartApi('CANCELPAYMENT', "");
              } catch(e) {
              }

              gblPayBtnDisabled = false;
              Navigator.of(context).pop(true);
              },
            child: new TrText('Yes'),
          ),
        ],
      ),
    )) ?? false;
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
    if( gblPayAction != null && gblPayAction != '' )
      {
        action = gblPayAction;
      }
    String url = '${widget.url}?gateway=$provider&rloc=$gblCurrentRloc&action=$action&guid=${gblSettings.vrsGuid}&mmb=${widget.isMmb}';
    if(gblRedeemingAirmiles &&  gblFqtvLoggedIn == true && gblPassengerDetail!.fqtv != ''){
      url += '&FQTVUsername=${gblPassengerDetail!.fqtv}';
    }
    if(gblSession != null) {
      url += '&VARSSessionID=${gblSession!.varsSessionId}';
      logit('Session = ${gblSession!.varsSessionId}');
    }

    if( gblPayFormVals != null) {
      gblPayFormVals!.forEach((key, value) {
        String qValue = value.replaceAll(' ', '%20');
          url += '&$key=$qValue';
      });
    }

    return url;
  }

  Future<void> _successfulPayment() async {
    logit('Load booking  $gblCurrentRloc');
    String data;


      data = await runVrsCommand('*$gblCurrentRloc~x');

      if( gblSettings.saveChangeBookingBeforePay == false){
        // make change flight changes
        if( gblPayAction == 'BOOKSEAT' && gblBookSeatCmd != '')
          {
            bool seatBooked = false;
            if (widget.pnrModel != null) {
              seatBooked = widget.pnrModel!.isSeatInPnr(gblBookSeatCmd);
            }
            if( !seatBooked) {
              data = await runVrsCommand('$gblBookSeatCmd^*R~x');
            }
          } else if (gblPayAction == 'CHANGEFLT') {
          await changeFlt(widget.pnrModel, widget.mmbBooking!, context);
        }
      }

    try {
      // Server Exception ?
      String pnrJson = data //response.body
          .replaceAll('<?xml version="1.0" encoding="utf-8"?>', '')
          .replaceAll('<string xmlns="http://videcom.com/">', '')
          .replaceAll('</string>', '');
      Map<String, dynamic> map = json.decode(pnrJson);
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
            logit('go to completed page');
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

  _gotoSuccessPage(PnrModel pnrModel)
  {
    logit('go to success $_endDetected');

    if(_endDetected != true) {
      _endDetected = true;

      _successfulPayment();
/*
      List<String> args =  getArgs(pnrModel.pNR);
      Navigator.of(context).pushNamedAndRemoveUntil(
            '/CompletedPage', (Route<dynamic> route) => false,
            arguments: args);
*/
    }
  }
}



import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/components/trText.dart';
import 'package:vmba/menu/menu.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/models/pnr.dart';

import 'package:vmba/data/globals.dart';
import 'package:vmba/payment/paymentCmds.dart';
import 'package:vmba/payment/v2/ProviderFields.dart';
import 'package:vmba/payment/webPaymentPage.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/utilities/widgets/appBarWidget.dart';
import 'package:vmba/data/models/providers.dart' as PaymentProvider;
import 'package:vmba/utilities/widgets/buttons.dart';
import 'package:vmba/v3pages/controls/V3Constants.dart';

import '../controllers/vrsCommands.dart';
import '../utilities/widgets/CustomPageRoute.dart';
import '../v3pages/cards/v3FormFields.dart';


bool wantrebook = false;

class ProviderFieldsPage extends StatefulWidget {
  ProviderFieldsPage({    Key key= const Key("provfipa_key"),
     this.newBooking,
    required this.pnrModel,
    this.isMmb=false,
    required this.mmbBooking,
    this.mmbAction,
    required this.provider
  }) : super(key: key);

  NewBooking? newBooking;
  final PnrModel pnrModel;
  final bool isMmb;
  final MmbBooking mmbBooking;
  final mmbAction;
  final PaymentProvider.Provider provider;

  @override
  ProviderFieldsPageState createState() => ProviderFieldsPageState();
}

class ProviderFieldsPageState extends State<ProviderFieldsPage> {
  GlobalKey<ScaffoldState> _key = GlobalKey();
  final formKey = new GlobalKey<FormState>();

  // bool _displayProcessingIndicator;
  //String _displayProcessingText = 'Making your Booking...';
  PaymentDetails paymentDetails = new PaymentDetails();
  String _displayProcessingText ='';
  bool _displayProcessingIndicator = false;
  String nostop = '';

  //bool _displayProcessingIndicator;
  // String _displayProcessingText;
  PnrModel? pnrModel;
  String rLOC = '';
  Session? session;

  @override
  initState() {
    super.initState();
    _displayProcessingIndicator = false;
    _displayProcessingText = 'Processing your payment...';
    double am = double.parse(widget.pnrModel.pNR.basket.outstanding.amount);
    setError( '');
    gblPayBtnDisabled = false;
    if (am <= 0) {
    //  signin().then((_) => completeBooking());
    }
  }

  @override
  Widget build(BuildContext context) {
    if( gblError != null && gblError.isNotEmpty) {
      return Scaffold(
        key: _key,
        appBar: appBar(context, 'Payment',PageEnum.providerFields,
          newBooking: widget.newBooking,
          curStep: 5,
          imageName: gblSettings.wantPageImages ? 'paymentPage' : '',),
        endDrawer: DrawerMenu(),
        body: new Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new TrText(
                    'Payment Error', style: TextStyle(fontSize: 16.0)),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new TrText(gblError, style: TextStyle(fontSize: 16.0),),
              ),
            ],
          ),
        ),
      );
    }
    if (_displayProcessingIndicator) {
      return Scaffold(
        key: _key,
        appBar: new AppBar(
          //brightness: gblSystemColors.statusBar,
          backgroundColor:
          gblSystemColors.primaryHeaderColor,
          iconTheme: IconThemeData(
              color: gblSystemColors.headerTextColor),
          title: new TrText('Payment',
              style: TextStyle(
                  color:
                  gblSystemColors.headerTextColor)),
        ),
        endDrawer: DrawerMenu(),
        body: new Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              new CircularProgressIndicator(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: new Text(_displayProcessingText),
              ),
            ],
          ),
        ),
      );
    }
      // no error
      return Scaffold(
        key: _key,
        appBar: appBar(context, 'Payment', PageEnum.providerFields,
          newBooking: widget.newBooking,
          curStep: 5,
          imageName: gblSettings.wantPageImages ? 'paymentPage' : '',) ,
        endDrawer: DrawerMenu(),
        body:Form(
          key: formKey,
          child: new SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                children: _getBody(),
              ),
            ),
          ),
        ),
      );

    }


  List<Widget> _getBody() {
    List <Widget> list = [];

    widget.provider.fields.paymentFields.forEach((element) {
   //   logit('Add field ${element.paymentFieldName}');
      FieldParams params = FieldParams();
      params.label = element.defaultLabel;
      params.maxLength = element.maxLen;
      params.minLength = element.minLen;
      params.required = element.requiredField;
      params.id = element.paymentFieldName;
      bool bShow = false;

      switch (element.paymentFieldName) {
        case 'CardType':
          bShow = true;
          params.ftype = FieldType.choice;
          params.options = element.fieldOptions;
          break;
        case 'BankName':
          break;
        case 'CardNumber':
          params.inputFormatters = [LengthLimitingTextInputFormatter(19)];
          bShow = true;
          break;
        case 'CardStartDate':
          break;
        case 'CardExpiryDate':
          break;
        case 'CardIssueNumber':
          break;
        case 'CardSecurityCode':
          break;
        case 'CardAuthorisationCode':
          break;
        case 'CardHolder':
          params.inputFormatters = [FilteringTextInputFormatter.allow(RegExp("[a-zA-Z- ÆØøäöåÄÖÅæé]")) ];
          bShow = true;
          break;
        case 'BillingAddressLine1':
         //params.inputFormatters = [FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z- ÆØøäöåÄÖÅæé]")) ];
          bShow = true;
          break;
        case 'BillingAddressLine2':
          //params.inputFormatters = [FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z- ÆØøäöåÄÖÅæé]")) ];
          bShow = true;
          break;
        case 'BillingAddressLine3':
          //params.inputFormatters = [FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z- ÆØøäöåÄÖÅæé]")) ];
          bShow = true;
          break;
        case 'BillingAddressLine4':
         // params.inputFormatters = [FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z- ÆØøäöåÄÖÅæé]")) ];
          bShow = true;
          break;
        case 'BillingAddressPostZipCode':
          params.inputFormatters = [FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z- ÆØøäöåÄÖÅæé]")) ];
          bShow = true;
          break;
        case 'BillingAddressCountry':
         // params.inputFormatters = [FilteringTextInputFormatter.allow(RegExp("[a-zA-Z- ÆØøäöåÄÖÅæé]")) ];
          bShow = true;
          break;
        case 'PaymentReference':
          bShow = true;
          break;
        case 'AgreePaymentTermsAndConditions':
          break;
        case 'CardNumberBinBase':
          break;
        case 'CreditCardFee':
          break;
        case 'BillingAddressCountryCodes':
          bShow = true;
          params.ftype = FieldType.country;
          break;
        case 'MobileNumber':
          break;
        case 'CardHolderFirstname':
          bShow = true;
          break;
        case 'CardHolderSurname':
          bShow = true;
          break;
        default:
          logit('pay field not supported ${element.paymentFieldName}');
          break;

     }
     if( bShow) {
       list.add(VInputField(fieldParams: params, provider: widget.provider, pnrModel: widget.pnrModel, key: Key((element.paymentFieldName as String) + '_key'),));
     }
    });


    list.add( Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
        smallButton( backClr: Colors.grey.shade500, id: 'backBtn', text: translate('Back'), icon: Icons.arrow_back, onPressed: ()
        { Navigator.pop(context);}),


          ElevatedButton(
            onPressed: () {
              if ( gblPayBtnDisabled == false ) {
                gblPayBtnDisabled = true;
                setState(() {

                });
                validateAndSubmit();
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: gblSystemColors
                    .primaryButtonColor, //Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0))),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                (gblPayBtnDisabled ) ?
                new Transform.scale(
                  scale: 0.5,
                  child: CircularProgressIndicator(),
                )   :
                Icon(Icons.check,
                  color: Colors.white,
                ),
                gblPayBtnDisabled ?  new TrText("Completing Payment...", style: TextStyle(color: Colors.white)) : TrText('PAY NOW',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          )]
           ),);
    logit('ret list');
    return list;

  }

  bool validate() {
    final form = formKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }
  void validateAndSubmit() async {
    if (validate()) {
      hasDataConnection().then((result) async {
        if (result == true) {
          if(widget.mmbAction == 'CHANGEFLT' ) { // && wantrebook
            await changeFlt(widget.pnrModel, widget.mmbBooking, context);
          }
          if( widget.newBooking == null ) widget.newBooking = NewBooking();
          await Navigator.push(
              context,
              //SlideTopRoute(
              CustomPageRoute(
                  builder: (context) => WebPayPage(
            widget.provider.paymentSchemeName, newBooking: widget.newBooking!,
            pnrModel: widget.pnrModel,
            isMmb: widget.isMmb,)));
          setState(() { });

        } else {
          setState(() {
            _displayProcessingIndicator = false;
          });
          //noInternetSnackBar(context);
        }
      });
    } else {
      gblPayBtnDisabled = false;
      _displayProcessingIndicator = false;
      setState(() {

      });
    }
  }



}



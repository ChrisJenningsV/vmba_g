import 'dart:async';
//import 'package:credit_card/credit_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vmba/utilities/helper.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/utilities/widgets/buttons.dart';
import '../CreditCardHelper.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';

class CardInputWidget extends StatefulWidget {
  final VoidCallback payCallback;
  final PaymentDetails  paymentDetails;

  const CardInputWidget({
    Key key,
    this.payCallback,
    this.paymentDetails}) : super(key: key);

  @override
  _CardInputWidgetState createState() => _CardInputWidgetState();
}

class _CardInputWidgetState extends State<CardInputWidget> {
  final formKey = new GlobalKey<FormState>();
  String cardNumber = '';
  String cardHolderName = '';
  String expiryDate = '';
  String cvvCode = '';

  String street = '';
  String town = '';
  String state = '';
  String postcode = '';
  String country = '';

  String aircode = '';
@override
void initState() {
  super.initState();
  gblPayBtnDisabled = false;
}

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Theme(
          data: ThemeData(
            primaryColor: Colors.blueAccent,
            primaryColorDark: Colors.blue,
          ),
          child: Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Column(
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(children: [
                  renderCardDetails(),
                  Divider(),
                  renderCardBillingDetails(),
                  Divider(),
                ]),
                showPayButton()
                    ? ElevatedButton(
                        onPressed: () {
                          if ( gblPayBtnDisabled == false ) {
                            gblPayBtnDisabled = true;
                            saveSettings();
                            widget.payCallback();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                            primary: gblSystemColors
                                .primaryButtonColor, //Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0))),
                        child: Row(
                          //mainAxisSize: MainAxisSize.min,
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
                      )
                    : Text('')
              ],
            ),
          ),
        ),
      ),
    );
  }

  saveSettings() {
    widget.paymentDetails.cardNumber =  cardNumber ;
    widget.paymentDetails.cardHolderName  = cardHolderName ;
    widget.paymentDetails.expiryDate =  expiryDate.replaceAll('/', '') ;
    widget.paymentDetails.cVV  = cvvCode ;

    widget.paymentDetails.addressLine1 = street ;
    widget.paymentDetails.town = town ;
    widget.paymentDetails.state = state ;
    widget.paymentDetails.postCode = postcode ;
    widget.paymentDetails.country  = country ;

  }
  bool showPayButton() {
    //Check card details
    if (cardNumber == '' ||
        cardHolderName == '' ||
        expiryDate == '' ||
        cvvCode == '') {
      return false;
    }

    //Check address details
    if (street == '' ||
        town == '' ||
        state == '' ||
        postcode == '' ||
        country == '') {
      return false;
    }

    return true;
  }

  Column renderCardDetails() {
    List<Widget> cardDetails = [];
//    new List<Widget>();
    cardDetails.add(Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
      width: double.maxFinite,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 5,
        child: InkWell(
          onTap: () {
            _showCreditCardDialog().then((value) => setState(() {}));
          },
          child: Stack(children: <Widget>[
            Container(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: getCardTypeIcon(cardNumber)
                          // Icon(
                          //   Icons.credit_card_rounded,
                          //   size: 40,
                          // ),
                          ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.contactless,
                          size: 40,
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  height: 16,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    cardNumber.isEmpty || cardNumber == null
                        ? 'XXXX XXXX XXXX XXXX'
                        : cardNumber,
                  ),
                ),
                Container(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: <Widget>[
                          Text(
                            translate('Expiry'),
                            style: TextStyle(
                              fontSize: 9,
                            ),
                          ),
                          Container(
                            width: 16,
                          ),
                          Text(
                            expiryDate.isEmpty || expiryDate == null
                                ? 'MM/YY'
                                : expiryDate,
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Text(
                            'Cvv',
                            style: TextStyle(
                              fontSize: 9,
                            ),
                          ),
                          Container(
                            width: 16,
                          ),
                          Text(
                            cvvCode.isEmpty || cvvCode == null
                                ? 'XXX'
                                : cvvCode,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 10,
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                  child: Text(
                    cardHolderName.isEmpty || cardHolderName == null
                        ? translate('Card Holder').toUpperCase()
                        : cardHolderName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ))
          ]),
        ),
      ),
    ));

    return Column(
      children: cardDetails,
    );
  }

  Widget renderCardBillingDetails() {
    List<Widget> cardDetails = [];
    // new List<Widget>();
//Section title
    cardDetails.add(Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        TrText(
          "Card Billing Address",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ],
    ));

    cardDetails.add(Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            child: street.isEmpty
                ? TrText('Add card details')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(street),
                      Text(town),
                      Text(state),
                      Text(postcode),
                      Text(country),
                    ],
                  ),
          ),
          smallButton( text: street.isEmpty ? translate('Add') : translate('Edit'),
              icon: street.isEmpty ? Icons.add : Icons.edit,
              onPressed: () {  _showAddressDialog().then((value) => setState(() {}));}),
          /*
          IconButton(
            onPressed: () {
              _showAddressDialog().then((value) => setState(() {}));
            },
            icon: street.isEmpty ? Icon(Icons.add) : Icon(Icons.edit),
            iconSize: 20,
          )

           */
        ],
      ),
    ));

    return Column(
      children: cardDetails,
    );
  }

  Future<void> _showCreditCardDialog() async {
    final MaskedTextController _cardNumberController =
        MaskedTextController(mask: '0000 0000 0000 0000');
    final TextEditingController _expiryDateController =
        MaskedTextController(mask: '00/00');
    final TextEditingController _cardHolderNameController =
        TextEditingController();
    final TextEditingController _cvvCodeController =
        MaskedTextController(mask: '0000');

    if (cardNumber != null) {
      _cardNumberController.text = cardNumber.toString();
    }
    if (expiryDate != null) {
      _expiryDateController.text = expiryDate.toString();
    }
    if (cardHolderName != null) {
      _cardHolderNameController.text = cardHolderName.toString();
    }
    if (cvvCode != null) {
      _cvvCodeController.text = cvvCode.toString();
    }
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Stack(children: [
            Container(
                width: double.infinity,
                //height: 200,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.white),
                padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: SingleChildScrollView(
                  child: Theme(
                    data: ThemeData(
                      primaryColor: Colors.blueAccent,
                      primaryColorDark: Colors.blue,
                    ),
                    child: Form(
                        key: formKey,
                        child: Column(
                          children: <Widget>[
                            Container(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: TrText('Enter your Card Details',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 20))),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              //margin: const EdgeInsets.only(left: 16, top: 16, right: 16),
                              child: TextFormField(
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return translate('Card number cannot be empty');
                                  }

                                  if (value.length < 15) {
                                    return translate('Card number not valid');
                                  }

                                  return null;
                                },

                                onSaved: (value) => cardNumber = value.trim(),
                                controller: _cardNumberController,
                                //   cursorColor: widget.cursorColor ?? themeColor,
                               //style: TextStyle(
                                    //    color: widget.textColor,
                                //    ),
                                decoration: getDecoration('Card number', prefixIcon: Icon(Icons.credit_card_sharp),hintText: 'xxxx xxxx xxxx xxxx'),
                                /*InputDecoration(
                                  prefixIcon: Icon(Icons.credit_card_sharp),
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(25.0),
                                    borderSide: new BorderSide(),
                                  ),
                                  labelText: translate('Card number'),
                                  hintText: 'xxxx xxxx xxxx xxxx',
                                  fillColor: Colors.white,
                                ),
                                */
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(19)
                                ],
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              //  margin: const EdgeInsets.only(left: 16, top: 8, right: 16),
                              child: TextFormField(
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return translate('Expiry date cannot be empty');
                                  }
                                  if (value.length < 5) {
                                    return translate('Expiry date not valid');
                                  }

                                  int expiryYear =
                                      int.parse(value.split('/')[1]) + 2000;
                                  int expiryMonth =
                                      int.parse(value.split('/')[0]);

                                  if (expiryYear < DateTime.now().year) {
                                    return translate('Expiry date not valid');
                                  }

                                  if (expiryMonth > 12) {
                                    return translate('Expiry date not valid');
                                  }

                                  if (expiryYear == DateTime.now().year) {
                                    if (expiryMonth < DateTime.now().month)
                                      return translate('Expiry date not valid');
                                  }

                                  if ((int.parse(value.split('/')[1]) + 2000) <
                                      DateTime.now().year) {
                                    return translate('Expiry date not valid');
                                  }

                                  return null;
                                },
                                onSaved: (value) => expiryDate = value.trim(),

                                controller: _expiryDateController,
                                decoration: getDecoration('Expiry Date', prefixIcon: Icon(Icons.date_range),hintText: 'MM/YY') ,
                                /*InputDecoration(
                                    prefixIcon: Icon(Icons.date_range),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            new BorderRadius.circular(25.0)),
                                    labelText: translate('Expiry Date'),
                                    hintText: 'MM/YY'),
                                */
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(5)
                                ],
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              // margin: const EdgeInsets.only(left: 16, top: 8, right: 16),
                              child: TextFormField(
                                // focusNode: cvvFocusNode,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return translate('Security code cannot be empty');
                                  }
                                  if (value.length < 3) {
                                    return translate('Security code not valid');
                                  }
                                  return null;
                                },
                                onSaved: (value) => cvvCode = value.trim(),
                                controller: _cvvCodeController,
                               decoration: getDecoration('Security Code', prefixIcon: Icon(Icons.lock),hintText: 'XXXX'),
                               /*InputDecoration(
                                  prefixIcon: Icon(Icons.lock),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          new BorderRadius.circular(25.0)),
                                  labelText: translate('Security Code'),
                                  hintText: 'XXXX',
                                ),
                                */
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[0-9]")),
                                  LengthLimitingTextInputFormatter(4)
                                ],
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: TextFormField(
                                validator: (value) => value.isEmpty
                                    ? translate('Card holder name cannot be empty')
                                    : null,
                                onSaved: (value) =>
                                    cardHolderName = value.trim(),
                                controller: _cardHolderNameController,
                                style: TextStyle(),
                                decoration: getDecoration( 'Card Holder'),
                                /* InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius:
                                        new BorderRadius.circular(25.0),
                                    borderSide: new BorderSide(),
                                  ),
                                  labelText: translate('Card Holder'),
                                ),
                                */
                                //keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.next,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp("[a-zA-Z- ÆØøäöåÄÖÅæé]")),
                                  LengthLimitingTextInputFormatter(50)
                                ],
                              ),
                            ),
                            Container(
                              child: ElevatedButton(
                                onPressed: () {validateAndSubmit();},
                                style: ElevatedButton.styleFrom(
                                    primary: gblSystemColors
                                        .primaryButtonColor,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(30.0))),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  //  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Icon(
                                      Icons.check,
                                      color: Colors.white,
                                    ),
                                    TrText(
                                      'Done',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Container(
                            //     padding: EdgeInsets.all(8),
                            //     child: Text("Scan my Card")),
                          ],
                        )),
                  ),
                )),
          ]),
        );
      },
    );
  }

  validateAndSubmit() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      Navigator.pop(context);
    }
  }


  Future<void> _showAddressDialog() async {
    TextEditingController _streetTextEditingController =
        TextEditingController();
    TextEditingController _townTextEditingController = TextEditingController();
    TextEditingController _stateTextEditingController = TextEditingController();
    TextEditingController _postcodeTextEditingController =
        TextEditingController();
    TextEditingController _countryTextEditingController =
        TextEditingController();

    if (street != null) {
      _streetTextEditingController.text = street.toString();
    }
    if (town != null) {
      _townTextEditingController.text = town.toString();
    }
    if (state != null) {
      _stateTextEditingController.text = state.toString();
    }
    if (postcode != null) {
      _postcodeTextEditingController.text = postcode.toString();
    }
    if (country != null) {
      _countryTextEditingController.text = country.toString();
    }

    void _updateCountryData(String value) {
      setState(() {
        _countryTextEditingController.text = value;
        FocusScope.of(context).requestFocus(new FocusNode());
      });
    }

    List<Widget> optionCountryList(AsyncSnapshot snapshot) {
      List<Widget> widgets = [];
      //new List<Widget>();
      Countrylist countrylist = snapshot.data;
      countrylist.countries.forEach((c) => widgets.add(ListTile(
          title: Text(c.enShortName),
          onTap: () {
            Navigator.pop(context, c.alpha2code);
            _updateCountryData(c.alpha2code);
            //Navigator.pop(context, c.alpha3code);
            //_updateCountryData(c.alpha3code);
          })));
      return widgets;
    }

    void _showCountriesDialog() {
      // flutter defined function
      showDialog(
        context: context,
        builder: (BuildContext context) {
          // return object of type Dialog
          return AlertDialog(
              title: new TrText('Country'),
              content: new FutureBuilder(
                future: getCountrylist(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data != null) {
                      return Container(
                        width: double.maxFinite,
                        child: new ListView(
                          children: optionCountryList(snapshot),
                        ),
                      );
                    } else {
                      return null;
                    }
                  } else {
                    return Container(
                      width: double.maxFinite,
                      child: new Center(
                        child: new CircularProgressIndicator(),
                      ),
                    );
                  }
                },
              ));
        },
      );
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
          child: Container(
              width: double.infinity,
              //height: 200,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), color: Colors.white),
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: SingleChildScrollView(
                child: Theme(
                  data: ThemeData(
                    primaryColor: Colors.blueAccent,
                    primaryColorDark: Colors.blue,
                  ),
                  child: Form(
                      key: formKey,
                      child: Column(
                        children: <Widget>[
                          Container(
                              padding: const EdgeInsets.only(bottom: 20.0),
                              child: TrText('Card Billing Details',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 20))),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            //margin: const EdgeInsets.only(left: 16, top: 16, right: 16),
                            child: TextFormField(
                              validator: (value) => value.isEmpty
                                  ? translate('Address field required')
                                  : null,

                              onSaved: (value) => street = value.trim(),
                              controller: _streetTextEditingController,
                              //   cursorColor: widget.cursorColor ?? themeColor,
                              style: TextStyle(
                                  //    color: widget.textColor,
                                  ),
                              decoration: getDecoration( translate('Address line') + ' 1'),
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp("[a-zA-Z0-9- ]"))
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            //  margin: const EdgeInsets.only(left: 16, top: 8, right: 16),
                            child: TextFormField(
                              validator: (value) => value.isEmpty
                                  ? translate('Address field required')
                                  : null,
                              onSaved: (value) => town = value.trim(),

                              controller: _townTextEditingController,
                              // cursorColor: widget.cursorColor ?? themeColor,
                              style: TextStyle(
                                  //  color: widget.textColor,
                                  ),
                              decoration: getDecoration(translate('Town or City')),
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                // FilteringTextInputFormatter.allow(
                                //    RegExp("[0-9]")),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            // margin: const EdgeInsets.only(left: 16, top: 8, right: 16),
                            child: TextFormField(
                              // focusNode: cvvFocusNode,
                              validator: (value) => value.isEmpty
                                  ? translate('Address field required')
                                  : null,
                              onSaved: (value) => state = value.trim(),
                              controller: _stateTextEditingController,
                              //cursorColor: widget.cursorColor ?? themeColor,
                              style: TextStyle(
                                  //color: widget.textColor,
                                  ),
                              decoration: getDecoration( aircode == 'SI'
                                    ? translate('Parish or County')
                                    : translate('County or State')),
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp("[a-zA-Z ]"))
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TextFormField(
                              validator: (value) => value.isEmpty
                                  ? translate('Address field required')
                                  : null,
                              onSaved: (value) => postcode = value.trim(),
                              controller: _postcodeTextEditingController,
                              style: TextStyle(),
                              decoration: getDecoration(translate('Post code / Zip Code')),
                              keyboardType: TextInputType.text,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp("[a-zA-Z0-9 ]"))
                              ],
                            ),
                          ),
                          Container(
                            child: InkWell(
                              onTap: () {
                                _showCountriesDialog();
                              },
                              child: IgnorePointer(
                                child: TextFormField(
                                  decoration: getDecoration(translate('Country')),
                                  controller: _countryTextEditingController,
                                  textInputAction: TextInputAction.done,
                                  validator: (value) => value.isEmpty
                                      ? translate('Address field required')
                                      : null,
                                  onSaved: (value) {
                                    if (value != null) {
                                      country = value.trim();
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          Container(
                            child: ElevatedButton(
                              onPressed: () {
                                validateAndSubmit();
                              },
                              style: ElevatedButton.styleFrom(
                                  primary: gblSystemColors
                                      .primaryButtonColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(30.0))),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  ),
                                  TrText(
                                    'Done',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )),
                ),
              )),
        );
      },
    );
  }
}



class MaskedTextController extends TextEditingController {
  MaskedTextController({String text, this.mask, Map<String, RegExp> translator})
      : super(text: text) {
    this.translator = translator ?? MaskedTextController.getDefaultTranslator();

    addListener(() {
      final String previous = _lastUpdatedText;
      if (this.beforeChange(previous, this.text)) {
        updateText(this.text);
        this.afterChange(previous, this.text);
      } else {
        updateText(_lastUpdatedText);
      }
    });

    updateText(this.text);
  }

  String mask;

  Map<String, RegExp> translator;

  Function afterChange = (String previous, String next) {};
  Function beforeChange = (String previous, String next) {
    return true;
  };

  String _lastUpdatedText = '';

  void updateText(String text) {
    if (text != null) {
      this.text = _applyMask(mask, text);
    } else {
      this.text = '';
    }

    _lastUpdatedText = this.text;
  }

  void updateMask(String mask, {bool moveCursorToEnd = true}) {
    this.mask = mask;
    updateText(text);

    if (moveCursorToEnd) {
      this.moveCursorToEnd();
    }
  }

  void moveCursorToEnd() {
    final String text = _lastUpdatedText;
    selection =
        TextSelection.fromPosition(TextPosition(offset: (text ?? '').length));
  }

  @override
  set text(String newText) {
    if (super.text != newText) {
      super.text = newText;
      moveCursorToEnd();
    }
  }

  static Map<String, RegExp> getDefaultTranslator() {
    return <String, RegExp>{
      'A': RegExp(r'[A-Za-z]'),
      '0': RegExp(r'[0-9]'),
      '@': RegExp(r'[A-Za-z0-9]'),
      '*': RegExp(r'.*')
    };
  }

  String _applyMask(String mask, String value) {
    String result = '';

    int maskCharIndex = 0;
    int valueCharIndex = 0;

    while (true) {
      // if mask is ended, break.
      if (maskCharIndex == mask.length) {
        break;
      }

      // if value is ended, break.
      if (valueCharIndex == value.length) {
        break;
      }

      final String maskChar = mask[maskCharIndex];
      final String valueChar = value[valueCharIndex];

      // value equals mask, just set
      if (maskChar == valueChar) {
        result += maskChar;
        valueCharIndex += 1;
        maskCharIndex += 1;
        continue;
      }

      // apply translator if match
      if (translator.containsKey(maskChar)) {
        if (translator[maskChar].hasMatch(valueChar)) {
          result += valueChar;
          maskCharIndex += 1;
        }

        valueCharIndex += 1;
        continue;
      }

      // not masked value, fixed char on mask
      result += maskChar;
      maskCharIndex += 1;
      continue;
    }

    return result;
  }
}

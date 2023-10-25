import 'package:flutter/material.dart';
import 'package:vmba/datePickers/models/flightDatesModel.dart';
import 'package:vmba/flightSearch/widgets/passenger.dart';
import 'package:vmba/flightSearch/widgets/searchButton.dart';
import 'package:vmba/flightSearch/widgets/type.dart';
import 'package:vmba/flightSearch/widgets/date.dart';
import 'package:vmba/flightSearch/widgets/journey.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/menu/menu.dart';
import 'package:vmba/flightSearch/widgets/evoucher.dart';
import 'package:vmba/utilities/widgets/appBarWidget.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';

import '../Helpers/settingsHelper.dart';
import '../components/bottomNav.dart';
import '../utilities/helper.dart';

class FlightSearchPage extends StatefulWidget {
  FlightSearchPage({this.ads = false});
  final bool ads;
  @override
  _FlightSearchPageState createState() => _FlightSearchPageState();
}

class _FlightSearchPageState extends State<FlightSearchPage> {
  NewBooking booking = NewBooking();
  bool adsTermsAccepted = false;
  bool firstBuild = true;

  @override
  initState() {
    super.initState();
    commonPageInit('FLIGHTSEARCH');

    booking = new NewBooking();

    gblUndoCommand = '';
    booking.currency = gblSettings.currency;
    gblSelectedCurrency = gblSettings.currency;
    adsTermsAccepted = false;
    gblCurrentRloc = '';

    if (widget.ads) {
      if(gblPassengerDetail != null && gblPassengerDetail!.adsNumber != null && gblPassengerDetail!.adsNumber.isNotEmpty &&
          gblPassengerDetail!.adsPin != null && gblPassengerDetail!.adsPin.isNotEmpty
      ) {
        booking.ads = new ADS(gblPassengerDetail!.adsPin,gblPassengerDetail!.adsNumber);
      } else {
        Repository.get().getADSDetails().then((v) {
          booking.ads = v;
        });
      }
    }
  }

  void flightSelected(String flight) {
    print(flight);
  }

  Passengers pax = new Passengers(1, 0, 0, 0, 0, 0, 0);
  bool _isReturn = true;

  void _handleReturnToggleChanged(bool newValue) {
    setState(() {
      _isReturn = newValue;
      booking.isReturn = newValue;
    });
  }

  void _handleFlightselectedChanged(SelectedRoute newValue) {
    booking.arrival = newValue.arrival;
    booking.departure = newValue.departure;
  }

  void _handlePaxNumberChanged(Passengers newValue) {
    booking.passengers = newValue;
  }

  void _handleDateChanged(FlightDates newValue) {
    if (newValue != null) {
      booking.departureDate = newValue.departureDate;
      booking.returnDate = newValue.returnDate;
    }
  }

  _handleEVoucherChanged(String newValue) {
    if (newValue != null) {
      booking.eVoucherCode = newValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String>? args = ModalRoute.of(context)?.settings.arguments as List<String>?;
    final bool showFab = MediaQuery.of(context).viewInsets.bottom == 0.0;
    String helpText ='';
    EdgeInsets pad = EdgeInsets.all(16.0);
    if( wantPageV2()) {
      pad = EdgeInsets.all(15.0);
    }
    if( gblBuildFlavor == 'UZ') {
      helpText = 'Route Tripoli to Istanbul normally has some fares available.';
    }

    if( firstBuild == true &&  args != null && args.contains('wantRedeemMiles' )) {
      gblShowRedeemingAirmiles = true;
    }
    firstBuild = false;
    return new Scaffold(
        appBar:
        appBar(context, widget.ads == true ? 'ADS/Island Resident Flight Search': 'Flight Search'),
        endDrawer: DrawerMenu(),
        floatingActionButton: showFab
            ? SearchButtonWidget(
          newBooking: booking,
          onChanged: _reloadSearch,
        )
            : null,
        bottomNavigationBar: getBottomNav(context, helpText:  helpText),
        body: SingleChildScrollView(
          padding: pad,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              JourneyTypeWidget(
                  isReturn: _isReturn,
                  onChanged: _handleReturnToggleChanged),
              new Padding(
                padding: EdgeInsets.only(bottom: 5, top: 5),
                child: new Divider(
                  height: 0.0,
                ),
              ),
              gblSettings.wantCurrencyPicker ?
              _currencyPicker() : Container(),
              SelectJourneyWidget(
                onChanged: _handleFlightselectedChanged,
              ),
              new Padding(
                padding: EdgeInsets.only(bottom: 5, top: 5),
                child: new Divider(
                  height: 0.0,
                ),
              ),
              JourneyDateWidget(
                  isReturn: _isReturn, onChanged: _handleDateChanged),
              (wantPageV2()) ?  Container() :
              new Padding(
                padding: EdgeInsets.only(bottom: 5, top: 5),
                child: new Divider(
                  height: 0.0,
                ),
              ) ,
              //Pax selection
              PassengerWidget(
                systemColors: gblSystemColors,
                passengers: booking.passengers,
                onChanged: _handlePaxNumberChanged,
              ),
              (wantPageV2()) ?  Container() :
              new Padding(
                padding: EdgeInsets.only(bottom: 5, top: 0),
                child: new Divider(
                  height: 0.0,
                ),
              ),

              gblSettings.eVoucher
                  ? EVoucherWidget(
                evoucherNo: booking.eVoucherCode,
                onChanged: _handleEVoucherChanged,
              )
                  : Container(),
              (_canDoRedeem())
                  ? CheckboxListTile(
                title: TrText("Redeem ${gblSettings.fqtvName} points"),
                value: gblRedeemingAirmiles,
                onChanged: (newValue) {
                  setState(() {
                    gblRedeemingAirmiles = newValue as bool;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,  //  <-- leading Checkbox
              ) : Container(),
            ],
          ),
        ));
  }

  Widget _currencyPicker() {
    if( gblSettings.currencies == null || gblSettings.currencies.isEmpty || gblSettings.currencies.contains(',') == false){
      return Container();
    }

    List<String> _currencies = []; //['SEK', 'NOK', 'DKK', 'EUR', 'GBP'];
    Map<String, String> countryCodes = {}; // {'S
    var curArray = gblSettings.currencies.split(','); // EK': 'se', 'NOK': 'no', 'DKK': 'dk', 'EUR': 'eu', 'GBP': 'gb'};
    var count = curArray.length ;
    for( var i = 0 ; i < count; i+=2) {
//      var selected = false;
      _currencies.add(curArray[i+1]);
      countryCodes[curArray[i+1]] = curArray[i];
//      if (langs[i] == gblLanguage) {
//        selected = true;
//      }
    }


    return Row(
        children: <Widget>[
          new TrText(
              'Currency',
              style: new TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15.0,
              )),
          SizedBox(width: 50,),
          DropdownButton(
              hint: TrText('Currency'), // Not necessary for Option 1
              value: booking.currency,
              onChanged: (newValue) {
                setState(() {
                  gblSelectedCurrency = newValue as String ;
                  booking.currency = newValue as String;
                });
              },
              items: _currencies.map((currency) {
                return DropdownMenuItem(
                  child: Row(children: <Widget>[
                    Image.asset('icons/flags/png/${countryCodes[currency]}.png', package: 'country_icons', width: 20,height: 20,),
                    SizedBox(width: 10,),
                    new Text(currency)]),
                  value: currency,
                );
              }).toList())]
    );
  }

  bool _canDoRedeem() {

    if( gblPassengerDetail == null ) {
      gblRedeemingAirmiles = false;
      gblShowRedeemingAirmiles = false;
      return false;
    }

    if( gblPassengerDetail!.fqtv == null || gblPassengerDetail!.fqtv.isEmpty) {
      gblRedeemingAirmiles = false;
      gblShowRedeemingAirmiles = false;
      return false;
    }


    if( gblFqtvBalance != null && gblFqtvBalance > 0 ) {
      return true;
    }
    return gblShowRedeemingAirmiles;
  }
  void _reloadSearch(NewBooking newBooking) {
    if (newBooking != null) {
      setState(() {
        booking = newBooking;
      });
    }
  }

 /* List<Widget> airportsInputs(BuildContext context) {
    return [
      new Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        new Expanded(
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                new Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      new TrText("Adults (16+)",
                          style: new TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15.0)),
                    ],
                  ),
                ),
                new Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TrText("Other Passengers", // """Children & Infants",
                          style: new TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15.0)),
                      TrText("Select",
                          style: new TextStyle(
                              fontWeight: FontWeight.w200,
                              fontSize: 17.0,
                              color: Colors.grey)),
                    ],
                  ),
                )
              ],
            )),
      ]),
      new Container(
          child: new Divider(
            height: 0.0,
          )),
    ];
  }*/
}


//       class CustomWidget {
// AppBar appBar(BuildContext context, String title) {
//      return AppBar(
//        leading: Padding(
//           padding: EdgeInsets.only(left: 10.0),
//           child: Image.asset(
//               'lib/assets/${AppConfig.of(context).appTitle}/images/appBarLeft.png',
//               color: Color.fromRGBO(255, 255, 255, 0.1),
//                colorBlendMode: BlendMode.modulate)),
//        brightness: AppConfig.of(context).systemColors.statusBar,
//        backgroundColor: AppConfig.of(context).systemColors.primaryHeaderColor,
//       iconTheme: IconThemeData(
//            color: AppConfig.of(context).systemColors.primaryHeaderOnColor),
//       title: new Text(title,
//          style: TextStyle(
//               color: AppConfig.of(context).systemColors.primaryHeaderOnColor)),
//      );}
//   }
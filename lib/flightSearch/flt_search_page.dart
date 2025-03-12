import 'package:flutter/material.dart';
import 'package:vmba/datePickers/models/flightDatesModel.dart';
import 'package:vmba/flightSearch/widgets/passenger.dart';
import 'package:vmba/flightSearch/widgets/searchButton.dart';
import 'package:vmba/flightSearch/widgets/oneWayReturnType.dart';
import 'package:vmba/flightSearch/widgets/departReturnDates.dart';
import 'package:vmba/flightSearch/widgets/journey.dart';
import 'package:vmba/data/models/models.dart';
import 'package:vmba/data/repository.dart';
import 'package:vmba/menu/icons.dart';
import 'package:vmba/menu/menu.dart';
import 'package:vmba/flightSearch/widgets/evoucher.dart';
import 'package:vmba/utilities/widgets/appBarWidget.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';

import '../Helpers/settingsHelper.dart';
import '../Managers/imageManager.dart';
import '../components/bottomNav.dart';
import '../components/vidAppBar.dart';
import '../utilities/helper.dart';
import '../v3pages/controls/V3Constants.dart';

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
    gblBookingCurrency = gblSelectedCurrency;
    adsTermsAccepted = false;
    gblCurrentRloc = '';

    // init search settings
    gblSearchParams.isReturn = true;

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
      gblSearchParams.isReturn = newValue;
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
    if( gblBuildFlavor == 'UZ') {
      helpText = 'Route Tripoli to Istanbul normally has some fares available.';
    }

    if( firstBuild == true &&  args != null && args.contains('wantRedeemMiles' )) {
      gblShowRedeemingAirmiles = true;
    }
    firstBuild = false;
    return new Scaffold(
        //backgroundColor: v2PageBackgroundColor(),

        appBar:
        vidAppBar(
          automaticallyImplyLeading: false,
          icon: getNamedIcon('FLIGHTSEARCH'),
          titleText: widget.ads == true ? 'ADS/Island Resident Flight Search': 'Flight Search' ,
        ),
        endDrawer: DrawerMenu(),
        floatingActionButton: showFab
            ? SearchButtonWidget(
          newBooking: booking,
          onChanged: _reloadSearch,
        )
            : null,
        bottomNavigationBar: getBottomNav(context, 'FLIGHTSEARCH', helpText:  helpText),
        body: ImageManager.getBodyWithBackground( 'FLIGHTSEARCH',_body())
    );
  }

  Widget _body() {
    EdgeInsets pad = EdgeInsets.all(0.0);

    if( gblSettings.homePageStyle == 'V3') {

      List<Widget> list = [];

      list.add(Padding(padding: EdgeInsets.all(5)));
      // return or One Way
      list.add(JourneyTypeWidget(
          isReturn: _isReturn,
          onChanged: _handleReturnToggleChanged));
      list.add(Padding(padding: EdgeInsets.all(5)));

      // ££
      if(gblSettings.wantCurrencyPicker ) {
        list.add(_currencyPicker());
      }

      // from to
      list.add( Card(
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          ),
          clipBehavior: Clip.antiAlias,
        child: Padding(
        padding: EdgeInsets.all(10),
        child:
        SelectJourneyWidget(
        onChanged: _handleFlightselectedChanged,
        ))));

      list.add(Padding(padding: EdgeInsets.all(5)));

      List<Widget> list2 = [];
      list2.add(JourneyDateWidget( isReturn: _isReturn,onChanged: _handleDateChanged));

      list2.add(Padding(padding: EdgeInsets.only(bottom: 5, top: 5),child: new Divider(height: 2.0,thickness: 2, color: Colors.grey,),));

      //Pax selection
      list2.add(PassengerWidget(systemColors: gblSystemColors, passengers: booking.passengers,onChanged: _handlePaxNumberChanged,));


      if( gblSettings.eVoucher) {
        list2.add(Padding(padding: EdgeInsets.only(bottom: 5, top: 5),child: new Divider(height: 2.0,thickness: 2, color: Colors.grey,),));

        list2.add(EVoucherWidget(evoucherNo: booking.eVoucherCode,
          onChanged: _handleEVoucherChanged,));
      }

      if(_canDoRedeem()) {
        list2.add(CheckboxListTile(
          title: TrText("Redeem ${gblSettings.fqtvName} points"),
          value: gblRedeemingAirmiles, onChanged: (newValue) {
          setState(() {
            gblRedeemingAirmiles = newValue as bool;
          });
        },
          controlAffinity: ListTileControlAffinity.leading,));
      }
      list.add( Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                children: list2,
              )
          )
      ));



      return SingleChildScrollView(
          padding: pad,
          child: Padding(
          padding: v2FormPadding(),
        child :Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: list,
        ))
      );

    } else {
      return
        SingleChildScrollView(
            padding: pad,
            child: Padding(
                padding: v2FormPadding(),
                child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),

                    clipBehavior: Clip.antiAlias,
                    child: Padding(
                      padding: EdgeInsets.all(10),
                      child:
                      Column(
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
                              isReturn: _isReturn,
                              onChanged: _handleDateChanged),
                          new Padding(
                            padding: EdgeInsets.only(bottom: 5, top: 5),
                            child: new Divider(
                              height: 0.0,
                            ),
                          ),
                          //Pax selection
                          PassengerWidget(
                            systemColors: gblSystemColors,
                            passengers: booking.passengers,
                            onChanged: _handlePaxNumberChanged,
                          ),
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
                            title: TrText(
                                "Redeem ${gblSettings.fqtvName} points"),
                            value: gblRedeemingAirmiles,
                            onChanged: (newValue) {
                              setState(() {
                                gblRedeemingAirmiles = newValue as bool;
                              });
                            },
                            controlAffinity: ListTileControlAffinity
                                .leading, //  <-- leading Checkbox
                          ) : Container(),
                        ],
                      ),
                    ))
            ));
    }
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
                  gblSearchParams.initAirports();
                  gblSelectedCurrency = newValue as String ;
                  booking.currency = newValue as String;
                  if(gblSettings.useLogin2 &&  gblSettings.currencyLimitedToDomesticRoutes != ''){
                    // clear from / to
                  }

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

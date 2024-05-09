import 'package:flutter/material.dart';
import 'package:vmba/Helpers/stringHelpers.dart';
import 'package:vmba/utilities/helper.dart';
import '../components/vidTextFormatting.dart';
import '../data/models/models.dart';
import '../data/models/pnr.dart';
import 'package:intl/intl.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';


class SummaryView extends StatelessWidget {
  SummaryView({Key key= const Key("sumview_key"), required this.newBooking}) : super(key: key);
  final NewBooking newBooking;
  //final PnrModel pnrModel;

  String currencyCode = '';

  @override
  Widget build(BuildContext context) {
    //Show dialog
    //print('build');
    setCurrencyCode();

    List <Widget> list = [];
    getPax(list);
    list.add(Divider(),);
    list.add(flightSegementSummary());

    if(gblPnrModel!.pNR.mPS != null && gblPnrModel!.pNR.mPS.mP != null ){
      if( gblPnrModel!.pNR.mPS.mP.where((p) =>  p.mPID != 'SSSS').length > 0 ){
        // got products this segment :)
        list.add(tableTitle(translate('Additional Items' + ':')));
        List<MP> mpList = [];
        gblPnrModel!.pNR.mPS.mP.forEach((p) {
          if( p.mPID != 'SSSS') {
            mpList.add(p);
          }
        });
        mpList.sort((a,b) => a.mPID.compareTo(b.mPID));

        int index = 1;
        int count =1;
        String last = '';
        String lastAmt = '';
        String lastCur = '';
        mpList.forEach((element) {

            if( last.length > 0 && last != element.text)
            {
                if(gblLogProducts) logit('$index no match - add $last');

                list.add(tableRow('$count * ' + last,formatPrice(lastCur, double.parse(lastAmt))));
                last='';
                count = 1;
            } else if (last == element.text) {
               count += 1;
            }


            if( index == mpList.length) {
              if(gblLogProducts) logit('$index end');
              if( last.length > 0 ) {
                if( last == element.text){
                  lastAmt = (double.parse(lastAmt) + double.parse(element.mPSAmt)).toString();
                }
                list.add(tableRow('$count * ' + last,formatPrice(lastCur, double.parse(lastAmt))));
              }
              // finished
              if(last != element.text ) {
                list.add(tableRow('$count * ' + element.text,
                    formatPrice(element.mPSCur, double.parse(element.mPSAmt))));
              }
            } else {
              if( last == element.text){
                lastAmt = (double.parse(lastAmt) + double.parse(element.mPSAmt)).toString();

              } else {
                last = element.text;
                lastAmt = element.mPSAmt;
                lastCur = element.mPSCur;
              }
            }
          index +=1;
        });
        list.add(Divider());
      }
    }




    list.add(tableTitle('Summary'));
    if (gblRedeemingAirmiles == true) {
      list.add(airMiles());
    } else {
      list.add(netFareTotal());
    }
    list.add(taxTotal());

    if (gblRedeemingAirmiles != true) {
      list.add(grandTotal());
    }
    list.add(discountTotal());
    list.add(Divider());

    if (gblRedeemingAirmiles != true) {
      list.add(tableTitle('Amount payable',right: amountPayable()));
    }


/*
    if (gblRedeemingAirmiles != true) {
      list.add(amountPayable());
    }
*/

    return Container(
        padding: EdgeInsets.all(16.0),
        child: new ListView(children: list,
        )
    );
  }

  void getPax(list) {
    if (newBooking.passengers.adults != 0) {
      list.add(tableRow(translate('No of ') + translate('Adults') + ': ',
          translateNo(newBooking.passengers.adults.toString())));
    }
      if (newBooking.passengers.youths != 0) {
        list.add(tableRow(translate('No of ') + translate('Youths') + ': ', translateNo(newBooking.passengers.youths.toString())));
      }
      if (newBooking.passengers.students != 0) {
        list.add(tableRow(translate('No of ') + translate('Students') + ': ',translateNo(newBooking.passengers.students.toString())));
      }
      if (newBooking.passengers.seniors != 0) {
        list.add(tableRow(translate('No of ') + translate('Seniors') + ': ',translateNo(newBooking.passengers.seniors.toString())));
      }
      if (newBooking.passengers.children != 0) {
        list.add(tableRow(translate('No of children: '),translateNo(newBooking.passengers.children.toString())));
      }

      if (newBooking.passengers.infants != 0) {
        list.add(tableRow(translate('No of ') + translate('Infants') + ': ',translateNo(newBooking.passengers.infants.toString())));
      }

  }

  Widget taxTotal() {
    if (gblLogSummary) logit('add tax');
    double tax = 0.0;
    double sepTax1 = 0.0;


    List <Row> rows = [];

    sepTax1 = sepTax();
    tax = incTax();

/*
    if (this.pnrModel.pNR.fareQuote.fareTax != null) {
      this.pnrModel.pNR.fareQuote.fareTax[0].paxTax.forEach((paxTax) {
        if (paxTax.separate == 'true') {
          sepTax1 += (double.tryParse(paxTax.amnt) ?? 0.0);
        } else {
          tax += (double.tryParse(paxTax.amnt) ?? 0.0);
        }
      });
    }
*/
    rows.add(tableRow(translate('Total Tax: '),formatPrice(currencyCode, tax) ));

    if (sepTax1 > 0) {
      rows.add( tableRow(translate('Additional Item(s) '), formatPrice(currencyCode, sepTax1)));
    }

    return Column(
      children: rows,
    );
  }
  double incTax() {
    double tax =0.0;
    if (gblPnrModel!.pNR.fareQuote.fareTax != null) {
      gblPnrModel!.pNR.fareQuote.fareTax[0].paxTax.forEach((paxTax) {
        if (paxTax.separate == 'true') {
//          sepTax1 += (double.tryParse(paxTax.amnt) ?? 0.0);
        } else {
          tax += (double.tryParse(paxTax.amnt) ?? 0.0);
        }
      });
    }
    return tax;
  }

double sepTax () {
    double sepTax1 = 0.0;
  if (gblPnrModel!.pNR.fareQuote.fareTax != null) {
    gblPnrModel!.pNR.fareQuote.fareTax[0].paxTax.forEach((paxTax) {
      if (paxTax.separate == 'true') {
        sepTax1 += (double.tryParse(paxTax.amnt) ?? 0.0);
      } else {
   //     tax += (double.tryParse(paxTax.amnt) ?? 0.0);
      }
    });
  }
  return sepTax1;
}


  Widget airMiles() {
    int miles;
    miles =
        int.tryParse(
            gblPnrModel!.pNR.basket.outstandingairmiles.airmiles) ??
            0;


    return tableRow('${gblSettings.fqtvName}' + translate(' Required points'),'$miles');
  }

  Row netFareTotal() {
    double total = 0.0;
    total = (double.tryParse(gblPnrModel!
        .pNR
        .fareQuote
        .fareStore
        .where((fareStore) => fareStore.fSID == 'Total')
        .first
        .total) ??
        0.0);
    double tax = 0.0;

    if (gblPnrModel!.pNR.fareQuote.fareTax != null) {
      gblPnrModel!.pNR.fareQuote.fareTax[0].paxTax.forEach((paxTax) {
        tax += (double.tryParse(paxTax.amnt) ?? 0.0);
      });
    }

    double netFareTotal = total - tax;

    return tableRow(translate('Net Fare:'),formatPrice(currencyCode, netFareTotal));
  }

  Row grandTotal() {
    double total = 0.0;

    gblPnrModel!.pNR.fareQuote.fareStore.forEach((f) {
      if (f.fSID == 'FQC') {
        f.segmentFS.forEach((d) {
          if( d.fare != null && d.fare != '')total += double.tryParse(d.fare ) as double;
          if( d.tax1 != null && d.tax1 != '')total += double.tryParse(d.tax1 ) as double;
          if( d.tax2 != null && d.tax2 != '')total +=  double.tryParse(d.tax2) as double;
          if( d.tax3 != null && d.tax3 != '')total +=  double.tryParse(d.tax2) as double;
          if (d.disc != null) {
            if (d.disc != '') {
              d.disc
                  .split(',')
                  .forEach((disc) => total += double.tryParse(disc) as double);
              // total += double.tryParse(d.disc ?? 0.0);

            }
          }
        });
      }
    });

    // subtract additionals
    total -= sepTax();

    return tableRow(translate('Flights Total: '),formatPrice(currencyCode, total));
  }

  Row discountTotal() {
    double total = 0.0;

    gblPnrModel!.pNR.fareQuote.fareStore.forEach((f) {
      if (f.fSID == 'FQC') {
        f.segmentFS.forEach((d) {
          if (d.disc != null && d.disc != '') {
            d.disc
                .split(',')
                .forEach((disc) => total += double.tryParse(disc) as double);
            //total += double.tryParse(d.disc ?? 0.0);
          }
        });
      }
    });

    if (total == 0.0) {
      return Row(
        children: <Widget>[],
      );
    } else {
      return tableRow(translate('Discount: '),formatPrice(currencyCode, total));
    }
  }

  String amountPayable() {
    FareStore fareStore = gblPnrModel!
        .pNR
        .fareQuote
        .fareStore
        .where((fareStore) => fareStore.fSID == 'Total')
        .first;

    var amount = fareStore.total;
    if (double.parse(amount) <= 0) {
      amount = "0";
    }
    String price = formatPrice(currencyCode, double.tryParse(amount) ?? 0.0);
    if (gblPayable != price) {
      gblPayable = price;
      /*    setState(() {

      });*/
    }
    return price;
    //return tableTitle(price);
  }

  Widget flightSegementSummary() {
    if (gblLogSummary) logit('flightSegementSummary');
    List<Widget> widgets = [];
    // new List<Widget>();
    for (var i = 0; i <= gblPnrModel!.pNR.itinerary.itin.length - 1; i++) {
      widgets.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(cityCodetoAirport(gblPnrModel!.pNR.itinerary.itin[i].depart),
                textScaleFactor: 1.25,
                style:  TextStyle(fontWeight: FontWeight.bold)),

            /*         FutureBuilder(
              future: cityCodeToName(
                gblPnrModel!.pNR.itinerary.itin[i].depart,
              ),
              initialData: gblPnrModel!.pNR.itinerary.itin[i].depart.toString(),
              builder: (BuildContext context, AsyncSnapshot<String> text) {
                return new Text(text.data as String,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  textScaleFactor: 1.25,
                );
              },
            ),*/
            Text(
              ' to ',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(cityCodetoAirport(gblPnrModel!.pNR.itinerary.itin[i].arrive),
                textScaleFactor: 1.25,
                style:  TextStyle(fontWeight: FontWeight.bold)),

            /*          FutureBuilder(
              future: cityCodeToName(
                gblPnrModel!.pNR.itinerary.itin[i].arrive,
              ),
              initialData: gblPnrModel!.pNR.itinerary.itin[i].arrive.toString(),
              builder: (BuildContext context, AsyncSnapshot<String> text) {
                return tableTitle(text.data as String);
              },
            ),*/
          ],
        ),
      );
      widgets.add(
          tableRow(translate('Flight No:'),'${gblPnrModel!.pNR.itinerary.itin[i].airID}${gblPnrModel!.pNR.itinerary.itin[i].fltNo}'));

      widgets.add(tableRow(translate('Departure Time:'),DateFormat('dd MMM kk:mm').format(gblPnrModel!.pNR.itinerary.itin[i].getDepartureDateTime())));
      String arrDate = gblPnrModel!.pNR.itinerary.itin[i].depDate;
      if(gblPnrModel!.pNR.itinerary.itin[i].arrOfst != null &&  gblPnrModel!.pNR.itinerary.itin[i].arrOfst != '0'
        && gblPnrModel!.pNR.itinerary.itin[i].arrOfst.trim() != ''
      ) {
        DateTime dt = DateTime.parse(gblPnrModel!.pNR.itinerary.itin[i].depDate);
        dt = dt.add(Duration(days: int.parse(gblPnrModel!.pNR.itinerary.itin[i].arrOfst)));
        arrDate = DateFormat('yyyy-MM-dd').format(dt);
      }
      if( gblPnrModel!.pNR.itinerary.itin[i].arrTime.length > 9) {
        // time includes date
        widgets.add(tableRow(translate('Arrival Time') + ':',
            DateFormat('dd MMM kk:mm').format(DateTime.parse(
                 gblPnrModel!.pNR.itinerary.itin[i].arrTime))));
      } else {
        if( gblPnrModel!.pNR.itinerary.itin[i].arrTime.length > 9 ){
          widgets.add(tableRow(translate('Arrival Time') + ':',
              DateFormat('dd MMM kk:mm').format(DateTime.parse(
                   gblPnrModel!.pNR.itinerary.itin[i].arrTime))));

        } else {
          if( gblPnrModel!.pNR.itinerary.itin[i].arrTime.length > 9 ) {
            widgets.add(tableRow(translate('Arrival Time') + ':',
                DateFormat('dd MMM kk:mm').format(DateTime.parse(
                        gblPnrModel!.pNR.itinerary.itin[i].arrTime))));
          } else {
            DateTime adt = DateTime.parse(arrDate + ' ' +gblPnrModel!.pNR.itinerary.itin[i].arrTime);
            widgets.add(tableRow(translate('Arrival Time') + ':',
                DateFormat('dd MMM kk:mm').format(adt)));
          }
        }
      }

      widgets.add(tableRow(translate('Fare Type:'),gblPnrModel!.pNR.itinerary.itin[i].classBandDisplayName ==
                'Fly Flex Plus'
                ? 'Fly Flex +'
                : gblPnrModel!.pNR.itinerary.itin[i].classBandDisplayName));

      double seatTotal = 0.0;
      int count = 0;
      if (gblPnrModel!.pNR.aPFAX != null) {
        gblPnrModel!
            .pNR.aPFAX.aFX
            .where((apFax) => apFax.seg == (i + 1).toString())
            .forEach((apFax) {
          if (apFax.aFXID == 'SEAT') {
            seatTotal += (double.tryParse(apFax.amt) ?? 0.0);
            count+=1;
          }
        });
      }
      if( count > 0){
        widgets.add(tableRow( '$count ' + translate('Seats:'), formatPrice(currencyCode, seatTotal)));
      }

      double taxTotal = 0.0;
      if (gblPnrModel!.pNR.fareQuote.fareTax != null) {
        gblPnrModel!
            .pNR
            .fareQuote
            .fareTax[0]
            .paxTax
            .where((paxTax) => paxTax.seg == (i + 1).toString())
            .forEach((paxTax) {
          if (paxTax.separate == 'false') {
            taxTotal += (double.tryParse(paxTax.amnt) ?? 0.0);
          }
        });
      }
      if (taxTotal != 0.0) {
        widgets.add(tableRow(translate('Tax:'),formatPrice(currencyCode, taxTotal)));
      }

  /*    double sepTax1 = 0.0;
      String desc1 = '';*/
      List<String> taxDescs = [];
      List<double> taxAmounts = [];


      if (gblPnrModel!.pNR.fareQuote.fareTax != null) {
        gblPnrModel!.pNR.fareQuote.fareTax[0].paxTax.forEach((paxTax) {
          if (paxTax.separate == 'true' &&
              paxTax.seg == (i + 1).toString()) { //
            bool found = false;
            for(int index =0; index < taxDescs.length; index++){
              if(paxTax.desc == taxDescs[index] ){
                found= true;
                taxAmounts[index] +=(double.tryParse(paxTax.amnt) ?? 0.0);
              }
            }
            if( !found){
              taxDescs.add(paxTax.desc);
              taxAmounts.add((double.tryParse(paxTax.amnt) ?? 0.0));
            }

          }
        });
      }
      if (taxDescs.length > 0) {
        int index = 0;
        taxDescs.forEach((element) {
          widgets.add(tableRow(element,formatPrice(currencyCode, taxAmounts[index])));
          index +=1;
        });

      }

      // add seats
      if(gblPnrModel!.pNR.aPFAX != null && gblPnrModel!.pNR.aPFAX.aFX != null ) {
        if (gblPnrModel!.pNR.aPFAX.aFX
            .where((p) => p.aFXID == 'SEAT' && p.seg == (i + 1).toString())
            .length > 0) {
          // got products this segment :)
          widgets.add(tableTitle(translate('Seats' )+ ':'));
          List<AFX> afList = [];
          gblPnrModel!.pNR.aPFAX.aFX.forEach((p) {
            if( p.aFXID == 'SEAT' && p.seg == (i + 1).toString()) {
              afList.add(p);
            }
          });

          afList.forEach((element) {
           // logit('pax: ' + element.pax + ' i:' + i.toString());
            //MP mps = gblPnrModel.pNR.mPS.mP.where((p) => p.mPID == 'SSSS' && p.seg == (i + 1).toString() && p.pax == element.pax).first;
            Iterable <MP> mpsa = gblPnrModel!.pNR.mPS.mP.where((p) => p.mPID == 'SSSS' && p.seg == (i + 1).toString() && p.pax == element.pax);
            if( mpsa != null && mpsa.length > 0 ) {
              MP mps = mpsa.first;

              if (mps != null) {
                widgets.add(tableRow('${element.name} ${element.seat}',
                    formatPrice(mps.mPSCur, double.parse(mps.mPSAmt))));
              }
            }
          });

        }
      }

      widgets.add(Divider());
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: widgets,
    );
  }


  void setCurrencyCode() {
    try {
      currencyCode = gblPnrModel!
          .pNR
          .fareQuote
          .fareStore
          .where((fareStore) => fareStore.fSID == 'Total')
          .first
          .cur;
    } catch (ex) {
      currencyCode = '';
      print(ex.toString());
    }
  }
}
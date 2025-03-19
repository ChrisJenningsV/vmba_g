
part of 'viewBookingPage.dart';

/*import 'package:vmba/mmb/viewBookingPage.dart';*/

extension Section on ViewBookingBodyState {

  List<Widget> getPassengerViewWidgets(PnrModel pnr, int journey) {
    List<Widget> list = [];

    //TODO:
    //Remove from list if pax checked in
    List<Pax> paxlist =  pnr.getBookedPaxList(journey);
    // new List<Pax>();
     for (var i = 0; i <= pnr.pNR.names.pAX.length - 1; i++) {
      String seatNo = '';
      if( pnr.pNR.aPFAX != null && pnr.pNR.aPFAX.aFX != null) {
        AFX? seatAfx ;
        bool found = false;
        pnr.pNR.aPFAX.aFX.forEach((f) {
          if(found==false &&  f.aFXID == 'SEAT' && f.pax == pnr.pNR.names.pAX[i].paxNo &&
              f.seg == (journey + 1).toString()){
            seatAfx = f;
            found = true;
          }
        });
        if (seatAfx != null) {
          seatNo = seatAfx!.seat;
        }
      }

      list.add(
        new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            (seatNo!= '' ) ? vidSeatIcon(seatNo) : Container(),
            Expanded(
              flex: 7,

              child: new Text(
                  pnr.pNR.names.pAX[i].firstName +
                      ' ' +
                      pnr.pNR.names.pAX[i].surname,
                  style: new TextStyle(
                      fontSize: 16.0, fontWeight: FontWeight.w400)),
            ),
            //(seatNo!= '' )? Text(seatNo + '  ') : Container(),
            new Row(children: getButtons(pnr, i, journey, paxlist)),
            //    ),
          ],
        ),
      );
    }

    list.add(Divider());
    if( pnr.allPaxCheckedIn()) {
      list.add(Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.info),
            Padding(
                padding: EdgeInsets.only(left: 5)),
            Text('All passengers checked in'),
          ]
      ));
    } else {
      list.add(
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.info),
            Padding(
              padding: EdgeInsets.only(left: 5),
            ),
            Expanded(
              child: FutureBuilder(
                future: checkinStatus(pnr.pNR.itinerary.itin[journey]),
                initialData: 'Check-in not open',
                builder: (BuildContext context, AsyncSnapshot<String> text) {
                  if (text.data != null) {
                    return new Text(text.data!);
                  } else {
                    return Text('');
                  }
                },
              ),
            )
          ],
        ),
      );
    }

    if( pnr.isFundTransferPayment()) {
      list.add(Padding(padding: EdgeInsets.all(3)));
      list.add(_paymentPending(pnr));
    }

    if (pnr.pNR.editFlights == true && pnr.isFundTransferPayment() == false  ) {
      int journeyToChange = getJourney(journey, pnr.pNR.itinerary);

      if(  _mmbBooking.journeys.journey.length >= journeyToChange) {
        var departureDate = DateTime.parse(_mmbBooking
            .journeys.journey[journeyToChange - 1].itin.first.depDate +
            ' ' +
            _mmbBooking.journeys.journey[journeyToChange - 1].itin.first.depTime);

        if ( wantChangeAnyFlight || DateTime.now().add(Duration(hours: 1)).isBefore(departureDate) ) {
          //&&             pnr.pNR.itinerary.itin[journey].status != 'QQ') {
          list.add(Divider());
          if (gblSettings.displayErrorPnr &&
              double.parse(objPNR!.pNR.basket.outstanding.amount) > 0) {
            list.add(Row(
                children: <Widget>[
                  Expanded(child: payOutstandingButton(
                      pnr, objPNR!.pNR.basket.outstanding.amount))
                ]));


//          'Payment incomplete, ${basket.outstanding.amount} outstanding';
            list.add(Divider());
          }
          list.add(Row(
            children: <Widget>[
              _flightButtons(pnr, journeyToChange),
            ],
          ));
        }
      }
    }

    return list;
  }

  Future<void> undoCheckin({int? p1, int? p2, String? p3}) async {
    // get ticket no and coupon no
    String ticketNo = '';
    String couponNo = '';
    try {
      gblPnrModel!.pNR.tickets.tKT.forEach((ticket) {
        if (ticket.tKTID == 'ELFT' && ticket.segNo != null && ticket.segNo != '' &&  int.parse(ticket.segNo) == (p1! + 1) && int.parse(ticket.pax) == (p2!+1)) {
          // strip spaces
          ticketNo = ticket.tktNo.replaceAll(' ', '');
          // get coupon without leading zero
          couponNo = int.parse(ticket.coupon).toString();
        }
      });
      logit('t=$ticketNo c=$couponNo');
      if (ticketNo == '') {
        // not found
        gblActionBtnDisabled = false;
        showVidDialog(context, 'Error', 'Ticket not found');
      } else {
        // get server to do unload
        gblActionBtnDisabled = true;
        gblPayAction = 'UNDOCHECKIN';
        CheckinRequest cr = new CheckinRequest();
        cr.rloc = gblPnrModel!.pNR.rLOC;
        cr.ticketNo = ticketNo;
        cr.couponNo = couponNo;

        String data = json.encode(cr);


        try {
          // let server do the work
          String reply = await callSmartApi('UNDOCHECKIN', data);
          Map<String, dynamic> map = json.decode(reply);
          CheckinReply checkinRs = new CheckinReply.fromJson(map);
          if (checkinRs.reply != null && checkinRs.reply != '') {
            showstatusMessage(translate('Check-in undone.'), context);
            //gblPnrModel!.loadFromString(seatRs.reply);
            await Repository.get().fetchPnr(widget.rloc);
            objPNR = gblPnrModel;
            // ok
            setState(() {});
          }
        } catch (e) {
          showVidDialog(context, 'Error', e.toString(), onComplete:() {
            setError('');
            setState(() {});
          });
          print(e.toString());
        }
        gblActionBtnDisabled = false;
      }
    } catch (e) {
      gblActionBtnDisabled = false;
      print(e.toString());
    }

    }


  List <Widget> getButtons(PnrModel pnr, int paxNo, int journeyNo, List<Pax> paxlist) {
    List <Widget> list = [];


    if( gblSettings.wantApis) {
      list.add(Column(
          children: [
            apisButtonOption(pnr, paxNo, journeyNo, paxlist),
            buttonOption(pnr, paxNo, journeyNo, paxlist),
          ]));

    } else {
      list.add(buttonOption(pnr, paxNo, journeyNo, paxlist));
    }
    return list;
  }

  Widget buttonOption(PnrModel pnr, int paxNo, int journeyNo, List<Pax> paxlist) {

    if( isFltPassedDate(pnr.pNR.itinerary.itin[journeyNo], 12)) {
      // departed, no actions
      logit('departed');
      return Container();
    }

    if ( pnr.isOtherAirline(journeyNo) ) {
      logit('other airline');
      return Text(''
        // 'Please check in at the airport',
      );
      //return new Text('No information for flight');
    }

    if ( pnr.apisRequired(paxNo,  journeyNo)) {
      //  Future<bool> hasDownloadedBoardingPass =
      //  Repository.get()
      //   .hasDownloadedBoardingPass(
      //       pnr.pNR.itinerary.itin[journeyNo].airID +
      //           pnr.pNR.itinerary.itin[journeyNo].fltNo,
      //       pnr.pNR.rLOC,
      //       paxNo);

      // check APIS done
      if (apisPnrStatus != null && apisPnrStatus!.apisRequired(journeyNo) &&
          _hasApisInfoForPax(journeyNo, paxNo) == false) {
        logit('apis required');
        return Container();
      }

      //return new TextButton(
      if( gblSettings.canUndoCheckin) {
        if(pnr.canCheckOut(paxNo+1, journeyNo+1)) {
          return Column(
            children: [
              vidTextButton(
                  context, 'Undo Check-in', undoCheckin, icon: Icons.close,
                  p1: journeyNo,
                  p2: paxNo),
              BoardingPassButton(pnr, paxNo, journeyNo, paxlist),
            ],
          );
        } else {
          return BoardingPassButton(pnr, paxNo, journeyNo, paxlist);
        }
      } else {
        return BoardingPassButton(pnr, paxNo, journeyNo, paxlist);
      }
    }

    //get apis state for the booking DSP/AATQ4T

    // all the rest need to be online
    if( gblNoNetwork == true){
      logit('no net');
      return Container();
    }


    bool checkinOpen = false;

    if (cities == null || pnr.pNR.itinerary.itin.length != cities.length) {
      checkinOpen =
      pnr.pNR.itinerary.itin[journeyNo].onlineCheckin.toLowerCase() ==
          'true'
          ? true
          : false;
    } else {
      DateTime checkinOpens;
      DateTime checkinClosed;
      DateTime now;

/*
      checkinOpens = DateTime.parse(pnr.pNR.itinerary.itin[journeyNo].ddaygmt +
              ' ' +
              pnr.pNR.itinerary.itin[journeyNo].dtimgmt)
          .subtract(new Duration(
              hours: cities
                  .firstWhere(
                      (c) => c.code == pnr.pNR.itinerary.itin[journeyNo].depart)
                  .webCheckinStart));
*/
      if( pnr.  pNR.itinerary.itin[journeyNo].onlineCheckinTimeStartGMT == null ||
          pnr.pNR.itinerary.itin[journeyNo].onlineCheckinTimeStartGMT == '' ||
          pnr.pNR.itinerary.itin[journeyNo].onlineCheckinTimeEndGMT == null ||
          pnr.pNR.itinerary.itin[journeyNo].onlineCheckinTimeEndGMT== ''){
        checkinOpen = false;
      } else {
        checkinOpens = DateTime.parse(
            pnr.pNR.itinerary.itin[journeyNo].onlineCheckinTimeStartGMT);
        // logit('checkin opens:${checkinOpens.toString()}');
        /*    checkinClosed = DateTime.parse(pnr.pNR.itinerary.itin[journeyNo].ddaygmt +
              ' ' +
              pnr.pNR.itinerary.itin[journeyNo].dtimgmt)
          .subtract(new Duration(
              hours: cities
                  .firstWhere(
                      (c) => c.code == pnr.pNR.itinerary.itin[journeyNo].depart)
                  .webCheckinEnd));*/

        checkinClosed = DateTime.parse(
            pnr.pNR.itinerary.itin[journeyNo].onlineCheckinTimeEndGMT);
        // logit('checkin closed:${checkinClosed.toString()}');

        now = getGmtTime();

        bool isBeforeClosed = is1After2( checkinClosed, now); // now.difference(checkinClosed).inMinutes <0;
        bool isAfterOpens =  is1After2( now, checkinOpens); // checkinOpens.difference(now).inMinutes > 0;

        checkinOpen = (isBeforeClosed && isAfterOpens)
            ? true
            : false;
        if(  (pnr.pNR.itinerary.itin[journeyNo].onlineCheckin != null || pnr.pNR.itinerary.itin[journeyNo].onlineCheckin != '')&&
            pnr.pNR.itinerary.itin[journeyNo].onlineCheckin == 'False' ) {
          checkinOpen = false;
        }
        if( (pnr.pNR.itinerary.itin[journeyNo].mMBCheckinAllowed != null || pnr.pNR.itinerary.itin[journeyNo].mMBCheckinAllowed != '' ) &&
            pnr.pNR.itinerary.itin[journeyNo].mMBCheckinAllowed == 'False' ) {
          //logit('mMBCheckinAllowed false');
          checkinOpen = false;
        }
      }
    }

    if (!isFltPassedDate(pnr.pNR.itinerary.itin[journeyNo], -1) &&
        pnr.pNR.itinerary.itin[journeyNo].secID == '') {
      if (checkinOpen)

        //if ((now.isBefore(checkinClosed) && now.isAfter(checkinOpens)))
        // if (pnr.pNR.itinerary.itin[journeyNo].onlineCheckin.toLowerCase() ==
        //         'true'
        //     ? true
        //     : false)
          {
        if ( pnr.pNR.itinerary.itin[journeyNo].status != 'QQ' &&
            (hasSeatSelected(
                pnr.pNR.aPFAX,
                pnr.pNR.names.pAX[paxNo].paxNo.toString(),
                journeyNo + 1,
                pnr.pNR.names) ||
                pnr.pNR.itinerary.itin[journeyNo].openSeating == 'True')) {

          // check if this is 'IN' and adults not checked in
          if (pnr.pNR.names.pAX[paxNo].paxType == 'IN') {

            var checkedInCount = 0;
            pnr.pNR.tickets.tKT.forEach((t){
              if( t.segNo != null && t.segNo.isNotEmpty) {
                if (int.parse(t.segNo) == (journeyNo + 1) &&
                    pnr.pNR.names.pAX[int.parse(t.pax) - 1].paxType == 'AD' &&
                    t.tKTID == 'ELFT') {
                  checkedInCount++;
                }
              }
            });

            if( checkedInCount == 0 ) {
              // no one is checked in so infant cannot check in
              logit('no one checked in');
              return Container();
            }

          }

          // any outstanding amount ??
          var amount = pnr.pNR.basket.outstanding.amount;
          if( amount == null || amount == '' ) {
            amount = '0';
          }
          if( double.parse(amount) > 0 ) {
            return payOutstandingButton(pnr, amount);

          }

          // apis button required and yet to be done ?
          if(apisPnrStatus != null && apisPnrStatus!.apisRequired(journeyNo) && _hasApisInfoForPax(journeyNo, paxNo) == false){
            logit('apis required');
            return Container();
          }


          //Checkin Button
          return vidTextButton(context, 'Check-in',
                  ({p1, p2, String? p3}) {
                    if( gblSettings.wantDangerousGoods == true || gblSettings.wantDangerousGoodsCheckin){
                      Navigator.push(
                          context,
                          SlideTopRoute(
                              page: DangerousGoodsWidget( pnr: pnr, journeyNo: journeyNo, paxNo: paxNo, ))).then((continuePass) {
                        if( continuePass != null &&  continuePass) {
                          //_displayCheckingDialog(pnr, journeyNo, paxNo);
                          _doPaxCheckin(pnr, journeyNo, paxNo);
                          gblActionBtnDisabled = false;
                          //Navigator.of(context).pop();
                        }
                      });
                    } else {
                      _displayCheckingDialog(pnr, journeyNo, paxNo);
                    }
                  }
          );
         /* return new TextButton(
            onPressed: () {
              if( gblSettings.wantDangerousGoods == true ){
                Navigator.push(
                    context,
                    SlideTopRoute(
                        page: DangerousGoodsWidget( pnr: pnr, journeyNo: journeyNo, paxNo: paxNo, ))).then((continuePass) {
                  if( continuePass != null &&  continuePass) {
                    _displayCheckingDialog(pnr, journeyNo, paxNo);

                  }
                });
              } else {
                _displayCheckingDialog(pnr, journeyNo, paxNo);
              }
            },
            style: TextButton.styleFrom(
                side: BorderSide(color:  gblSystemColors.textButtonTextColor, width: 1),
                foregroundColor: gblSystemColors.textButtonTextColor),
            child: Row(
              children: <Widget>[
                TrText(
                  'Check-in',
                  style: TextStyle(
                      color: gblSystemColors
                          .textButtonTextColor),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 5.0),
                ),

                Text(
                  '',
                  style: TextStyle(
                      color: gblSystemColors
                          .textButtonTextColor),
                )
              ],
            ),
          );*/
        } else {
          if (pnr.pNR.itinerary.itin[journeyNo].secID != '') {
            return Text('');
          } else if (pnr.pNR.itinerary.itin[journeyNo].operatedBy.isNotEmpty &&
              ((pnr.pNR.itinerary.itin[journeyNo].operatedBy != gblSettings.aircode) &&
                  (pnr.pNR.itinerary.itin[journeyNo].operatedBy != gblSettings.altAircode))
          )  {
            return TrText('Check-in with partner airline');
          } else if (pnr.pNR.names.pAX[paxNo].paxType != 'IN' &&
              pnr.pNR.itinerary.itin[journeyNo].openSeating != 'True') {
            bool chargeForPreferredSeating =
            pnr.pNR.itinerary.itin[journeyNo].classBand.toLowerCase() ==
                'fly'
                ? true
                : false;
            if( pnr.isFundTransferPayment()) {
              logit('fund transfer');
              return Container();
            } else {
              return seatButton(paxNo, journeyNo, pnr, paxlist, checkinOpen,
                  chargeForPreferredSeating);
            }
          } else if (pnr.pNR.names.pAX[paxNo].paxType == 'IN') {
            return new Padding(
              padding: EdgeInsets.all(20),
              child: new TrText('No seat option'),
            );
          } else if (pnr.pNR.itinerary.itin[journeyNo].openSeating == 'True') {
            return new Padding(
              padding: EdgeInsets.all(20),
              child: new TrText('Open seating'),
            );
          }
        }
      }

      //TODO:
      //Remove from not pnr.pNR.itinerary.itin[journeyNo].classBand.toLowerCase() != 'fly' ? true : false) &&
      checkinStatus(pnr.pNR.itinerary.itin[journeyNo]);

      bool chargeForPreferredSeating =
      pnr.pNR.itinerary.itin[journeyNo].classBand.toLowerCase() == 'fly'
          ? true
          : false;
      if( pnr.pNR.itinerary.itin[journeyNo].operatedBy.isNotEmpty &&
          ((pnr.pNR.itinerary.itin[journeyNo].operatedBy != gblSettings.aircode) &&
              (pnr.pNR.itinerary.itin[journeyNo].operatedBy != gblSettings.altAircode))
      )  {
        return TrText('Check-in with partner airline');
      }
      if (pnr.pNR.names.pAX[paxNo].paxType != 'IN' &&
          pnr.pNR.itinerary.itin[journeyNo].openSeating != 'True') {
        if( pnr.isFundTransferPayment()) {
          logit('fund transfer');
          return Container();
        } else {
          return seatButton(paxNo, journeyNo, pnr, paxlist, checkinOpen,
              chargeForPreferredSeating);
        }
      }

      if (pnr.pNR.itinerary.itin[journeyNo].openSeating == 'True') {
        return Row(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: TrText('Open seating'),
            )
          ],
        );
      }
    }

    return Row(
        children: pnr.pNR.aPFAX != null &&
            pnr.pNR.aPFAX.aFX
                .where(
                  (aFX) =>
              aFX.aFXID == 'SEAT' &&
                  aFX.pax == pnr.pNR.names.pAX[paxNo].paxNo &&
                  aFX.seg == pnr.pNR.itinerary.itin[journeyNo].line,
            )
                .length <
                0
            ? [
          new Icon(
            Icons.airline_seat_recline_normal,
            size: 20.0,
          ),
          new Text(
              pnr.pNR.aPFAX.aFX
                  .singleWhere(
                    (aFX) =>
                aFX.aFXID == 'SEAT' &&
                    aFX.pax == pnr.pNR.names.pAX[paxNo].paxNo &&
                    aFX.seg == pnr.pNR.itinerary.itin[journeyNo].line,
              )
                  .seat,
              style: new TextStyle(
                  fontSize: 20.0, fontWeight: FontWeight.w200))
        ]
            : [new Text('')]);
  }

  Widget BoardingPassButton(PnrModel pnr, int paxNo, int journeyNo, List<Pax> paxlist) {
    bool hasDownloadedBoardingPass = true;

    return new TextButton(
      onPressed: () {
        hasDownloadedBoardingPass
            ? Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BoardingPassWidget(
                pnr: pnr,
                journeyNo: journeyNo,
                paxNo: paxNo,
              ),
            ))
        // ignore: unnecessary_statements
            : () => {};
      },
      style: TextButton.styleFrom(
          side: BorderSide(color:  gblSystemColors.textButtonTextColor, width: 1),
          foregroundColor: gblSystemColors.textButtonTextColor),
      child: Row(
        children: <Widget>[
          TrText(
            'Boarding Pass',
            style: TextStyle(
                color:
                gblSystemColors.textButtonTextColor),
          ),
          Padding(
            padding: EdgeInsets.only(left: 5.0),
          ),
          hasDownloadedBoardingPass != null
              ? Icon(
            Icons.airplane_ticket,
            size: 20.0,
            color:
            Colors.grey,
          )
              : Icon(
            Icons.file_download,
            size: 20.0,
            color:
            Colors.grey,
          )
        ],
      ),
    );
  }
}
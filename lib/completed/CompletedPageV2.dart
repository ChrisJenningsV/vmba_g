import 'package:flutter/material.dart';
import 'package:vmba/menu/menu.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';

class CompletedPageV2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<String> args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
        appBar: AppBar(
          brightness: gblSystemColors.statusBar,
          backgroundColor:
          gblSystemColors.primaryHeaderColor,
          iconTheme: IconThemeData(
              color: gblSystemColors.headerTextColor),
          title: TrText("Payment Completed",
              style: TextStyle(
                  color:
                  gblSystemColors.headerTextColor)),
        ),
        endDrawer: DrawerMenu(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new TrText(
                "Thank you for your booking",
                style: TextStyle(fontSize: 18),
              ),
              new Text(
                "Your reference is " + args[0],
                style: TextStyle(fontSize: 18),
              ),
              // args[1] == 'true'
              //     ?
              Padding(
                padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/MyBookingsPage', (Route<dynamic> route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                      primary:
                      gblSystemColors.primaryButtonColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0))),
                  child: TrText(
                    args[1] == 'true'
                        ? 'View booking and choose a seat'
                        : 'View booking',
                    style: TextStyle(
                        color: gblSystemColors
                            .primaryButtonTextColor),
                  ),
                ),
              )
              // : Padding(
              //     padding: EdgeInsets.zero,
              //   )
            ],
          ),
        ));
  }
}

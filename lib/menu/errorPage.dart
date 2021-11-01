import 'package:flutter/material.dart';
import 'package:vmba/menu/menu.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';

class ErrorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
   // final List<String> args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
        appBar: AppBar(
          //brightness: gblSystemColors.statusBar,
          backgroundColor:
          gblSystemColors.primaryHeaderColor,
          iconTheme: IconThemeData(
              color: gblSystemColors.headerTextColor),
          title: TrText(gblErrorTitle,
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
                gblError,
                style: TextStyle(fontSize: 18),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/FlightSearchPage', (Route<dynamic> route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                      primary:
                      gblSystemColors.primaryButtonColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0))),
                  child: TrText('Start Again',
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

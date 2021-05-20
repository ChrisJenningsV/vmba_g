import 'package:flutter/material.dart';
import 'package:vmba/menu/menu.dart';
import 'package:vmba/data/globals.dart';

class CompletedPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<String> args = ModalRoute.of(context).settings.arguments;
    return Scaffold(
        appBar: AppBar(
          brightness: gbl_SystemColors.statusBar,
          backgroundColor:
          gbl_SystemColors.primaryHeaderColor,
          iconTheme: IconThemeData(
              color: gbl_SystemColors.headerTextColor),
          title: Text("Payment Completed",
              style: TextStyle(
                  color:
                  gbl_SystemColors.headerTextColor)),
        ),
        endDrawer: DrawerMenu(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Text(
                "Thank you for your booking",
                style: TextStyle(fontSize: 18),
              ),
              new Text(
                "Your reference is ${args[0]}",
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
                      gbl_SystemColors.primaryButtonColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0))),
                  child: Text(
                    args[1] == 'true'
                        ? 'View booking and choose a seat'
                        : 'View booking',
                    style: TextStyle(
                        color: gbl_SystemColors
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

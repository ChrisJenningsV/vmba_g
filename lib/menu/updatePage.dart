import 'package:flutter/material.dart';
import 'package:vmba/data/globals.dart';
import 'package:vmba/components/trText.dart';

class UpdatePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    String title = "App Update Available";
    String btnLabel = "Update Now";
      return  Scaffold(
          body: Container(
            color: Colors.white, constraints: BoxConstraints.expand(),
            child: Center(
              child:
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TrText('update Required'),
                  ),
                ],
              ),
            ),
          ));

    }
  }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vmba/components/trText.dart';
import 'CountDownTimer.dart';
import 'package:vmba/data/globals.dart';

class TimerWidget extends StatelessWidget {
  final VoidCallback timerExpired;

  const TimerWidget({Key key= const Key("timer"), required this.timerExpired}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if( gblTimerExpired == false ) {
      Provider.of<CountDownTimer>(context, listen: false).start();
    return Consumer<CountDownTimer>(builder: (context, countDownTimer, child) {
      if (countDownTimer.formattedTime == '0:00') {
        timerExpired();
      }
      return Text(
        '${countDownTimer.formattedTime}',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w300),
      );
    });
  } else {
      return TrText('expired');
    }

  }
}

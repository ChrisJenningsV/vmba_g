import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vmba/data/globals.dart';

class CountDownTimer extends ChangeNotifier {
  Timer timer;

  Stopwatch _stopwatch = new Stopwatch();
  final double _timerStart = 600000;
  var _timeRemainingMinutes;
  var _timeRemainingSeconds;
  double _timeRemaining;
  String formattedTime = '';

  void start() {
    _stopwatch.start();
    gblTimerExpired = false;
    timer = new Timer.periodic(new Duration(seconds: 1), callback);
  }

  void stop() {
    gblTimerExpired = true;
    _stopwatch.stop();
    _stopwatch = null;
    timer.cancel();
    timer = null;
    gblTimerExpired = true;
  }

  void callback(Timer timer) {
    if ( gblTimerExpired == true ) {
      timer.cancel();
      _stopwatch = null;
      return;
    }
      if( _stopwatch != null ) {
      _timeRemaining = _timerStart - _stopwatch.elapsedMilliseconds;
      _timeRemainingMinutes = (_timeRemaining / (1000 * 60)) % 60;
      _timeRemainingSeconds = (_timeRemaining / (1000)) % 60;
      if (0 >= _timeRemaining) {
        formattedTime = "00:00";
        timer.cancel();
        stop();
      } else {
        formattedTime = _timeRemainingMinutes.toString().split('.')[0] +
            ':' +
            _timeRemainingSeconds.toString().split('.')[0].padLeft(2, '0');
      }
      update();
    } else {
      timer.cancel();
    }
  }

  void update() {
    if ( gblTimerExpired == false ) {
      notifyListeners();
    } else {
      _stopwatch.stop();
      _stopwatch = null;
      timer.cancel();
      timer = null;

    }
  }
}

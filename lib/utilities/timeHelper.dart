

// functions toget diff between phone time and GMT



import 'dart:async';

void setGMT(String gmtTime){
  gblGmtTime = DateTime.parse(gmtTime);
  // calc diff between GMT and phone time
  initGmtTimer();
  //gmtDiff = DateTime.now().difference(dt);

}

Timer? gmtTimer;
DateTime? gblGmtTime;
//Duration? gmtDiff;

void initGmtTimer()
{
  if( gmtTimer!= null ) endGmtTimer();

  gmtTimer = Timer.periodic(Duration(minutes: 1), (Timer t){
    // inc timer
     if( gblGmtTime != null) gblGmtTime = gblGmtTime?.add(Duration(minutes: 1));
  });
}

void endGmtTimer(){
  if( gmtTimer!= null ) {
    gmtTimer?.cancel();
    gmtTimer = null;
  }
}

DateTime getGmtTime() {
   if( gblGmtTime != null)
     // use our internal VRS based time
       return gblGmtTime as DateTime;
   else
     // calc GMT from phone time (may be set wrong by user!)
     return DateTime.now().toUtc();
}
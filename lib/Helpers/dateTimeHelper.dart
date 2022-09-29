

bool is1After2( DateTime dt1, DateTime dt2) {
  if( dt1.year > dt2.year){
    return true;
  }
  if( dt1.year < dt2.year ){
    return false;
  }
  if( dt1.month > dt2.month){
    return true;
  }
  if( dt1.month < dt2.month ){
    return false;
  }
  if( dt1.day > dt2.day){
    return true;
  }
  if( dt1.day < dt2.day ){
    return false;
  }
  // same date
  if( dt1.hour > dt2.hour){
    return true;
  }
  if( dt1.hour < dt2.hour ){
    return false;
  }
  if( dt1.minute > dt2.minute){
    return true;
  }
  if( dt1.minute < dt2.minute ){
    return false;
  }
  return false;

}
import 'package:vmba/Seats/plan.dart';
import 'package:vmba/data/models/seatplan.dart';

class Pax {
  String name;
  String seat;
  String savedSeat;
  int id;
  bool selected;
  String paxType;
  Pax(this.name, this.seat, this.selected, this.id, this.savedSeat, this.paxType);


  Map  toJson() {
    Map map = new Map();
    map['name'] = name;
    map['seat'] = seat;
    map['savedSeat'] = savedSeat;
    map['id'] = id;
    map['selected'] = selected;
    map['paxType'] = paxType;
    return map;
  }

}

class PaxList{
  List<Pax>? list = [];

  void init(List<Pax> paxList){
    list = paxList;
  }

  String getOccupant(String code, Seat? seat, String rloc){
    bool bFound = false;
    this.list!.forEach((pax) {
       if( pax.seat == code){
         // get initials
         List<String> strArray = pax.name.split(' ');
         code = strArray[0].substring(0, 1);
         if (strArray.length > 1) {
           code += strArray[1].substring(0, 1);
           bFound = true;
         }
       }
    });
    if( bFound)     return code;
    if(seat != null ) {
      if (seat.sRLOC == rloc) {
        if( seat.sFirstName != '' ) {
          code = seat.sFirstName.substring(0, 1);
          if (seat.sLastName != '') {
            code += seat.sLastName.substring(0, 1);
            bFound = true;
          }
        }
      }
    }
    return code;
  }

  int allocatedCount() {
    int cont = 0;
    this.list!.forEach((pax) {
      if( pax.seat != '' ) cont++;
    });
    return cont;
  }

  void releaseSeat(String sCode){
    this.list!.forEach((pax) {
      if( pax.seat == sCode){
        pax.seat = '';
        pax.selected = false;
      }
    });
      int index = 0;
      gblSelectedSeats.forEach((seat) {
        if ( seat == sCode) {
          gblSelectedSeats[index] ='';
        }
        index+=1;
      });
  }
}
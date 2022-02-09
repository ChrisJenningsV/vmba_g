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
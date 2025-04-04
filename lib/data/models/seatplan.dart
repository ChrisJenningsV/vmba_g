
import 'package:vmba/data/globals.dart';
import 'package:vmba/data/models/pax.dart';

import '../../utilities/helper.dart';

class Seatplan {
  Seats seats = Seats();

  Seatplan();

  Seatplan.fromJson(Map<String, dynamic> json) {
    if(json['Seats'] != null ) seats = Seats.fromJson(json['Seats']) ;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.seats != null) {
      data['Seats'] = this.seats.toJson();
    }
    return data;
  }

  int getMinCol() {
    int minCol = -1;
    this.seats.seat.forEach((Seat s) {
      if (minCol == -1 || minCol > s.sCol) {
        if( s.isSeat()) {
          minCol = s.sCol;
        }
      }
    });
    return minCol;
  }

  int getMaxCol() {
    int maxCol = 0;
    this.seats.seat.forEach((s) {
      if (s.sCol > maxCol) {
        maxCol = s.sCol;
      }
    });
    return maxCol;
  }


  List<Seat> getSeatsForRow(int row){
    List<Seat> seats = [];
    seats = this
        .seats
        .seat
        .where((a) => a.sRow == row)
        .toList();
    if (seats == null) {} else {
      seats.sort((a, b) => a.sCol.compareTo(b.sCol));
    }
    return seats;
  }

  SeatPlanDefinition? getPlanDataTable() {
      return init();
  }
  SeatPlanDefinition? init() {
    SeatPlanDefinition def = new SeatPlanDefinition();
    // build a table of seats
    //def.noRows = this.seats.seat.last.sRow;

    int minCol = -1;
    int maxCol = -1;
    int minRow = -1;
    int maxRow = -1;
    this.seats.seat.forEach((s) {
      if(minCol == -1 || minCol > s.sCol ){
        minCol = s.sCol;
      }
      if(s.sCol > maxCol ) {
        maxCol = s.sCol;
      }
      if(s.sRow > maxRow ) {
        maxRow = s.sRow;
      }
      if(s.sRow < minRow || minRow == -1 ) {
        if( s.isSeat()) {
          minRow = s.sRow;
        }
      }

    });
    def.minRow = minRow;
    def.minCol = minCol;
    def.maxCol = maxCol;
    def.maxRow = maxRow;
    if( maxCol > 10) {
      logit('mini seats $maxCol');
      def.seatSize = SeatSize.small;
      def.seatWidth = 24;
      def.seatHeight = 24;
      def.asileWidth = 1;
    } else if( maxCol > 7) {
      logit('small seats $maxCol');
      def.seatSize = SeatSize.medium;
      def.seatWidth = 35;
      def.seatHeight = 35;
      def.asileWidth = 2;
    } else {
      def.seatSize = SeatSize.large;

      logit('regular seats $maxCol');
    }

    int cols = this.seats.seat.last.sRow;
    int maxSeatsPerRow = 0;
    int maxAiselsPerRow = 0;
    // step through rows
    for (var indexRow = 1; indexRow <= def.maxRow; indexRow++) {
      List<Seat> seats = this.seats.seat.where((a) => a.sRow == indexRow).toList();

      SeatPlanRow sRow = new SeatPlanRow();
      sRow.rowNo = indexRow;
      // add something for each column
      int seatsThisRow = 0;
      int aiselsThisRow = 0;
      for ( var indexCol = 0; indexCol <= def.maxCol ; indexCol++){
        Seat? seat  = seats.where((a) => a.sCol == indexCol).firstOrNull;
        if( indexCol == 5){
          int x = 1;
        }
        if( seat != null && seat!.isSeat()) {
          seatsThisRow ++;
        } else if(  seat != null && seat!.isAisle()) {
          //logit('aisle r=${seat!.sRow} c=${seat!.sCol}');
          aiselsThisRow++;
        }
        // add this seat (or null ) to map
        sRow.cols[indexCol] = seat;
      }
      if( seatsThisRow > maxSeatsPerRow ) maxSeatsPerRow = seatsThisRow ;
      if( aiselsThisRow > maxAiselsPerRow ) maxAiselsPerRow = aiselsThisRow;

      def.table.add(sRow);
    }
    def.maxSeatsPerRow = maxSeatsPerRow;
    def.maxAiselsPerRow = maxAiselsPerRow;

    // aisel
    def.colTypes = [];
    for (var colRow = 0; colRow <= def.maxCol; colRow++) {
      List<Seat>? colSeats = seats.seat.where((a) => a.sCol == colRow && a.sCode != '').toList();
      if(colSeats == null ||  colSeats.length == 0) {
        def.colTypes.add('A');
      } else {
        def.colTypes.add( 'S');
      }
    }

      def.initPaxList();

      return def;
  }


  void simplifyPlan() {
    logit('simplifying plan');

    // remove first col if markers only
    bool canRemove = true;
    this.seats.seat.forEach((s) {
      if( s.sCol == 1){
        if( s.sCellDescription == 'Wing Middle' || s.sCellDescription == 'Wing End' || s.sCellDescription == 'Wing Start') {

        } else {
          logit('col=${s.sCol} d=${s.sCellDescription}');
          canRemove = false;
        }
      }

    });
    if( canRemove == true) {
      // delete all col 1
      this.seats.seat.removeWhere((item) => item.sCol == 1);
    }

    // what is last col ?
    int maxCol = 1;
    this.seats.seat.forEach((s) {
      if (s.sCol > maxCol) {
        maxCol = s.sCol;
      }
    });
    this.seats.seat.forEach((s) {
      if( s.sCol == maxCol){
        if( s.sCellDescription == 'Wing Middle' || s.sCellDescription == 'Wing End'
            || s.sCellDescription == 'Wing Start' || s.sCellDescription == 'DoorUp'
            || s.sCellDescription == 'DoorDown') {

        } else {
          logit('col=${s.sCol} d=${s.sCellDescription}');
          canRemove = false;
        }
      }

    });
    if( canRemove == true) {
      // delete all col 1
      this.seats.seat.removeWhere((item) => item.sCol == maxCol);
    }

    if( gblSettings.wantNewSeats) {
      canRemove = true;
      bool canRemoveA = true;
      this.seats.seat.forEach((s) {
        if( s.sRow == 3) logit(' s r=${s.sRow} c=${s.sCol} d=${s.sCellDescription} n=${s.sCode}');

        if (s.sRow == 2) {
          if (s.sCellDescription != 'Aisle') {
            canRemoveA = false;
          }
        }
        if (s.sRow == 1) {
          if (s.sCellDescription.length == 1 || s.sCellDescription.length == 0) {
          } else {
            logit('col=${s.sCol} d=${s.sCellDescription}');
            canRemove = false;
          }
        }
      });
      if (canRemove == true) {
        // delete all col 1
        this.seats.seat.removeWhere((item) => item.sRow == 1);
      }
      if( canRemoveA == true){
        // delete all col 2
        this.seats.seat.removeWhere((item) => item.sRow == 2);
      }
    }

  }

  bool hasSeatsAvailable() {
    if (this
            .seats
            .seat
            .where((seat) =>
                seat.sSeatID == '0' &&
                seat.sCode != '' &&
                !seat.sCellDescription.contains('Block'))
            .toList()
            .length >
        0) {
      return true;
    } else {
      return false;
    }
  }

  bool hasWings() {
    return (this
        .seats
        .seat
        .where((seat) =>
    (seat.sCellDescription.contains('Wing')) )
        .toList()
        .length >
        0) ;
  }

  int getLeftWing() {
    int min = 10;

    this.seats.seat.forEach((seat) {
      if(seat.sCellDescription.contains('Wing')){
          if( seat.sCol != 0 && seat.sCol < min ){
            min = seat.sCol;
          }
        }
      });
    return min;
  }

  int getRightWing() {
    int max = 0;

    this.seats.seat.forEach((seat) {
      if(seat.sCellDescription.contains('Wing')){
        if( seat.sCol != 0 && seat.sCol > max ){
          max = seat.sCol;
        }
      }
    });
    return max;
  }

  bool hasBlockedSeats() {
    if (this
            .seats
            .seat
            .where((seat) =>
                (seat.sSeatID == '0' &&
                    seat.sCode != '' &&
                    seat.sCellDescription.contains('Block')) ||
                (seat.sSeatID != '0' &&
                    seat.sLastName == '' &&
                    seat.sCellDescription.contains('Seat')))
            .toList()
            .length >
        0) {
      return true;
    } else {
      return false;
    }
  }
}

enum SeatSize{
  small,
  medium,
  large
}

class SeatPlanRow {
  int rowNo = 0;
  Map cols = new Map();

}
// 'logical' breakdown of VRS seat plan
class SeatPlanDefinition{
  // table of seats by row / col
  List<SeatPlanRow> table = [];

//  int noRows = 0;
  int minRow = 0;
  int maxRow = 0;
  int minCol = 0;
  int maxCol = 0;
  int maxSeatsPerRow = 0;
  int maxAiselsPerRow = 0;
  double seatWidth = 35;
  double seatHeight = 35;
  double asileWidth = 5;
  SeatSize seatSize = SeatSize.large;
  List<Pax>? paxlist;

  double getTableRowHeight(){
    return seatHeight;
  }

  void initPaxList() {
    paxlist =  gblPnrModel!.getBookedPaxList(gblCurJourney);
  }

  List<Pax>? getPaxList(){
    return paxlist;
  }

  String dump(bool toPrint  ){
    String dumpOut='';
    if(table != null  ){
      int iRow = 1;
      table!.forEach((row){
        String sDump = '';
        for ( var indexCol = 0; indexCol <= this.maxCol ; indexCol++){
          if( row.cols[indexCol] != null ){
            Seat seat = row.cols[indexCol];
            if( seat.sCode == ''){
              String seatTxt = '';
              switch (seat.sCellDescription){
                case 'SeatPlanWidthMarker':
                  seatTxt = 'w';
                  break;
                case 'Wing Start':
                  seatTxt = 's';
                  break;
                case 'Wing Middle':
                  seatTxt = 'm';
                  break;
                case 'Wing End':
                  seatTxt = 'e';
                  break;
                case 'DoorDown':
                  seatTxt = 'd';
                  break;
                case 'DoorUp':
                  seatTxt = 'u';
                  break;
                case 'Aisle':
                  seatTxt = 'a';
                  break;
                default:
                  seatTxt = seat.sCellDescription;
                  break;

              }
              sDump += ' $seatTxt';
            } else {
              sDump += ' ${seat.sCode}';
            }
          }
        };
        //logit('r: $iRow $sDump');
        dumpOut += ' r: $iRow ' + sDump + '\n\r';
        iRow++;
      });
    }
    return dumpOut;
  }

  // type of col - used to set width
  // Seat, Aisel
  List<String> colTypes = [];

  Seat? getSeatAt(int row, int col){
    Seat? retSeat = null;
    if( row <= maxRow) {
      if( col <= maxCol ){
        table.forEach((tr) {
          if( tr.rowNo == row){
           // SeatPlanRow seatPlanRow = table[row];
            retSeat  = tr.cols[col];
          }
        });
      }
    }
    return retSeat;
  }
  // cabins

  // prices
}

class Seats {
  SeatsFlt seatsFlt = SeatsFlt();
  CabinCount cabinCount = CabinCount();
  List<Seat> seat = List.from([Seat()]);

  Seats();

  Seats.fromJson(Map<String, dynamic> json) {
    try {
      if (json['SeatsFlt'] != null)
        seatsFlt = SeatsFlt.fromJson(json['SeatsFlt']);
      if (json['CabinCount'] != null)
        cabinCount = CabinCount.fromJson(json['CabinCount']);
      if (json['Seat'] != null) {
        seat = [];
        // new List<Seat>();
        json['Seat'].forEach((v) {
          seat.add(new Seat.fromJson(v));
        });
      }
    } catch(e) {
      logit(e.toString());
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.seatsFlt != null) {
      data['SeatsFlt'] = this.seatsFlt.toJson();
    }
    if (this.cabinCount != null) {
      data['CabinCount'] = this.cabinCount.toJson();
    }
    if (this.seat != null) {
      data['Seat'] = this.seat.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class SeatsFlt {
  String sFltNo='';
  String sFltDate='';
  String sDepart='';
  String sDestin='';
  String sFltID='';
  String sRef='';
  String displayInfo = '';
  String departTime = '';

  SeatsFlt();

  SeatsFlt.fromJson(Map<String, dynamic> json) {
    if( json['FltNo'] != null ) sFltNo = json['FltNo'];
    if( json['Flt_Date'] != null ) sFltDate = json['Flt_Date'];
    if( json['Depart'] != null ) sDepart = json['Depart'];
    if( json['Destin'] != null ) sDestin = json['Destin'];
    if( json['FltID'] != null ) sFltID = json['FltID'];
    if( json['Ref'] != null ) sRef = json['Ref'];
    if( json['DisplayInfo'] != null ) displayInfo = json['DisplayInfo'];
    if( json['DepartTime'] != null ) departTime = json['DepartTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['FltNo'] = this.sFltNo;
    data['Flt_Date'] = this.sFltDate;
    data['Depart'] = this.sDepart;
    data['Destin'] = this.sDestin;
    data['FltID'] = this.sFltID;
    data['Ref'] = this.sRef;
    return data;
  }
}

class CabinCount {
  List<Cabin> cabins = [];

  CabinCount();

  CabinCount.fromJson(Map<String, dynamic> json) {
    print('${json['Cabin'].runtimeType}');

    if( json['Cabin'].runtimeType.toString() == '_InternalLinkedHashMap<String, dynamic>' ||
        json['Cabin'].runtimeType.toString() == '_Map<String, dynamic>') {
      if( json['Cabin'] != null ) {
        cabins.add(new Cabin.fromJson(json['Cabin']));
      }
      } else {
      json['Cabin'].forEach((element){
        cabins.add(new Cabin.fromJson(element));
      });

    }
  //  cabins.add(value) = json['Cabin'] != null ? new Cabin.fromJson(json['Cabin']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.cabins != null) {
      //data['Cabin'] = this.cabins.toJson();
    }
    return data;
  }
}

class Cabin {
  String sCabinClass ='';
  String sSeats ='';

  Cabin();

  Cabin.fromJson(Map<String, dynamic> json) {
    sCabinClass = json['CabinClass'];
    sSeats = json['Seats'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['CabinClass'] = this.sCabinClass;
    data['Seats'] = this.sSeats;
    return data;
  }
}

class Seat {
  String sSeatID ='';
  int sRow =1;
  int sCol =1;
  String sCode ='';
  String sCabinClass ='';
  String sCellDescription ='';
  String sSccode ='';
  String sScinfo ='';
  String sCur ='';
  String sScprice ='';
  String sSeatdescription ='';
  String sFirstName ='';
  String sLastName ='';
  String sMFCI ='';
  String sStatus ='';
  String sRLOC ='';
  String sPAXNumber ='';
  String sTktStatus ='';
  String sDCSStatus ='';
  String sSequence ='';
  bool noInfantSeat=false;
  bool pRMSeat=false;

  Seat({this.sCellDescription = '', this.sCode='', this.noInfantSeat = false});

  Seat.fromJson(Map<String, dynamic> json) {
    try {
    if(json['SeatID'] != null )sSeatID = json['SeatID'];
    if(json['Row'] != null )sRow = int.parse(json['Row']);
    if(json['Col'] != null )sCol = int.parse(json['Col']);
    if(json['Code'] != null )sCode = json['Code'];
    if(json['CabinClass'] != null )sCabinClass = json['CabinClass'];
    if(json['CellDescription'] != null )sCellDescription = json['CellDescription'];
    if(json['sccode']!= null )sSccode = json['sccode'];
    if(json['scinfo'] != null )sScinfo = json['scinfo'];
    if(json['cur'] != null )sCur = json['cur'];
    if(json['scprice'] != null )sScprice = json['scprice'];
    if(json['seatdescription'] != null )sSeatdescription = json['seatdescription'];
    if(json['FirstName'] != null )sFirstName = json['FirstName'];
    if(json['LastName'] != null )sLastName = json['LastName'];
    if( json['MFCI'] != null )sMFCI = json['MFCI'];
    if(json['Status'] != null )sStatus = json['Status'];
    if(json['RLOC'] != null )sRLOC = json['RLOC'];
    if( json['PAXNumber'] != null )sPAXNumber = json['PAXNumber'];
    if(json['TktStatus'] != null )sTktStatus = json['TktStatus'];
    if( json['DCSStatus'] != null )sDCSStatus = json['DCSStatus'];
    if(json['Sequence'] != null )sSequence = json['Sequence'];
    if(json['NoInfantSeat'] != null && (json['NoInfantSeat'] == '1' || json['NoInfantSeat'] == 'True' )) {
      noInfantSeat = true;
    } else {
      noInfantSeat = false;
    }
    if(json['PRMSeat']!= null && (json['PRMSeat'] == '1' || json['PRMSeat'] == 'True' )) {
      pRMSeat = true;
    } else {
      pRMSeat = false;
    }
    } catch(e) {
      logit(e.toString());
    }
  }

  bool isSeat() {
    if( this.sCellDescription == 'Seat' || this.sCellDescription == 'EmergencySeat' || this.sCellDescription == 'Block Seat'){
      return true;
    }
    return false;
  }
  bool isAisle() {
    if( this.sCellDescription == 'Aisle' ){
      return true;
    }
    return false;

  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['SeatID'] = this.sSeatID;
    data['Row'] = this.sRow;
    data['Col'] = this.sCol;
    data['Code'] = this.sCode;
    data['CabinClass'] = this.sCabinClass;
    data['CellDescription'] = this.sCellDescription;
    data['sccode'] = this.sSccode;
    data['scinfo'] = this.sScinfo;
    data['cur'] = this.sCur;
    data['scprice'] = this.sScprice;
    data['seatdescription'] = this.sSeatdescription;
    return data;
  }
}

class SeatPlanConfig {
  String version = '';
  String name = '';
  String layout = '';
  double top = 0;
  double left = 0;
  double cabinWidth = 0;
  double seatHorzSpace = 0;
  double seatVertSpace = 0;
  double seatWidth = 0;
  double seatHeight = 0;
  double aiselWidth = 0;

  SeatPlanConfig.fromJson(Map<String, dynamic> json) {
    try {
      if (json['version'] != null) version = json['version'];
      if (json['name'] != null) name = json['name'];
      if (json['layout'] != null) layout = json['layout'];
      if (json['top'] != null) top = double.parse(json['top']);
      if (json['left'] != null) left = double.parse(json['left']);
      if (json['cabinWidth'] != null) cabinWidth = double.parse(json['cabinWidth']);

      if (json['seatVertSpace'] != null) seatVertSpace = double.parse(json['seatVertSpace']);
      if (json['seatHorzSpace'] != null) seatHorzSpace = double.parse(json['seatHorzSpace']);
      if (json['seatWidth'] != null) seatWidth = double.parse(json['seatWidth']);
      if (json['seatHeight'] != null) seatHeight = double.parse(json['seatHeight']);
      if (json['aiselWidth'] != null) aiselWidth = double.parse(json['aiselWidth']);

    } catch (e) {

    }
  }
}
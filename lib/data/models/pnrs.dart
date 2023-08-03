import 'package:meta/meta.dart';

class PnrDBCopy {
  static final dbRloc = "rloc";
  static final dbData = "data";
  static final dbDelete = "deleteRecord";

  String rloc, data;
  int delete=0, nextFlightSinceEpoch=0;
  bool success=true;

  PnrDBCopy({
    required this.rloc,
    required this.data,
    required this.delete,
    this.nextFlightSinceEpoch=0,
    this.success=true
  });

  PnrDBCopy.fromMap(Map<String, dynamic> map)
      : this(
          rloc: map[dbRloc],
          data: map[dbData],
          delete: map[dbDelete],
          
        );

  // Currently not used
  Map<String, dynamic> toMap() {
    return {
      dbRloc: rloc,
      dbData: data,
      dbDelete: delete,
    };
  }
}

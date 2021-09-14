import 'package:meta/meta.dart';

class PnrDBCopy {
  static final dbRloc = "rloc";
  static final dbData = "data";
  static final dbDelete = "deleteRecord";

  String rloc, data;
  int delete, nextFlightSinceEpoch;
  bool success;

  PnrDBCopy({
    @required this.rloc,
    @required this.data,
    @required this.delete,
    this.nextFlightSinceEpoch,
    this.success
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

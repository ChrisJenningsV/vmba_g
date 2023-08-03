import 'package:meta/meta.dart';

class UserProfileRecord {
  //static final db_id = "id";
  static final dbName = "name";
  static final dbValue = "value";

  String value='', name='';
  int id=0;

  UserProfileRecord({
   // this.id,
    required this.name,
    required this.value,
  });

  UserProfileRecord.fromMap(Map<String, dynamic> map)
      : this(
        //  id: map[db_id],
          name: map[dbName],
          value: map[dbValue],
        );

  // Currently not used
  Map<String, dynamic> toMap() {
    return {
     // db_id: id,
      dbName: name,
      dbValue: value,
    };
  }

}

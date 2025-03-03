

import '../utilities/helper.dart';

List<String> gblAuditBuffer= [];


class AuditManager {
  static void add(String action, dynamic obj) {
    try {
      String output = '';
      output += action + ' ';
      output += obj.toLog();

      gblAuditBuffer.add(output);
    } catch(e) {
      logit('AuditManager.add ' + e.toString());
    }
  }


}
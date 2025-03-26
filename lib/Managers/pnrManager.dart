

import 'dart:convert';

import '../data/models/pnr.dart';
import '../data/models/pnrs.dart';
import '../data/repository.dart';

class PnrManager {

// gradually add all PNR store / manage functions here

  static bool savePnrIfNotPresent(String pnrJson) {

    Map<String, dynamic> map = json.decode(pnrJson);
    print('Fetch PNR');
    PnrModel pnrModel = new PnrModel.fromJson(map);

    PnrDBCopy pnrDBCopy = new PnrDBCopy(
        rloc: pnrModel.pNR.rLOC, //_rloc,
        data: pnrJson,
        success: true,
        delete: 0,
        nextFlightSinceEpoch: pnrModel.getnextFlightEpoch());

    Repository.get().updatePnr(pnrDBCopy);
    return true;
  }

}
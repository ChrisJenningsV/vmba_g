
part of 'viewBookingPage.dart';

/*import 'package:vmba/mmb/viewBookingPage.dart';*/

extension Section on ViewBookingPageState{

Future <void> doRefresh() async{
  refreshBooking(gblCurrentRloc);
  setState(() {

  });
}

void _onPressedRefund({int? p1}) async {
  RefundRequest rfund = new RefundRequest();
  rfund.rloc = widget.rloc;
  rfund.journeyNo = p1!;

  String data =  json.encode(rfund);

  try {
    String reply = await callSmartApi('REFUND', data);
    Map<String, dynamic> map = json.decode(reply);
    RefundReply refundRs = new RefundReply.fromJson(map);
    gblActionBtnDisabled = false;
    if( refundRs.success == true ) {
      showAlertDialog(context, 'Refund', 'Refund successful');
    } else {
      showAlertDialog(context, 'Refund', 'refund failed');
    }
  } catch(e) {
    logit(e.toString());
  }
}

}
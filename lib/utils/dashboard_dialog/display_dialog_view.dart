import 'package:attend_app/utils/attend_request_items/absence_items.dart';
import 'package:attend_app/utils/attend_request_items/cuti_items.dart';
import 'package:attend_app/utils/attend_request_items/early_items.dart';
import 'package:attend_app/utils/attend_request_items/late_items.dart';
import 'package:attend_app/utils/attend_request_items/leave_items.dart';
import 'package:attend_app/utils/attend_request_items/overtime_items.dart';
import 'package:attend_app/utils/colors.dart';
import 'package:attend_app/widgets/navbar.dart';
import 'package:flutter/material.dart';

class DashDisplayDialog extends StatefulWidget {
  final int id;
  final DateTime date;

  const DashDisplayDialog({Key key, this.id, this.date}) : super(key: key);
  @override
  State<StatefulWidget> createState() => DashDisplayDialogState(id, date);
}

class DashDisplayDialogState extends State<DashDisplayDialog> {
  final int id;
  final DateTime date;

  DashDisplayDialogState(this.id, this.date);

  String attendCategory = '';

  @override
  void initState() {
    super.initState();
    if (id == 0) {
      attendCategory = "Absen Tepat Waktu";
    } else if (id == 1) {
      attendCategory = "Absen Telat";
    } else if (id == 2) {
      attendCategory = "Pulang Cepat";
    } else if (id == 3) {
      attendCategory = "Lembur";
    } else if (id == 4) {
      attendCategory = "Izin";
    } else if (id == 5) {
      attendCategory = "Cuti";
    } else {
      attendCategory = "KATEGORI INVALID!!!";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(
        title: "AKTIVITAS HARI INI",
        rightOptions: false,
        backButton: true,
      ),
//      appBar: AppBar(
//        automaticallyImplyLeading: false,
//        elevation: 10.0,
//        shape: RoundedRectangleBorder(
//          borderRadius: BorderRadius.only(
//              bottomLeft: Radius.circular(15.0),
//              bottomRight: Radius.circular(15.0)),
//        ),
//        backgroundColor: white,
//        title: Text(
//          "AKTIVITAS HARI INI",
//          style: TextStyle(color: teal),
//        ),
//        centerTitle: true,
//      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration:
        BoxDecoration(
            image: DecorationImage(
                alignment: Alignment.bottomCenter,
                image: AssetImage("assets/images/onboard-background.png"),
                fit: BoxFit.fitWidth
            )
        ),
//            BoxDecoration(gradient: LinearGradient(colors: [info, primary])),
        child: _body(),
      ),
    );
  }

  Widget _body() {
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 100,
            ),
            Card(
              elevation: 20.0,
              shadowColor: kAppSoftLightTeal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(left: 10.0, top: 10.0),
                    child: Text(
                      'Aktivitas $attendCategory',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: info,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(
                        left: 5.0, right: 5.0, top: 5.0, bottom: 5.0),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height / 1.5,
                    child: listWidget(),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 100,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget listWidget() {
    if (id == 0) {
      return AbsenceItems(
        dateTime: date,
        timeCategory: 'Daily',
      );
    } else if (id == 1) {
      return LateItems(
        dateTime: date,
        timeCategory: 'Daily',
        status: 'Belum Terproses',
      );
    } else if (id == 2) {
      return EarlyItems(
        dateTime: date,
        timeCategory: 'Daily',
        status: 'Belum Terproses',
      );
    } else if (id == 3) {
      return OvertimeItems(
        dateTime: date,
        timeCategory: 'Daily',
        status: 'Belum Terproses',
      );
    } else if (id == 4) {
      return LeaveItems(
        dateTime: date,
        timeCategory: 'Daily',
        status: 'Belum Terproses',
      );
    } else if (id == 5) {
      return CutiItems(
        dateTime: date,
        timeCategory: 'Daily',
        status: 'Belum Terproses',
      );
    } else {
      return Container();
    }
  }
}

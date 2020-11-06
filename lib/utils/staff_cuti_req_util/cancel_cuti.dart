import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../colors.dart';
import '../utils.dart';

class CancelCuti extends StatefulWidget {
  final ParseObject objectDetailView;

  const CancelCuti({Key key, this.objectDetailView}) : super(key: key);
  @override
  State<StatefulWidget> createState() => CancelCutiState(objectDetailView);
}

class CancelCutiState extends State<CancelCuti>
    with SingleTickerProviderStateMixin {
  final ParseObject objectDetailView;

  CancelCutiState(this.objectDetailView);

  SharedPreferences prefs;
  ProgressDialog pr;

  Map<String, dynamic> mapDetailView;

  @override
  void initState() {
    super.initState();
    mapDetailView = Map<String, dynamic>.from(objectDetailView.toJson());
    print(mapDetailView);
    pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(message: "MENGIRIM DATA...");
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          alignment: Alignment.center,
          margin: EdgeInsets.all(20.0),
          padding: EdgeInsets.all(10.0),
          height: MediaQuery.of(context).size.height / 3.0,
          width: MediaQuery.of(context).size.width,
          decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0))),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Text(
                    'Cancel cuti request ${mapDetailView['fullname']}?',
                    style: TextStyle(fontSize: 16.0, color: teal),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 25.0),
                _okButton(),
                SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _okButton() {
    return Container(
      child: Align(
        alignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.only(left: 10.0, right: 10.0),
          width: MediaQuery.of(context).size.width / 2.5,
          height: 50.0,
          child: RaisedButton(
            elevation: 10.0,
            child: Text("OK", style: TextStyle(color: Colors.white)),
            color: blueButton,
            onPressed: () {
              setState(() {
                pr.show();
                cancelCuti();
              });
            },
            shape: RoundedRectangleBorder(
                side: BorderSide(
                    style: BorderStyle.solid, color: blue, width: 2.0),
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
          ),
        ),
      ),
    );
  }

  void cancelCuti() async {
    prefs = await SharedPreferences.getInstance();
    ParseObject parseCancel = ParseObject(mapDetailView['className']);
    parseCancel.set('objectId', mapDetailView['objectId']);
    parseCancel.delete().then((value) {
      if (value.statusCode == 200) {
        prefs.setString('lastCutiDate', '');
        prefs.setBool('hasCuti', true);
        setState(() {
          pr.hide();
        });
        Alert(
          context: context,
          style: Utils.alertStyle,
          type: AlertType.success,
          title: 'BERHASIL',
          desc: 'Request cuti anda berhasil di cancel',
          buttons: [
            DialogButton(
              child: Text(
                "OK",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () {
                setState(() {
                  pr.hide();
                });
                Navigator.of(context).pop();
              },
              color: Color.fromRGBO(0, 179, 134, 1.0),
              radius: BorderRadius.circular(0.0),
            ),
          ],
        ).show().whenComplete(() {
          Navigator.pop(context, ['cancel', mapDetailView]);
        });
      } else {
        setState(() {
          pr.hide();
        });
        Alert(
          context: context,
          style: Utils.alertStyle,
          type: AlertType.error,
          title: 'GAGAL',
          desc: 'Mohon periksa koneksi anda\ndan\nkirim lagi data anda',
          buttons: [
            DialogButton(
              child: Text(
                "OK",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () {
                setState(() {
                  pr.hide();
                });
                Navigator.of(context).pop();
              },
              color: Color.fromRGBO(0, 179, 134, 1.0),
              radius: BorderRadius.circular(0.0),
            ),
          ],
        ).show();
      }
    }).catchError((e) {
      setState(() {
        pr.hide();
      });
      Alert(
        context: context,
        style: Utils.alertStyle,
        type: AlertType.error,
        title: 'GAGAL',
        desc: 'Mohon periksa koneksi anda\ndan\nkirim lagi data anda',
        buttons: [
          DialogButton(
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              setState(() {
                pr.hide();
              });
              Navigator.of(context).pop();
            },
            color: Color.fromRGBO(0, 179, 134, 1.0),
            radius: BorderRadius.circular(0.0),
          ),
        ],
      ).show();
    });
  }
}

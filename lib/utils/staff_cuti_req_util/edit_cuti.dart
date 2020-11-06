import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../colors.dart';
import '../utils.dart';

class EditCuti extends StatefulWidget {
  final ParseObject objectDetailView;

  const EditCuti({Key key, this.objectDetailView}) : super(key: key);
  @override
  State<StatefulWidget> createState() => EditCutiState(objectDetailView);
}

class EditCutiState extends State<EditCuti>
    with SingleTickerProviderStateMixin {
  final ParseObject objectDetailView;

  EditCutiState(this.objectDetailView);

  SharedPreferences prefs;
  ProgressDialog pr;

  Map<String, dynamic> mapDetailView, mapDari, mapSampai;

  var reasonController = TextEditingController();

  DateTime firstDate = DateTime.now();
  DateTime lastDate = DateTime.now();

  String firstDateDisplay = '--, --/--/--', lastDateDisplay = '--, --/--/--';
  int totalDay = 0;

  Color areaColor = Colors.black,
      firstDateColor = Colors.black,
      lastDateColor = Colors.black;

  @override
  void initState() {
    super.initState();
    mapDetailView = Map<String, dynamic>.from(objectDetailView.toJson());
    if (mapDetailView['dari'] != null) {
      mapDari = mapDetailView['dari'];
      firstDate = DateTime.parse(mapDari['iso']).toLocal();
    }
    if (mapDetailView['sampai'] != null) {
      mapSampai = mapDetailView['sampai'];
      lastDate = DateTime.parse(mapSampai['iso']).toLocal();
    }
    firstDateDisplay = DateFormat("EE, dd/MM/yyyy ").format(firstDate);
    lastDateDisplay = DateFormat("EE, dd/MM/yyyy ").format(lastDate);
    reasonController.text = mapDetailView['alasanIzin'];
    if (firstDate == lastDate) {
      totalDay = 1;
    } else {
      totalDay = lastDate.difference(firstDate).inDays + 1;
    }
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
          margin: EdgeInsets.all(20.0),
          padding: EdgeInsets.all(10.0),
          height: MediaQuery.of(context).size.height / 1.5,
          width: MediaQuery.of(context).size.width,
          decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0))),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _textDetailItem('Nama Lengkap', mapDetailView['fullname']),
                Container(
                  margin: const EdgeInsets.only(left: 10.0, top: 10.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width / 6,
                        child: Text(
                          'Dari',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: info,
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 15,
                        child: Text(
                          ':',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: info,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                            left: 5.0, right: 5.0, top: 5.0, bottom: 5.0),
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: firstDateColor, width: 2.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
                        child: Text(
                          firstDateDisplay,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      Container(
                        child: IconButton(
                          splashColor: Colors.black,
                          icon: Icon(Icons.date_range, color: blue),
                          onPressed: () {
                            _showDatePicker(0, firstDate);
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width / 6,
                        child: Text(
                          'Sampai',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: info,
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 15,
                        child: Text(
                          ':',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: info,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(
                            left: 5.0, right: 5.0, top: 5.0, bottom: 5.0),
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: lastDateColor, width: 2.0),
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0))),
                        child: Text(
                          lastDateDisplay,
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                      Container(
                        child: IconButton(
                          icon: Icon(Icons.date_range, color: blue),
                          splashColor: Colors.black,
                          onPressed: () {
                            _showDatePicker(1, lastDate);
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10.0, top: 10.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        child: Text(
                          'Jumlah Hari : ',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: info,
                          ),
                        ),
                      ),
                      Container(
                        child: Text(
                          totalDay.toString(),
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ),
                    ],
                  ),
                ),
                _detailItem('Alasan'),
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

  Widget _textDetailItem(String label, String value) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 10.0, top: 10.0),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16.0,
                  color: info,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 25.0, top: 5.0),
              child: Text(
                value,
                style: TextStyle(
                  fontSize: 14.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailItem(String label) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10.0),
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 10.0, top: 10.0),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16.0,
                  color: info,
                ),
              ),
            ),
            _textArea()
          ],
        ),
      ),
    );
  }

  Widget _textArea() {
    return Center(
      child: Container(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        margin: const EdgeInsets.all(10.0),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            border: Border.all(color: areaColor, width: 2.0),
            borderRadius: BorderRadius.all(Radius.circular(15.0))),
        child: TextFormField(
          maxLines: 12,
          decoration: InputDecoration(
            border: InputBorder.none,
          ),
          controller: reasonController,
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }

  Future<void> _showDatePicker(int id, DateTime time) async {
    final picked = await showDatePicker(
        context: context,
        initialDate: time,
        firstDate: DateTime(time.year),
        lastDate: DateTime(time.year + 10));
    if (picked != null) {
      setState(() {
        if (id == 0) {
          firstDate = picked;
          firstDateDisplay = DateFormat("EE, dd/MM/yyyy ").format(firstDate);
        } else if (id == 1) {
          lastDate = picked;
          lastDateDisplay = DateFormat("EE, dd/MM/yyyy ").format(lastDate);
          if (firstDate == lastDate) {
            totalDay = 1;
          } else {
            totalDay = lastDate.difference(firstDate).inDays + 1;
          }
        }
      });
    }
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
              _formValidate();
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

  void _formValidate() {
    setState(() {
      if (firstDate != null &&
          lastDate != null &&
          reasonController.text.trim() != null &&
          (totalDay != 0 || totalDay > 0)) {
        pr.show();
        updateCuti();
      }
    });
  }

  void updateCuti() async {
    prefs = await SharedPreferences.getInstance();
    ParseObject updateCuti = ParseObject('Izin');
    updateCuti.set('objectId', mapDetailView['objectId']);
    updateCuti.set('dari', firstDate.toUtc());
    updateCuti.set('sampai', lastDate.toUtc());
    updateCuti.set('alasanIzin', reasonController.text.trim());
    updateCuti.update().then((value) {
      if (value.statusCode == 200) {
        prefs.setString('lastCutiDate', lastDate.toString());
        prefs.setBool('hasCuti', true);
        setState(() {
          pr.hide();
        });
        Alert(
          context: context,
          style: Utils.alertStyle,
          type: AlertType.success,
          title: "BERHASIl",
          desc: "Update Data berhasil dilakukan",
          buttons: [
            DialogButton(
              child: Text(
                "OK",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () => Navigator.pop(context),
              color: Colors.blue,
              radius: BorderRadius.circular(0.0),
            ),
          ],
        ).show().whenComplete(() {
          Navigator.pop(context, ['edited', mapDetailView]);
        });
      } else {
        setState(() {
          pr.hide();
        });
        Alert(
          context: context,
          style: Utils.alertStyle,
          type: AlertType.error,
          title: "GAGAL",
          desc: "Update Data gagal dilakukan.\nMohon kirim ulang",
          buttons: [
            DialogButton(
              child: Text(
                "OK",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () => Navigator.pop(context),
              color: Colors.blue,
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
        title: "GAGAL",
        desc: "Update Data gagal dilakukan.\nMohon kirim ulang",
        buttons: [
          DialogButton(
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
            color: Colors.blue,
            radius: BorderRadius.circular(0.0),
          ),
        ],
      ).show();
    });
  }
}

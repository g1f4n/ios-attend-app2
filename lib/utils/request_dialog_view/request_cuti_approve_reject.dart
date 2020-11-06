import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../colors.dart';
import '../utils.dart';

class CutiApproveRejectDialog extends StatefulWidget {
  final ParseObject objectDetailView;
  final int code;
  final String classname;

  const CutiApproveRejectDialog(
      {Key key, this.objectDetailView, this.code, this.classname})
      : super(key: key);
  @override
  State<StatefulWidget> createState() =>
      CutiApproveRejectDialogState(objectDetailView, code, classname);
}

class CutiApproveRejectDialogState extends State<CutiApproveRejectDialog>
    with SingleTickerProviderStateMixin {
  final ParseObject objectDetailView;
  final int code;
  final String classname;

  CutiApproveRejectDialogState(
      this.objectDetailView, this.code, this.classname);
  ProgressDialog pr;
  TextEditingController reasonController = TextEditingController();
  Map<String, dynamic> mapDetailView, mapDari, mapSampai, mapUserId;
  DateTime timeDari, timeSampai;
  String userObjectId;

  Color areaColor = Colors.black;

  bool finish = false;

  @override
  void initState() {
    super.initState();
    pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(message: "Update Data...");
    mapDetailView = Map<String, dynamic>.from(objectDetailView.toJson());
    if (mapDetailView['dari'] != null) {
      mapDari = mapDetailView['dari'];
      timeDari = DateTime.parse(mapDari['iso']);
    } else {
      mapDari = {'iso': null};
    }
    if (mapDetailView['sampai'] != null) {
      mapSampai = mapDetailView['sampai'];
      timeSampai = DateTime.parse(mapSampai['iso']);
    } else {
      mapSampai = {'iso': null};
    }
    if (mapDetailView['user'] != null) {
      mapUserId = mapDetailView['user'];
      userObjectId = mapUserId['objectId'];
    } else {
      mapUserId = {'objectId': null};
    }
  }

  @override
  void dispose() {
    super.dispose();
    reasonController.dispose();
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
          height: code == 1
              ? MediaQuery.of(context).size.height / 1.5
              : MediaQuery.of(context).size.height / 3.0,
          width: MediaQuery.of(context).size.width,
          decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0))),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                code == 1
                    ? _detailItem('Alasan Reject')
                    : Container(
                        child: Text(
                          'Approve request ${mapDetailView['fullname']}?',
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

  Widget _detailItem(String label) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(10.0),
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
            child: Text(finish ? "FINISH" : code == 1 ? "REJECT" : "APPROVE",
                style: TextStyle(color: Colors.white)),
            color: blueButton,
            onPressed: () {
              if (finish) {
                Navigator.of(context).pop();
              } else {
                setState(() {
                  pr.show();
                  if (code == 1) {
                    parseReject(mapDetailView['objectId']);
                  } else {
                    parseApprove(mapDetailView['objectId']);
                  }
                });
              }
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

  void parseApprove(String objectId) {
    int totalCuti = timeSampai.difference(timeDari).inDays + 1;
    ParseObject('_User').getObject(userObjectId).then((value) {
      if (value.statusCode == 200) {
        ParseObject getCutiDays = value.results[0];
        int sisaCuti = getCutiDays['jumlahCuti'] - totalCuti;
        if (sisaCuti >= 0) {
          ParseObject updateCutiUSer = ParseObject('_User');
          updateCutiUSer.set('objectId', userObjectId);
          updateCutiUSer.set('jumlahCuti', sisaCuti);
          updateCutiUSer.update().then((value) {
            ParseObject parseupdate = ParseObject(classname);
            parseupdate.set('objectId', objectId);
            parseupdate.set('status', 1);
            parseupdate.update().then((value) {
              if (value.statusCode == 200) {
                setState(() {
                  finish = true;
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
                  Navigator.pop(context, ['approve', mapDetailView]);
                });
              } else {
                setState(() {
                  finish = true;
                  pr.hide();
                });
                Alert(
                  context: context,
                  style: Utils.alertStyle,
                  type: AlertType.error,
                  title: "GAGAL",
                  desc: "Update Data gagal dilakukan",
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
                  Navigator.pop(context);
                });
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
        } else {
          setState(() {
            finish = true;
            pr.hide();
          });
          Alert(
            context: context,
            style: Utils.alertStyle,
            type: AlertType.error,
            title: "GAGAL",
            desc: "Update Data gagal dilakukan",
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
            Navigator.pop(context);
          });
        }
      } else {
        setState(() {
          finish = true;
          pr.hide();
        });
        Alert(
          context: context,
          style: Utils.alertStyle,
          type: AlertType.error,
          title: "GAGAL",
          desc: "Update Data gagal dilakukan",
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
          Navigator.pop(context);
        });
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

  void parseReject(String objectId) {
    ParseObject parseupdate = ParseObject(classname);
    parseupdate.set('objectId', objectId);
    parseupdate.set('status', 0);
    parseupdate.set('alasanReject', reasonController.text.trim());
    parseupdate.update().then((value) {
      if (value.statusCode == 200) {
        setState(() {
          finish = true;
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
          Navigator.pop(context, ['reject', mapDetailView]);
        });
      } else {
        setState(() {
          finish = true;
          pr.hide();
        });
        Alert(
          context: context,
          style: Utils.alertStyle,
          type: AlertType.error,
          title: "GAGAL",
          desc: "Update Data gagal dilakukan",
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
          Navigator.pop(context);
        });
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

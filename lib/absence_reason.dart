import 'package:attend_app/utils/Theme.dart';
import 'package:attend_app/utils/colors.dart';
import 'package:attend_app/widgets/navbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils/utils.dart';

class AbsenceReason extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AbsenceReasonState();
}

class AbsenceReasonState extends State<AbsenceReason> {
  SharedPreferences prefs;
  var reasonController = TextEditingController();

  String fullName = '';
  String nik = '';
  String description = '';
  String prefJamMasuk = '';
  String prefJamKeluar = '';
  DateTime dateAttend;

  List listAlasanTelat = [
    'Pilih Alasan...',
    'Kendala Perjalanan',
    'Urusan Pribadi',
    'Urusan Pekerjaan',
    'Lainnya',
  ];
  List listAlasanPulangCepat = [
    'Pilih Alasan...',
    'Sakit',
    'Urusan Pribadi',
    'Urusan Pekerjaan',
    'Lainnya',
  ];
  List listAlasanLembur = [
    'Pilih Alasan...',
    'Lembur',
    'Lainnya',
  ];

  List<DropdownMenuItem<String>> listDropItem;
  String currentAlasanItem;

  Color reasonFieldColor, reasonAreaColor;

  bool _otherVisible;
  int submitCode;

  ProgressDialog pr;

  @override
  void initState() {
    super.initState();
    pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(message: "CEK VALIDASI...");
    _loadDate();
    reasonFieldColor = reasonAreaColor = Colors.black;
    _otherVisible = false;
  }

  void _loadDate() async {
    String dateTime;
    String getTime;
    String desc;
    prefs = await SharedPreferences.getInstance();
    setState(() {
      fullName = prefs.getString('fullName');
      nik = prefs.getString('inputNik');
      dateTime = prefs.getString('dateAttend');
      dateAttend = DateTime.parse(dateTime);
      desc = prefs.getString('description');
      prefJamMasuk = prefs.getString('jamMasuk');
      prefJamKeluar = prefs.getString('jamKeluar');
      submitCode = prefs.getInt('submitCode');

      if (fullName == null) {
        fullName = '-';
      }
      if (nik == null) {
        nik = '-';
      }

      String descJamMasuk;
      if (prefJamMasuk.length > 1) {
        descJamMasuk = "$prefJamMasuk:00";
      } else {
        descJamMasuk = "0$prefJamMasuk:00";
      }

      String descJamKeluar = prefJamKeluar;
      if (prefJamKeluar.length > 1) {
        descJamKeluar = "$prefJamKeluar:00";
      } else {
        descJamKeluar = "0$prefJamKeluar:00";
      }

      // getTime = '${dateAttend.hour}:${dateAttend.minute}';
      getTime = DateFormat("HH:mm").format(dateAttend.toLocal());

      if (desc == 'Telat') {
        description =
            '$desc,\nwaktu saat anda melakukan absensi masuk:\n$getTime lebih dari $descJamMasuk';
        listDropItem = getDropDownMenuItems(listAlasanTelat);
      } else if (desc == 'PulangCepat') {
        description =
            'Pulang Cepat,\nwaktu saat anda melakukan absensi keluar:\n$getTime kurang dari $descJamKeluar';
        listDropItem = getDropDownMenuItems(listAlasanPulangCepat);
      } else if (desc == 'Lembur') {
        description =
            '$desc,\nwaktu saat anda melakukan absensi keluar:\n$getTime lebih dari $descJamKeluar';
        listDropItem = getDropDownMenuItems(listAlasanLembur);
      } else {
        description = '-';
      }
      currentAlasanItem = listDropItem[0].value;
    });
  }

  List<DropdownMenuItem<String>> getDropDownMenuItems(List getItems) {
    List<DropdownMenuItem<String>> items = new List();
    for (String item in getItems) {
      items.add(
        new DropdownMenuItem(
            value: item,
            child: Text(
              item,
              style: TextStyle(fontSize: 14.0),
              overflow: TextOverflow.ellipsis,
              maxLines: 5,
            )),
      );
    }
    return items;
  }

  @override
  void dispose() {
    super.dispose();
    // reasonController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ArgonColors.bgColorScreen,
        appBar: Navbar(
          title: "INFORMASI ABSENSI",
          backButton: true,
          rightOptions: false,
        ),
//        appBar: AppBar(
//          elevation: 10.0,
////          shape: RoundedRectangleBorder(
////            borderRadius: BorderRadius.only(
////                bottomLeft: Radius.circular(15.0),
////                bottomRight: Radius.circular(15.0)),
////          ),
//          backgroundColor: white,
//          title: Text(
//            'INFORMASI ABSENSI',
//            style: TextStyle(color: teal),
//          ),
//          centerTitle: true,
//        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration:
//              BoxDecoration(gradient: LinearGradient(colors: [info, primary])),
              BoxDecoration(
                  image: DecorationImage(
                      alignment: Alignment.bottomCenter,
                      image: AssetImage("assets/images/onboard-background.png"),
                      fit: BoxFit.fitWidth
                  )
              ),
          child: _body(),
        ));
  }

  Widget _body() {
    return SingleChildScrollView(
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height / 50,
            ),
            Container(
              margin: const EdgeInsets.only(left: 5.0, right: 5.0),
              width: MediaQuery.of(context).size.width,
              child: Card(
                shadowColor: kAppSoftLightTeal,
                elevation: 20.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(left: 10.0, top: 10.0),
                      child: Text(
                        'Nama Lengkap :',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: info,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 25.0, top: 5.0),
                      child: Text(
                        fullName,
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10.0, top: 10.0),
                      child: Text(
                        'NIK :',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: info,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 25.0, top: 5.0),
                      child: Text(
                        nik,
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10.0, top: 10.0),
                      child: Text(
                        'Deskripsi :',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: info,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 25.0, top: 5.0),
                      child: Text(
                        description,
                        style: TextStyle(fontSize: 14.0),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 50,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 10.0, top: 10.0),
                      child: Text(
                        'Alasan :',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: info,
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 25.0, top: 5.0),
                      child: _spinner(
                          listDropItem, currentAlasanItem, reasonFieldColor),
                    ),
                    Visibility(
                      visible: _otherVisible,
                      child: _textArea(reasonAreaColor),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 25,
                    ),
                    _nextButton(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 25,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _spinner(
      List<DropdownMenuItem<dynamic>> items, dynamic firstValue, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.5,
      child: DropdownButton<String>(
        isExpanded: true,
        value: firstValue,
        items: items,
        iconEnabledColor: Colors.greenAccent,
        underline: Divider(
          color: color,
          thickness: 2.0,
        ),
        onChanged: (value) {
          setState(() {
            currentAlasanItem = value;
            if (value == listDropItem[0].value) {
              _otherVisible = false;
              reasonFieldColor = reasonAreaColor = Colors.black;
            } else if (value == listDropItem.last.value) {
              _otherVisible = true;
              reasonFieldColor = reasonAreaColor = Colors.black;
            } else {
              _otherVisible = false;
              reasonFieldColor = reasonAreaColor = Colors.black;
            }
          });
        },
      ),
    );
  }

  Widget _textArea(Color color) {
    return Center(
      child: Container(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        margin: const EdgeInsets.all(10.0),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            border: Border.all(color: color, width: 2.0),
            borderRadius: BorderRadius.all(Radius.circular(4.0))),
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

  Widget _nextButton() {
    return Container(
      child: Align(
        alignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.only(left: 10.0, right: 10.0),
          width: MediaQuery.of(context).size.width / 2,
          height: 50.0,
          child: RaisedButton(
            elevation: 5.0,
            child: Text("LANJUTKAN", style: TextStyle(color: ArgonColors.white, fontWeight: FontWeight.w600, fontSize: 16.0)),
            color: blueButton,
            onPressed: _formValidate,
            shape: RoundedRectangleBorder(
                side: BorderSide(
                    style: BorderStyle.solid, color: ArgonColors.primary, width: 2.0),
                borderRadius: BorderRadius.all(Radius.circular(4.0))),
          ),
        ),
      ),
    );
  }

  void _formValidate() {
    if (_otherVisible) {
      if (reasonController.text.trim() == '' ||
          reasonController.text.trim() == null) {
        setState(() {
          reasonAreaColor = Colors.red;
        });
      } else {
        // prefs.setString('reason', reasonController.text.trim());
        if (submitCode == 1) {
          prefs.setString('reasonMasuk', reasonController.text.trim());
          // setState(() {
          //   pr.show();
          // });
          // parseCheckValidation(submitCode);
          // Navigator.of(context).pushNamed('/radiusCheck');
          Navigator.of(context).pushNamed('/cameraVision');
        } else {
          prefs.setString('reasonKeluar', reasonController.text.trim());
          Navigator.of(context).pushNamed('/cameraSelfie');
          // Navigator.of(context).pushNamed('/cameraVision');
        }
      }
    } else {
      if (currentAlasanItem != listDropItem[0].value ||
          currentAlasanItem == '') {
        // prefs.setString('reason', currentAlasanItem);
        if (submitCode == 1) {
          prefs.setString('reasonMasuk', currentAlasanItem);
          // setState(() {
          //   pr.show();
          // });
          // parseCheckValidation(submitCode);
          // Navigator.of(context).pushNamed('/radiusCheck');
          Navigator.of(context).pushNamed('/cameraVision');
        } else {
          prefs.setString('reasonKeluar', currentAlasanItem);
          Navigator.of(context).pushNamed('/cameraSelfie');
          // Navigator.of(context).pushNamed('/cameraVision');
        }
      } else {
        setState(() {
          reasonFieldColor = Colors.red;
        });
      }
    }
  }

  void parseCheckValidation(int id) async {
    DateTime nowValidTime = await NTP.now().catchError((e) {
      setState(() {
        pr.hide();
      });
      Alert(
        context: context,
        style: Utils.alertStyle,
        type: AlertType.error,
        title: "KONEKSI BERMASALAH",
        desc: "Mohon cek koneksi anda",
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
    ParseUser user = await ParseUser.currentUser();

    ParseObject userValid;
    Map<String, dynamic> userValidMap;
    Map<String, dynamic> getDateFailed;
    ParseObject timeValid;
    Map<String, dynamic> timeMap;

    QueryBuilder<ParseObject> queryUserValidation =
        QueryBuilder<ParseObject>(ParseObject(('UserValidation')))
          ..whereEqualTo('userId', user)
          ..whereEqualTo('hasFailed', true)
          ..whereEqualTo('hasExpired', false);

    queryUserValidation.query().then((value) {
      if (value.statusCode == 200) {
        if (value.results != null) {
          userValid = value.results[0];
          userValidMap = Map<String, dynamic>.from(userValid.toJson());
          getDateFailed = Map<String, dynamic>.from(userValidMap['dateFailed']);
          ParseObject('AppSetting').getObject('eCKkuDGSvv').then((value) {
            timeValid = value.results[0];
            timeMap = Map<String, dynamic>.from(timeValid.toJson());
            DateTime userValidTime = DateTime.parse(getDateFailed['iso']);
            userValidTime = userValidTime.toLocal();
            double timer = timeMap['validationTimer'] / 60;
            int convertTimer = timer.toInt();
            DateTime datePlusFive = DateTime(
                userValidTime.year,
                userValidTime.month,
                userValidTime.day,
                userValidTime.hour,
                userValidTime.minute + convertTimer,
                userValidTime.second);
            if (value.statusCode == 200) {
              Duration timeValidDiff = nowValidTime.difference(userValidTime);
              if (timeValidDiff.inMinutes >= convertTimer) {
                ParseObject updateFailed = ParseObject('UserValidation');
                updateFailed.set('objectId', userValidMap['objectId']);
                updateFailed.set('hasFailed', false);
                updateFailed.set('hasExpired', true);
                updateFailed.update().then((value) {
                  if (value.statusCode == 200) {
                    setState(() {
                      pr.hide();
                    });
                    if (id == 1) {
                      Navigator.of(context).pushNamed('/cameraVision');
                      // Navigator.of(context).pushNamed('/radiusCheck');
                    } else {
                      Navigator.of(context).pushNamed('/cameraSelfie');
                      // Navigator.of(context).pushNamed('/cameraVision');
                    }
                  } else {
                    parseCheckValidation(id);
                  }
                }).catchError((e) {
                  setState(() {
                    pr.hide();
                  });
                  Alert(
                    context: context,
                    style: Utils.alertStyle,
                    type: AlertType.error,
                    title: "KONEKSI BERMASALAH",
                    desc: "Mohon cek koneksi anda",
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
                  pr.hide();
                });
                Alert(
                  context: context,
                  style: Utils.alertStyle,
                  type: AlertType.error,
                  title: "ALERT",
                  desc:
                      "Anda bisa melakukan absensi pada pukul\n${datePlusFive.hour}:${datePlusFive.minute}:${datePlusFive.second}",
                  buttons: [
                    DialogButton(
                      child: Text(
                        "OK",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      color: Colors.red,
                      radius: BorderRadius.circular(0.0),
                    ),
                  ],
                ).show();
              }
            } else {
              parseCheckValidation(id);
            }
          }).catchError((e) {
            setState(() {
              pr.hide();
            });
            Alert(
              context: context,
              style: Utils.alertStyle,
              type: AlertType.error,
              title: "KONEKSI BERMASALAH",
              desc: "Mohon cek koneksi anda",
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
            pr.hide();
          });
          if (id == 1) {
            Navigator.of(context).pushNamed('/cameraVision');
            // Navigator.of(context).pushNamed('/radiusCheck');
          } else {
            Navigator.of(context).pushNamed('/cameraSelfie');
            // Navigator.of(context).pushNamed('/cameraVision');
          }
        }
      } else {
        parseCheckValidation(id);
      }
    }).catchError((e) {
      Alert(
        context: context,
        style: Utils.alertStyle,
        type: AlertType.error,
        title: "KONEKSI BERMASALAH",
        desc: "Mohon cek koneksi anda",
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

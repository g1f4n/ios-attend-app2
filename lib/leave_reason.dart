import 'dart:io';

import 'package:attend_app/utils/Theme.dart';
import 'package:attend_app/utils/colors.dart';
import 'package:attend_app/utils/utils.dart';
import 'package:attend_app/widgets/navbar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeaveReason extends StatefulWidget {
  final String imageFilePath;

  const LeaveReason({Key key, this.imageFilePath}) : super(key: key);
  @override
  State<StatefulWidget> createState() => LeaveReasonState(imageFilePath);
}

class LeaveReasonState extends State<LeaveReason> {
  Geolocator geolocator = Geolocator();
  Position userPosition;
  String userLongitude;
  String userLatitude;

  ProgressDialog pr;
  final String imageFilePath;
  SharedPreferences prefs;
  var reasonController = TextEditingController();

  String fullName = '';
  String nik = '';
  String description = '';
  DateTime dateAttend;

  List descItems = [
    'Pilih Kategori Izin...',
    'Sakit',
    'Lainnya',
  ];
  List<DropdownMenuItem<String>> _listDescItem;
  String _currentDescItem;

  Color spinnerColor,
      reasonFieldColor,
      documentFieldColor,
      firstDateColor,
      lastDateColor;

  bool reasonVisible, documentVisible, sickVisible;

  bool spinnerValid, reasonValid, documentValid, totalDayValid, daySwitch;

  DateTime firstDate = DateTime.now();
  DateTime lastDate = DateTime.now();

  String firstDateDisplay = '--, --/--/--',
      lastDateDisplay = '--, --/--/--',
      prefFirst,
      prefLast,
      getRole,
      role;

  int totalDay = 0;

  LeaveReasonState(this.imageFilePath);

  @override
  void initState() {
    super.initState();
    _loadDate();
    reasonVisible = documentVisible = sickVisible =
        reasonValid = documentValid = totalDayValid = daySwitch = false;
    _listDescItem = getDropDownMenuItems(descItems);
    _currentDescItem = _listDescItem[0].value;
    spinnerColor = reasonFieldColor =
        documentFieldColor = firstDateColor = lastDateColor = Colors.black;

    pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(message: "MENGIRIM DATA...");

    if (imageFilePath != null) {
      _currentDescItem = _listDescItem[1].value;
      documentVisible = true;
      sickVisible = true;
      daySwitch = true;
    }
  }

  void _loadDate() async {
    String dateTime;
    prefs = await SharedPreferences.getInstance();
    setState(() {
      fullName = prefs.getString('fullName');
      nik = prefs.getString('inputNik');
      getRole = prefs.getString('roles');

      if (getRole == 'staff') {
        role = 'Staff';
      } else {
        role = 'Leader';
      }

      dateTime = prefs.getString('dateAttend');
      dateAttend = DateTime.parse(dateTime);

      prefFirst = prefs.getString('firstDate');
      prefLast = prefs.getString('lastDate');

      if (prefFirst == '-' || prefFirst == null) {
        firstDateDisplay = '--, --/--/--';
      } else {
        firstDateDisplay =
            DateFormat("EE, dd/MM/yyyy ").format(DateTime.parse(prefFirst));
        firstDate = DateTime.parse(prefFirst);
      }
      if (prefLast == '-' || prefLast == null) {
        lastDateDisplay = '--, --/--/--';
      } else {
        lastDateDisplay =
            DateFormat("EE, dd/MM/yyyy ").format(DateTime.parse(prefLast));
        lastDate = DateTime.parse(prefLast);
        if (firstDate == lastDate) {
          totalDay = 1;
        } else {
          totalDay = lastDate.difference(firstDate).inDays + 1;
        }
      }

      if (fullName == null) {
        fullName = '-';
      }
      if (nik == null) {
        nik = '-';
      }

      description = DateFormat("EE, dd/MM/yyyy 'at' HH:mm")
          .format(DateTime.parse(dateTime));
    });
  }

  Future<bool> _showAlert(
      {int id, AlertType alertType, String alertTitle, String alertDesc}) {
    return alertType != null
        ? Alert(
            type: alertType,
            context: context,
            style: Utils.alertStyle,
            title: alertTitle,
            desc: alertDesc,
            buttons: [
              DialogButton(
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: () {
                  if (id == 0) {
                    prefs.setString('firstDate', '-');
                    prefs.setString('lastDate', '-');
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/home$role', (Route<dynamic> route) => false);
                  } else if (id == 1) {
                    Navigator.of(context).pop();
                  }
                },
                color: Color.fromRGBO(0, 179, 134, 1.0),
                radius: BorderRadius.circular(0.0),
              ),
            ],
          ).show()
        : Alert(
            image: Image.asset("assets/images/loc_service.jpg"),
            context: context,
            style: Utils.alertStyle,
            title: alertTitle,
            desc: alertDesc,
            buttons: [
              DialogButton(
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: () => Navigator.of(context).pop(),
                color: Color.fromRGBO(0, 179, 134, 1.0),
                radius: BorderRadius.circular(0.0),
              ),
            ],
          ).show();
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
    reasonController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArgonColors.bgColorScreen,
      appBar: Navbar(
        title: "INFORMASI IZIN",
        backButton: true,
        rightOptions: false,
      ),
//      appBar: AppBar(
//        elevation: 10.0,
////        shape: RoundedRectangleBorder(
////          borderRadius: BorderRadius.only(
////              bottomLeft: Radius.circular(25.0),
////              bottomRight: Radius.circular(25.0)),
////        ),
//        backgroundColor: white,
//        title: Text(
//          'INFORMASI IZIN',
//          style: TextStyle(color: teal),
//        ),
//        centerTitle: true,
//      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration:
//            BoxDecoration(gradient: LinearGradient(colors: [info, primary])),
        BoxDecoration(
            image: DecorationImage(
                alignment: Alignment.bottomCenter,
                image: AssetImage("assets/images/onboard-background.png"),
                fit: BoxFit.fitWidth
            )
        ),
        child: _body(),
      ),
    );
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
                        child: _spinner(
                            _listDescItem, _currentDescItem, spinnerColor)),
                    Container(
                      margin: const EdgeInsets.only(left: 10.0, top: 10.0),
                      child: Text(
                        'Waktu Pengajuan Izin :',
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
                    Visibility(
                      visible: sickVisible,
                      child: Container(
                        margin: const EdgeInsets.only(left: 10.0, top: 10.0),
                        child: Text(
                          'Lama Hari Izin Sakit :',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: info,
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: sickVisible,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            child: Text('1 Hari'),
                          ),
                          Container(
                            child: Switch(
                              value: daySwitch,
                              onChanged: (value) {
                                setState(() {
                                  daySwitch = value;
                                  if (value) {
                                    documentVisible = true;
                                  } else {
                                    documentVisible = false;
                                  }
                                });
                              },
                            ),
                          ),
                          Container(
                            child: Text('> 1 Hari'),
                          ),
                        ],
                      ),
                    ),
                    Stack(
                      children: <Widget>[
                        Visibility(
                          visible: reasonVisible,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 10.0, top: 10.0),
                                child: Text(
                                  'Alasan :',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: info,
                                  ),
                                ),
                              ),
                              _textArea(reasonFieldColor),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: documentVisible,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 10.0, top: 10.0),
                                child: Row(
                                  children: <Widget>[
                                    Container(
                                      width:
                                          MediaQuery.of(context).size.width / 6,
                                      child: Text(
                                        'Dari',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: info,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width /
                                          15,
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
                                          left: 5.0,
                                          right: 5.0,
                                          top: 5.0,
                                          bottom: 5.0),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: firstDateColor,
                                              width: 2.0),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0))),
                                      child: Text(
                                        firstDateDisplay,
                                        style: TextStyle(fontSize: 14.0),
                                      ),
                                    ),
                                    Container(
                                      child: IconButton(
                                        splashColor: Colors.black,
                                        icon:
                                            Icon(Icons.date_range, color: blue),
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
                                      width:
                                          MediaQuery.of(context).size.width / 6,
                                      child: Text(
                                        'Sampai',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                          color: info,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: MediaQuery.of(context).size.width /
                                          15,
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
                                          left: 5.0,
                                          right: 5.0,
                                          top: 5.0,
                                          bottom: 5.0),
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: lastDateColor, width: 2.0),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5.0))),
                                      child: Text(
                                        lastDateDisplay,
                                        style: TextStyle(fontSize: 14.0),
                                      ),
                                    ),
                                    Container(
                                      child: IconButton(
                                        icon:
                                            Icon(Icons.date_range, color: blue),
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
                                margin: const EdgeInsets.only(
                                    left: 10.0, top: 10.0),
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
                              SizedBox(
                                height: MediaQuery.of(context).size.height / 50,
                              ),
                              Container(
                                margin: const EdgeInsets.only(
                                    left: 10.0, top: 10.0),
                                child: Text(
                                  'Alasan :',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: info,
                                  ),
                                ),
                              ),
                              _takePhoto('Lampirkan foto surat dokter',
                                  documentFieldColor, imageFilePath),
                            ],
                          ),
                        ),
                      ],
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
            _currentDescItem = value;
            if (value == descItems[0]) {
              reasonVisible = false;
              documentVisible = false;
              daySwitch = false;
              sickVisible = false;
              reasonFieldColor = Colors.black;
              documentFieldColor = Colors.black;
            } else if (value == descItems[1]) {
              reasonVisible = false;
              sickVisible = true;
              spinnerColor = Colors.black;
            } else {
              spinnerColor = Colors.black;
              documentVisible = false;
              daySwitch = false;
              reasonVisible = true;
              sickVisible = false;
            }
          });
        },
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
          prefs.setString('firstDate', firstDate.toString());
        } else if (id == 1) {
          lastDate = picked;
          lastDateDisplay = DateFormat("EE, dd/MM/yyyy ").format(lastDate);
          prefs.setString('lastDate', lastDate.toString());
          if (firstDate == lastDate) {
            totalDay = 1;
          } else {
            totalDay = lastDate.difference(firstDate).inDays + 1;
          }
        }
      });
    }
  }

  Widget _takePhoto(
    String labelText,
    Color color,
    String image,
  ) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 10.0),
        width: MediaQuery.of(context).size.width / 1.25,
        height: MediaQuery.of(context).size.height / 2.5,
        decoration: BoxDecoration(
            border: Border.all(color: color, width: 2.0),
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(10),
              child: Text(
                labelText,
                style: TextStyle(fontFamily: "Montserrat", color: blue),
              ),
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width / 1.4,
                height: MediaQuery.of(context).size.height / 3.2,
                decoration: BoxDecoration(
                    border: Border.all(color: color, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: Container(
                        child: image == null
                            ? Container()
                            : Image.file(File(image)),
                      ),
                    ),
                    Center(
                      child: Container(
                          alignment: Alignment.bottomCenter,
                          child: RaisedButton(
                            elevation: 0,
                            color: Colors.transparent,
                            onPressed: () {
                              Navigator.of(context)
                                  .pushReplacementNamed('/cameraFile');
                            },
                            child: Icon(
                              Icons.camera_alt,
                              size: 50.0,
                              color: blue,
                            ),
                          )),
                    ),
                  ],
                ),
              ),
            )
          ],
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
            child: Text("LANJUTKAN", style: TextStyle(color: Colors.white)),
            color: blueButton,
            onPressed: () {
              _formValidate();
              if (spinnerValid) {
                if (reasonVisible) {
                  if (reasonValid) {
                    _getUserLocation();
                  }
                } else if (sickVisible) {
                  if (daySwitch) {
                    if (documentValid && totalDayValid) {
                      _getUserLocation();
                    }
                  } else {
                    _getUserLocation();
                  }
                }
              }
            },
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
    setState(() {
      if (_currentDescItem == descItems[0]) {
        spinnerColor = Colors.red;
      } else {
        prefs.setString('descItem', _currentDescItem);
        spinnerValid = true;
      }
      if (reasonVisible) {
        if (reasonController.text.trim() != '') {
          prefs.setString('reason', reasonController.text.trim());
          reasonFieldColor = Colors.black;
          reasonValid = true;
        } else {
          reasonFieldColor = Colors.red;
        }
      }
      if (documentVisible) {
        if (imageFilePath == '' || imageFilePath == null) {
          documentFieldColor = Colors.red;
        } else {
          documentValid = true;
        }
        if (totalDay == 0 || totalDay < 0) {
          lastDateColor = Colors.red;
        } else {
          totalDayValid = true;
          lastDateColor = Colors.black;
        }
      }
    });
  }

  Future _getUserLocation() {
    return geolocator.isLocationServiceEnabled().then((locationService) {
      if (locationService) {
        print("true");
        setState(() {
          pr.show();
        });
        geolocator
            .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
            .then((Position position) {
          setState(() {
            userPosition = position;
            userLatitude = userPosition.latitude.toString();
            userLongitude = userPosition.longitude.toString();
          });
          _parseIzin();
        }).catchError((e) {
          _showAlert(
              id: 1,
              alertType: AlertType.warning,
              alertDesc: "Mohon berikan akses lokasi, terima kasih",
              alertTitle: "Izin Akses Aplikasi");
          setState(() {
            userPosition = null;
          });
        });
      } else {
        _showAlert(
            id: 1,
            alertDesc: "Mohon nyalakan servis lokasi pada smartphone anda",
            alertTitle: "Servis Lokasi Mati");
      }
    });
  }

  void _parseIzin() async {
    DateTime now = await NTP.now().catchError((e) {
      setState(() {
        pr.hide();
      });
      _showAlert(
        id: 1,
        alertType: AlertType.error,
        alertTitle: 'GAGAL',
        alertDesc: 'Mohon periksa koneksi anda\ndan\nkirim lagi data anda',
      );
    });
    ParseFile parseImage;
    ParseUser user = await ParseUser.currentUser();
    String roles = user.get('roles');
    ParseObject leaderId;

    switch (roles) {
      case 'staff':
        leaderId = user.get("leaderIdNew");
        break;
      case 'leader':
        leaderId = user.get("supervisorID");
        break;
      case 'supervisor':
        leaderId = user.get("managerID");
        break;
      case 'manager':
        leaderId = user.get("headID");
        break;
      case 'head':
        leaderId = user.get("gmID");
        break;
      case 'gm':
        leaderId = user;
        break;
      default:
    }
    DateTime sendLastDate;

    ParseObject izin = ParseObject('Izin');
    izin.set("fullname", fullName);
    izin.set<ParseUser>("user", user);
    izin.set("leaderIdNew", leaderId);
    izin.set("date", dateAttend.toUtc());
    izin.set("descIzin", _currentDescItem);
    izin.set("longitude", userLongitude);
    izin.set("latitude", userLatitude);
    izin.set('statusIzin', 1);
    if (reasonVisible) {
      if (reasonController.text.trim() != '-') {
        sendLastDate = DateTime(now.year, now.month, now.day);
        izin.set("alasanIzin", reasonController.text.trim());
      }
    }
    if (sickVisible) {
      if (daySwitch) {
        if (imageFilePath == '-' || imageFilePath == null) {
        } else {
          parseImage = ParseFile(File(imageFilePath));
          sendLastDate = lastDate;
          izin.set<ParseFile>("attachFile", parseImage);
        }
        izin.set("alasanIzin", '-');
        izin.set("dari", firstDate.toUtc());
        izin.set("sampai", sendLastDate.toUtc());
      } else {
        sendLastDate = DateTime(now.year, now.month, now.day);
        izin.set("alasanIzin", 'izin sakit satu hari');
        izin.set("dari", DateTime(now.year, now.month, now.day).toUtc());
        izin.set("sampai", sendLastDate.toUtc());
      }
    }
    izin.save().then((value) {
      if (value.statusCode == 201) {
        prefs.setString('lastLeaveDate', sendLastDate.toString());
        prefs.setBool('hasIzin', true);
        if (imageFilePath == '-' || imageFilePath == null) {
        } else {
          if (File(imageFilePath).existsSync()) {
            File(imageFilePath).deleteSync();
          }
        }
        setState(() {
          pr.hide();
        });
        _showAlert(
          id: 0,
          alertType: AlertType.success,
          alertTitle: 'BERHASIL',
          alertDesc:
              'Permohonan izin berhasil terkirim, mohon tunggu konfirmasi leader anda',
        );
      } else {
        setState(() {
          pr.hide();
        });
        _showAlert(
          id: 1,
          alertType: AlertType.error,
          alertTitle: 'GAGAL',
          alertDesc: 'Mohon periksa koneksi anda\ndan\nkirim lagi data anda',
        );
      }
    }).catchError((e) {
      setState(() {
        pr.hide();
      });
      _showAlert(
        id: 1,
        alertType: AlertType.error,
        alertTitle: 'GAGAL',
        alertDesc: 'Mohon periksa koneksi anda\ndan\nkirim lagi data anda',
      );
    });
  }
}

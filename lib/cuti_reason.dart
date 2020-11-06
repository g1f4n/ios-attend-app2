import 'package:attend_app/utils/Theme.dart';
import 'package:attend_app/utils/colors.dart';
import 'package:attend_app/utils/utils.dart';
import 'package:attend_app/widgets/navbar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CutiReason extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CutiReasonState();
}

class CutiReasonState extends State<CutiReason> {
  Geolocator geolocator = Geolocator();
  Position userPosition;
  String userLongitude;
  String userLatitude;

  ProgressDialog pr;
  SharedPreferences prefs;
  var reasonController = TextEditingController();

  String fullName = '';
  String nik = '';
  String description = '';
  DateTime dateAttend;

  List descItems = [
    'Pilih Kategori Cuti...',
    'Cuti Tahunan',
    'Cuti di Luar Tanggungan',
  ];
  List<DropdownMenuItem<String>> _listDescItem;
  String _currentDescItem;

  Color spinnerColor, reasonFieldColor, firstDateColor, lastDateColor;

  bool reasonVisible;

  bool spinnerValid, reasonValid, totalDayValid;

  DateTime firstDate = DateTime.now();
  DateTime lastDate = DateTime.now();

  String firstDateDisplay = '--, --/--/--',
      lastDateDisplay = '--, --/--/--',
      getRole,
      role;

  int totalDay = 0;
  int totalCuti;

  @override
  void initState() {
    super.initState();
    _loadDate();
    _loadCuti();
    reasonVisible = reasonValid = totalDayValid = false;
    _listDescItem = getDropDownMenuItems(descItems);
    _currentDescItem = _listDescItem[0].value;
    spinnerColor =
        reasonFieldColor = firstDateColor = lastDateColor = Colors.black;
    pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(message: "MENGIRIM DATA...");
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

  void _loadCuti() async {
    ParseUser user = await ParseUser.currentUser();

    ParseObject('_User').getObject(user.objectId).then((value) {
      if (value.statusCode == 200) {
        ParseObject userObject = value.results[0];
        setState(() {
          totalCuti = userObject['jumlahCuti'];
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
          desc: 'Mohon periksa koneksi andaF',
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
        desc: 'Mohon periksa koneksi anda',
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
                onPressed: () {
                  Navigator.of(context).pop();
                },
                color: Color.fromRGBO(0, 179, 134, 1.0),
                radius: BorderRadius.circular(0.0),
              ),
            ],
          ).show();
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
        title: "INFORMASI CUTI",
        backButton: true,
        rightOptions: false,
      ),
//      appBar: AppBar(
//        elevation: 10.0,
////        shape: RoundedRectangleBorder(
////          borderRadius: BorderRadius.only(
////              bottomLeft: Radius.circular(15.0),
////              bottomRight: Radius.circular(15.0)),
////        ),
//        backgroundColor: white,
//        title: Text(
//          'INFORMASI CUTI',
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
                        'Waktu Pengajuan Cuti :',
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
                                border: Border.all(
                                    color: firstDateColor, width: 2.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4.0))),
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
                                border: Border.all(
                                    color: lastDateColor, width: 2.0),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4.0))),
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
                    Container(
                      margin: const EdgeInsets.only(left: 10.0, top: 10.0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            child: Text(
                              'Sisa cuti : ',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: info,
                              ),
                            ),
                          ),
                          Container(
                            child: totalCuti == null
                                ? Container(
                                    width: 15.0,
                                    height: 15.0,
                                    child: CircularProgressIndicator(),
                                  )
                                : Text(
                                    totalCuti.toString(),
                                    style: TextStyle(fontSize: 14.0),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 50,
                    ),
                    Visibility(
                      visible: reasonVisible,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin:
                                const EdgeInsets.only(left: 10.0, top: 10.0),
                            child: Text(
                              'Alasan :',
                              style: TextStyle(
                                fontSize: 16.0,
                                color: info,
                              ),
                            ),
                          ),
                          _textArea(reasonFieldColor)
                        ],
                      ),
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
              reasonFieldColor = Colors.black;
            } else {
              spinnerColor = Colors.black;
              reasonVisible = true;
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
              if (reasonVisible) {
                if (spinnerValid && reasonValid && totalDayValid) {
                  _getUserLocation();
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
        spinnerValid = false;
      } else {
        spinnerValid = true;
      }
      if (reasonVisible) {
        if (reasonController.text.trim() != '') {
          reasonValid = true;
          reasonFieldColor = Colors.black;
        } else {
          reasonValid = false;
          reasonFieldColor = Colors.red;
        }
      }
      if (totalDay == 0 || totalDay < 0) {
        lastDateColor = Colors.red;
        totalDayValid = false;
      } else {
        totalDayValid = true;
        lastDateColor = Colors.black;
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
          _parseCuti();
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

  void _parseCuti() async {
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

    if (totalCuti < totalDay) {
      _showAlert(
        id: 1,
        alertType: AlertType.error,
        alertTitle: 'GAGAL',
        alertDesc:
            'Hari Cuti yang anda miliki tidak mencukupi.\nHari cuti anda sebanyak : $totalCuti hari',
      ).then((value) {
        setState(() {
          pr.hide();
        });
      });
    } else {
      // prefs.setInt('jumlahCuti', totalCuti);

      // ParseObject parseUser = ParseObject('_User');
      // parseUser.set('objectId', user['objectId']);
      // parseUser.set('jumlahCuti', totalCuti);
      // parseUser.update().then((value) {
      //   if (value.statusCode == 200) {
      ParseObject cuti = ParseObject('Izin');
      cuti.set("fullname", fullName);
      cuti.set<ParseUser>("user", user);
      cuti.set("leaderIdNew", leaderId);
      cuti.set("date", dateAttend.toUtc());
      cuti.set("dari", firstDate.toUtc());
      cuti.set("sampai", lastDate.toUtc());
      cuti.set("descIzin", _currentDescItem);
      cuti.set("longitude", userLongitude);
      cuti.set("latitude", userLatitude);
      cuti.set("alasanIzin", reasonController.text.trim());
      cuti.set('statusIzin', 2);
      cuti.save().then((value) {
        if (value.statusCode == 201) {
          prefs.setString('lastCutiDate', lastDate.toString());
          prefs.setBool('hasCuti', true);
          setState(() {
            pr.hide();
          });
          _showAlert(
            id: 0,
            alertType: AlertType.success,
            alertTitle: 'BERHASIL',
            alertDesc:
                'Permohonan cuti berhasil terkirim, mohon tunggu konfirmasi leader anda',
          );
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

    // } else {
    //   setState(() {
    //     pr.hide();
    //   });
    //   Alert(
    //     context: context,
    //     style: Utils.alertStyle,
    //     type: AlertType.error,
    //     title: 'GAGAL',
    //     desc: 'Mohon periksa koneksi anda\ndan\nkirim lagi data anda',
    //     buttons: [
    //       DialogButton(
    //         child: Text(
    //           "OK",
    //           style: TextStyle(color: Colors.white, fontSize: 20),
    //         ),
    //         onPressed: () {
    //           setState(() {
    //             pr.hide();
    //           });
    //           Navigator.of(context).pop();
    //         },
    //         color: Color.fromRGBO(0, 179, 134, 1.0),
    //         radius: BorderRadius.circular(0.0),
    //       ),
    //     ],
    //   ).show();
    // }
    // }).catchError((e) {
    //   setState(() {
    //     pr.hide();
    //   });
    //   Alert(
    //     context: context,
    //     style: Utils.alertStyle,
    //     type: AlertType.error,
    //     title: 'GAGAL',
    //     desc: 'Mohon periksa koneksi anda\ndan\nkirim lagi data anda',
    //     buttons: [
    //       DialogButton(
    //         child: Text(
    //           "OK",
    //           style: TextStyle(color: Colors.white, fontSize: 20),
    //         ),
    //         onPressed: () {
    //           setState(() {
    //             pr.hide();
    //           });
    //           Navigator.of(context).pop();
    //         },
    //         color: Color.fromRGBO(0, 179, 134, 1.0),
    //         radius: BorderRadius.circular(0.0),
    //       ),
    //     ],
    //   ).show();
    // });
  }
}

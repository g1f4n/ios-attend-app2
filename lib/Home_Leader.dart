import 'package:attend_app/utils/Theme.dart';
import 'package:attend_app/utils/colors.dart';
import 'package:attend_app/utils/utils.dart';
import 'package:attend_app/widgets/navbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeLeader extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomeLeaderState();
}

class HomeLeaderState extends State<HomeLeader> {
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  ProgressDialog pr;
  String fullName,
      inputNik,
      password,
      userImagePath,
      roles,
      role,
      lembur,
      jamKerja;
  bool hasAttend = false,
      hasAttendFinish = false,
      hasIzin = false,
      hasCuti = false;
  SharedPreferences prefs;

  DateTime dateAttend;

  DateTime pointTime, timeHasAttend, timeHasFinishAttend, timeIzin, timeCuti;
  DateFormat checkFormat, timeFormat;

  int jamMasuk, jamKeluar;
  String prefJamMasuk, prefJamKeluar;

  Future<bool> _confirmLogout() {
    return Alert(
      context: context,
      style: Utils.alertStyle,
      type: AlertType.warning,
      title: "Logout",
      desc: "Logout akan menghapus data login anda. Yakin logout?",
      buttons: [
        DialogButton(
          child: Text(
            "Tidak",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          color: Colors.blue,
          radius: BorderRadius.circular(0.0),
        ),
        DialogButton(
          child: Text(
            "Ya",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () {
            prefs.setBool("hasLogin", false);
            prefs.setString('fullName', '');
            prefs.setString('inputNik', '');
            prefs.setString('password', '');
            prefs.setString('roles', '');
            ParseUser user = ParseUser(inputNik, password, '');
            user.logout();
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/login', (Route<dynamic> route) => false);
          },
          color: Colors.red,
          radius: BorderRadius.circular(0.0),
        ),
      ],
    ).show();
  }

  @override
  void initState() {
    super.initState();
    pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(message: "CEK VALIDASI...");
    getDataProfile();
  }

  void getDataProfile() async {
    prefs = await SharedPreferences.getInstance();
    DateTime now = await NTP.now().catchError((e) {
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
    setState(() {
      checkFormat = DateFormat.yMd();
      timeFormat = DateFormat.yMd();
      fullName = prefs.getString('fullName');
      inputNik = prefs.getString('inputNik');
      password = prefs.getString('password');
      roles = prefs.getString('roles');
      if (roles == 'staff') {
        role = 'Staff';
      } else {
        role = 'Leader';
      }
      lembur = prefs.getString('lembur');
      jamKerja = prefs.getString('jamKerja');
      userImagePath = prefs.getString('imageLoginPath');
      prefJamMasuk = prefs.getString('jamMasuk');
      prefJamKeluar = prefs.getString('jamKeluar');
      jamMasuk = int.parse(prefJamMasuk);
      jamKeluar = int.parse(prefJamKeluar);
      // jamMasuk = int.parse(prefJamMasuk.split(':').first);
      // jamKeluar = int.parse(prefJamKeluar.split(':').first);
      bool getHasAttend = prefs.getBool('hasAttend');
      bool getHasAttendFinish = prefs.getBool('hasAttendFinish');
      bool getHasIzin = prefs.getBool('hasIzin');
      bool getHasCuti = prefs.getBool('hasCuti');
      pointTime = now.toLocal();

      String timeAbsence = prefs.getString('dateAttendMasuk');
      String timeAttendFinish = prefs.getString('dateAttendKeluar');
      String timeGetIzin = prefs.getString('lastLeaveDate');
      String timeGetCuti = prefs.getString('lastCutiDate');

      String checkDate;
      String hasAbsenceDate;
      String hasAttendFinishDate;
      int hasReqIzin;
      int hasReqCuti;

      if (timeAbsence != null) {
        timeHasAttend = DateTime.parse(timeAbsence).toLocal();

        checkDate = checkFormat.format(pointTime);
        hasAbsenceDate = timeFormat.format(timeHasAttend);
      }

      if (timeAttendFinish != null) {
        timeHasFinishAttend = DateTime.parse(timeAttendFinish).toLocal();

        checkDate = checkFormat.format(pointTime);
        hasAttendFinishDate = timeFormat.format(timeHasFinishAttend);
      }

      if (timeGetIzin != null) {
        DateTime checkLeavePoint =
            DateTime(pointTime.year, pointTime.month, pointTime.day);
        DateTime timeLeaveP = DateTime.parse(timeGetIzin).toLocal();
        timeIzin = DateTime(timeLeaveP.year, timeLeaveP.month, timeLeaveP.day);

        hasReqIzin = timeIzin.difference(checkLeavePoint).inDays;
      }

      if (timeGetCuti != null && timeGetCuti != '') {
        DateTime checkCutiPoint =
            DateTime(pointTime.year, pointTime.month, pointTime.day);
        DateTime timeCutiP = DateTime.parse(timeGetCuti).toLocal();
        timeCuti = DateTime(timeCutiP.year, timeCutiP.month, timeCutiP.day);

        hasReqCuti = timeCuti.difference(checkCutiPoint).inDays;
      }

      if (getHasAttend == null) {
        hasAttend = false;
      } else {
        if (getHasAttend) {
          if (checkDate == hasAbsenceDate) {
            hasAttend = true;
          } else {
            prefs.setBool('hasAttend', false);
            hasAttend = false;
          }
        }
      }

      if (getHasAttendFinish == null) {
        hasAttendFinish = false;
      } else {
        if (getHasAttendFinish) {
          if (checkDate == hasAttendFinishDate) {
            hasAttendFinish = true;
          } else {
            prefs.setBool('hasAttendFinish', false);
            hasAttendFinish = false;
          }
        }
      }

      if (getHasIzin == null) {
        hasIzin = false;
      } else {
        if (getHasIzin) {
          if (hasReqIzin >= 0) {
            hasIzin = true;
          } else {
            prefs.setBool('hasIzin', false);
            hasIzin = false;
          }
        }
      }

      if (getHasCuti == null) {
        hasCuti = false;
      } else {
        if (getHasCuti) {
          if (hasReqCuti >= 0) {
            hasCuti = true;
          } else {
            prefs.setBool('hasCuti', false);
            hasCuti = false;
          }
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _homePage();
  }

  Widget _homePage() {
    return Scaffold(
      key: _key,
      backgroundColor: ArgonColors.bgColorScreen,
      extendBodyBehindAppBar: true,
      appBar: Navbar(
        title: "HOME",
        rightOptions: false,
        transparent: true,
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
//          "HOME",
//          style: TextStyle(color: teal),
//        ),
//        centerTitle: true,
//        leading: IconButton(
//          icon: Icon(
//            Icons.menu,
//            color: teal,
//          ),
//          onPressed: () {
//            _key.currentState.openDrawer();
//          },
//        ),
//      ),
      drawer: Utils.drawer(context, userImagePath, fullName, inputNik, _confirmLogout),
      body: _gridHome(),
    );
  }

  Widget _gridHome() {
    return Container(
      decoration:
//          BoxDecoration(gradient: LinearGradient(colors: [info, primary])),
      BoxDecoration(
          image: DecorationImage(
              alignment: Alignment.topCenter,
              image: AssetImage("assets/images/profile-screen-bg.png"),
              fit: BoxFit.fitWidth
          )
      ),
      child: GridView.count(
        crossAxisCount: 2,
        children: <Widget>[
          _gridItem(1, 'Absen Masuk', Icons.date_range, hasAttend),
          _gridItem(
              2, 'Absen Keluar', Icons.assignment_return, hasAttendFinish),
          _gridItem(3, 'Izin', Icons.library_books, hasIzin),
          _gridItem(4, 'Cuti', Icons.calendar_today, hasCuti),
          _gridItem(5, 'Daftar Absensi', Icons.view_list, false),
          _gridItem(6, 'Daftar Request', Icons.view_agenda, false),
          _gridItem(7, 'Dashboard', Icons.dashboard, false),
        ],
      ),
    );
  }

  Widget _gridItem(int id, String labelText, IconData icons, bool func) {
    return Container(
      margin: const EdgeInsets.all(20.0),
      child: Material(
        color: Colors.white,
        shadowColor: kAppSoftLightTeal,
        type: MaterialType.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 15.0,
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
          splashColor: kAppLigthTeal,
          child: Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  icons,
                  size: 100.0,
                  color: func ? Colors.black38 : teal,
                ),
                Text(
                  labelText,
                  style: TextStyle(
                    color: func ? Colors.black38 : teal,
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                )
              ],
            ),
          ),
          onTap: func
              ? null
              : () {
                  _gridItemFunction(id);
                },
        ),
      ),
    );
  }

  void _gridItemFunction(int id) async {
    dateAttend = await NTP.now().catchError((e) {
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
    prefs.setString('dateAttend', dateAttend.toString());
    int hour = dateAttend.hour;
    if (id == 1) {
      prefs.setString('dateAttendMasuk', dateAttend.toString());
      prefs.setInt('submitCode', 1);
      if (hour >= jamMasuk) {
        if (hasAttend) {
        } else {
          if (jamKerja == 'Jam fleksibel') {
            prefs.setString('description', 'OnTime');
            // setState(() {
            //   pr.show().whenComplete(() {
            //     parseCheckValidation(1);
            //   });
            // });
            // Navigator.of(context).pushNamed('/radiusCheck');
            Navigator.of(context).pushNamed('/cameraVision');
          } else {
            prefs.setString('description', 'Telat');
            Navigator.of(context).pushNamed('/absenceReason');
          }
        }
      } else {
        prefs.setString('description', 'OnTime');
        if (hasAttend) {
        } else {
          // setState(() {
          //   pr.show().whenComplete(() {
          //     parseCheckValidation(1);
          //   });
          // });
          // Navigator.of(context).pushNamed('/radiusCheck');
          Navigator.of(context).pushNamed('/cameraVision');
        }
      }
    } else if (id == 2) {
      prefs.setString('dateAttendKeluar', dateAttend.toString());
      prefs.setInt('submitCode', 2);
      if (hasAttend) {
        if (hour < jamKeluar) {
          prefs.setString('description', 'PulangCepat');
          Navigator.of(context).pushNamed('/absenceReason');
        } else if (hour >= jamKeluar + 1) {
          prefs.setString('description', 'Lembur');
          if (lembur == 'ya') {
            Navigator.of(context).pushNamed('/absenceReason');
          } else if (lembur == 'tidak') {
            Alert(
              context: context,
              style: Utils.alertStyle,
              type: AlertType.warning,
              title: "INFORMASI",
              desc: "Akun anda tidak diperkenankan untuk melakukan lembur",
              buttons: [
                DialogButton(
                  child: Text(
                    "Ya",
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  color: Colors.red,
                  radius: BorderRadius.circular(0.0),
                ),
              ],
            ).show();
          }
        } else {
          prefs.setString('description', 'OnTime');
          Navigator.of(context).pushNamed('/cameraSelfie');
          // setState(() {
          //   pr.show().whenComplete(() {
          //     parseCheckValidation(2);
          //   });
          // });
        }
      } else {
        Alert(
          context: context,
          style: Utils.alertStyle,
          type: AlertType.warning,
          title: "INFORMASI",
          desc: "Mohon untuk absen masuk terlebih dahulu",
          buttons: [
            DialogButton(
              child: Text(
                "Ya",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              color: Colors.red,
              radius: BorderRadius.circular(0.0),
            ),
          ],
        ).show();
      }
    } else if (id == 3) {
      prefs.setString('dateIzin', dateAttend.toString());
      prefs.setInt('submitCode', 3);
      prefs.setString('firstDate', '-');
      prefs.setString('lastDate', '-');
      Navigator.of(context).pushNamed('/leaveReason');
    } else if (id == 4) {
      prefs.setString('dateCuti', dateAttend.toString());
      prefs.setInt('submitCode', 4);
      Navigator.of(context).pushNamed('/cutiReason');
    } else if (id == 5) {
      Navigator.of(context).pushNamed('/display').then((value) {
        Navigator.of(context).pushReplacementNamed('/home$role');
      });
    } else if (id == 6) {
      Navigator.of(context).pushNamed('/requestList');
    } else if (id == 7) {
      Navigator.of(context).pushNamed('/dashboard');
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
                      Navigator.of(context).pushNamed('/cameraVision');
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
            Navigator.of(context).pushNamed('/cameraVision');
          }
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
  }
}

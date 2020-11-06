import 'dart:io';
import 'dart:math';

// import 'package:android_multiple_identifier/android_multiple_identifier.dart';
import 'package:attend_app/api/apiService.dart';
import 'package:attend_app/utils/Theme.dart';
import 'package:attend_app/utils/colors.dart';
import 'package:attend_app/utils/utils.dart';
import 'package:attend_app/widgets/navbar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Submit extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SubmitState();
}

class SubmitState extends State<Submit> {
  Geolocator geolocator = Geolocator();
  Position userPosition;
  String userLongitude;
  String userLatitude;

  ProgressDialog pr;
  String filename;
  int submitCode, radiusAbsen;

  SharedPreferences prefs;
  String fullName,
      nik,
      dateAttend,
      imageSelfiePath,
      imageFilePath,
      reasonMasuk,
      reasonKeluar,
      time,
      desc;
  String name, distance, message;
  DateTime timeAttend;
  bool done = false;
  bool retake = false;

  String title = 'KIRIM DATA';

  String descItem = '';

  String _platformImei = 'unknown';

  String getRole, role, officeName, officeLong, officeLat;

  List<String> alertMessageList = [
    'Ingat,\nbahwa Kesuksesan tidak diperoleh\nhanya dalam semalam.',
    'Keberhasilan dalam kehidupan\nhanya bisa didapatkan ketika seseorang\nmau berjuang dengan keras.',
    'Tak ada rahasia untuk menggapai sukses.\nSukses itu dapat terjadi karena persiapan, kerja keras,\ndan mau belajar dari kegagalan.',
    'Kamu harus berjuang untuk mencapai impianmu.\nKamu harus berkorban dan bekerja keras untuk\nimpian tersebut.',
    'Dalam kesuksesan,\nkemauan kamu untuk sukses harus lebih besar\ndaripada ketakutan anda akan kegagalan.',
    'Menetapkan tujuan adalah\nlangkah pertama dalam mengubah yang\ntak terlihat menjadi terlihat.'
  ];

  int randomMessage = 0;

  @override
  void initState() {
    super.initState();
    // notif = Notifications();
    // notif.initializing();
    pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(message: "MENGIRIM DATA...");
    _loadData();
    generateRandomNumber();
  }

  // void getUniqueId() async {
  //   Utils().getAndroidVersion().then((value) {
  //     if (value >= 29) {
  //       _platformImei = prefs.getString('uniqueId');
  //       if (_platformImei != null) {
  //       } else {
  //         _showAlert(
  //           alertType: AlertType.error,
  //           alertTitle: "ERROR",
  //           alertDesc:
  //               "Unique ID ataupun Imei tidak bisa didapatkan.\nMohon laporkan error ini",
  //         );
  //       }
  //     } else {
  //       _getImei();
  //     }
  //   });
  // }
  void getUniqueId() async {
    if (Platform.isAndroid) {
      Utils().getAndroidVersion().then((value) {
        if (value >= 29) {
          _platformImei = prefs.getString('uniqueId');
          if (_platformImei != null) {
          } else {
            _showAlert(
              alertType: AlertType.error,
              alertTitle: "ERROR",
              alertDesc:
                  "Unique ID ataupun Imei tidak bisa didapatkan.\nMohon laporkan error ini",
            );
          }
        } else {
          _getImei();
        }
      }).catchError((error) {
        _getImei();
      });
    } else if (Platform.isIOS) {
      _platformImei = prefs.getString('uniqueId');
      if (_platformImei != null) {
      } else {
        _showAlert(
          alertType: AlertType.error,
          alertTitle: "ERROR",
          alertDesc:
              "Unique ID ataupun Imei tidak bisa didapatkan.\nMohon laporkan error ini",
        );
      }
    }
  }

  void generateRandomNumber() {
    var random = new Random();

    randomMessage = random.nextInt(5);
  }

  void _loadData() async {
    prefs = await SharedPreferences.getInstance();
    getUniqueId();
    setState(
      () {
        submitCode = prefs.getInt('submitCode');
        if (submitCode == 1 || submitCode == 2) {
          title = 'MENGIRIMKAN DATA ABSEN';
        } else {
          title = 'MENGIRIMKAN DATA IZIN';
        }

        fullName = prefs.getString("fullName");
        nik = prefs.getString("inputNik");
        desc = prefs.getString('description');
        getRole = prefs.getString('roles');
        officeName = prefs.getString('officeName');
        officeLong = prefs.getString('officeLong');
        officeLat = prefs.getString('officeLat');
        radiusAbsen = prefs.getInt('radiusAbsen');

        if (getRole == 'staff') {
          role = 'Staff';
        } else {
          role = 'Leader';
        }

        dateAttend = prefs.getString('dateAttend');
        timeAttend = DateTime.parse(dateAttend);
        time =
            '${timeAttend.day}-${timeAttend.month}-${timeAttend.year}/${timeAttend.hour}:${timeAttend.minute}';

        imageSelfiePath = prefs.getString('imageSelfiePath');

        imageFilePath = prefs.getString('imageFilePath');
        descItem = prefs.getString('descItem');

        reasonMasuk = prefs.getString('reasonMasuk');
        if (reasonMasuk == null) {
          reasonMasuk = '-';
        }
        reasonKeluar = prefs.getString('reasonKeluar');
        if (reasonKeluar == null) {
          reasonKeluar = '-';
        }
        if (descItem == null) {
          descItem = '-';
        }
        if (imageFilePath == null) {
          imageFilePath = '-';
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _showAlert(
      {AlertType alertType, String alertTitle, String alertDesc}) {
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
                onPressed: () => Navigator.pop(context),
                color: blue,
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
                onPressed: () => Navigator.pop(context),
                color: blue,
                radius: BorderRadius.circular(0.0),
              ),
            ],
          ).show();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArgonColors.bgColorScreen,
//      appBar: Navbar(
//        title: title,
//        rightOptions: true,
//        backButton: true,
//      ),
      appBar: AppBar(
        elevation: 10.0,
//        shape: RoundedRectangleBorder(
//          borderRadius: BorderRadius.only(
//              bottomLeft: Radius.circular(15.0),
//              bottomRight: Radius.circular(15.0)),
//        ),
        backgroundColor: ArgonColors.white,
        title: Text(
          title,
          style: TextStyle(fontSize: 18.0, color: ArgonColors.initial),
        ),
        centerTitle: false,
        titleSpacing: 0.0,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration:
//            BoxDecoration(gradient: LinearGradient(colors: [info, primary])),
            BoxDecoration(
                image: DecorationImage(
                    alignment: Alignment.bottomCenter,
                    image: AssetImage("assets/images/onboard-background.png"),
                    fit: BoxFit.fitWidth)),
        child: _body(),
      ),
    );
  }

  Widget _body() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height / 20,
          ),
          Container(
            margin: const EdgeInsets.only(left: 5.0, right: 5.0),
            width: MediaQuery.of(context).size.width,
            child: Card(
              shape: RoundedRectangleBorder(
//                side: BorderSide(color: teal),
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
              ),
              shadowColor: kAppSoftLightTeal,
              elevation: 20.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.only(
                        left: 20.0, top: 15.0, bottom: 10.0),
                    child: Text(
                      'FOTO SELFIE',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: info,
                      ),
                    ),
                  ),
                  imageSelfiePath != null
                      ? Container(
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.height / 2,
                          child: Image.file(File(imageSelfiePath)),
                        )
                      : Container(
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.person_outline,
                            size: 200.0,
                          ),
                        ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 25,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height / 10,
                width: MediaQuery.of(context).size.width / 2.5,
                child: Material(
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  color: ArgonColors.error,
                  elevation: 5.0,
                  shadowColor: kAppSoftLightTeal,
                  child: InkWell(
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(
                        "Ulangi Selfie",
                        style: TextStyle(fontSize: 18.0, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                    onTap: () {
                      if (File(imageSelfiePath).existsSync()) {
                        File(imageSelfiePath).deleteSync();
                      }
                      if (File(imageFilePath).existsSync()) {
                        File(imageFilePath).deleteSync();
                      }
                      if (!retake && !done) {
                        Navigator.of(context)
                            .pushReplacementNamed('/cameraSelfie');
                      } else if (retake) {
                        Navigator.of(context)
                            .pushReplacementNamed('/cameraSelfie');
                      } else {}
                    },
                  ),
                ),
              ),
              SizedBox(
                width: 10.0,
              ),
              Container(
                height: MediaQuery.of(context).size.height / 10,
                width: MediaQuery.of(context).size.width / 2.5,
                child: Material(
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                  color: ArgonColors.success,
                  elevation: 5.0,
                  shadowColor: kAppSoftLightTeal,
                  child: done == false
                      ? InkWell(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              "Kirimkan Data",
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          onTap: () {
                            _getUserLocation();
                          },
                        )
                      : InkWell(
                          child: Container(
                            alignment: Alignment.center,
                            child: Text(
                              retake == true ? '< Mohon ulangi' : "SELESAI",
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(50.0)),
                          onTap: retake == true
                              ? null
                              : () {
                                  if (File(imageSelfiePath).existsSync()) {
                                    File(imageSelfiePath).deleteSync();
                                  }
                                  if (File(imageFilePath).existsSync()) {
                                    File(imageFilePath).deleteSync();
                                  }
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      '/home$role',
                                      (Route<dynamic> route) => false);
                                },
                        ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Future _getImei() {
    // return AndroidMultipleIdentifier.checkPermission().then(
    //   (identifierPermission) {
    //     print(identifierPermission);
    //     if (identifierPermission == true) {
    //       AndroidMultipleIdentifier.imeiCode.then((imeiUser) {
    //         if (imeiUser != "returned null") {
    //           setState(() {
    //             _platformImei = imeiUser;
    //           });
    //         } else {
    //           setState(() {
    //             _platformImei = "Unknown";
    //           });
    //         }
    //       }).catchError((e) {
    //         setState(() {
    //           _platformImei = "Unknown";
    //         });
    //       });
    //     } else {
    //       AndroidMultipleIdentifier.requestPermission().then(
    //         (identifierPermission) {
    //           print(identifierPermission);
    //           if (identifierPermission == false) {
    //             _getImei();
    //           } else {
    //             _getImei();
    //           }
    //         },
    //       );
    //     }
    //   },
    // );
  }

  Future _getUserLocation() {
    return geolocator.isLocationServiceEnabled().then(
      (locationService) {
        if (locationService) {
          print("true");
          setState(
            () {
              pr.show();
            },
          );
          geolocator
              .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
              .then((Position position) {
            setState(
              () {
                userPosition = position;
                userLatitude = userPosition.latitude.toString();
                userLongitude = userPosition.longitude.toString();
              },
            );
            _attendData();
          }).catchError(
            (e) {
              print(e);
              setState(
                () {
                  pr.hide();
                },
              );
              _showAlert(
                  alertType: AlertType.warning,
                  alertDesc: "Mohon berikan akses lokasi, terima kasih",
                  alertTitle: "Izin Akses Aplikasi");
              setState(
                () {
                  userPosition = null;
                },
              );
            },
          );
        } else {
          setState(
            () {
              pr.hide();
            },
          );
          _showAlert(
              alertDesc: "Mohon nyalakan servis lokasi pada smartphone anda",
              alertTitle: "Servis Lokasi Mati");
        }
      },
    );
  }

  //Attend data membangdingkan sesuai imei

  void _attendData() {
    var response;
    ApiService().attendData(imageSelfiePath, filename, _platformImei).then(
      (value) {
        response = Map<String, dynamic>.from(value);
        print(response);
        print(response['status']);
        try {
          if (response['status'] == 1) {
            setState(() {
              name = response['name'].toString();
              distance = response['distance'].toString();
              message = response['message'].toString();
            });
            if (submitCode == 1) {
              if (desc == 'OnTime') {
                _parseAbsenMasuk();
              } else if (desc == 'Telat') {
                _parseTelat();
              }
            } else if (submitCode == 2) {
              if (desc == 'OnTime') {
                _parseAbsenKeluar();
              } else if (desc == 'PulangCepat') {
                _parsePulangCepat();
              } else if (desc == 'Lembur') {
                _parseLembur();
              }
            }
          } else if (response['status'] == -1) {
            setState(() {
              pr.hide();
              retake = true;
              done = true;
            });
            _showAlert(
                alertType: AlertType.error,
                alertDesc:
                    "Wajah anda tidak dikenali\nMohon untuk mengambil foto ulang.",
                alertTitle: 'TIDAK DIKENALI');
          } else if (response['status'] == -2) {
            setState(() {
              pr.hide();
              retake = true;
              done = true;
            });
            _showAlert(
                alertType: AlertType.error,
                alertDesc:
                    "Tidak ada wajah terdeteksi\nMohon untuk mengambil foto ulang.",
                alertTitle: 'Wajah Tidak Terdeteksi');
          } else if (response['status'] == 2) {
            setState(() {
              pr.hide();
              retake = true;
              done = true;
            });
            _showAlert(
                alertType: AlertType.error,
                alertDesc:
                    "Tidak ada foto yang terkirim\nMohon untuk mengambil foto ulang.",
                alertTitle: 'Invalid Photo');
          } else if (response['status'] == 3) {
            setState(() {
              pr.hide();
              done = true;
              retake = true;
            });
            _showAlert(
                alertType: AlertType.error,
                alertDesc:
                    "NIP tidak ada pada sistem. Mohon periksa NIP anda dan ulangi proses absensi.",
                alertTitle: "GAGAL");
          } else if (response['status'] == 5) {
            setState(() {
              pr.hide();
              done = true;
              retake = true;
            });
            _showAlert(
                alertType: AlertType.error,
                alertDesc:
                    "Data anda tidak ada dalam dataset. Mohon melakukan proses registrasi",
                alertTitle: "GAGAL");
          } else {
            setState(() {
              pr.hide();
            });
            _showAlert(
                alertType: AlertType.error,
                alertDesc: "Proses absensi gagal. Mohon cek koneksi anda.",
                alertTitle: "GAGAL");
          }
        } catch (e) {
          setState(() {
            pr.hide();
          });
          _showAlert(
              alertType: AlertType.error,
              alertDesc: "Proses absensi gagal. Mohon dicoba kembali.",
              alertTitle: "GAGAL");
        }
      },
    );
  }

  void _parseAbsenMasuk() async {
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

    ParseFile parseImage = ParseFile(File(imageSelfiePath));

    ParseObject absenMasuk = ParseObject('Absence');
    absenMasuk.set("fullname", fullName);
    absenMasuk.set("absenMasuk", timeAttend.toUtc());
    absenMasuk.set("longitude", userLongitude);
    absenMasuk.set("latitude", userLatitude);
    absenMasuk.set<ParseFile>("selfieImage", parseImage);
    absenMasuk.set<ParseUser>("user", user);
    absenMasuk.set("leaderIdNew", leaderId.toPointer());
    absenMasuk.save().then(
      (value) {
        if (value.statusCode == 201) {
          setState(
            () {
              pr.hide();
              retake = false;
              done = true;
            },
          );
          ParseObject response = value.results[0];
          prefs.setString('objectIdIn', response['objectId']);
          prefs.setBool('hasAttend', true);
          if (officeName == 'BEBAS (MOBILE)') {
            _showAlert(
                alertType: AlertType.success,
                alertDesc: alertMessageList[randomMessage].toString(),
                alertTitle: "BERHASIL TERKIRIM");
          } else {
            geolocator
                .distanceBetween(
                    double.parse(userLatitude),
                    double.parse(userLongitude),
                    double.parse(officeLat),
                    double.parse(officeLong))
                .then((value) {
              if (value > radiusAbsen.toDouble()) {
                prefs.setDouble('getDistanceBetween', value);
                Navigator.of(context).pushNamed('/radiusCheck');
              } else {
                _showAlert(
                    alertType: AlertType.success,
                    alertDesc: alertMessageList[randomMessage].toString(),
                    alertTitle: "BERHASIL TERKIRIM");
              }
            }).catchError((e) {
              setState(() {
                retake = true;
                done = true;
              });
              _showAlert(
                  alertType: AlertType.error,
                  alertDesc:
                      "Lokasi anda tidak bisa di tentukan.\nMohon untuk mengulangi kembali.",
                  alertTitle: "LOKASI TIDAK VALID");
            });
          }
        } else {
          setState(() {
            pr.hide();
            retake = true;
            done = true;
          });
          _showAlert(
              alertType: AlertType.error,
              alertDesc: "Mohon ulangi kembali",
              alertTitle: "GAGAL TERKIRIM");
        }
      },
    ).catchError((e) {
      setState(() {
        pr.hide();
        retake = true;
        done = true;
      });
      _showAlert(
          alertType: AlertType.error,
          alertDesc: "Mohon ulangi kembali",
          alertTitle: "GAGAL TERKIRIM");
    });
  }

  void _parseAbsenKeluar() async {
    String objectId = prefs.getString('objectIdIn');
    ParseObject absenKeluar = ParseObject('Absence');
    absenKeluar.set('objectId', objectId);
    absenKeluar.set("absenKeluar", timeAttend.toUtc());
    absenKeluar.update().then(
      (value) {
        if (value.statusCode == 200) {
          setState(
            () {
              pr.hide();
              retake = false;
              done = true;
            },
          );
          prefs.setBool('hasAttendFinish', true);
          _showAlert(
              alertType: AlertType.success,
              alertDesc: alertMessageList[randomMessage].toString(),
              alertTitle: "BERHASIL TERKIRIM");
        } else {
          setState(() {
            pr.hide();
            retake = true;
            done = true;
          });
          _showAlert(
              alertType: AlertType.error,
              alertDesc: "Mohon ulangi kembali",
              alertTitle: "GAGAL TERKIRIM");
        }
      },
    ).catchError((e) {
      setState(() {
        pr.hide();
        retake = true;
        done = true;
      });
      _showAlert(
          alertType: AlertType.error,
          alertDesc: "Mohon ulangi kembali",
          alertTitle: "GAGAL TERKIRIM");
    });
  }

  void _parseTelat() async {
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

    ParseFile parseImage = ParseFile(File(imageSelfiePath));

    ParseObject late = ParseObject('Absence');
    late.set("fullname", fullName);
    late.set<ParseUser>("user", user);
    late.set("leaderIdNew", leaderId);
    late.set("lateTimes", timeAttend.toUtc());
    late.set("approvalLate", 3);
    late.set("alasanMasuk", reasonMasuk);
    late.set<ParseFile>("selfieImage", parseImage);
    late.set("longitude", userLongitude);
    late.set("latitude", userLatitude);
    late.save().then(
      (value) {
        if (value.statusCode == 201) {
          setState(
            () {
              pr.hide();
              retake = false;
              done = true;
            },
          );
          ParseObject response = value.results[0];
          prefs.setString('objectIdIn', response['objectId']);
          prefs.setBool('hasAttend', true);
          if (officeName == 'BEBAS (MOBILE)') {
            _showAlert(
                alertType: AlertType.success,
                alertDesc: alertMessageList[randomMessage].toString(),
                alertTitle: "BERHASIL TERKIRIM");
          } else {
            geolocator
                .distanceBetween(
                    double.parse(userLatitude),
                    double.parse(userLongitude),
                    double.parse(officeLat),
                    double.parse(officeLong))
                .then((value) {
              if (value > radiusAbsen.toDouble()) {
                prefs.setDouble('getDistanceBetween', value);
                Navigator.of(context).pushNamed('/radiusCheck');
              } else {
                _showAlert(
                    alertType: AlertType.success,
                    alertDesc: alertMessageList[randomMessage].toString(),
                    alertTitle: "BERHASIL TERKIRIM");
              }
            }).catchError((e) {
              setState(() {
                retake = true;
                done = true;
              });
              _showAlert(
                  alertType: AlertType.error,
                  alertDesc:
                      "Lokasi anda tidak bisa di tentukan.\nMohon untuk mengulangi kembali.",
                  alertTitle: "LOKASI TIDAK VALID");
            });
          }
        } else {
          setState(() {
            pr.hide();
            retake = true;
            done = true;
          });
          _showAlert(
              alertType: AlertType.error,
              alertDesc: "Mohon ulangi kembali",
              alertTitle: "GAGAL TERKIRIM");
        }
      },
    ).catchError((e) {
      setState(() {
        pr.hide();
        retake = true;
        done = true;
      });
      _showAlert(
          alertType: AlertType.error,
          alertDesc: "Mohon ulangi kembali",
          alertTitle: "GAGAL TERKIRIM");
    });
  }

  void _parsePulangCepat() async {
    String objectId = prefs.getString('objectIdIn');
    // ParseUser user = await ParseUser.currentUser();

    // ParseFile parseImage = ParseFile(File(imageSelfiePath));

    ParseObject earlyLeave = ParseObject('Absence');
    // earlyLeave.set("fullname", fullName);
    // earlyLeave.set<ParseUser>("user", user);
    // earlyLeave.set("leaderId", user['leaderId']);
    // earlyLeave.set("leaderIdNew", user['leaderIdNew']);
    earlyLeave.set('objectId', objectId);
    earlyLeave.set("earlyTimes", timeAttend.toUtc());
    earlyLeave.set("approvalEarly", 3);
    earlyLeave.set("alasanKeluar", reasonKeluar);
    // earlyLeave.set<ParseFile>("imageSelfie", parseImage);
    // earlyLeave.set("longitude", userLongitude);
    // earlyLeave.set("latitude", userLatitude);
    earlyLeave.update().then(
      (value) {
        if (value.statusCode == 200) {
          setState(
            () {
              pr.hide();
              retake = false;
              done = true;
            },
          );
          prefs.setBool('hasAttendFinish', true);
          _showAlert(
              alertType: AlertType.success,
              alertDesc: alertMessageList[randomMessage].toString(),
              alertTitle: "BERHASIL TERKIRIM");
        } else {
          setState(() {
            pr.hide();
            retake = true;
            done = true;
          });
          _showAlert(
              alertType: AlertType.error,
              alertDesc: "Mohon ulangi kembali",
              alertTitle: "GAGAL TERKIRIM");
        }
      },
    ).catchError((e) {
      setState(() {
        pr.hide();
        retake = true;
        done = true;
      });
      _showAlert(
          alertType: AlertType.error,
          alertDesc: "Mohon ulangi kembali",
          alertTitle: "GAGAL TERKIRIM");
    });
  }

  void _parseLembur() async {
    String objectId = prefs.getString('objectIdIn');
    // ParseUser user = await ParseUser.currentUser();

    // ParseFile parseImage = ParseFile(File(imageSelfiePath));

    ParseObject overtime = ParseObject('Absence');
    // overtime.set("fullname", fullName);
    // overtime.set<ParseUser>("user", user);
    // overtime.set("leaderId", user['leaderId']);
    // overtime.set("leaderIdNew", user['leaderIdNew']);
    overtime.set('objectId', objectId);
    overtime.set("overtimeOut", timeAttend.toUtc());
    overtime.set("approvalOvertime", 3);
    overtime.set("alasanKeluar", reasonKeluar);
    // overtime.set<ParseFile>("imageSelfie", parseImage);
    // overtime.set("longitude", userLongitude);
    // overtime.set("latitude", userLatitude);
    overtime.update().then(
      (value) {
        if (value.statusCode == 200) {
          setState(
            () {
              pr.hide();
              retake = false;
              done = true;
            },
          );
          prefs.setBool('hasAttendFinish', true);
          _showAlert(
              alertType: AlertType.success,
              alertDesc: alertMessageList[randomMessage].toString(),
              alertTitle: "BERHASIL TERKIRIM");
        } else {
          setState(() {
            pr.hide();
            retake = true;
            done = true;
          });
          _showAlert(
              alertType: AlertType.error,
              alertDesc: "Mohon ulangi kembali",
              alertTitle: "GAGAL TERKIRIM");
        }
      },
    ).catchError((e) {
      setState(() {
        pr.hide();
        retake = true;
        done = true;
      });
      _showAlert(
          alertType: AlertType.error,
          alertDesc: "Mohon ulangi kembali",
          alertTitle: "GAGAL TERKIRIM");
    });
  }
}

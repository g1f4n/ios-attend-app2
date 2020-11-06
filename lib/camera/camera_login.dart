import 'dart:io';

// import 'package:android_multiple_identifier/android_multiple_identifier.dart';
import 'package:attend_app/api/apiService.dart';
import 'package:attend_app/utils/colors.dart';
import 'package:attend_app/utils/utils.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CameraLogin extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CameraLoginState();
}

class CameraLoginState extends State<CameraLogin> {
  Geolocator geolocator = Geolocator();
  Position userPosition;
  String userLongitude;
  String userLatitude;

  SharedPreferences prefs;
  ProgressDialog pr;

  CameraController cameraController;
  List cameras;
  int selectedCameraIdx;

  String name, distance, message, filename, imageLoginPath;

  String _platformImei = 'unknown';

  String nik, password;

  String roles;

  @override
  void initState() {
    super.initState();
    availableCameras().then(
      (availableCameras) {
        cameras = availableCameras;
        if (cameras.length > 0) {
          setState(() {
            selectedCameraIdx = 0;
          });

          _initCameraController(cameras[selectedCameraIdx]).then((void v) {});
        } else {
          print("No camera available");
        }
      },
    ).catchError(
      (err) {
        print("Error : $err.code\nError Message : $err.message");
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:
          BoxDecoration(gradient: LinearGradient(colors: [info, primary])),
      child: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height / 1.2,
            width: MediaQuery.of(context).size.width,
            child: _cameraPreview(context),
          ),
          Container(
            alignment: Alignment.center,
            height: MediaQuery.of(context).size.height / 6,
            child: Container(
              height: 100.0,
              width: 100.0,
              child: Material(
                color: Colors.white,
                elevation: 10.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  side: BorderSide(color: kAppSoftDarkBlue, width: 1.5),
                ),
                shadowColor: kAppSoftLightTeal,
                child: InkWell(
                  child: Icon(
                    Icons.camera,
                    size: 100.0,
                    color: kAppDarkYellow,
                  ),
                  splashColor: kAppLigthTeal,
                  customBorder: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: BorderSide(color: kAppLightBlue, width: 2.5),
                  ),
                  onTap: () {
                    _onCapturePressed(context);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future _initCameraController(CameraDescription cameraDescription) async {
    final availableCamera = await availableCameras();
    final frontCam = availableCamera[1];

    if (cameraController != null) {
      await cameraController.dispose();
    }

    cameraController = CameraController(frontCam, ResolutionPreset.high);

    cameraController.addListener(() {
      if (mounted) {
        setState(() {});
      }
      if (cameraController.value.hasError) {
        print("Camera error ${cameraController.value.errorDescription}");
      }
    });

    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      print(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  Widget _cameraPreview(context) {
    if (cameraController == null || !cameraController.value.isInitialized) {
      return const Center(
        child: Text(
          "LOADING",
          textAlign: TextAlign.center,
          style: TextStyle(
              color: Colors.black, fontSize: 20.0, fontWeight: FontWeight.w900),
        ),
      );
    }
    return AspectRatio(
      aspectRatio: cameraController.value.aspectRatio,
      child: Stack(
        children: <Widget>[
          CameraPreview(cameraController),
          Container(
            margin: const EdgeInsets.only(top: 50.0),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/selfie_ktp_trans.png"),
                    fit: BoxFit.cover)),
          )
        ],
      ),
    );
  }

  void _onCapturePressed(BuildContext context) async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      pr = new ProgressDialog(context,
          type: ProgressDialogType.Normal,
          isDismissible: false,
          showLogs: false);
      pr.style(message: "MENGIRIM DATA...");
      pr.show();
    });

    String date = DateTime.now().toString();
    List<String> lDate = date.split(" ");
    String times = lDate.last;
    List<String> lTime = times.split(".");
    String ddmmyy = lDate.first.replaceAll("-", "");
    String time = lTime.first.replaceAll(":", "");

    String filename = "login_" + ddmmyy + time + ".jpg";

    try {
      final path = join((await getExternalStorageDirectory()).path, filename);

      await cameraController.takePicture(path).then((value) {
        setState(() {
          imageLoginPath = path;
        });
        prefs.setString('imageLoginPath', path);
        getUniqueId(context);
      });
    } catch (e) {
      print(e);
    }
  }

  // void getUniqueId(BuildContext context) async {
  //   prefs = await SharedPreferences.getInstance();
  //   Utils().getAndroidVersion().then((value) {
  //     if (value >= 29) {
  //       _platformImei = prefs.getString('uniqueId');
  //       if (_platformImei != null) {
  //         _getUserLocation(context);
  //       } else {
  //         setState(() {
  //           pr.hide();
  //         });
  //         _showAlert(
  //           context: context,
  //           alertType: AlertType.error,
  //           alertTitle: "ERROR",
  //           alertDesc:
  //               "Unique ID ataupun Imei tidak bisa didapatkan.\nMohon laporkan error ini",
  //         );
  //       }
  //     } else {
  //       _getImei(context);
  //     }
  //   });
  // }
  void getUniqueId(BuildContext context) async {
    prefs = await SharedPreferences.getInstance();
    if (Platform.isAndroid) {
      Utils().getAndroidVersion().then((value) {
        if (value >= 29) {
          _platformImei = prefs.getString('uniqueId');
          if (_platformImei != null) {
            _getUserLocation(context);
          } else {
            setState(() {
              pr.hide();
            });
            _showAlert(
              context: context,
              alertType: AlertType.error,
              alertTitle: "ERROR",
              alertDesc:
                  "Unique ID ataupun Imei tidak bisa didapatkan.\nMohon laporkan error ini",
            );
          }
        } else {
          _getImei(context);
        }
      }).catchError((error) {
        _getImei(context);
      });
    } else if (Platform.isIOS) {
      _platformImei = prefs.getString('uniqueId');
      if (_platformImei != null) {
        _getUserLocation(context);
      } else {
        setState(() {
          pr.hide();
        });
        _showAlert(
          context: context,
          alertType: AlertType.error,
          alertTitle: "ERROR",
          alertDesc:
              "Unique ID ataupun Imei tidak bisa didapatkan.\nMohon laporkan error ini",
        );
      }
    }
  }

  Future _getImei(BuildContext context) {
    // return AndroidMultipleIdentifier.checkPermission()
    //     .then((identifierPermission) {
    //   print(identifierPermission);
    //   if (identifierPermission == true) {
    //     AndroidMultipleIdentifier.imeiCode.then((imeiUser) {
    //       if (imeiUser != "returned null") {
    //         setState(() {
    //           _platformImei = imeiUser;
    //         });
    //         _getUserLocation(context);
    //       } else {
    //         setState(() {
    //           _platformImei = "Unknown";
    //         });
    //         _getUserLocation(context);
    //       }
    //     }).catchError((e) {
    //       setState(() {
    //         _platformImei = "Unknown";
    //       });
    //       _getUserLocation(context);
    //     });
    //   } else {
    //     AndroidMultipleIdentifier.requestPermission()
    //         .then((identifierPermission) {
    //       print(identifierPermission);
    //       if (identifierPermission == false) {
    //         _getImei(context);
    //       } else {
    //         _getImei(context);
    //       }
    //     });
    //   }
    // });
  }

  Future _getUserLocation(BuildContext context) {
    return geolocator.isLocationServiceEnabled().then((locationService) {
      if (locationService) {
        print("true");
        geolocator
            .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
            .then((Position position) {
          setState(() {
            userPosition = position;
            userLatitude = userPosition.latitude.toString();
            userLongitude = userPosition.longitude.toString();
          });
          _attendData(context);
        }).catchError((e) {
          setState(() {
            pr.hide();
          });
          _showAlert(
              context: context,
              alertType: AlertType.warning,
              alertDesc: "Please turn on GPS permission thanks",
              alertTitle: "Permission");
          setState(() {
            userPosition = null;
          });
        });
      } else {
        setState(() {
          pr.hide();
        });
        _showAlert(
            context: context,
            alertDesc: "Please enable location service on your device",
            alertTitle: "Location Service is Off");
      }
    });
  }

  void _attendData(BuildContext context) {
    var response;
    ApiService()
        .attendData(imageLoginPath, filename, _platformImei)
        .then((value) {
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
          _queryUser(context);
        } else if (response['status'] == -1) {
          setState(() {
            pr.hide();
          });
          _showAlert(
              context: context,
              alertType: AlertType.error,
              alertDesc:
                  "Wajah anda tidak dikenali\nMohon untuk mengambil foto ulang.",
              alertTitle: 'TIDAK DIKENALI');
        } else if (response['status'] == -2) {
          setState(() {
            pr.hide();
          });
          _showAlert(
              context: context,
              alertType: AlertType.error,
              alertDesc:
                  "Tidak ada wajah yang terdeteksi\nMohon untuk mengambil foto ulang.",
              alertTitle: 'Wajah Tidak Terdeteksi');
        } else if (response['status'] == 2) {
          setState(() {
            pr.hide();
          });
          _showAlert(
              context: context,
              alertType: AlertType.error,
              alertDesc:
                  "Tidak ada foto yang terkirim\nMohon untuk mengambil foto ulang.",
              alertTitle: 'Foto Invalid');
        } else if (response['status'] == 3) {
          setState(() {
            pr.hide();
          });
          _showAlert(
              context: context,
              alertType: AlertType.error,
              alertDesc:
                  "NIP tidak ada pada sistem. Mohon periksa NIP anda dan ulangi proses absensi.",
              alertTitle: "GAGAL");
        } else if (response['status'] == 5) {
          setState(() {
            pr.hide();
          });
          _showAlert(
              context: context,
              alertType: AlertType.error,
              alertDesc: "Proses absensi gagal. Mohon dicoba kembali.",
              alertTitle:
                  "Data anda tidak ada dalam dataset. Mohon melakukan proses registrasi");
        } else {
          setState(() {
            pr.hide();
          });
          _showAlert(
              context: context,
              alertType: AlertType.error,
              alertDesc: "Proses absensi gagal. Mohon cek koneksi anda",
              alertTitle: "GAGAL");
        }
      } catch (e) {
        setState(() {
          pr.hide();
        });
        _showAlert(
            context: context,
            alertType: AlertType.error,
            alertDesc: "Proses absensi gagal. Mohon dicoba kembali.",
            alertTitle: "GAGAL");
      }
    });
  }

  void _queryUser(BuildContext context) async {
    QueryBuilder<ParseObject> queryUser =
        QueryBuilder<ParseObject>(ParseObject('_User'))
          ..whereEqualTo('imei', _platformImei)
          ..includeObject(['absenPoint', 'appSetting']);

    queryUser.query().then((value) {
      setState(() {
        if (value.statusCode == 200) {
          if (value.results != null) {
            ParseObject userInfo = value.results[0];
            Map<String, dynamic> userInfoMap =
                Map<String, dynamic>.from(userInfo.toJson());
            prefs.setString('fullName', userInfoMap['fullname'].toString());
            prefs.setString('inputNik', userInfoMap['username'].toString());
            prefs.setString(
                'password', userInfoMap['passwordClone'].toString());
            prefs.setString('roles', userInfoMap['roles'].toString());
            prefs.setInt('jumlahCuti', userInfoMap['jumlahCuti']);
            prefs.setString('lembur', userInfoMap['lembur'].toString());
            prefs.setString('jamKerja', userInfoMap['jamKerja'].toString());
            prefs.setString('jamMasuk', userInfoMap['jamMasuk'].toString());
            prefs.setString('jamKeluar', userInfoMap['jamKeluar'].toString());
            setState(() {
              nik = userInfoMap['username'].toString();
              password = userInfoMap['passwordClone'].toString();
              roles = userInfoMap['roles'].toString();
            });
            // Map<String, dynamic> shiftingUserMap =
            //     Map<String, dynamic>.from(userInfoMap['shifting']);
            // ParseObject('Shifting')
            //     .getObject(shiftingUserMap['objectId'])
            //     .then((value) {
            //   if (value.statusCode == 200) {

            String lokasiKerja = userInfoMap['lokasiKerja'].toString();

            if (lokasiKerja == 'Tetap') {
              ParseObject absentPoint = userInfo.get<ParseObject>('absenPoint');
              Map<String, dynamic> mapAbsenPoint =
                  Map<String, dynamic>.from(absentPoint.toJson());
              prefs.setString('officeName', mapAbsenPoint['placeName']);
              prefs.setString('officeLong', mapAbsenPoint['longitude']);
              prefs.setString('officeLat', mapAbsenPoint['latitude']);

              ParseObject appSetting = userInfo.get<ParseObject>('appSetting');
              Map<String, dynamic> mapAppSetting =
                  Map<String, dynamic>.from(appSetting.toJson());
              prefs.setInt('radiusAbsen', mapAppSetting['radiusAbsen']);
            } else {
              prefs.setString('officeName', 'BEBAS (MOBILE)');
              prefs.setString('officeLong', "0");
              prefs.setString('officeLat', "0");
              prefs.setInt('radiusAbsen', 0);
            }

            _navigateToHome(context);
            //   } else {
            //     pr.hide();
            //     _showAlert(
            //         context: context,
            //         alertType: AlertType.error,
            //         alertTitle: 'KONEKSI ERROR',
            //         alertDesc: 'Mohon check koneksi anda');
            //   }
            // }).catchError((e) {
            //   pr.hide();
            //   _showAlert(
            //       context: context,
            //       alertType: AlertType.error,
            //       alertTitle: 'KONEKSI ERROR',
            //       alertDesc: 'Mohon check koneksi anda');
            // });
          } else {
            pr.hide();
            _showAlert(
                context: context,
                alertType: AlertType.error,
                alertTitle: 'AKUN TIDAK DITEMUKAN',
                alertDesc: 'Akun anda tidak ada di database');
          }
        } else {
          pr.hide();
          _showAlert(
              context: context,
              alertType: AlertType.error,
              alertTitle: 'KONEKSI ERROR',
              alertDesc: 'Mohon check koneksi anda');
        }
      });
    }).catchError((e) {
      pr.hide();
      _showAlert(
          context: context,
          alertType: AlertType.error,
          alertTitle: 'ERROR',
          alertDesc: 'Mohon beritahukan admin');
    });
  }

  void _navigateToHome(BuildContext context) async {
    prefs = await SharedPreferences.getInstance();
    ParseUser user = ParseUser(nik, password, '');
    user.login().then((value) {
      if (value.statusCode == 200 && value.results != []) {
        prefs.setBool("hasLogin", true);
        setState(() {
          pr.hide();
        });
        if (roles == 'staff') {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/homeStaff', (Route<dynamic> route) => false);
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/homeLeader', (Route<dynamic> route) => false);
        }
      } else {}
    });
  }

  Future<bool> _showAlert(
      {AlertType alertType,
      String alertTitle,
      String alertDesc,
      BuildContext context}) {
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
                onPressed: () => Navigator.pop(context),
                color: Color.fromRGBO(0, 179, 134, 1.0),
                radius: BorderRadius.circular(0.0),
              ),
            ],
          ).show();
  }
}

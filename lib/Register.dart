import 'dart:convert';
import 'dart:io';

// import 'package:android_multiple_identifier/android_multiple_identifier.dart';
import 'package:attend_app/camera/camera_regist.dart';
import 'package:attend_app/utils/Theme.dart';
import 'package:attend_app/utils/colors.dart';
import 'package:attend_app/utils/utils.dart';
import 'package:attend_app/widgets/input.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Registration extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RegistrationState();
}

class RegistrationState extends State<Registration> {
  SharedPreferences prefs;
  ProgressDialog pr;
  String _pickedFile;
  bool imeiFailed = false, load = false;
  String _platformImei;

  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  TextEditingController controller3 = TextEditingController();
  TextEditingController controller4 = TextEditingController();

  Color imageColor, nameColor, emailColor, passColor, nikColor, tglColor;
  @override
  void initState() {
    super.initState();
    imageColor =
        nameColor = emailColor = passColor = nikColor = tglColor = Colors.black;
    pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(message: "Mengirimkan Data...");
    createUniqueId();
  }

  // void createUniqueId() async {
  //   prefs = await SharedPreferences.getInstance();
  //   Utils().getAndroidVersion().then((value) {
  //     if (value >= 29) {
  //       String id = prefs.getString('uniqueId');
  //       if (id != null) {
  //         _platformImei = id;
  //       } else {
  //         _platformImei = Utils().createCryptoRandomString();
  //         prefs.setString('uniqueId', _platformImei);
  //       }
  //     } else {
  //       _getImei();
  //     }
  //   });
  // }
  void createUniqueId() async {
    prefs = await SharedPreferences.getInstance();
    if (Platform.isAndroid) {
      Utils().getAndroidVersion().then((value) {
        if (value >= 29) {
          String id = prefs.getString('uniqueId');
          if (id != null) {
            _platformImei = id;
            print(_platformImei);
          } else {
            _platformImei = Utils().createCryptoRandomString();
            print(_platformImei);
            prefs.setString('uniqueId', _platformImei);
          }
        } else {
          _getImei();
        }
      }).catchError((error) {
        _getImei();
      });
    } else if (Platform.isIOS) {
      String id = prefs.getString('uniqueId');
      if (id != null) {
        _platformImei = id;
        print(_platformImei);
      } else {
        _platformImei = Utils().createCryptoRandomString();
        print(_platformImei);
        prefs.setString('uniqueId', _platformImei);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: EdgeInsets.all(20.0),
          height: MediaQuery.of(context).size.height / 1.2,
          width: MediaQuery.of(context).size.width,
          decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0))),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _imageDetailItem('FOTO SELFIE', imageColor),
                SizedBox(height: 10.0),
                _textDetailItem(
                    'Nama Lengkap', controller1, Icons.person, nameColor),
                _textDetailItem('Nomor Induk Karyawan', controller2,
                    Icons.credit_card, nikColor),
                _textDetailItem('Email', controller3, Icons.email, emailColor),
                _textDetailItem(
                    'Password', controller4, Icons.lock_outline, passColor),
                SizedBox(height: 20.0),
                _okButton(),
                SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _imageDetailItem(String label, Color color) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(
            top: 10.0, left: 10.0, right: 10.0, bottom: 0.5),
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
            Center(
              child: Container(
                margin: const EdgeInsets.only(
                    top: 10.0, left: 10.0, right: 10.0, bottom: 10.0),
                height: MediaQuery.of(context).size.height / 4,
                width: MediaQuery.of(context).size.width / 2,
                decoration: BoxDecoration(
                    border: Border.all(color: color, width: 1.0),
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                child: Stack(
                  children: <Widget>[
                    _pickedFile != null
                        ? Container(
                            alignment: Alignment.center,
                            child: Image.file(
                              File(_pickedFile),
                              fit: BoxFit.contain,
                            ),
                          )
                        : Container(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.person_outline,
                              size: 75.0,
                              color: Colors.grey,
                            ),
                          ),
                    Container(
                      alignment: Alignment.bottomRight,
                      child: FloatingActionButton(
                        elevation: 10.0,
                        backgroundColor: ArgonColors.primary,
                        child: Icon(Icons.add_photo_alternate),
                        onPressed: () {
                          Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CameraRegist()))
                              .then((value) {
                            print(value);
                            if (value != '' && value != null) {
                              setState(() {
                                _pickedFile = value;
                              });
                            } else {
                              _pickedFile = null;
                            }
                          });
                        },
                      ),
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

  Widget _textDetailItem(String label, TextEditingController controller,
      IconData icon, Color color) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(
            top: 10.0, bottom: 10.0, right: 25.0, left: 25.0),
        width: MediaQuery.of(context).size.width,
        child: Input(
          placeholder: label,
          controller: controller,
          borderColor: color,
          prefixIcon: Icon(
            icon,
            color: info,
          ),
        ),
        // Column(
        //   crossAxisAlignment: CrossAxisAlignment.start,
        //   children: <Widget>[
        //     Container(
        //       margin: const EdgeInsets.only(left: 10.0, top: 10.0),
        //       child: Text(
        //         label,
        //         style: TextStyle(
        //           fontSize: 16.0,
        //           color: info,
        //         ),
        //       ),
        //     ),
        //     Container(
        //       margin: const EdgeInsets.only(left: 15.0, top: 5.0, right: 15.0),
        //       padding: const EdgeInsets.only(left: 5.0),
        //       decoration: BoxDecoration(
        //           border: Border.all(color: color, width: 2.0),
        //           borderRadius: BorderRadius.all(Radius.circular(10.0))),
        //       child: TextField(
        //         keyboardType: textInputType,
        //         decoration: InputDecoration(
        //           hintText: hintText,
        //         ),
        //         controller: controller,
        //       ),
        //     ),
        //   ],
        // ),
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

  Widget _okButton() {
    return Container(
      child: Align(
        alignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.only(left: 10.0, right: 10.0),
          width: MediaQuery.of(context).size.width / 2,
          height: 50.0,
          child: RaisedButton(
            elevation: 5.0,
            child: load
                ? CircularProgressIndicator()
                : Text(
                    imeiFailed
                        ? 'Imei anda tidak bisa didapatkan.\nMohon ulangi kembali'
                        : "REGISTER",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: ArgonColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.0)),
            color: blueButton,
            onPressed: () {
              validation();
            },
            shape: RoundedRectangleBorder(
                side: BorderSide(
                    style: BorderStyle.solid,
                    color: ArgonColors.primary,
                    width: 2.0),
                borderRadius: BorderRadius.all(Radius.circular(4.0))),
          ),
        ),
      ),
    );
  }

  void validation() {
    setState(() {
      if (_pickedFile != null &&
          controller1.text.trim() != '' &&
          controller2.text.trim() != '' &&
          controller2.text.trim().length == 8 &&
          controller3.text.trim() != '' &&
          controller4.text.trim() != '' &&
          _platformImei != 'Unknown' &&
          _platformImei != null) {
        load = true;
        checkAccRegistExist();
      }
      if (_pickedFile == null) {
        imageColor = Colors.red;
      } else {
        imageColor = Colors.black;
      }
      if (controller1.text.trim() == '') {
        nameColor = Colors.red;
      } else {
        nameColor = Colors.black;
      }
      if (controller2.text.trim() == '' ||
          controller2.text.trim().length != 8) {
        nikColor = Colors.red;
      } else {
        nikColor = Colors.black;
      }
      if (controller3.text.trim() == '') {
        emailColor = Colors.red;
      } else {
        emailColor = Colors.black;
      }
      if (controller4.text.trim() == '') {
        passColor = Colors.red;
      } else {
        passColor = Colors.black;
      }
      if (_platformImei == 'Unknown' || _platformImei == null) {
        imeiFailed = true;
      } else {
        imeiFailed = false;
      }
    });
  }

  void checkAccRegistExist() {
    QueryBuilder<ParseObject> queryAccRegist =
        QueryBuilder<ParseObject>(ParseObject(('SelfRegist')))
          ..whereEqualTo('imei', _platformImei);

    queryAccRegist.query().then((value) {
      if (value.statusCode == 200) {
        if (value.results == null) {
          checkAccValidity();
        } else {
          setState(() {
            load = false;
          });
          Alert(
            context: context,
            style: Utils.alertStyle,
            type: AlertType.warning,
            title: "SUDAH MEREGISTRASI",
            desc: "Akun anda sedang dalam\nproses konfirmasi oleh admin",
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
          ).show().then((value) {
            if (File(_pickedFile).existsSync()) {
              File(_pickedFile).deleteSync();
            }
            Navigator.pop(context);
          });
        }
      } else {
        setState(() {
          load = false;
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
        ).show().then((value) {
          if (File(_pickedFile).existsSync()) {
            File(_pickedFile).deleteSync();
          }
          Navigator.pop(context);
        });
      }
    }).catchError((e) {
      setState(() {
        load = false;
      });
      Alert(
        context: context,
        style: Utils.alertStyle,
        type: AlertType.error,
        title: "ERROR",
        desc: "Terjadi masalah pada saat pengecekan.\Silahkan hubungi admin",
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
      ).show().then((value) {
        if (File(_pickedFile).existsSync()) {
          File(_pickedFile).deleteSync();
        }
        Navigator.pop(context);
      });
    });
  }

  void checkAccValidity() {
    QueryBuilder<ParseObject> queryAccount =
        QueryBuilder<ParseObject>(ParseObject(('_User')))
          ..whereEqualTo('imei', _platformImei);

    queryAccount.query().then((value) {
      if (value.statusCode == 200) {
        if (value.results == null) {
          parseSelfRegist();
        } else {
          setState(() {
            load = false;
          });
          Alert(
            context: context,
            style: Utils.alertStyle,
            type: AlertType.warning,
            title: "SUDAH TEREGISTRASI",
            desc: "Akun anda sudah teregistrasi",
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
          ).show().then((value) {
            if (File(_pickedFile).existsSync()) {
              File(_pickedFile).deleteSync();
            }
            Navigator.pop(context);
          });
        }
      } else {
        setState(() {
          load = false;
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
        ).show().then((value) {
          if (File(_pickedFile).existsSync()) {
            File(_pickedFile).deleteSync();
          }
          Navigator.pop(context);
        });
      }
    }).catchError((e) {
      setState(() {
        load = false;
      });
      Alert(
        context: context,
        style: Utils.alertStyle,
        type: AlertType.error,
        title: "ERROR",
        desc: "Terjadi masalah pada saat pengecekan.\Silahkan hubungi admin",
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
      ).show().then((value) {
        if (File(_pickedFile).existsSync()) {
          File(_pickedFile).deleteSync();
        }
        Navigator.pop(context);
      });
    });
  }

  void parseSelfRegist() {
    ParseFile parseImage = ParseFile(File(_pickedFile));

    var bytes = utf8.encode(controller4.text.trim());
    var hashedMd5 = md5.convert(bytes);

    ParseObject parseSelfRegist = ParseObject('SelfRegist');
    parseSelfRegist.set('fullname', controller1.text.trim());
    parseSelfRegist.set('nik', controller2.text.trim());
    parseSelfRegist.set('usernameClone', controller2.text.trim().toUpperCase());
    parseSelfRegist.set('passwordClone', hashedMd5.toString());
    parseSelfRegist.set('email', controller3.text.trim());
    parseSelfRegist.set('imei', _platformImei);
    parseSelfRegist.set<ParseFile>('fotoWajah', parseImage);
    parseSelfRegist.save().then((value) {
      if (value.statusCode == 201) {
        setState(() {
          load = false;
        });
        Alert(
          context: context,
          style: Utils.alertStyle,
          type: AlertType.success,
          title: "REGISTRASI BERHASIL",
          desc: "registrasi berhasil.\nMohon Tunggu konfirmasi di inbox!",
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
        ).show().then((value) {
          if (File(_pickedFile).existsSync()) {
            File(_pickedFile).deleteSync();
          }
          Navigator.pop(context);
        });
      } else {
        setState(() {
          load = false;
        });
        Alert(
          context: context,
          style: Utils.alertStyle,
          type: AlertType.error,
          title: "REGISTRASI GAGAl",
          desc: "registrasi gagal.\nMohon registrasi ulang!",
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
        ).show().then((value) {
          if (File(_pickedFile).existsSync()) {
            File(_pickedFile).deleteSync();
          }
          Navigator.pop(context);
        });
      }
    }).catchError((e) {
      setState(() {
        load = false;
      });
      Alert(
        context: context,
        style: Utils.alertStyle,
        type: AlertType.error,
        title: "REGISTRASI GAGAl",
        desc: "registrasi gagal.\nMohon registrasi ulang!",
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
      ).show().then((value) {
        if (File(_pickedFile).existsSync()) {
          File(_pickedFile).deleteSync();
        }
        Navigator.pop(context);
      });
    });
  }
}

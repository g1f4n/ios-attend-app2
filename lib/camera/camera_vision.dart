import 'dart:async';
import 'dart:math';

import 'package:attend_app/utils/colors.dart';
import 'package:attend_app/utils/scanner_utils.dart';
// import 'package:attend_app/utils/utils.dart';
import 'package:camera/camera.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
// import 'package:ntp/ntp.dart';
// import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CameraVision extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CameraVisionState();
}

class CameraVisionState extends State<CameraVision> {
  SharedPreferences prefs;
  CameraController cameraController;
  List cameras;
  int selectedCameraIdx;
  dynamic _scanResults;
  CameraImage img;

  bool _isDetecting = false;

  List<String> validateFramePath = [];
  List<String> labelCommand = [];
  int frameCount = 0;

  List<String> staticCommand = [
    'hadapKanan',
    'hadapKiri',
    'miringKanan',
    'miringKiri',
    'tersenyum'
  ];
  List<String> generateListCmd = [];
  List<String> newCommand = [];
  List<bool> commandValid = [];
  List<String> commandLabel = [
    "Hadapkan Wajah Anda ke Arah Kanan",
    "Hadapkan Wajah Anda ke Arah Kiri",
    "Miringkan Kepala ke Arah Kanan",
    "Miringkan Kepala Anda ke Arah Kiri",
    "Mohon Tersenyum ke Arah Kamera"
  ];
  String commandLabelView = "Tidak Ada Perintah Yang Diberikan", role;

  bool allValidate = false;
  bool cancelValidation = false;
  bool isCountdown = false;
  bool failValidate = false;
  bool failProgress = false;
  int countdown = 15;

  Color commandLabelColor = Colors.blue;

  final FaceDetector _faceDetector = FirebaseVision.instance
      .faceDetector(FaceDetectorOptions(enableClassification: true));

  @override
  void initState() {
    super.initState();
    newCommand = generateCommand();
    isCountdown = true;
    loadPref();
    starCountdown();
    init();
  }

  void loadPref() async {
    prefs = await SharedPreferences.getInstance();
    String getRole = prefs.getString('roles');
    if (getRole == 'staff') {
      role = 'Staff';
    } else {
      role = 'Leader';
    }
  }

  List<String> generateCommand() {
    var rng = Random();

    for (int i = 0; i < 3; i++) {
      generateListCmd.add(staticCommand[rng.nextInt(5)]);
      if (generateListCmd.length == 2) {
        checkSecondElement();
      }
      if (generateListCmd.length == 3) {
        checkThirdElement();
      }
    }

    return generateListCmd;
  }

  void checkSecondElement() {
    var rng = Random();
    if (generateListCmd[1] == generateListCmd[0]) {
      generateListCmd[1] = staticCommand[rng.nextInt(5)];
      checkSecondElement();
    } else {}
  }

  void checkThirdElement() {
    var rng = Random();
    if (generateListCmd[2] == generateListCmd[1] ||
        generateListCmd[2] == generateListCmd[0]) {
      generateListCmd[2] = staticCommand[rng.nextInt(5)];
      checkThirdElement();
    } else {}
  }

  void init() async {
    availableCameras().then((availableCameras) {
      cameras = availableCameras;
      if (cameras.length > 0) {
        setState(() {
          selectedCameraIdx = 0;
        });

        _initCameraController(cameras[selectedCameraIdx]).then((void v) {});
      } else {
        print("No camera available");
      }
    }).catchError((err) {
      print("Error : $err.code\nError Message : $err.message");
    });
  }

  Future _initCameraController(CameraDescription cameraDescription) async {
    final availableCamera = await availableCameras();
    final frontCam = availableCamera[1];

    if (cameraController != null) {
      await cameraController.dispose();
    }

    cameraController = CameraController(frontCam, ResolutionPreset.ultraHigh);

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
      startStream();
    } on CameraException catch (e) {
      print(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  Future<dynamic> Function(FirebaseVisionImage image) _getDetectionMethod() {
    return _faceDetector.processImage;
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose().then((value) {
      _faceDetector.close();
    });
  }

  void startStream() async {
    final CameraDescription description =
        await ScannerUtils.getCamera(CameraLensDirection.front);
    cameraController.startImageStream((img) {
      if (_isDetecting) return;

      _isDetecting = true;

      ScannerUtils.detect(
        image: img,
        detectInImage: _getDetectionMethod(),
        imageRotation: description.sensorOrientation,
      ).then(
        (results) {
          setState(() {
            _scanResults = results;
          });
        },
      ).whenComplete(() => _isDetecting = false);
      scanFace(img);
    }).then((value) {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration:
            BoxDecoration(gradient: LinearGradient(colors: [info, primary])),
        child: Column(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).size.height / 1.2,
                  width: MediaQuery.of(context).size.width,
                  child: _cameraPreview(context),
                ),
                cameraController != null
                    ? Container(
                        height: MediaQuery.of(context).size.height / 1.2,
                        width: MediaQuery.of(context).size.width,
                        alignment: Alignment.topCenter,
                        child: Container(
                            margin: const EdgeInsets.only(top: 50.0),
                            height: MediaQuery.of(context).size.height / 10,
                            width: MediaQuery.of(context).size.width,
                            alignment: Alignment.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                isCountdown == true
                                    ? Text(
                                        "Waktu Validasi : $countdown detik",
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 4,
                                        style: TextStyle(
                                            fontSize: 12.0,
                                            color: Colors.redAccent),
                                      )
                                    : Container(),
                                Text(
                                  commandLabelView,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 4,
                                  style: TextStyle(
                                      fontSize: 18.0, color: commandLabelColor),
                                ),
                              ],
                            )),
                      )
                    : Container(),
                failValidate == true
                    ? Container(
                        height: MediaQuery.of(context).size.height / 1.2,
                        width: MediaQuery.of(context).size.width,
                        child: Center(
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            height: MediaQuery.of(context).size.height / 5,
                            width: MediaQuery.of(context).size.width / 1.2,
                            child: failProgress == true
                                ? Container(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        CircularProgressIndicator(),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width /
                                              25,
                                        ),
                                        Text('Memproses Data'),
                                      ],
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(
                                        "VERIFIKASI WAJAH GAGAL.",
                                        textAlign: TextAlign.center,
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.red, fontSize: 16.0),
                                      ),
                                      Text(
                                        // "Mohon ulangi lagi setelah 5 menit",
                                        "Mohon ulangi lagi",
                                        textAlign: TextAlign.center,
                                        maxLines: 4,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 16.0),
                                      ),
                                      SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              50),
                                      Container(
                                        child: RaisedButton(
                                          child: Text(
                                            "OK",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pushNamedAndRemoveUntil(
                                                    '/home$role',
                                                    (Route<dynamic> route) =>
                                                        false);
                                          },
                                          color:
                                              Color.fromRGBO(0, 179, 134, 1.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
            Container(
              alignment: Alignment.center,
              height: MediaQuery.of(context).size.height / 6,
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  side: BorderSide(color: Colors.blue, width: 1.5),
                ),
                elevation: 10.0,
                color: Colors.white,
                child: Icon(
                  Icons.camera,
                  size: 75.0,
                  color: Colors.deepOrangeAccent,
                ),
                onPressed: allValidate == true
                    ? () {
                        _onCapturePressed(context);
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void starCountdown() {
    isCountdown = true;
    const oneSec = const Duration(seconds: 1);
    if (countdown > 0) {
      Timer.periodic(oneSec, (Timer timer) {
        if (allValidate || cancelValidation) {
          timer.cancel();
        }
        if (countdown <= 5 && commandValid.length == 0) {
          timer.cancel();
          setState(() {
            countdown = 15;
          });
          failFaceValidation(1);
        }
        if (countdown > 0) {
          setState(() {
            countdown = countdown - 1;
          });
        } else {
          timer.cancel();
          setState(() {
            countdown = 15;
          });
          if (!allValidate) {
            failFaceValidation(0);
          }
        }
      });
    } else {}
  }

  void setCommandLabel(String cmd) {
    setState(() {
      if (cmd == 'hadapKanan') {
        commandLabelView = commandLabel[0];
        commandLabelColor = Colors.deepOrange;
      } else if (cmd == 'hadapKiri') {
        commandLabelView = commandLabel[1];
        commandLabelColor = Colors.teal;
      } else if (cmd == 'miringKanan') {
        commandLabelView = commandLabel[2];
        commandLabelColor = Colors.blue;
      } else if (cmd == 'miringKiri') {
        commandLabelView = commandLabel[3];
        commandLabelColor = Colors.orange;
      } else if (cmd == 'tersenyum') {
        commandLabelView = commandLabel[4];
        commandLabelColor = Colors.purple;
      }
    });
  }

  bool faceDirectionCheck(String cmd, double rotY, double rotZ, double smile) {
    if (cmd == 'hadapKanan') {
      return rightFace(rotY);
    } else if (cmd == 'hadapKiri') {
      return leftFace(rotY);
    } else if (cmd == 'miringKanan') {
      return rightTiltFace(rotZ);
    } else if (cmd == 'miringKiri') {
      return leftTiltFace(rotZ);
    } else if (cmd == 'tersenyum') {
      return smileDetect(smile);
    } else {
      return false;
    }
  }

  void scanFace(CameraImage image) {
    double rotY;
    double rotZ;
    double smile;
    bool valid = false;

    if (newCommand.isNotEmpty && !failValidate) {
      setCommandLabel(newCommand[0]);
    }

    if (newCommand.isNotEmpty && !failValidate) {
      if (_scanResults != null && _scanResults != []) {
        for (Face face in _scanResults) {
          setCommandLabel(newCommand[0]);
          smile = face.smilingProbability * 100;
          rotY = face.headEulerAngleY;
          rotZ = face.headEulerAngleZ;
          valid = faceDirectionCheck(newCommand[0], rotY, rotZ, smile);

          if (valid) {
            setState(() {
              labelCommand.add(newCommand[0]);
              newCommand.removeAt(0);
              frameCount = frameCount + 1;
            });
            // cameraController.stopImageStream().whenComplete(() {
            //   _captureFrame(context);
            // });
          }
        }
      }
    } else {
      faceLiveValidation();
    }
  }

  void faceLiveValidation() {
    if (commandValid.length == 3) {
      if (commandValid[0] == true &&
          commandValid[1] == true &&
          commandValid[2] == true) {
        setState(() {
          cameraController.stopImageStream();
          allValidate = true;
          isCountdown = false;
          commandLabelColor = Colors.indigoAccent;
          commandLabelView =
              "Semua Perintah Sudah Tervalidasi Silahkan Ambil Selfie";
        });
      }
    }
  }

  void failFaceValidation(int code) {
    if (code == 0) {
      setState(() {
        cameraController.stopImageStream();
        isCountdown = false;
        failValidate = true;
        commandLabelColor = Colors.redAccent;
        commandLabelView = "Validasi perintah gagal. Silahkan coba kembali";
        // "Validasi perintah gagal. Silahkan kembali ke menu utama dan coba kembali";
      });
    } else {
      setState(() {
        cameraController.stopImageStream();
        labelCommand.add(newCommand[0]);
        // cameraController.stopImageStream().whenComplete(() {
        //   _captureFrame(context);
        // });
        isCountdown = false;
        failValidate = true;
        commandLabelColor = Colors.redAccent;
        commandLabelView = "Validasi perintah gagal. Silahkan coba kembali";
        // "Validasi perintah gagal. Silahkan kembali ke menu utama dan coba kembali";
      });
    }
    parseUserLiveValidation();
  }

  void parseUserLiveValidation() async {
    setState(() {
      // failProgress = true;
      failProgress = false;
    });
    // DateTime now = await NTP.now();
    // ParseUser user = await ParseUser.currentUser();

    // ParseObject('AppSetting').getObject('eCKkuDGSvv').then((value) {
    //   if (value.statusCode == 200) {
    //     ParseObject userValidation = ParseObject('UserValidation');
    //     userValidation.set("userId", user);
    //     userValidation.set("hasFailed", true);
    //     userValidation.set("dateFailed", now.toUtc());
    //     userValidation.save().then((value) {
    //       setState(() {
    //         failProgress = false;
    //       });
    //     }).catchError((e) {
    //       parseUserLiveValidation();
    //     });
    //   } else {
    //     parseUserLiveValidation();
    //   }
    // }).catchError((e) {
    //   parseUserLiveValidation();
    // });
  }

  bool rightFace(double faceRotY) {
    if (faceRotY < -20) {
      commandValid.add(true);

      return true;
    } else {
      return false;
    }
  }

  bool leftFace(double faceRotY) {
    if (faceRotY > 20) {
      commandValid.add(true);
      return true;
    } else {
      return false;
    }
  }

  bool rightTiltFace(double faceRotZ) {
    if (faceRotZ > 20) {
      commandValid.add(true);
      return true;
    } else {
      return false;
    }
  }

  bool leftTiltFace(double faceRotZ) {
    if (faceRotZ < -20) {
      commandValid.add(true);
      return true;
    } else {
      return false;
    }
  }

  bool smileDetect(double smile) {
    if (smile >= 60) {
      commandValid.add(true);
      return true;
    } else {
      return false;
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
            margin: const EdgeInsets.only(top: 100.0),
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/selfie_ktp_trans.png"),
                    fit: BoxFit.cover)),
          ),
        ],
      ),
    );
  }

  // void _captureFrame(context) async {
  //   String date = DateTime.now().toString();
  //   List<String> lDate = date.split(" ");
  //   String times = lDate.last;
  //   List<String> lTime = times.split(".");
  //   String ddmmyy = lDate.first.replaceAll("-", "");
  //   String time = lTime.first.replaceAll(":", "");

  //   String filename = "Frame_$frameCount" + "_" + ddmmyy + time + ".jpg";

  //   try {
  //     final path = join((await getExternalStorageDirectory()).path, filename);

  //     validateFramePath.add(path);
  //     cameraController.takePicture(path).then((value) {
  //       startStream();
  //     });
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  void _onCapturePressed(context) async {
    String nik = prefs.getString("inputNik");
    String date = DateTime.now().toString();
    List<String> lDate = date.split(" ");
    String times = lDate.last;
    List<String> lTime = times.split(".");
    String ddmmyy = lDate.first.replaceAll("-", "");
    String time = lTime.first.replaceAll(":", "");

    String filename = nik + "_" + ddmmyy + time + ".jpg";

    try {
      final path = join((await getExternalStorageDirectory()).path, filename);

      await cameraController.takePicture(path);

      validateFramePath.add(path);

      Navigator.of(context).pushNamed('/submit');
      prefs.setString('imageSelfiePath', path);
    } catch (e) {
      print(e);
    }
  }
}

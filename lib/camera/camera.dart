import 'package:attend_app/utils/colors.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CameraSelfie extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CameraSelfieState();
}

class CameraSelfieState extends State<CameraSelfie> {
  SharedPreferences prefs;

  CameraController cameraController;
  List cameras;
  int selectedCameraIdx;
  String imagePath;

  @override
  void initState() {
    super.initState();
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

    _loadData();
  }

  void _loadData() async {
    prefs = await SharedPreferences.getInstance();
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
              )),
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

      prefs.setString('imageSelfiePath', path);
      Navigator.of(context).pushNamed('/submit');
    } catch (e) {
      print(e);
    }
  }
}

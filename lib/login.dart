import 'dart:io';
import 'dart:ui';

import 'package:attend_app/Register.dart';
import 'package:attend_app/utils/Theme.dart';
import 'package:attend_app/utils/colors.dart';
import 'package:attend_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:ntp/ntp.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LoginState();
}

class LoginState extends State<Login> {
  SharedPreferences prefs;
  String inputNik, inputPass;
  String prefsName, prefsNik;
  var _inputNik = TextEditingController();
  var _inputPass = TextEditingController();

  bool isRegister = false;

  DateTime now;

  @override
  void initState() {
    super.initState();
    loadDate();
    requestPermission();
  }

  // void requestPermission() async {
  //   Map<Permission, PermissionStatus> statuses = await [
  //     Permission.location,
  //     Permission.storage,
  //     Permission.camera,
  //     Permission.microphone,
  //     Permission.phone,
  //   ].request();
  // }
  void requestPermission() async {
    if (Platform.isAndroid) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.storage,
        Permission.camera,
        Permission.microphone,
        Permission.phone,
      ].request();
    } else if (Platform.isIOS) {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.photos,
        Permission.camera,
        Permission.microphone,
      ].request();
    }
  }

  void loadDate() async {
    prefs = await SharedPreferences.getInstance();
    bool hasLogin = prefs.getBool('hasLogin');
    if (hasLogin == null || !hasLogin) {
      DateTime getNow = await NTP.now().catchError((e) {
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
              color: blue,
              radius: BorderRadius.circular(0.0),
            ),
          ],
        ).show();
      });
      setState(() {
        now = getNow;
      });
    } else {}
  }

  @override
  void dispose() {
    super.dispose();
    _inputNik.dispose();
    _inputPass.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(
                  // gradient: LinearGradient(colors: [info, primary])
                  image: DecorationImage(
                      image: AssetImage("assets/images/onboard-background.png"),
                      fit: BoxFit.cover)),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Container(
                width: MediaQuery.of(context).size.width,
                // height: MediaQuery.of(context).size.height / 2,
                child: Material(
                  color: ArgonColors.black.withOpacity(0.3),
                  type: MaterialType.card,
                  // shape: BeveledRectangleBorder(
                  //     borderRadius: new BorderRadius.only(
                  //         topLeft: Radius.circular(1000))),
                ),
              ),
            ),
            // Container(
            //   alignment: Alignment.bottomCenter,
            //   height: MediaQuery.of(context).size.height,
            //   width: MediaQuery.of(context).size.width,
            //   child: Container(
            //     width: MediaQuery.of(context).size.width,
            //     height: MediaQuery.of(context).size.height / 2,
            //     child: Material(
            //       color: defaults,
            //       type: MaterialType.card,
            //       shape: BeveledRectangleBorder(
            //         borderRadius:
            //             new BorderRadius.only(topLeft: Radius.circular(1000)),
            //       ),
            //     ),
            //   ),
            // ),
            Container(
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 8,
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 15.0, right: 15.0),
                      child: Image.asset(
                        "assets/images/title.png",
                        fit: BoxFit.fill,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 50,
                    ),
                    Container(
                      child: Text(
                        "DANAMAS INSAN KREASI ANDALAN",
                        style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontFamily: 'OpenSans'),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 10,
                    ),
                    _loginForm(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 10,
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            now == null ? "@ " : "@${now.year} ",
                            style: TextStyle(color: ArgonColors.white),
                          ),
                          Text(
                            "KTA Team",
                            style: TextStyle(
                                color: ArgonColors.white,
                                fontFamily: 'OpenSans'),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loginForm() {
    return Container(
      alignment: Alignment.center,
      height: MediaQuery.of(context).size.height / 2.5,
      width: MediaQuery.of(context).size.width / 1.3,
      decoration: ShapeDecoration(
          color: white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 250.0,
            height: 50.0,
            child: RaisedButton(
              elevation: 10.0,
              onPressed: () {
                Navigator.of(context).pushNamed('/cameraLogin');
              },
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                      style: BorderStyle.solid,
                      color: ArgonColors.info,
                      width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(4.0))),
              child: Text("MASUK", style: TextStyle(color: Colors.white)),
              color: ArgonColors.info,
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 15,
          ),
          Container(
            width: 250.0,
            height: 50.0,
            child: RaisedButton(
              elevation: 10.0,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => Registration(),
                );
              },
              shape: RoundedRectangleBorder(
                  side: BorderSide(
                      style: BorderStyle.solid,
                      color: ArgonColors.info,
                      width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(4.0))),
              child: Text("REGISTER", style: TextStyle(color: Colors.white)),
              color: ArgonColors.info,
            ),
          ),
        ],
      ),
    );
  }
}

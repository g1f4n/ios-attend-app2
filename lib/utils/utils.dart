import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:attend_app/utils/Theme.dart';
import 'package:attend_app/utils/colors.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utils {
  static AlertStyle alertStyle = AlertStyle(
    animationType: AnimationType.fromTop,
    isCloseButton: false,
    isOverlayTapDismiss: false,
    descStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
    animationDuration: Duration(milliseconds: 400),
    alertBorder: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(0.0),
      side: BorderSide(
        color: Colors.grey,
      ),
    ),
    titleStyle: TextStyle(
      color: Colors.red,
    ),
  );

  static Widget drawer(BuildContext context, String userImagePath,
      String fullName, String inputNik, Future<bool> confirmLogout()) {
    return ClipPath(
      clipper: ShapeBorderClipper(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(0.0),
              bottomRight: Radius.circular(0.0)),
        ),
      ),
      child: Drawer(
        child: Container(
          padding: const EdgeInsets.only(left: 16.0, right: 40),
          decoration: BoxDecoration(
            color: ArgonColors.white,
            boxShadow: [
              BoxShadow(color: Colors.purpleAccent),
            ],
          ),
          width: 300,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 75.0,
                  ),
                  Container(
                    width: 100.0,
                    height: 100.0,
                    decoration: BoxDecoration(
                        color: Colors.orangeAccent,
                        borderRadius: BorderRadius.all(Radius.circular(100.0))),
                    child: userImagePath == null
                        ? Icon(
                            Icons.person_outline,
                            size: 75.0,
                          )
                        : CircleAvatar(
                            backgroundImage: FileImage(File(userImagePath)),
                          ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                    margin: const EdgeInsets.all(10.0),
                    child: Text(
                      fullName ?? "User",
                      style: TextStyle(color: teal, fontSize: 18.0),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    child: Text(
                      inputNik ?? "-",
                      style: TextStyle(color: teal, fontSize: 16.0),
                    ),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  _buildDivider(),
                  _refresh(context),
                  _buildDivider(),
                  _logout(confirmLogout, userImagePath),
                  _buildDivider()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Divider _buildDivider() {
    return Divider(
      color: Colors.teal,
    );
  }

  static Widget _logout(Future<bool> confirmLogout(), String userIMagePath) {
    return Container(
      height: 50.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(50.0)),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.power_settings_new,
                color: Colors.red,
                size: 25.0,
              ),
              SizedBox(
                width: 10.0,
              ),
              Text(
                "LOGOUT",
                style: TextStyle(color: Colors.red),
              )
            ],
          ),
          onTap: () {
            if (File(userIMagePath).existsSync()) {
              File(userIMagePath).deleteSync();
            }
            confirmLogout();
          },
        ),
      ),
    );
  }

  static Widget _refresh(BuildContext context) {
    return Container(
      height: 50.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(50.0)),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.refresh,
                color: purple,
                size: 25.0,
              ),
              SizedBox(
                width: 10.0,
              ),
              Text(
                "REFRESH",
                style: TextStyle(color: purple),
              )
            ],
          ),
          onTap: () {
            refreshFunction(context);
          },
        ),
      ),
    );
  }

  static void refreshFunction(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String role = prefs.getString('roles');
    if (role == 'staff') {
      Navigator.of(context).pushNamedAndRemoveUntil(
          '/homeStaff', (Route<dynamic> route) => false);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
          '/homeLeader', (Route<dynamic> route) => false);
    }
  }

  Future<int> getAndroidVersion() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    AndroidDeviceInfo androidDeviceInfo = await deviceInfoPlugin.androidInfo;

    return androidDeviceInfo.version.sdkInt;
  }

  String createCryptoRandomString([int length = 32]) {
    Random _random = Random();

    var values = List<int>.generate(length, (i) => _random.nextInt(256));

    return base64Url.encode(values);
  }
}

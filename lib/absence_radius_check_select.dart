import 'dart:io';

import 'package:attend_app/utils/Theme.dart';
import 'package:attend_app/utils/colors.dart';
import 'package:attend_app/utils/utils.dart';
import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RadiusCheck extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RadiusCheckState();
}

class RadiusCheckState extends State<RadiusCheck> {
  SharedPreferences prefs;
  // Geolocator geolocator = Geolocator();
  // Position userPosition;
  // String userLongitude;
  // String userLatitude;
  ProgressDialog pr;

  // List listGeopoint;
  // ParseObject objectGeopoint, appSetting;
  // Map<String, dynamic> mapGeopoint, mapAppSetting;

  TextEditingController reasonController = TextEditingController();

  // List listDropdownGeo = ['Pilih Lokasi...'];
  // List<DropdownMenuItem<String>> dropdownGeo;
  // String currentGeo, desc;

  // List listLatitude = ['EMPTY'];
  // List listLongitude = ['EMPTY'];

  Color reasonFieldColor, textAreaColor;

  // bool locValidity = false;

  String objectIdIn, officeName, imageSelfiePath, getRole, role;
  double distanceRadius = 0.0;
  int rangeDB;

  @override
  void initState() {
    super.initState();
    pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(message: "VERIFIKASI...");
    reasonFieldColor = textAreaColor = Colors.black;
    // _getUserLocation().whenComplete(() {
    loadDataProfile();
    // });
  }

  void loadDataProfile() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      objectIdIn = prefs.getString('objectIdIn');
      officeName = prefs.getString('officeName');
      distanceRadius = prefs.getDouble('getDistanceBetween');
      rangeDB = prefs.getInt('radiusAbsen');
      imageSelfiePath = prefs.getString('imageSelfiePath');
      getRole = prefs.getString('roles');
      if (getRole == 'staff') {
        role = 'Staff';
      } else {
        role = 'Leader';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArgonColors.bgColorScreen,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 10.0,
//        shape: BeveledRectangleBorder(
//          borderRadius: BorderRadius.only(
//              bottomLeft: Radius.circular(25.0),
//              bottomRight: Radius.circular(25.0)),
//        ),
        backgroundColor: ArgonColors.bgColorScreen,
        title: Text(
          "ABSEN DILUAR BATAS",
          style: TextStyle(color: ArgonColors.initial),
        ),
        centerTitle: true,
        titleSpacing: 3.3,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration:
            BoxDecoration(gradient: LinearGradient(colors: [info, primary])),
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
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 50,
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(left: 10.0, top: 10.0),
                      child: Text(
                        "Jarak anda dengan lokasi absen ${distanceRadius.round()} m\nmelebihi dari jarak yang ditentukan\n($rangeDB meter)",
                        style: TextStyle(fontSize: 14.0, color: danger),
                        textAlign: TextAlign.center,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(left: 10.0, top: 10.0),
                      child: Text(
                        'Alasan absen diluar dari jarak yang ditentukan',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: info,
                        ),
                      ),
                    ),
                    _textArea(textAreaColor),
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

  // List<DropdownMenuItem<String>> getDropDownMenuItems(List getItems) {
  //   List<DropdownMenuItem<String>> items = new List();
  //   for (String item in getItems) {
  //     items.add(
  //       new DropdownMenuItem(
  //           value: item,
  //           child: Text(
  //             item,
  //             style: TextStyle(fontSize: 14.0),
  //             overflow: TextOverflow.ellipsis,
  //             maxLines: 5,
  //           )),
  //     );
  //   }
  //   return items;
  // }

  // Widget _spinner(
  //     List<DropdownMenuItem<dynamic>> items, dynamic firstValue, Color color) {
  //   return Container(
  //     width: MediaQuery.of(context).size.width / 1.5,
  //     child: DropdownButton<String>(
  //       isExpanded: true,
  //       value: firstValue,
  //       items: items,
  //       iconEnabledColor: Colors.greenAccent,
  //       underline: Divider(
  //         color: color,
  //         thickness: 2.0,
  //       ),
  //       onChanged: (value) {
  //         setState(() {
  //           currentGeo = value;
  //         });
  //       },
  //     ),
  //   );
  // }

  Widget _nextButton() {
    return Container(
      child: Align(
        alignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.only(left: 10.0, right: 10.0),
          width: MediaQuery.of(context).size.width / 2,
          height: 50.0,
          child: RaisedButton(
            elevation: 20.0,
            child: Text("LANJUTKAN", style: TextStyle(color: Colors.white)),
            color: blueButton,
            onPressed: () {
              _formValidate();
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
    if (reasonController.text.trim() != '') {
      setState(() {
        pr.show();
        textAreaColor = Colors.black;
      });
      ParseObject updateLocation = ParseObject('Absence');
      updateLocation.set('objectId', objectIdIn);
      updateLocation.set('workPlace', officeName);
      updateLocation.set('outBoundReason', reasonController.text.trim());
      updateLocation.update().then((value) {
        if (value.statusCode == 200) {
          setState(() {
            pr.hide();
          });
          _showAlert(
                  alertType: AlertType.success,
                  alertDesc: "Update data berhasil terkirim",
                  alertTitle: "BERHASIL TERKIRIM")
              .whenComplete(() {
            if (File(imageSelfiePath).existsSync()) {
              File(imageSelfiePath).deleteSync();
            }
            Navigator.of(context).pushNamedAndRemoveUntil(
                '/home$role', (Route<dynamic> route) => false);
          });
        } else {
          setState(() {
            pr.hide();
          });
          _showAlert(
              alertType: AlertType.error,
              alertDesc: "Update data gagal terkirim",
              alertTitle: "GAGAL TERKIRIM");
        }
      }).catchError((e) {
        setState(() {
          pr.hide();
        });
        _showAlert(
            alertType: AlertType.error,
            alertDesc: "Update data gagal terkirim",
            alertTitle: "GAGAL TERKIRIM");
      });
    } else {
      setState(() {
        textAreaColor = Colors.red;
      });
    }
    // if (locValidity) {
    //   if (reasonController.text.trim() != '') {
    //     prefs.setString('outBoundReason', reasonController.text.trim());
    //     prefs.setString('workPlace', currentGeo);
    //     Navigator.of(context).pushNamed('/cameraVision');
    //   } else {
    //     textAreaColor = Colors.red;
    //   }
    // } else {
    //   if (currentGeo == listDropdownGeo[0]) {
    //     reasonFieldColor = Colors.red;
    //   } else {
    //     reasonFieldColor = Colors.black;
    //     int getIndex = listDropdownGeo.indexOf(currentGeo);
    //     if (userPosition != null) {
    //       geolocator
    //           .distanceBetween(
    //               double.parse(userLatitude),
    //               double.parse(userLongitude),
    //               double.parse(listLatitude[getIndex]),
    //               double.parse(listLongitude[getIndex]))
    //           .then((value) {
    //         setState(() {
    //           print(value);
    //           distanceRadius = value;
    //           if (distanceRadius > rangeDB.toDouble()) {
    //             locValidity = true;
    //           } else {
    //             prefs.setString('outBoundReason', '-');
    //             prefs.setString('workPlace', currentGeo);
    //             Navigator.of(context).pushNamed('/cameraVision');
    //           }
    //         });
    //       }).catchError((e) {
    //         prefs.setString('outBoundReason',
    //             'userPosition is null when calculate distance');
    //         prefs.setString('workPlace', currentGeo);
    //         Navigator.of(context).pushNamed('/cameraVision');
    //       });
    //     } else {
    //       prefs.setString(
    //           'outBoundReason', 'userPosition is null when calculate distance');
    //       prefs.setString('workPlace', currentGeo);
    //       Navigator.of(context).pushNamed('/cameraVision');
    //     }
    //   }
    // }
  }

  // Future _getUserLocation() {
  //   return geolocator.isLocationServiceEnabled().then(
  //     (locationService) {
  //       if (locationService) {
  //         print("true");
  //         setState(() {
  //           pr.show();
  //         });
  //         geolocator
  //             .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
  //             .then((Position position) {
  //           setState(() {
  //             if (position != null) {
  //               userPosition = position;
  //               userLatitude = userPosition.latitude.toString();
  //               userLongitude = userPosition.longitude.toString();
  //             } else {
  //               userPosition = null;
  //               userLatitude = null;
  //               userLongitude = null;
  //             }
  //           });
  //         }).catchError(
  //           (e) {
  //             setState(() {
  //               pr.hide();
  //               userPosition = null;
  //             });
  //             _showAlert(
  //                 alertType: AlertType.warning,
  //                 alertDesc: "Mohon berikan akses lokasi, terima kasih",
  //                 alertTitle: "Izin Akses Aplikasi");
  //           },
  //         );
  //       } else {
  //         setState(() {
  //           pr.hide();
  //         });
  //         _showAlert(
  //             alertDesc: "Mohon nyalakan servis lokasi pada smartphone anda",
  //             alertTitle: "Servis Lokasi Mati");
  //       }
  //     },
  //   );
  // }

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

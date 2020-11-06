import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import '../colors.dart';
import '../utils.dart';

class TeamEditDialog extends StatefulWidget {
  final ParseObject objectDetailView;
  final List listShift;
  final List listShiftObjectId;

  const TeamEditDialog(
      {Key key, this.objectDetailView, this.listShift, this.listShiftObjectId})
      : super(key: key);
  @override
  State<StatefulWidget> createState() =>
      TeamEditDialogState(objectDetailView, listShift, listShiftObjectId);
}

class TeamEditDialogState extends State<TeamEditDialog>
    with SingleTickerProviderStateMixin {
  final ParseObject objectDetailView;
  final List listShift;
  final List listShiftObjectId;

  TeamEditDialogState(
      this.objectDetailView, this.listShift, this.listShiftObjectId);

  ProgressDialog pr;

  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();

  ParseFile facePhoto;
  Map<String, dynamic> mapFacePhoto;
  Map<String, dynamic> mapDetailView;

  bool finish = false;

  List workHourItems = [
    'Jam Tetap',
    'Jam Fleksibel',
    'Jam Bebas',
  ];
  List<DropdownMenuItem<String>> listWorkHourItems;
  String currentWorkHourItems;

  List workLocItems = [
    'Tetap',
    'Bebas (mobile)',
  ];
  List<DropdownMenuItem<String>> listWorkLocItems;
  String currentWorkLocItems;

  List overtimeItems = [
    'Ya',
    'Tidak',
  ];
  List<DropdownMenuItem<String>> listOvertimeItems;
  String currentOvertimeItems;

  List<DropdownMenuItem<String>> listShiftItems;
  String currentShiftItem;

  final picker = ImagePicker();
  File _pickedFile;

  Color color1, color2, color3, color4;

  @override
  void initState() {
    super.initState();
    pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal, isDismissible: false, showLogs: false);
    pr.style(message: "Mengirimkan Request...");

    color1 = color2 = color3 = Colors.black;
    listWorkHourItems = getDropDownMenuItems(workHourItems);
    listWorkLocItems = getDropDownMenuItems(workLocItems);
    listOvertimeItems = getDropDownMenuItems(overtimeItems);
    currentWorkHourItems = listWorkHourItems[0].value;
    currentWorkLocItems = listWorkLocItems[0].value;
    currentOvertimeItems = listOvertimeItems[0].value;
    if (listShift != null) {
      listShiftItems = getDropDownMenuItems(listShift);
      currentShiftItem = listShiftItems[0].value;
    } else {
      List dummy = [
        'Tidak Ada Data',
      ];
      listShiftItems = getDropDownMenuItems(dummy);
      currentShiftItem = listShiftItems[0].value;
    }

    mapDetailView = Map<String, dynamic>.from(objectDetailView.toJson());

    facePhoto = mapDetailView['fotoWajah'];
    if (facePhoto != null) {
      mapFacePhoto = Map<String, dynamic>.from(facePhoto.toJson());
    } else {
      mapFacePhoto = {'url': null};
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller1.dispose();
    controller2.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: EdgeInsets.all(20.0),
          padding: EdgeInsets.all(10.0),
          height: MediaQuery.of(context).size.height / 1.5,
          width: MediaQuery.of(context).size.width,
          decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0))),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _imageDetailItem('FOTO WAJAH', color1),
                // _textDetailItem(
                //     'IMEI', controller1, 'Masukkan imei hp', color2),
                // _spinnerDetailItem(
                //     0, 'JAM KERJA', listWorkHourItems, currentWorkHourItems),
                // _spinnerDetailItem(
                //     1, 'LOKASI KERJA', listWorkLocItems, currentWorkLocItems),
                _textDetailItem(
                    'Jumlah Cuti', controller2, 'Masukkan jumlah cuti', color2),
                _spinnerDetailItem(3, 'TIPE SHIFTING', listShiftItems,
                    currentShiftItem, color3),
                _spinnerDetailItem(2, 'LEMBUR', listOvertimeItems,
                    currentOvertimeItems, color4),
                SizedBox(height: 25.0),
                _okButton(),
                SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _textDetailItem(String label, TextEditingController controller,
      String hintText, Color color) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(10.0),
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
            Container(
              margin: const EdgeInsets.only(left: 10.0, top: 5.0),
              padding: const EdgeInsets.only(left: 5.0),
              decoration: BoxDecoration(
                  border: Border.all(color: color, width: 2.0),
                  borderRadius: BorderRadius.all(Radius.circular(10.0))),
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: hintText,
                ),
                controller: controller,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _spinnerDetailItem(int id, String label,
      List<DropdownMenuItem<dynamic>> items, dynamic firstValue, Color color) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(10.0),
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
            Container(
              margin: const EdgeInsets.only(left: 25.0, top: 5.0),
              child: _spinner(id, items, firstValue, color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageDetailItem(String label, Color color) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(10.0),
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 10.0, top: 10.0, bottom: 5.0),
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
                height: MediaQuery.of(context).size.height / 4,
                width: MediaQuery.of(context).size.width / 2,
                decoration: BoxDecoration(
                    border: Border.all(color: color, width: 2.0),
                    borderRadius: BorderRadius.all(Radius.circular(10.0))),
                child: Stack(
                  children: <Widget>[
                    _pickedFile != null
                        ? Container(
                            alignment: Alignment.center,
                            child: Image.file(
                              _pickedFile,
                              fit: BoxFit.contain,
                            ),
                          )
                        : Container(
                            alignment: Alignment.center,
                            child: Icon(Icons.person),
                          ),
                    Container(
                      alignment: Alignment.bottomRight,
                      child: FloatingActionButton(
                        elevation: 10.0,
                        backgroundColor: blue,
                        child: Icon(Icons.add_photo_alternate),
                        onPressed: () {
                          imageSelectorGallery();
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

  void imageSelectorGallery() async {
    final pickedImage = await picker.getImage(source: ImageSource.gallery);
    setState(() {
      _pickedFile = File(pickedImage.path);
    });
  }

  Widget _okButton() {
    return Container(
      child: Align(
        alignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.only(left: 10.0, right: 10.0),
          width: MediaQuery.of(context).size.width / 1.5,
          height: 50.0,
          child: RaisedButton(
            elevation: 10.0,
            child: Text(finish ? 'FINISH' : "Request Pengubahan Data",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white)),
            color: blueButton,
            onPressed: () {
              if (finish) {
                Navigator.of(context).pop();
              } else {
                validation();
              }
            },
            shape: RoundedRectangleBorder(
                side: BorderSide(
                    style: BorderStyle.solid,
                    color: blue,
                    width: 2.0),
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
          ),
        ),
      ),
    );
  }

  void validation() {
    setState(() {
      if (_pickedFile != null &&
          // controller1.text.trim() != '' &&
          controller2.text.trim() != '' &&
          currentShiftItem != 'Tidak Ada Data' &&
          currentShiftItem != listShift[0]) {
        pr.show();
        parseRequestEditData();
      }
      if (currentShiftItem != listShift[0]) {
        color3 = Colors.red;
      } else {
        color3 = Colors.black;
      }
      if (_pickedFile == null) {
        color1 = Colors.red;
      } else {
        color1 = Colors.black;
      }
      // if (controller1.text.trim() == '') {
      //   color2 = Colors.red;
      // } else {
      //   color2 = Colors.black;
      // }
      if (controller2.text.trim() == '') {
        color2 = Colors.red;
      } else {
        color2 = Colors.black;
      }
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

  Widget _spinner(int id, List<DropdownMenuItem<dynamic>> items,
      dynamic firstValue, Color color) {
    return Container(
      width: MediaQuery.of(context).size.width / 1.5,
      child: DropdownButton<String>(
        isExpanded: true,
        value: firstValue,
        items: items,
        iconEnabledColor: Colors.greenAccent,
        underline: Divider(
          color: Colors.transparent,
        ),
        iconSize: 30.0,
        onChanged: (value) {
          setState(() {
            if (id == 0) {
              currentWorkHourItems = value;
            } else if (id == 1) {
              currentWorkLocItems = value;
            } else if (id == 2) {
              currentOvertimeItems = value;
            } else if (id == 3 && listShift != null) {
              currentShiftItem = value;
            }
          });
        },
      ),
    );
  }

  void parseRequestEditData() async {
    ParseUser user = await ParseUser.currentUser();
    ParseFile parseImage = ParseFile(_pickedFile);

    ParseObject parseRequestEdit = ParseObject('ChangeRequest');
    parseRequestEdit.set('userId', {
      "__type": "Pointer",
      "className": "_User",
      "objectId": mapDetailView['objectId']
    });
    parseRequestEdit.set('idUser', {
      "__type": "Pointer",
      "className": "_User",
      "objectId": mapDetailView['objectId']
    });
    parseRequestEdit.set('leaderId', {
      "__type": "Pointer",
      "className": "_User",
      "objectId": user['objectId']
    });
    parseRequestEdit.set<ParseFile>('fotoWajah', parseImage);
    parseRequestEdit.set('imei', mapDetailView['imei']);
    // parseRequestEdit.set('jamKerja', currentWorkHourItems);
    // parseRequestEdit.set('lokasiKerja', currentWorkLocItems);
    parseRequestEdit.set('shifting', {
      "__type": "Pointer",
      "className": "Shifting",
      "objectId": listShiftObjectId[listShift.indexOf(currentShiftItem)],
    });
    parseRequestEdit.set('jumlahCuti', int.parse(controller2.text.trim()));
    parseRequestEdit.set('lembur', currentOvertimeItems);
    parseRequestEdit.set('statusApprove', 0);
    parseRequestEdit.set('fullname', mapDetailView['fullname']);
    parseRequestEdit.set('nik', mapDetailView['nik']);

    parseRequestEdit.save().then((value) {
      if (value.statusCode == 201) {
        setState(() {
          finish = true;
          pr.hide();
        });
        Alert(
          context: context,
          style: Utils.alertStyle,
          type: AlertType.success,
          title: "BERHASIl",
          desc:
              "Request Perubahan data sudah terkirim.\nMohon menunggu untuk admin memproses request.",
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
        ).show().whenComplete(() {
          Navigator.pop(context, 'edited');
        });
      } else {
        setState(() {
          finish = true;
          pr.hide();
        });
        Alert(
          context: context,
          style: Utils.alertStyle,
          type: AlertType.success,
          title: "GAGAL",
          desc: "Request Perubahan data gagal.\nMohon ulangi kembali.",
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
        ).show().whenComplete(() {
          Navigator.pop(context);
        });
      }
    }).catchError((e) {
      setState(() {
        pr.hide();
      });
      Alert(
        context: context,
        style: Utils.alertStyle,
        type: AlertType.error,
        title: "GAGAL",
        desc: "Request Perubahan data gagal.\nMohon ulangi kembali.",
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

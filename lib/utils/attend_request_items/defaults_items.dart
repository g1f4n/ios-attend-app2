import 'package:attend_app/utils/colors.dart';
import 'package:attend_app/utils/request_dialog_view/request_absen_aprrove_reject_dialog.dart';
import 'package:attend_app/utils/request_dialog_view/request_absen_image_view_dialog.dart';
import 'package:attend_app/utils/request_dialog_view/request_cuti_approve_reject.dart';
import 'package:attend_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DefaultItems extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DefaultItemsState();
}

class DefaultItemsState extends State<DefaultItems> {
  SharedPreferences prefs;
  List listDefault = [];
  ParseObject objectAbsence;
  ParseFile userImage;
  Map<String, dynamic> mapDefault,
      mapUserImage,
      mapDateMasuk,
      mapDateKeluar,
      mapDari,
      mapSampai;
  DateTime dateIn;
  bool data1 = false,
      data2 = false,
      data3 = false,
      data4 = false,
      data5 = false;

  @override
  void initState() {
    super.initState();
    getProfile();
    parseLoadData();
  }

  void getProfile() async {
    prefs = await SharedPreferences.getInstance();
    String getJamMasuk = prefs.getString('jamMasuk');
    dateIn = DateTime.parse(getJamMasuk).toLocal();
  }

  void parseLoadData() async {
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
    DateTime startDate = DateTime(now.year, now.month, now.day, 0, 0, 0);
    DateTime finishDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    ParseUser user = await ParseUser.currentUser();
    String roles = user.get('roles');

    QueryBuilder<ParseObject> queryTeam =
        QueryBuilder<ParseObject>(ParseObject(('_User')));
    switch (roles) {
      case 'leader':
        queryTeam.whereEqualTo('leaderIdNew', user.toPointer());
        break;
      case 'supervisor':
        queryTeam.whereEqualTo('supervisorID', user.toPointer());
        break;
      case 'manager':
        queryTeam.whereEqualTo('managerID', user.toPointer());
        break;
      case 'head':
        queryTeam.whereEqualTo('headID', user.toPointer());
        break;
      case 'gm':
        queryTeam.whereEqualTo('gmID', user.toPointer());
        break;
      default:
    }

    QueryBuilder<ParseObject> queryAbsence =
        QueryBuilder<ParseObject>(ParseObject(('Absence')))
          ..whereMatchesKeyInQuery('user', 'objectId', queryTeam)
          ..whereGreaterThanOrEqualsTo('createdAt', startDate)
          ..whereLessThan('createdAt', finishDate)
          ..whereEqualTo('status', 3)
          ..orderByDescending('createdAt');
    QueryBuilder<ParseObject> queryLCuti =
        QueryBuilder<ParseObject>(ParseObject(('Izin')))
          ..whereMatchesKeyInQuery('user', 'objectId', queryTeam)
          ..whereGreaterThanOrEqualsTo('createdAt', startDate)
          ..whereLessThan('createdAt', finishDate)
          ..whereEqualTo('status', 3)
          ..orderByDescending('createdAt');

    queryAbsence.query().then((value) {
      setState(() {
        if (value.statusCode == 200) {
          if (value.results != null) {
            listDefault.addAll(value.results);
          } else {
            data1 = true;
            listDefault.add({'desc': 'THERE IS NO DATA'});
          }
        } else {
          listDefault.add('CONNECTION ERROR');
        }
      });
    }).catchError((e) {
      print(e);
      setState(() {
        listDefault.add('CONNECTION ERROR');
      });
    });

    queryLCuti.query().then((value) {
      setState(() {
        if (value.statusCode == 200) {
          if (value.results != null) {
            listDefault.addAll(value.results);
          } else {
            data5 = true;
            listDefault.add({'desc': 'THERE IS NO DATA'});
          }
        } else {
          listDefault.add('CONNECTION ERROR');
        }
      });
    }).catchError((e) {
      print(e);
      setState(() {
        listDefault.add('CONNECTION ERROR');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(),
    );
  }

  Widget _body() {
    return listDefault.isEmpty
        ? Container(
            margin: const EdgeInsets.only(
                left: 5.0, right: 5.0, top: 10.0, bottom: 10.0),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height / 1.2,
            child: Card(
              margin: const EdgeInsets.only(bottom: 50.0),
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.black38),
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
              ),
              shadowColor: kAppSoftLightTeal,
              elevation: 5.0,
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        : listDefault.contains('CONNECTION ERROR')
            ? Container(
                margin: const EdgeInsets.only(
                    left: 5.0, right: 5.0, top: 10.0, bottom: 10.0),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height / 1.2,
                child: Card(
                  margin: const EdgeInsets.only(bottom: 50.0),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.black38),
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  ),
                  shadowColor: kAppSoftLightTeal,
                  elevation: 5.0,
                  child: Center(
                    child: Text('CONNECTION ERROR'),
                  ),
                ),
              )
            : Card(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.black38),
                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                ),
                shadowColor: kAppSoftLightTeal,
                elevation: 5.0,
                child: data1 && data2
                    ? Center(
                        child: Text('THERE IS NO DATA'),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: listDefault.length,
                        itemBuilder: (context, index) {
                          String kategoriAbsenMasuk = '-';
                          String kategoriAbsenKeluar = '-';
                          Color colorCategoryMasuk = info;
                          Color colorCategoryKeluar = info;
                          if (listDefault[index]['desc'] ==
                              'THERE IS NO DATA') {
                            return Container();
                          } else {
                            objectAbsence = listDefault[index];
                          }
                          mapDefault =
                              Map<String, dynamic>.from(objectAbsence.toJson());

                          if (mapDefault['absenMasuk'] != null) {
                            mapDateMasuk = mapDefault['absenMasuk'];
                            kategoriAbsenMasuk = "Tepat Waktu";
                            colorCategoryMasuk = success;
                          } else if (mapDefault['lateTimes'] != null) {
                            mapDateMasuk = mapDefault['lateTimes'];
                            kategoriAbsenMasuk = "Telat";
                            colorCategoryMasuk = danger;
                          } else {
                            mapDateMasuk = {'iso': null};
                          }

                          if (mapDefault['absenKeluar'] != null) {
                            mapDateKeluar = mapDefault['absenKeluar'];
                            kategoriAbsenKeluar = "Tepat Waktu";
                            colorCategoryKeluar = green;
                          } else if (mapDefault['earlyTimes'] != null) {
                            mapDateKeluar = mapDefault['earlyTimes'];
                            kategoriAbsenKeluar = "Pulang Cepat";
                            colorCategoryKeluar = teal;
                          } else if (mapDefault['overtimeOut'] != null) {
                            mapDateKeluar = mapDefault['overtimeOut'];
                            kategoriAbsenKeluar = "Lembur";
                            colorCategoryKeluar = orange;
                          } else {
                            mapDateKeluar = {'iso': null};
                          }

                          if (mapDefault['dari'] != null) {
                            mapDari = mapDefault['dari'];
                          } else {
                            mapDari = {'iso': null};
                          }
                          if (mapDefault['sampai'] != null) {
                            mapSampai = mapDefault['sampai'];
                          } else {
                            mapSampai = {'iso': null};
                          }

                          return Card(
                            margin: EdgeInsets.all(10.0),
                            elevation: 10.0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                Container(
                                  margin: const EdgeInsets.all(5.0),
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 5.0),
                                        child: Text(
                                          mapDefault['fullname'] == null
                                              ? '-'
                                              : mapDefault['fullname'],
                                          style: TextStyle(
                                              fontSize: 16.0, color: blue),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      mapDateMasuk['iso'] != null
                                          ? Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Expanded(
                                                    flex: 4,
                                                    child: Container(
                                                      child: Text(
                                                        'Jam masuk',
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Container(
                                                      child: Text(
                                                        ' : ',
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 7,
                                                    child: Container(
                                                      child: Text(
                                                        mapDateMasuk['iso'] ==
                                                                null
                                                            ? '-'
                                                            : DateFormat(
                                                                    "EE, dd MMMM yyyy 'at' HH:mm")
                                                                .format(DateTime.parse(
                                                                        mapDateMasuk[
                                                                            'iso'])
                                                                    .toLocal()),
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container(),
                                      mapDateKeluar['iso'] != null
                                          ? Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Expanded(
                                                    flex: 4,
                                                    child: Container(
                                                      child: Text(
                                                        'Jam keluar',
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Container(
                                                      child: Text(
                                                        ' : ',
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 7,
                                                    child: Container(
                                                      child: Text(
                                                        mapDateKeluar['iso'] ==
                                                                null
                                                            ? '-'
                                                            : DateFormat(
                                                                    "EE, dd MMMM yyyy 'at' HH:mm")
                                                                .format(DateTime.parse(
                                                                        mapDateKeluar[
                                                                            'iso'])
                                                                    .toLocal()),
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                        ),
                                                        maxLines: 2,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container(),
                                      mapDefault['dari'] != null
                                          ? Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    flex: 3,
                                                    child: Container(
                                                      child: Text(
                                                        'Dari',
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Container(
                                                      child: Text(
                                                        ' : ',
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 6,
                                                    child: Container(
                                                      child: Text(
                                                        mapDari['iso'] == null
                                                            ? '-'
                                                            : DateFormat(
                                                                    "EE, dd MMMM yyyy")
                                                                .format(DateTime.parse(
                                                                        mapDari[
                                                                            'iso'])
                                                                    .toLocal()),
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container(),
                                      mapDefault['sampai'] != null
                                          ? Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    flex: 3,
                                                    child: Container(
                                                      child: Text(
                                                        'Sampai',
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Container(
                                                      child: Text(
                                                        ' : ',
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 6,
                                                    child: Container(
                                                      child: Text(
                                                        mapSampai['iso'] == null
                                                            ? '-'
                                                            : DateFormat(
                                                                    "EE, dd MMMM yyyy")
                                                                .format(DateTime.parse(
                                                                        mapSampai[
                                                                            'iso'])
                                                                    .toLocal()),
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container(),
                                      mapDefault['descIzin'] != null
                                          ? Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    flex: 3,
                                                    child: Container(
                                                      child: Text(
                                                        'Kategori',
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Container(
                                                      child: Text(
                                                        ' : ',
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 6,
                                                    child: Container(
                                                      child: Text(
                                                        mapDefault['descIzin'] ==
                                                                null
                                                            ? '-'
                                                            : mapDefault[
                                                                'descIzin'],
                                                        style: TextStyle(
                                                          color: info,
                                                          fontSize: 14.0,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container(),
                                      mapDefault['className'] == 'Absence'
                                          ? Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    flex: 4,
                                                    child: Container(
                                                      child: Text(
                                                        'Kategori Masuk',
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Container(
                                                      child: Text(
                                                        ' : ',
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 7,
                                                    child: Container(
                                                      child: Text(
                                                        kategoriAbsenMasuk,
                                                        style: TextStyle(
                                                          color:
                                                              colorCategoryMasuk,
                                                          fontSize: 14.0,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container(),
                                      mapDefault['className'] == 'Absence'
                                          ? Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    flex: 4,
                                                    child: Container(
                                                      child: Text(
                                                        'Kategori Keluar',
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Container(
                                                      child: Text(
                                                        ' : ',
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 7,
                                                    child: Container(
                                                      child: Text(
                                                        kategoriAbsenKeluar,
                                                        style: TextStyle(
                                                          color:
                                                              colorCategoryKeluar,
                                                          fontSize: 14.0,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container(),
                                      mapDefault['alasanIzin'] != null
                                          ? Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    flex: 2,
                                                    child: Container(
                                                      child: Text(
                                                        'Alasan',
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Container(
                                                      child: Text(
                                                        ' : ',
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 4,
                                                    child: Container(
                                                      child: Text(
                                                        mapDefault['alasanIzin'] ==
                                                                null
                                                            ? '-'
                                                            : mapDefault[
                                                                'alasanIzin'],
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container(),
                                      mapDefault['alasanMasuk'] != null
                                          ? Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    flex: 4,
                                                    child: Container(
                                                      child: Text(
                                                        'Alasan Masuk',
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Container(
                                                      child: Text(
                                                        ' : ',
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 7,
                                                    child: Container(
                                                      child: Text(
                                                        mapDefault['alasanMasuk'] ==
                                                                null
                                                            ? '-'
                                                            : mapDefault[
                                                                'alasanMasuk'],
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container(),
                                      mapDefault['alasanKeluar'] != null
                                          ? Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    flex: 4,
                                                    child: Container(
                                                      child: Text(
                                                        'Alasan Keluar',
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 0,
                                                    child: Container(
                                                      child: Text(
                                                        ' : ',
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 7,
                                                    child: Container(
                                                      child: Text(
                                                        mapDefault['alasanKeluar'] ==
                                                                null
                                                            ? '-'
                                                            : mapDefault[
                                                                'alasanKeluar'],
                                                        style: TextStyle(
                                                          fontSize: 14.0,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : Container(),
                                    ],
                                  ),
                                ),
                                mapDefault['className'] != 'Absence'
                                    ? Row(
                                        children: <Widget>[
                                          mapDefault['attachFile'] != null
                                              ? Expanded(
                                                  child: Container(
                                                    height: 40.0,
                                                    child: RaisedButton(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  15.0),
                                                        ),
                                                      ),
                                                      color: orange,
                                                      child: Row(
                                                        children: <Widget>[
                                                          Expanded(
                                                              child: Icon(
                                                                  Icons
                                                                      .remove_red_eye,
                                                                  color: Colors
                                                                      .white)),
                                                        ],
                                                      ),
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (_) =>
                                                              ImageViewDialog(
                                                            objectDetailView:
                                                                listDefault[
                                                                    index],
                                                            type: 'LeaveCuti',
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                )
                                              : Container(),
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              height: 40.0,
                                              child: RaisedButton(
                                                shape: mapDefault[
                                                            'attachFile'] !=
                                                        null
                                                    ? RoundedRectangleBorder()
                                                    : RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  15.0),
                                                        ),
                                                      ),
                                                color: blue,
                                                child: Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                        child: Icon(Icons.check,
                                                            color:
                                                                Colors.white)),
                                                    Expanded(
                                                        child: Text('Approve',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)))
                                                  ],
                                                ),
                                                onPressed: () {
                                                  ParseObject objectClass =
                                                      listDefault[index];
                                                  Map<String, dynamic>
                                                      mapClass =
                                                      Map<String, dynamic>.from(
                                                          objectClass.toJson());
                                                  if (mapClass['className'] ==
                                                          'Izin' &&
                                                      mapClass['descIzin']
                                                          .toString()
                                                          .toLowerCase()
                                                          .contains('cuti')) {
                                                    showDialog(
                                                      context: context,
                                                      builder: (_) =>
                                                          CutiApproveRejectDialog(
                                                        objectDetailView:
                                                            listDefault[index],
                                                        classname: mapClass[
                                                            'className'],
                                                      ),
                                                    ).then((value) {
                                                      if (value[0] ==
                                                              'approve' ||
                                                          value[0] ==
                                                              'reject') {
                                                        setState(() {
                                                          listDefault.clear();
                                                          parseLoadData();
                                                        });
                                                      }
                                                    });
                                                  } else {
                                                    showDialog(
                                                      context: context,
                                                      builder: (_) =>
                                                          ApproveRejectDialog(
                                                        objectDetailView:
                                                            listDefault[index],
                                                        classname: mapClass[
                                                            'className'],
                                                      ),
                                                    ).then((value) {
                                                      if (value[0] ==
                                                              'approve' ||
                                                          value[0] ==
                                                              'reject') {
                                                        setState(() {
                                                          listDefault.clear();
                                                          parseLoadData();
                                                        });
                                                      }
                                                    });
                                                  }
                                                },
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 2,
                                            child: Container(
                                              height: 40.0,
                                              child: RaisedButton(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    bottomRight:
                                                        Radius.circular(15.0),
                                                  ),
                                                ),
                                                color: danger,
                                                child: Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                        child: Icon(Icons.clear,
                                                            color:
                                                                Colors.white)),
                                                    Expanded(
                                                        child: Text('Reject',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)))
                                                  ],
                                                ),
                                                onPressed: () {
                                                  ParseObject objectClass =
                                                      listDefault[index];
                                                  Map<String, dynamic>
                                                      mapClass =
                                                      Map<String, dynamic>.from(
                                                          objectClass.toJson());
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) =>
                                                        ApproveRejectDialog(
                                                      objectDetailView:
                                                          listDefault[index],
                                                      code: 1,
                                                      classname:
                                                          mapClass['className'],
                                                    ),
                                                  ).then((value) {
                                                    if (value[0] == 'approve' ||
                                                        value[0] == 'reject') {
                                                      setState(() {
                                                        listDefault.clear();
                                                        parseLoadData();
                                                      });
                                                    }
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container()
                              ],
                            ),
                          );
                        },
                      ),
              );
  }
}

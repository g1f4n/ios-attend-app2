import 'package:attend_app/utils/colors.dart';
import 'package:attend_app/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DefaultPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DefaultPageState();
}

class DefaultPageState extends State<DefaultPage> {
  SharedPreferences prefs;
  List listAbsence = [];
  ParseObject objectAbsence;
  ParseFile userImage;
  Map<String, dynamic> mapDefault, mapUserImage, mapDateMasuk, mapDateKeluar;
  bool data1 = false, data2 = false;

  @override
  void initState() {
    super.initState();
    getProfile();
    parseLoadAbsence();
  }

  void getProfile() async {
    prefs = await SharedPreferences.getInstance();
    // String getJamMasuk = prefs.getString('jamMasuk');
  }

  void parseLoadAbsence() async {
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
    ParseUser user = await ParseUser.currentUser();
    DateTime startDate = DateTime(now.year, now.month, now.day, 0, 0, 0);
    DateTime finishDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

    QueryBuilder<ParseObject> queryAbsence =
        QueryBuilder<ParseObject>(ParseObject(('Absence')))
          ..whereEqualTo('user', user)
          ..whereGreaterThanOrEqualsTo('createdAt', startDate)
          ..whereLessThan('createdAt', finishDate)
          ..orderByDescending('createdAt');

    queryAbsence.query().then((value) {
      setState(() {
        if (value.statusCode == 200) {
          if (value.results != null) {
            listAbsence.addAll(value.results);
          } else {
            data1 = true;
            listAbsence.add({'desc': 'THERE IS NO DATA'});
          }
        } else {
          listAbsence.add('CONNECTION ERROR');
        }
      });
    }).catchError((e) {
      print(e);
      setState(() {
        listAbsence.add('CONNECTION ERROR');
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
    return listAbsence.isEmpty
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
        : listAbsence.contains('CONNECTION ERROR')
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
                child: data1 == true
                    ? Center(
                        child: Text('THERE IS NO DATA'),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: listAbsence.length,
                        itemBuilder: (context, index) {
                          String kategoriAbsenMasuk = '-';
                          String kategoriAbsenKeluar = '-';
                          Color colorCategoryMasuk = info;
                          Color colorCategoryMasukKeluar = info;
                          if (listAbsence[index]['desc'] ==
                              'THERE IS NO DATA') {
                            return Container();
                          } else {
                            objectAbsence = listAbsence[index];
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
                            colorCategoryMasukKeluar = green;
                          } else if (mapDefault['earlyTimes'] != null) {
                            mapDateKeluar = mapDefault['earlyTimes'];
                            kategoriAbsenKeluar = "Pulang Cepat";
                            colorCategoryMasukKeluar = teal;
                          } else if (mapDefault['overtimeOut'] != null) {
                            mapDateKeluar = mapDefault['overtimeOut'];
                            kategoriAbsenKeluar = "Lembur";
                            colorCategoryMasukKeluar = orange;
                          } else {
                            mapDateKeluar = {'iso': null};
                          }
                          return Card(
                            margin: EdgeInsets.all(10.0),
                            elevation: 10.0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(5.0),
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 5.0),
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
                                  Container(
                                    width: MediaQuery.of(context).size.width,
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        Expanded(
                                          flex: 4,
                                          child: Container(
                                            child: Text(
                                              'Jam Masuk',
                                              style: TextStyle(
                                                fontSize: 14.0,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
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
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 7,
                                          child: Container(
                                            child: Text(
                                              mapDateMasuk['iso'] == null
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
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
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
                                              overflow: TextOverflow.ellipsis,
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
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 7,
                                          child: Container(
                                            child: Text(
                                              mapDateKeluar['iso'] == null
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
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
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
                                              overflow: TextOverflow.ellipsis,
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
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 7,
                                          child: Container(
                                            child: Text(
                                              kategoriAbsenMasuk,
                                              style: TextStyle(
                                                color: colorCategoryMasuk,
                                                fontSize: 14.0,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
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
                                              overflow: TextOverflow.ellipsis,
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
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 7,
                                          child: Container(
                                            child: Text(
                                              kategoriAbsenKeluar,
                                              style: TextStyle(
                                                color: colorCategoryMasukKeluar,
                                                fontSize: 14.0,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              );
  }
}

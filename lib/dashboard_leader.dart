import 'dart:async';
import 'dart:math';

// import 'package:attend_app/utils/attend_request_items/absence_items.dart';
// import 'package:attend_app/utils/attend_request_items/cuti_items.dart';
// import 'package:attend_app/utils/attend_request_items/early_items.dart';
// import 'package:attend_app/utils/attend_request_items/late_items.dart';
// import 'package:attend_app/utils/attend_request_items/leave_items.dart';
// import 'package:attend_app/utils/attend_request_items/overtime_items.dart';
import 'package:attend_app/utils/Theme.dart';
import 'package:attend_app/utils/colors.dart';
import 'package:attend_app/utils/dashboard_dialog/display_dialog_view.dart';
import 'package:attend_app/utils/dashboard_dialog/unabsence_dialog_view.dart';
import 'package:attend_app/utils/utils.dart';
import 'package:attend_app/widgets/navbar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:ntp/ntp.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
// import 'package:shared_preferences/shared_preferences.dart';

class LeaderDashboard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => LeaderDashboardState();
}

class LeaderDashboardState extends State<LeaderDashboard> {
  GoogleMapController _mapController;
  CameraPosition _firstCameraPosition;
  Set<Marker> _markers = {};
  List<DataRow> dataRow = [];
  List listDefault = [], listUnAbsence;
  Map<String, dynamic> mapDefault, mapDateMasuk, mapDateKeluar;
  DateTime dateNow;
  bool data1 = false, data2 = false, data3 = false;
  Random rng = new Random();
  int team = 0,
      absence = 0,
      late = 0,
      early = 0,
      overtime = 0,
      leave = 0,
      cuti = 0,
      teamUnabsence = 0;

  @override
  void initState() {
    super.initState();
    getProfile();
    getCount();
    _firstCameraPosition = CameraPosition(
      target: LatLng(-6.2128274, 106.8100491),
      zoom: 10.0,
    );
  }

  void getProfile() async {
    dateNow = await NTP.now().catchError((e) {
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
  }

  Future<void> getCount() async {
    DateTime dateTime = await NTP.now().catchError((e) {
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
    DateTime startDate =
        DateTime(dateTime.year, dateTime.month, dateTime.day, 0, 0, 0);
    DateTime finishDate =
        DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59);
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
          ..orderByDescending('createdAt');
    QueryBuilder<ParseObject> queryUnAbsence =
        QueryBuilder<ParseObject>(ParseObject(('_User')))
          ..whereDoesNotMatchKeyInQuery('userId', 'user', queryAbsence);
    switch (roles) {
      case 'leader':
        queryUnAbsence.whereEqualTo('leaderIdNew', user.toPointer());
        break;
      case 'supervisor':
        queryUnAbsence.whereEqualTo('supervisorID', user.toPointer());
        break;
      case 'manager':
        queryUnAbsence.whereEqualTo('managerID', user.toPointer());
        break;
      case 'head':
        queryUnAbsence.whereEqualTo('headID', user.toPointer());
        break;
      case 'gm':
        queryUnAbsence.whereEqualTo('gmID', user.toPointer());
        break;
      default:
    }
    QueryBuilder<ParseObject> queryCuti =
        QueryBuilder<ParseObject>(ParseObject(('Izin')))
          ..whereMatchesKeyInQuery('user', 'objectId', queryTeam)
          ..whereGreaterThanOrEqualsTo('createdAt', startDate)
          ..whereLessThan('createdAt', finishDate)
          ..whereEqualTo('statusIzin', 2)
          ..orderByDescending('createdAt');
    QueryBuilder<ParseObject> queryLeave =
        QueryBuilder<ParseObject>(ParseObject(('Izin')))
          ..whereMatchesKeyInQuery('user', 'objectId', queryTeam)
          ..whereGreaterThanOrEqualsTo('createdAt', startDate)
          ..whereLessThan('createdAt', finishDate)
          ..whereEqualTo('statusIzin', 1)
          ..orderByDescending('createdAt');

    queryTeam.query().then((value) {
      if (value.statusCode == 200) {
        if (value.results != null) {
          setState(() {
            team = value.count;
          });
        }
      }
    });
    queryAbsence.query().then((value) {
      if (value.statusCode == 200) {
        setState(() {
          if (value.results != null) {
            listDefault.addAll(value.results);
            ParseObject parseAbsen;
            Map<String, dynamic> mapAbsen;
            for (int index = 0; index < listDefault.length; index++) {
              parseAbsen = listDefault[index];
              mapAbsen = Map<String, dynamic>.from(parseAbsen.toJson());
              setState(() {
                if (mapAbsen['absenMasuk'] != null) {
                  absence += 1;
                } else if (mapAbsen['lateTimes'] != null) {
                  late += 1;
                } else {}

                if (mapAbsen['earlyTimes'] != null) {
                  early += 1;
                } else if (mapAbsen['overtimeOut'] != null) {
                  overtime += 1;
                } else {}
              });
            }
          } else {
            data1 = true;
            listDefault.add({'desc': 'THERE IS NO DATA'});
          }
        });
      }
    }).catchError((e) {
      print(e);
      setState(() {
        listDefault.add('CONNECTION ERROR');
      });
    });
    queryUnAbsence.query().then((value) {
      if (value.statusCode == 200) {
        setState(() {
          if (value.results != null) {
            setState(() {
              teamUnabsence = value.count;
            });
            listUnAbsence = value.results;
          } else {
            data2 = true;
            listUnAbsence = ['THERE IS NO DATA'];
          }
        });
      }
    }).catchError((e) {
      print(e);
      setState(() {
        listUnAbsence = ['CONNECTION ERROR'];
      });
    });
    queryCuti.query().then((value) {
      if (value.statusCode == 200) {
        if (value.results != null) {
          setState(() {
            cuti = value.count;
          });
        }
      }
    });
    queryLeave.query().then((value) {
      if (value.statusCode == 200) {
        if (value.results != null) {
          setState(() {
            leave = value.count;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArgonColors.bgColorScreen,
      appBar: Navbar(
        title: "DASHBOARD",
        rightOptions: false,
        backButton: true,
      ),
//      appBar: AppBar(
//        automaticallyImplyLeading: false,
//        elevation: 10.0,
//        shape: RoundedRectangleBorder(
//          borderRadius: BorderRadius.only(
//              bottomLeft: Radius.circular(15.0),
//              bottomRight: Radius.circular(15.0)),
//        ),
//        backgroundColor: white,
//        title: Text(
//          "DASHBOARD",
//          style: TextStyle(color: teal),
//        ),
//        centerTitle: true,
//      ),
      body: _body(),
    );
  }

  Widget _body() {
    return Container(
      height: MediaQuery.of(context).size.height,
      padding: const EdgeInsets.all(10.0),
      decoration:
//          BoxDecoration(gradient: LinearGradient(colors: [info, primary])),
      BoxDecoration(
          image: DecorationImage(
              alignment: Alignment.bottomCenter,
              image: AssetImage("assets/images/onboard-background.png"),
              fit: BoxFit.fitWidth
          )
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: clickableDisplay(0, "ABSEN", green, absence),
                ),
                Expanded(
                  child: clickableDisplay(1, "TELAT", danger, late),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: clickableDisplay(2, "PULANG CEPAT", orange, early),
                ),
                Expanded(
                  child: clickableDisplay(3, "LEMBUR", pink, overtime),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: clickableDisplay(4, "IZIN", purple, leave),
                ),
                Expanded(
                  child: clickableDisplay(5, "CUTI", indigo, cuti),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: clickableDisplay(6, "JUMLAH STAFF", info, team),
                ),
                Expanded(
                  child: clickableDisplay(
                      7, "BELUM ABSEN", warning, teamUnabsence),
                ),
              ],
            ),
            _tableToday(),
            googleMap(),
          ],
        ),
      ),
    );
  }

  Widget clickableDisplay(int id, String label, Color colorLable, int value) {
    return Container(
      height: 100,
      width: 200,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.0)),
        ),
        shadowColor: kAppSoftLightTeal,
        elevation: 10.0,
        child: Material(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
          child: InkWell(
            onTap: id == 6
                ? null
                : () {
                    clickableFunc(id);
                  },
            splashColor: kAppLigthTeal,
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    margin: const EdgeInsets.only(top: 10.0, left: 10.0),
                    child: Text(
                      label,
                      style: TextStyle(
                        color: colorLable,
                      ),
                    )),
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.all(10.0),
                  child: Text(
                    '$value',
                    style: TextStyle(fontSize: 18.0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void clickableFunc(int id) {
    if (id == 0) {
      showDialog(
          context: context,
          builder: (_) => DashDisplayDialog(
                date: dateNow,
                id: 0,
              ));
    } else if (id == 1) {
      showDialog(
          context: context,
          builder: (_) => DashDisplayDialog(
                date: dateNow,
                id: 1,
              ));
    } else if (id == 2) {
      showDialog(
          context: context,
          builder: (_) => DashDisplayDialog(
                date: dateNow,
                id: 2,
              ));
    } else if (id == 3) {
      showDialog(
          context: context,
          builder: (_) => DashDisplayDialog(
                date: dateNow,
                id: 3,
              ));
    } else if (id == 4) {
      showDialog(
          context: context,
          builder: (_) => DashDisplayDialog(
                date: dateNow,
                id: 4,
              ));
    } else if (id == 5) {
      showDialog(
          context: context,
          builder: (_) => DashDisplayDialog(
                date: dateNow,
                id: 5,
              ));
    } else if (id == 6) {
    } else if (id == 7) {
      showDialog(
          context: context,
          builder: (_) => UnabsenceDialog(
                listUnabsence: listUnAbsence,
              ));
    }
  }

  Widget _tableToday() {
    return Container(
      margin: const EdgeInsets.only(top: 10.0, bottom: 10.0),
      height: 400,
      decoration: BoxDecoration(
          color: white, borderRadius: BorderRadius.circular(4.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 10.0, top: 10.0),
            child: Text(
              "ABSEN HARI INI",
              style: TextStyle(color: info),
            ),
          ),
          listDefault.isEmpty
              ? Container(
                  margin: const EdgeInsets.all(10.0),
                  width: MediaQuery.of(context).size.width,
                  height: 350,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : listDefault.contains('CONNECTION ERROR')
                  ? Container(
                      margin: const EdgeInsets.all(10.0),
                      width: MediaQuery.of(context).size.width,
                      height: 350,
                      child: Center(
                        child: Text('CONNECTION ERROR'),
                      ),
                    )
                  : Container(
                      margin: const EdgeInsets.all(10.0),
                      width: MediaQuery.of(context).size.width,
                      height: 350,
                      child: data1 == true
                          ? Center(
                              child: Text('THERE IS NO DATA'),
                            )
                          : ListView.builder(
                              itemCount: listDefault.length,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, index) {
                                String lat, long, fullname;
                                ParseObject objectList;

                                String kategoriAbsenMasuk = '-';
                                String kategoriAbsenKeluar = '-';
                                Color colorCategoryMasuk = info;
                                Color colorCategoryKeluar = info;
                                if (listDefault[index]['desc'] ==
                                    'THERE IS NO DATA') {
                                  return Container();
                                } else {
                                  objectList = listDefault[index];
                                }
                                objectList = listDefault[index];
                                mapDefault = Map<String, dynamic>.from(
                                    objectList.toJson());

                                if (mapDefault['fullname'] == null) {
                                  fullname = '-';
                                } else {
                                  fullname = mapDefault['fullname'];
                                }

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

                                if (mapDefault['absenKeluar'] != null &&
                                    mapDefault['earlyTimes'] == null &&
                                    mapDefault['overtimeOut'] == null) {
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

                                if (mapDefault['latitude'] != null) {
                                  lat = mapDefault['latitude'];
                                } else {
                                  lat = '0';
                                }
                                if (mapDefault['longitude'] != null) {
                                  long = mapDefault['longitude'];
                                } else {
                                  long = '0';
                                }

                                double hue = rng.nextDouble() * 239.0;
                                _markers.add(Marker(
                                  infoWindow: InfoWindow(title: fullname),
                                  markerId: MarkerId("marker$index"),
                                  icon: BitmapDescriptor.defaultMarkerWithHue(
                                      hue),
                                  position: LatLng(
                                      double.parse(lat), double.parse(long)),
                                ));

                                return Card(
                                  elevation: 10.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15.0)),
                                  ),
                                  child: Material(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(15.0)),
                                    child: InkWell(
                                      onTap: () {
                                        updateCamera(lat, long);
                                      },
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15.0)),
                                      splashColor: kAppLigthTeal,
                                      child: Container(
                                        margin: const EdgeInsets.all(5.0),
                                        padding: const EdgeInsets.all(10.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  bottom: 5.0),
                                              child: Text(
                                                fullname,
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    color: blue),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            mapDateMasuk['iso'] != null
                                                ? Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
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
                                                              overflow:
                                                                  TextOverflow
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
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 7,
                                                          child: Container(
                                                            child: Text(
                                                              mapDateMasuk[
                                                                          'iso'] ==
                                                                      null
                                                                  ? '-'
                                                                  : DateFormat(
                                                                          "EE, dd MMMM yyyy 'at' HH:mm")
                                                                      .format(DateTime.parse(
                                                                              mapDateMasuk['iso'])
                                                                          .toLocal()),
                                                              style: TextStyle(
                                                                fontSize: 14.0,
                                                              ),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
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
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
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
                                                              overflow:
                                                                  TextOverflow
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
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                        Expanded(
                                                          flex: 7,
                                                          child: Container(
                                                            child: Text(
                                                              mapDateKeluar[
                                                                          'iso'] ==
                                                                      null
                                                                  ? '-'
                                                                  : DateFormat(
                                                                          "EE, dd MMMM yyyy 'at' HH:mm")
                                                                      .format(DateTime.parse(
                                                                              mapDateKeluar['iso'])
                                                                          .toLocal()),
                                                              style: TextStyle(
                                                                fontSize: 14.0,
                                                              ),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
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
                                                    width:
                                                        MediaQuery.of(context)
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
                                                              overflow:
                                                                  TextOverflow
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
                                                              overflow:
                                                                  TextOverflow
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
                                                              overflow:
                                                                  TextOverflow
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
                                                    width:
                                                        MediaQuery.of(context)
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
                                                              overflow:
                                                                  TextOverflow
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
                                                              overflow:
                                                                  TextOverflow
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
                                                              overflow:
                                                                  TextOverflow
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
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
        ],
      ),
    );
  }

  void updateCamera(String lat, String long) {
    _markers.clear();
    _mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
          target: LatLng(double.parse(lat), double.parse(long)), zoom: 15.0),
    ));
  }

  Widget googleMap() {
    return Container(
      margin: const EdgeInsets.all(10.0),
      height: 500,
      child: GoogleMap(
        scrollGesturesEnabled: true,
        zoomGesturesEnabled: true,
        zoomControlsEnabled: true,
        rotateGesturesEnabled: true,
        mapType: MapType.normal,
        initialCameraPosition: _firstCameraPosition,
        markers: _markers,
        onMapCreated: (controller) {
          _mapController = controller;
        },
        onTap: (argument) {
          print(dataRow);
        },
      ),
    );
  }
}

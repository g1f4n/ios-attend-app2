import 'package:attend_app/utils/colors.dart';
import 'package:attend_app/utils/staff_cuti_req_util/cancel_cuti.dart';
import 'package:attend_app/utils/staff_cuti_req_util/edit_cuti.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class CutiPage extends StatefulWidget {
  final DateTime dateTime;
  final String status;
  final String timeCategory;

  const CutiPage({Key key, this.dateTime, this.status, this.timeCategory})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      CutiPageState(dateTime, status, timeCategory);
}

class CutiPageState extends State<CutiPage> {
  final DateTime dateTime;
  final String status;
  final String timeCategory;

  List listCuti;
  ParseObject objectCuti;
  ParseFile userImage;
  Map<String, dynamic> mapCuti, mapUserImage, mapDari, mapSampai, mapTime;
  String statusText;
  Color colorStatus;

  CutiPageState(this.dateTime, this.status, this.timeCategory);

  @override
  void initState() {
    super.initState();
    colorStatus = Colors.lightBlueAccent;
    parseLoadCuti();
  }

  void parseLoadCuti() async {
    ParseUser user = await ParseUser.currentUser();
    DateTime startDate;
    DateTime finishDate;
    if (timeCategory == 'Daily') {
      startDate =
          DateTime(dateTime.year, dateTime.month, dateTime.day, 0, 0, 0);
      finishDate =
          DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59);
    } else if (timeCategory == 'Weekly') {
      var dayOfWeek = 1;
      DateTime monday =
          dateTime.subtract(Duration(days: dateTime.weekday - dayOfWeek));
      startDate = DateTime(dateTime.year, dateTime.month, monday.day, 0, 0, 0);
      finishDate =
          DateTime(dateTime.year, dateTime.month, monday.day + 6, 23, 59, 59);
    } else if (timeCategory == 'Monthly') {
      int day = DateTime(dateTime.year, dateTime.month, 0).day;
      startDate = DateTime(dateTime.year, dateTime.month, 1, 0, 0, 0);
      finishDate = DateTime(dateTime.year, dateTime.month, day, 23, 59, 59);
    }

    QueryBuilder<ParseObject> queryCuti =
        QueryBuilder<ParseObject>(ParseObject(('Izin')))
          ..whereEqualTo('user', user)
          ..whereGreaterThanOrEqualsTo('createdAt', startDate)
          ..whereLessThan('createdAt', finishDate)
          ..whereEqualTo('statusIzin', 2)
          ..orderByDescending('createdAt');

    if (status == 'Approved') {
      queryCuti.whereEqualTo('status', 1);
    } else if (status == 'Rejected') {
      queryCuti.whereEqualTo('status', 0);
    } else {
      queryCuti.whereEqualTo('status', 3);
    }

    queryCuti.query().then((value) {
      setState(() {
        if (value.statusCode == 200) {
          if (value.results != null) {
            listCuti = value.results;
          } else {
            listCuti = ['THERE IS NO DATA'];
          }
        } else {
          listCuti = ['CONNECTION ERROR'];
        }
      });
    }).catchError((e) {
      print(e);
      setState(() {
        listCuti = ['CONNECTION ERROR'];
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
    return listCuti == null
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
        : listCuti[0] == 'CONNECTION ERROR'
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
                    child: Text(listCuti[0]),
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
                child: listCuti[0] == 'THERE IS NO DATA'
                    ? Center(
                        child: Text(listCuti[0]),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: listCuti.length,
                        itemBuilder: (context, index) {
                          objectCuti = listCuti[index];
                          mapCuti =
                              Map<String, dynamic>.from(objectCuti.toJson());
                          if (mapCuti['status'] != null) {
                            if (mapCuti['status'] == 3) {
                              statusText = 'Belum terproses';
                              colorStatus = Colors.purpleAccent;
                            } else if (mapCuti['status'] == 0) {
                              statusText = 'Rejected';
                              colorStatus = Colors.redAccent;
                            } else if (mapCuti['status'] == 1) {
                              statusText = 'Approved';
                              colorStatus = Colors.green;
                            } else {
                              statusText = '-';
                            }
                          } else {
                            mapCuti['status'] = null;
                          }
                          if (mapCuti['dari'] != null) {
                            mapDari = mapCuti['dari'];
                          } else {
                            mapDari = {'iso': null};
                          }
                          if (mapCuti['sampai'] != null) {
                            mapSampai = mapCuti['sampai'];
                          } else {
                            mapSampai = {'iso': null};
                          }
                          if (mapCuti['date'] != null) {
                            mapTime = mapCuti['date'];
                          } else {
                            mapTime = {'iso': null};
                          }
                          userImage = mapCuti['attachFile'];
                          if (userImage != null) {
                            mapUserImage =
                                Map<String, dynamic>.from(userImage.toJson());
                          } else {
                            mapUserImage = {'url': null};
                          }
                          return Card(
                            margin: EdgeInsets.all(10.0),
                            elevation: 10.0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15.0)),
                            ),
                            child: Column(
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
                                          mapCuti['fullname'] == null
                                              ? '-'
                                              : mapCuti['fullname'],
                                          style: TextStyle(
                                              fontSize: 18.0, color: blue),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                child: Text(
                                                  'Waktu request',
                                                  style: TextStyle(
                                                    fontSize: 14.0,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Container(
                                                child: Text(
                                                  mapTime['iso'] == null
                                                      ? '-'
                                                      : DateFormat(
                                                              "EE, dd MMMM yyyy 'at' HH:mm")
                                                          .format(DateTime.parse(
                                                                  mapTime[
                                                                      'iso'])
                                                              .toLocal()),
                                                  style: TextStyle(
                                                    fontSize: 14.0,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                child: Text(
                                                  'Dari',
                                                  style: TextStyle(
                                                    fontSize: 14.0,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                child: Text(
                                                  'Sampai',
                                                  style: TextStyle(
                                                    fontSize: 14.0,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                child: Text(
                                                  'Kategori',
                                                  style: TextStyle(
                                                    fontSize: 14.0,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Container(
                                                child: Text(
                                                  mapCuti['descIzin'] == null
                                                      ? '-'
                                                      : mapCuti['descIzin'],
                                                  style: TextStyle(
                                                    fontSize: 14.0,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width,
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
                                                  overflow:
                                                      TextOverflow.ellipsis,
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
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Container(
                                                child: Text(
                                                  mapCuti['alasanIzin'] == null
                                                      ? '-'
                                                      : mapCuti['alasanIzin'],
                                                  style: TextStyle(
                                                    fontSize: 14.0,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin:
                                            const EdgeInsets.only(top: 10.0),
                                        child: Text(
                                          statusText == null ? '-' : statusText,
                                          style: TextStyle(
                                            fontSize: 14.0,
                                            color: colorStatus,
                                          ),
                                        ),
                                      ),
                                      // Row(
                                      //   children: <Widget>[],
                                      // ),
                                    ],
                                  ),
                                ),
                                mapCuti['status'] == 3
                                    ? Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Container(
                                              height: 40.0,
                                              child: RaisedButton(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(15.0),
                                                  ),
                                                ),
                                                color: orange,
                                                child: Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                        child: Icon(Icons.edit,
                                                            color:
                                                                Colors.white)),
                                                    Expanded(
                                                        child: Text('Edit',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)))
                                                  ],
                                                ),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) => EditCuti(
                                                      objectDetailView:
                                                          listCuti[index],
                                                    ),
                                                  ).then((value) {
                                                    if (value[0] == 'edited') {
                                                      setState(() {
                                                        parseLoadCuti();
                                                      });
                                                    }
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                          Expanded(
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
                                                        child: Text('Cancel',
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white)))
                                                  ],
                                                ),
                                                onPressed: () {
                                                  showDialog(
                                                    context: context,
                                                    builder: (_) => CancelCuti(
                                                      objectDetailView:
                                                          listCuti[index],
                                                    ),
                                                  ).then((value) {
                                                    if (value[0] == 'cancel') {
                                                      setState(() {
                                                        parseLoadCuti();
                                                      });
                                                    }
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : Container(),
                              ],
                            ),
                          );
                        },
                      ),
              );
  }
}

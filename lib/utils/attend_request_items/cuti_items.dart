import 'package:attend_app/utils/request_dialog_view/request_absen_image_view_dialog.dart';
import 'package:attend_app/utils/request_dialog_view/request_cuti_approve_reject.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import '../colors.dart';

class CutiItems extends StatefulWidget {
  final DateTime dateTime;
  final String status;
  final String timeCategory;

  const CutiItems({Key key, this.dateTime, this.status, this.timeCategory})
      : super(key: key);
  @override
  State<StatefulWidget> createState() =>
      CutiItemsState(dateTime, status, timeCategory);
}

class CutiItemsState extends State<CutiItems> {
  final DateTime dateTime;
  final String status;
  final String timeCategory;

  List listCuti;
  ParseObject objectCuti;
  Map<String, dynamic> mapCuti, mapDari, mapSampai;

  String action;
  Color actionColor;

  CutiItemsState(this.dateTime, this.status, this.timeCategory);

  @override
  void initState() {
    super.initState();
    parseLoadCuti();
  }

  void parseLoadCuti() async {
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
    QueryBuilder<ParseObject> queryCuti =
        QueryBuilder<ParseObject>(ParseObject(('Izin')))
          ..whereMatchesKeyInQuery('user', 'objectId', queryTeam)
          ..whereGreaterThanOrEqualsTo('createdAt', startDate)
          ..whereLessThan('createdAt', finishDate)
          ..whereEqualTo('statusIzin', 2)
          ..orderByDescending('createdAt');

    if (status == 'Approved') {
      action = 'Approved';
      actionColor = Colors.green;
      queryCuti.whereEqualTo('status', 1);
    } else if (status == 'Rejected') {
      action = 'Rejected';
      queryCuti.whereEqualTo('status', 0);
      actionColor = Colors.red;
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
                child: Center(
                  child: listCuti[0] == 'THERE IS NO DATA'
                      ? Center(
                          child: Text(listCuti[0]),
                        )
                      : ListView.builder(
                          addAutomaticKeepAlives: true,
                          scrollDirection: Axis.vertical,
                          itemCount: listCuti.length,
                          itemBuilder: (context, index) {
                            objectCuti = listCuti[index];
                            mapCuti =
                                Map<String, dynamic>.from(objectCuti.toJson());
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
                            return Card(
                              margin: EdgeInsets.all(10.0),
                              elevation: 10.0,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(color: Colors.black45),
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
                                          margin: const EdgeInsets.only(
                                              bottom: 5.0),
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
                                            children: <Widget>[
                                              Expanded(
                                                flex: 1,
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
                                                flex: 3,
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
                                                flex: 1,
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
                                                flex: 3,
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
                                                flex: 1,
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
                                                flex: 3,
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
                                                flex: 1,
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
                                                flex: 3,
                                                child: Container(
                                                  child: Text(
                                                    mapCuti['alasanIzin'] ==
                                                            null
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
                                        status == 'Belum Terproses'
                                            ? Container()
                                            : Container(
                                                margin: const EdgeInsets.only(
                                                    top: 10.0),
                                                child: Text(
                                                  action,
                                                  style: TextStyle(
                                                      fontSize: 16.0,
                                                      color: actionColor),
                                                ),
                                              ),
                                      ],
                                    ),
                                  ),
                                  status == 'Belum Terproses'
                                      ? Row(
                                          children: <Widget>[
                                            mapCuti['attachFile'] != null
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
                                                                  listCuti[
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
                                                  shape: mapCuti[
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
                                                          child: Icon(
                                                              Icons.check,
                                                              color: Colors
                                                                  .white)),
                                                      Expanded(
                                                          child: Text('Approve',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white)))
                                                    ],
                                                  ),
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (_) =>
                                                          CutiApproveRejectDialog(
                                                        objectDetailView:
                                                            listCuti[index],
                                                        classname: 'Izin',
                                                      ),
                                                    ).then((value) {
                                                      if (value[0] ==
                                                              'approve' ||
                                                          value[0] ==
                                                              'reject') {
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
                                                          child: Icon(
                                                              Icons.clear,
                                                              color: Colors
                                                                  .white)),
                                                      Expanded(
                                                          child: Text('Reject',
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white)))
                                                    ],
                                                  ),
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (_) =>
                                                          CutiApproveRejectDialog(
                                                        objectDetailView:
                                                            listCuti[index],
                                                        code: 1,
                                                        classname: 'Izin',
                                                      ),
                                                    ).then((value) {
                                                      if (value[0] ==
                                                              'approve' ||
                                                          value[0] ==
                                                              'reject') {
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
                                      : Container()
                                ],
                              ),
                            );
                          },
                        ),
                ),
              );
  }
}

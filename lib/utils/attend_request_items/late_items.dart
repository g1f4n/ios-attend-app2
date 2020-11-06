import 'package:attend_app/utils/request_dialog_view/request_absen_aprrove_reject_dialog.dart';
import 'package:attend_app/utils/request_dialog_view/request_absen_image_view_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import '../colors.dart';

class LateItems extends StatefulWidget {
  final DateTime dateTime;
  final String status;
  final String timeCategory;

  const LateItems({Key key, this.dateTime, this.status, this.timeCategory})
      : super(key: key);
  @override
  State<StatefulWidget> createState() =>
      LateItemsState(dateTime, status, timeCategory);
}

class LateItemsState extends State<LateItems> {
  final DateTime dateTime;
  final String status;
  final String timeCategory;

  LateItemsState(this.dateTime, this.status, this.timeCategory);

  List listLate;
  ParseObject objectLate;
  Map<String, dynamic> mapLate, mapTime;
  String action;
  Color actionColor;

  @override
  void initState() {
    super.initState();
    parseLoadLate();
  }

  void parseLoadLate() async {
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
    QueryBuilder<ParseObject> queryLate =
        QueryBuilder<ParseObject>(ParseObject(('Absence')))
          ..whereMatchesKeyInQuery('user', 'objectId', queryTeam)
          ..whereGreaterThanOrEqualsTo('createdAt', startDate)
          ..whereLessThan('createdAt', finishDate)
          ..whereValueExists('lateTimes', true)
          ..orderByDescending('createdAt');

    if (status == 'Approved') {
      action = 'Approved';
      actionColor = Colors.green;
      queryLate.whereEqualTo('approvalLate', 1);
    } else if (status == 'Rejected') {
      action = 'Rejected';
      queryLate.whereEqualTo('approvalLate', 0);
      actionColor = Colors.red;
    } else {
      queryLate.whereEqualTo('approvalLate', 3);
    }

    queryLate.query().then((value) {
      setState(() {
        if (value.statusCode == 200) {
          if (value.results != null) {
            listLate = value.results;
          } else {
            listLate = ['THERE IS NO DATA'];
          }
        } else {
          listLate = ['CONNECTION ERROR'];
        }
      });
    }).catchError((e) {
      print(e);
      setState(() {
        listLate = ['CONNECTION ERROR'];
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
    return listLate == null
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
        : listLate[0] == 'CONNECTION ERROR'
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
                    child: Text(listLate[0]),
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
                  child: listLate[0] == 'THERE IS NO DATA'
                      ? Center(
                          child: Text(listLate[0]),
                        )
                      : ListView.builder(
                          addAutomaticKeepAlives: true,
                          scrollDirection: Axis.vertical,
                          itemCount: listLate.length,
                          itemBuilder: (context, index) {
                            objectLate = listLate[index];
                            mapLate =
                                Map<String, dynamic>.from(objectLate.toJson());
                            if (mapLate['lateTimes'] != null) {
                              mapTime = mapLate['lateTimes'];
                            } else {
                              mapTime = {'iso': null};
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
                                            mapLate['fullname'] == null
                                                ? '-'
                                                : mapLate['fullname'],
                                            style: TextStyle(
                                                fontSize: 16.0, color: blue),
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
                                                    mapLate['alasanMasuk'] ==
                                                            null
                                                        ? '-'
                                                        : mapLate[
                                                            'alasanMasuk'],
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
                                                  color: kAppDarkYellow,
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
                                                  onPressed: () async {
                                                    await showDialog(
                                                      context: context,
                                                      builder: (_) =>
                                                          ImageViewDialog(
                                                        objectDetailView:
                                                            listLate[index],
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                height: 40.0,
                                                child: RaisedButton(
                                                  color: kAppLightBlue,
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
                                                          ApproveRejectDialog(
                                                        objectDetailView:
                                                            listLate[index],
                                                        classname: 'Absence',
                                                      ),
                                                    ).then((value) {
                                                      if (value[0] ==
                                                              'approve' ||
                                                          value[0] ==
                                                              'reject') {
                                                        setState(() {
                                                          parseLoadLate();
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
                                                  color: Colors.red,
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
                                                          ApproveRejectDialog(
                                                        objectDetailView:
                                                            listLate[index],
                                                        code: 1,
                                                        classname: 'Absence',
                                                      ),
                                                    ).then((value) {
                                                      if (value[0] ==
                                                              'approve' ||
                                                          value[0] ==
                                                              'reject') {
                                                        setState(() {
                                                          parseLoadLate();
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

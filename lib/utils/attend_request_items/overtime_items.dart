import 'package:attend_app/utils/request_dialog_view/request_absen_aprrove_reject_dialog.dart';
import 'package:attend_app/utils/request_dialog_view/request_absen_image_view_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import '../colors.dart';

class OvertimeItems extends StatefulWidget {
  final DateTime dateTime;
  final String status;
  final String timeCategory;

  const OvertimeItems({Key key, this.dateTime, this.status, this.timeCategory})
      : super(key: key);
  @override
  State<StatefulWidget> createState() =>
      OvertimeItemsState(dateTime, status, timeCategory);
}

class OvertimeItemsState extends State<OvertimeItems> {
  final DateTime dateTime;
  final String status;
  final String timeCategory;

  List listOvertime;
  ParseObject objectOvertime;
  Map<String, dynamic> mapOvertime, mapTime;

  String action;
  Color actionColor;

  OvertimeItemsState(this.dateTime, this.status, this.timeCategory);

  @override
  void initState() {
    super.initState();
    parseLoadOver();
  }

  void parseLoadOver() async {
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
    QueryBuilder<ParseObject> queryOver =
        QueryBuilder<ParseObject>(ParseObject(('Absence')))
          ..whereMatchesKeyInQuery('user', 'objectId', queryTeam)
          ..whereGreaterThanOrEqualsTo('createdAt', startDate)
          ..whereLessThan('createdAt', finishDate)
          ..whereValueExists('overtimeOut', true)
          ..orderByDescending('createdAt');

    if (status == 'Approved') {
      action = 'Approved';
      actionColor = Colors.green;
      queryOver.whereEqualTo('approvalOvertime', 1);
    } else if (status == 'Rejected') {
      action = 'Rejected';
      queryOver.whereEqualTo('approvalOvertime', 0);
      actionColor = Colors.red;
    } else {
      queryOver.whereEqualTo('approvalOvertime', 3);
    }

    queryOver.query().then((value) {
      setState(() {
        if (value.statusCode == 200) {
          if (value.results != null) {
            listOvertime = value.results;
          } else {
            listOvertime = ['THERE IS NO DATA'];
          }
        } else {
          listOvertime = ['CONNECTION ERROR'];
        }
      });
    }).catchError((e) {
      print(e);
      setState(() {
        listOvertime = ['CONNECTION ERROR'];
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
    return listOvertime == null
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
        : listOvertime[0] == 'CONNECTION ERROR'
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
                    child: Text(listOvertime[0]),
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
                  child: listOvertime[0] == 'THERE IS NO DATA'
                      ? Center(
                          child: Text(listOvertime[0]),
                        )
                      : ListView.builder(
                          addAutomaticKeepAlives: true,
                          scrollDirection: Axis.vertical,
                          itemCount: listOvertime.length,
                          itemBuilder: (context, index) {
                            objectOvertime = listOvertime[index];
                            mapOvertime = Map<String, dynamic>.from(
                                objectOvertime.toJson());
                            if (mapOvertime['overtimeOut'] != null) {
                              mapTime = mapOvertime['overtimeOut'];
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
                                            mapOvertime['fullname'] == null
                                                ? '-'
                                                : mapOvertime['fullname'],
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
                                                    mapOvertime['alasanKeluar'] ==
                                                            null
                                                        ? '-'
                                                        : mapOvertime[
                                                            'alasanKeluar'],
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
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (_) =>
                                                          ImageViewDialog(
                                                        objectDetailView:
                                                            listOvertime[index],
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
                                                            listOvertime[index],
                                                        classname: 'Absence',
                                                      ),
                                                    ).then((value) {
                                                      if (value[0] ==
                                                              'approve' ||
                                                          value[0] ==
                                                              'reject') {
                                                        setState(() {
                                                          parseLoadOver();
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
                                                            listOvertime[index],
                                                        code: 1,
                                                        classname: 'Absence',
                                                      ),
                                                    ).then((value) {
                                                      if (value[0] ==
                                                              'approve' ||
                                                          value[0] ==
                                                              'reject') {
                                                        setState(() {
                                                          parseLoadOver();
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

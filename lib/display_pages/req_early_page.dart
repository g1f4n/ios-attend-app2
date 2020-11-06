import 'package:attend_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class EarlyLeavePage extends StatefulWidget {
  final DateTime dateTime;
  final String status;
  final String timeCategory;

  const EarlyLeavePage({Key key, this.dateTime, this.status, this.timeCategory})
      : super(key: key);
  @override
  State<StatefulWidget> createState() =>
      EarlyLeavePageState(dateTime, status, timeCategory);
}

class EarlyLeavePageState extends State<EarlyLeavePage> {
  final DateTime dateTime;
  final String status;
  final String timeCategory;

  List listEarly;
  ParseObject objectEarly;
  ParseFile userImage;
  Map<String, dynamic> mapEarly, mapUserImage, mapTime;
  String statusText;

  Color colorStatus;

  EarlyLeavePageState(this.dateTime, this.status, this.timeCategory);

  @override
  void initState() {
    super.initState();
    colorStatus = Colors.lightBlueAccent;
    parseLoadEarly();
  }

  void parseLoadEarly() async {
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
    QueryBuilder<ParseObject> queryEarly =
        QueryBuilder<ParseObject>(ParseObject(('Absence')))
          ..whereEqualTo('user', user)
          ..whereGreaterThanOrEqualsTo('createdAt', startDate)
          ..whereLessThan('createdAt', finishDate)
          ..whereValueExists('earlyTimes', true)
          ..orderByDescending('createdAt');

    if (status == 'Approved') {
      queryEarly.whereEqualTo('approvalEarly', 1);
    } else if (status == 'Rejected') {
      queryEarly.whereEqualTo('approvalEarly', 0);
    } else {
      queryEarly.whereEqualTo('approvalEarly', 3);
    }

    queryEarly.query().then((value) {
      setState(() {
        if (value.statusCode == 200) {
          if (value.results != null) {
            listEarly = value.results;
          } else {
            listEarly = ['THERE IS NO DATA'];
          }
        } else {
          listEarly = ['CONNECTION ERROR'];
        }
      });
    }).catchError((e) {
      print(e);
      setState(() {
        listEarly = ['CONNECTION ERROR'];
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
    return listEarly == null
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
        : listEarly[0] == 'CONNECTION ERROR'
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
                    child: Text(listEarly[0]),
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
                child: listEarly[0] == 'THERE IS NO DATA'
                    ? Center(
                        child: Text(listEarly[0]),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: listEarly.length,
                        itemBuilder: (context, index) {
                          objectEarly = listEarly[index];
                          mapEarly =
                              Map<String, dynamic>.from(objectEarly.toJson());
                          if (mapEarly['approvalEarly'] != null) {
                            if (mapEarly['approvalEarly'] == 3) {
                              statusText = 'Belum terproses';
                              colorStatus = Colors.purpleAccent;
                            } else if (mapEarly['approvalEarly'] == 0) {
                              statusText = 'Rejected';
                              colorStatus = Colors.redAccent;
                            } else if (mapEarly['approvalEarly'] == 1) {
                              statusText = 'Approved';
                              colorStatus = Colors.green;
                            } else {
                              statusText = '-';
                            }
                          } else {
                            mapEarly['approvalEarly'] = null;
                          }
                          if (mapEarly['earlyTimes'] != null) {
                            mapTime = mapEarly['earlyTimes'];
                          } else {
                            mapTime = {'iso': null};
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
                                      mapEarly['fullname'] == null
                                          ? '-'
                                          : mapEarly['fullname'],
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
                                          flex: 2,
                                          child: Container(
                                            child: Text(
                                              'Waktu request',
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
                                          flex: 4,
                                          child: Container(
                                            child: Text(
                                              mapTime['iso'] == null
                                                  ? '-'
                                                  : DateFormat(
                                                          "EE, dd MMMM yyyy 'at' HH:mm")
                                                      .format(DateTime.parse(
                                                              mapTime['iso'])
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
                                          flex: 2,
                                          child: Container(
                                            child: Text(
                                              'Alasan',
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
                                          flex: 4,
                                          child: Container(
                                            child: Text(
                                              mapEarly['alasanKeluar'] == null
                                                  ? '-'
                                                  : mapEarly['alasanKeluar'],
                                              style: TextStyle(
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
                                    margin: const EdgeInsets.only(top: 10.0),
                                    child: Text(
                                      statusText == null ? '-' : statusText,
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        color: colorStatus,
                                      ),
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

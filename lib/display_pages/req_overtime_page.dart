import 'package:attend_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class OvertimePage extends StatefulWidget {
  final DateTime dateTime;
  final String status;
  final String timeCategory;

  const OvertimePage({Key key, this.dateTime, this.status, this.timeCategory})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      OvertimePageState(dateTime, status, timeCategory);
}

class OvertimePageState extends State<OvertimePage> {
  final DateTime dateTime;
  final String status;
  final String timeCategory;

  List listOvertime;
  ParseObject objectOvertime;
  ParseFile userImage;
  Map<String, dynamic> mapOvertime, mapUserImage, mapTime;
  String statusText;
  Color colorStatus;

  OvertimePageState(this.dateTime, this.status, this.timeCategory);

  @override
  void initState() {
    super.initState();
    colorStatus = Colors.lightBlueAccent;
    parseLoadOver();
  }

  void parseLoadOver() async {
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
    QueryBuilder<ParseObject> queryOver =
        QueryBuilder<ParseObject>(ParseObject(('Absence')))
          ..whereEqualTo('user', user)
          ..whereGreaterThanOrEqualsTo('createdAt', startDate)
          ..whereLessThan('createdAt', finishDate)
          ..whereValueExists('overtimeOut', true)
          ..orderByDescending('createdAt');

    if (status == 'Approved') {
      queryOver.whereEqualTo('approvalOvertime', 1);
    } else if (status == 'Rejected') {
      queryOver.whereEqualTo('approvalOvertime', 0);
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
                child: listOvertime[0] == 'THERE IS NO DATA'
                    ? Center(
                        child: Text(listOvertime[0]),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: listOvertime.length,
                        itemBuilder: (context, index) {
                          objectOvertime = listOvertime[index];
                          mapOvertime = Map<String, dynamic>.from(
                              objectOvertime.toJson());
                          if (mapOvertime['approvalOvertime'] != null) {
                            if (mapOvertime['status'] == 3) {
                              statusText = 'Belum terproses';
                              colorStatus = Colors.purpleAccent;
                            } else if (mapOvertime['approvalOvertime'] == 0) {
                              statusText = 'Rejected';
                              colorStatus = Colors.redAccent;
                            } else if (mapOvertime['approvalOvertime'] == 1) {
                              statusText = 'Approved';
                              colorStatus = Colors.green;
                            } else {
                              statusText = '-';
                            }
                          } else {
                            mapOvertime['approvalOvertime'] = null;
                          }
                          if (mapOvertime['overtimeOut'] != null) {
                            mapTime = mapOvertime['overtimeOut'];
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
                                              mapOvertime['alasanKeluar'] ==
                                                      null
                                                  ? '-'
                                                  : mapOvertime['alasanKeluar'],
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

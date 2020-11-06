import 'package:attend_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class LatePage extends StatefulWidget {
  final DateTime dateTime;
  final String status;
  final String timeCategory;

  const LatePage({Key key, this.dateTime, this.status, this.timeCategory})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      LatePageState(dateTime, status, timeCategory);
}

class LatePageState extends State<LatePage> {
  final DateTime dateTime;
  final String status;
  final String timeCategory;

  List listLate;
  ParseObject objectLate;
  ParseFile userImage;
  Map<String, dynamic> mapLate, mapUserImage, mapTime;
  String statusText;
  Color colorStatus;

  LatePageState(this.dateTime, this.status, this.timeCategory);

  @override
  void initState() {
    super.initState();
    colorStatus = Colors.lightBlueAccent;
    parseLoadLate();
  }

  void parseLoadLate() async {
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
    QueryBuilder<ParseObject> queryLate =
        QueryBuilder<ParseObject>(ParseObject(('Absence')))
          ..whereEqualTo('user', user)
          ..whereGreaterThanOrEqualsTo('createdAt', startDate)
          ..whereLessThan('createdAt', finishDate)
          ..whereValueExists('lateTimes', true)
          ..orderByDescending('createdAt');

    if (status == 'Approved') {
      queryLate.whereEqualTo('approvalLate', 1);
    } else if (status == 'Rejected') {
      queryLate.whereEqualTo('approvalLate', 0);
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
                child: listLate[0] == 'THERE IS NO DATA'
                    ? Center(
                        child: Text(listLate[0]),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: listLate.length,
                        itemBuilder: (context, index) {
                          objectLate = listLate[index];
                          mapLate =
                              Map<String, dynamic>.from(objectLate.toJson());
                          if (mapLate['approvalLate'] != null) {
                            if (mapLate['approvalLate'] == 3) {
                              statusText = 'Belum terproses';
                              colorStatus = Colors.purpleAccent;
                            } else if (mapLate['approvalLate'] == 0) {
                              statusText = 'Rejected';
                              colorStatus = Colors.redAccent;
                            } else if (mapLate['approvalLate'] == 1) {
                              statusText = 'Approved';
                              colorStatus = Colors.green;
                            } else {
                              statusText = '-';
                            }
                          } else {
                            mapLate['approvalLate'] = null;
                          }
                          if (mapLate['lateTimes'] != null) {
                            mapTime = mapLate['lateTimes'];
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
                                              mapLate['alasanMasuk'] == null
                                                  ? '-'
                                                  : mapLate['alasanMasuk'],
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

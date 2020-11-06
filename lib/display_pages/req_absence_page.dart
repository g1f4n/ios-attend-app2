import 'package:attend_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class AbsencePage extends StatefulWidget {
  final DateTime dateTime;
  final String timeCategory;

  const AbsencePage({Key key, this.dateTime, this.timeCategory})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      AbsencePageState(dateTime, timeCategory);
}

class AbsencePageState extends State<AbsencePage> {
  final DateTime dateTime;
  final String timeCategory;

  List listAbsence;
  ParseObject objectAbsence;
  ParseFile userImage;
  Map<String, dynamic> mapAbsence, mapUserImage, mapDateMasuk, mapDateKeluar;

  AbsencePageState(this.dateTime, this.timeCategory);

  @override
  void initState() {
    super.initState();
    parseLoadAbsence();
  }

  void parseLoadAbsence() async {
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
    QueryBuilder<ParseObject> queryAbsence =
        QueryBuilder<ParseObject>(ParseObject(('Absence')))
          ..whereEqualTo('user', user)
          ..whereGreaterThanOrEqualsTo('createdAt', startDate)
          ..whereLessThan('createdAt', finishDate)
          ..whereValueExists('lateTimes', false)
          ..whereValueExists('earlyTimes', false)
          ..whereValueExists('overtimeOut', false)
          ..orderByDescending('createdAt');

    queryAbsence.query().then((value) {
      setState(() {
        if (value.statusCode == 200) {
          if (value.results != null) {
            listAbsence = value.results;
          } else {
            listAbsence = ['THERE IS NO DATA'];
          }
        } else {
          listAbsence = ['CONNECTION ERROR'];
        }
      });
    }).catchError((e) {
      print(e);
      setState(() {
        listAbsence = ['CONNECTION ERROR'];
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
    return listAbsence == null
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
        : listAbsence[0] == 'CONNECTION ERROR'
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
                    child: Text(listAbsence[0]),
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
                child: listAbsence[0] == 'THERE IS NO DATA'
                    ? Center(
                        child: Text(listAbsence[0]),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: listAbsence.length,
                        itemBuilder: (context, index) {
                          objectAbsence = listAbsence[index];
                          mapAbsence =
                              Map<String, dynamic>.from(objectAbsence.toJson());
                          if (mapAbsence['absenMasuk'] != null) {
                            mapDateMasuk = mapAbsence['absenMasuk'];
                          } else {
                            mapDateMasuk = {'iso': null};
                          }
                          if (mapAbsence['absenKeluar'] != null) {
                            mapDateKeluar = mapAbsence['absenKeluar'];
                          } else {
                            mapDateKeluar = {'iso': null};
                          }
                          userImage = mapAbsence['selfieImage'];
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
                            child: Container(
                              margin: const EdgeInsets.all(5.0),
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 5.0),
                                    child: Text(
                                      mapAbsence['fullname'] == null
                                          ? '-'
                                          : mapAbsence['fullname'],
                                      style: TextStyle(
                                          fontSize: 16.0, color: blue),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                                              'Jam masuk',
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
                                          flex: 5,
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
                                          flex: 2,
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
                                          flex: 5,
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

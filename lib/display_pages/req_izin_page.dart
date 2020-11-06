import 'package:attend_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class IzinPage extends StatefulWidget {
  final DateTime dateTime;
  final String status;
  final String timeCategory;

  const IzinPage({Key key, this.dateTime, this.status, this.timeCategory})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      IzinPageState(dateTime, status, timeCategory);
}

class IzinPageState extends State<IzinPage> {
  final DateTime dateTime;
  final String status;
  final String timeCategory;

  List listLeave;
  ParseObject objectIzin;
  ParseFile userImage;
  Map<String, dynamic> mapIzin, mapUserImage, mapDari, mapSampai, mapTime;
  String statusText;
  Color colorStatus;

  IzinPageState(this.dateTime, this.status, this.timeCategory);

  @override
  void initState() {
    super.initState();
    colorStatus = Colors.lightBlueAccent;
    parseLoadLeave();
  }

  void parseLoadLeave() async {
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

    QueryBuilder<ParseObject> queryLeave =
        QueryBuilder<ParseObject>(ParseObject(('Izin')))
          ..whereEqualTo('user', user)
          ..whereGreaterThanOrEqualsTo('createdAt', startDate)
          ..whereLessThan('createdAt', finishDate)
          ..whereEqualTo('statusIzin', 1)
          ..orderByDescending('createdAt');

    if (status == 'Approved') {
      queryLeave.whereEqualTo('status', 1);
    } else if (status == 'Rejected') {
      queryLeave.whereEqualTo('status', 0);
    } else {
      queryLeave.whereEqualTo('status', 3);
    }

    queryLeave.query().then((value) {
      setState(() {
        if (value.statusCode == 200) {
          if (value.results != null) {
            listLeave = value.results;
          } else {
            listLeave = ['THERE IS NO DATA'];
          }
        } else {
          listLeave = ['CONNECTION ERROR'];
        }
      });
    }).catchError((e) {
      print(e);
      setState(() {
        listLeave = ['CONNECTION ERROR'];
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
    return listLeave == null
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
        : listLeave[0] == 'CONNECTION ERROR'
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
                    child: Text(listLeave[0]),
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
                child: listLeave[0] == 'THERE IS NO DATA'
                    ? Center(
                        child: Text(listLeave[0]),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: listLeave.length,
                        itemBuilder: (context, index) {
                          objectIzin = listLeave[index];
                          mapIzin =
                              Map<String, dynamic>.from(objectIzin.toJson());
                          if (mapIzin['status'] != null) {
                            if (mapIzin['status'] == 3) {
                              statusText = 'Belum terproses';
                              colorStatus = Colors.purpleAccent;
                            } else if (mapIzin['status'] == 0) {
                              statusText = 'Rejected';
                              colorStatus = Colors.redAccent;
                            } else if (mapIzin['status'] == 1) {
                              statusText = 'Approved';
                              colorStatus = Colors.green;
                            } else {
                              statusText = '-';
                            }
                          } else {
                            mapIzin['status'] = null;
                          }
                          if (mapIzin['dari'] != null) {
                            mapDari = mapIzin['dari'];
                          } else {
                            mapDari = {'iso': null};
                          }
                          if (mapIzin['sampai'] != null) {
                            mapSampai = mapIzin['sampai'];
                          } else {
                            mapSampai = {'iso': null};
                          }
                          if (mapIzin['date'] != null) {
                            mapTime = mapIzin['date'];
                          } else {
                            mapTime = {'iso': null};
                          }
                          userImage = mapIzin['attachFile'];
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
                                      mapIzin['fullname'] == null
                                          ? '-'
                                          : mapIzin['fullname'],
                                      style: TextStyle(
                                          fontSize: 16.0, color: blue),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  mapIzin['date'] != null
                                      ? Container(
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
                                        )
                                      : Container(),
                                  mapIzin['dari'] != null
                                      ? Container(
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
                                        )
                                      : Container(),
                                  mapIzin['sampai'] != null
                                      ? Container(
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
                                        )
                                      : Container(),
                                  Container(
                                    width: MediaQuery.of(context).size.width,
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
                                              mapIzin['descIzin'] == null
                                                  ? '-'
                                                  : mapIzin['descIzin'],
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
                                              mapIzin['alasanIzin'] == null
                                                  ? '-'
                                                  : mapIzin['alasanIzin'],
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

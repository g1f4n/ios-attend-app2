import 'package:attend_app/utils/colors.dart';
import 'package:attend_app/utils/request_dialog_view/request_team_detail_dialog.dart';
import 'package:attend_app/utils/request_dialog_view/request_team_edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class ChangeTeamInfo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ChangeTeamInfoState();
}

class ChangeTeamInfoState extends State<ChangeTeamInfo> {
  List listTeamInfo;
  ParseObject objectTeamInfo;
  ParseFile facePhoto;
  Map<String, dynamic> mapTeamInfo;
  Map<String, dynamic> mapFacePhoto;

  List listTableShifting;
  List listShift = ['Pilih Tipe Shift'];
  List listObjectIdShift = ['EMPTY'];
  ParseObject objectShifting;
  Map<String, dynamic> mapShifting;

  @override
  void initState() {
    super.initState();
    _loadTeam();
  }

  void _loadTeam() async {
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

    queryTeam.query().then((value) {
      setState(() {
        if (value.statusCode == 200) {
          if (value.results != null) {
            listTeamInfo = value.results;
          } else {
            listTeamInfo = ['THERE IS NO DATA'];
          }
        } else {
          listTeamInfo = ['CONNECTION ERROR'];
        }
      });
    }).catchError((e) {
      print(e);
      setState(() {
        listTeamInfo = ['CONNECTION ERROR'];
      });
    });

    QueryBuilder<ParseObject> queryShift =
        QueryBuilder<ParseObject>(ParseObject(('Shifting')));

    queryShift.query().then((value) {
      setState(() {
        if (value.statusCode == 200) {
          if (value.results != null) {
            listTableShifting = value.results;
            for (int index = 0; index < listTableShifting.length; index++) {
              objectShifting = listTableShifting[index];
              mapShifting = Map<String, dynamic>.from(objectShifting.toJson());
              if (mapShifting['tipeShift'] != null) {
                listShift.add(mapShifting['tipeShift']);
                listObjectIdShift.add(mapShifting['objectId']);
              } else {
                listShift.add('-');
                listObjectIdShift.add(mapShifting['objectId']);
              }
            }
          } else {
            listTableShifting = ['THERE IS NO DATA'];
          }
        } else {
          listTableShifting = ['CONNECTION ERROR'];
        }
      });
    }).catchError((e) {
      print(e);
      setState(() {
        listTableShifting = ['CONNECTION ERROR'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration:
//            BoxDecoration(gradient: LinearGradient(colors: [info, primary])),
        BoxDecoration(
            image: DecorationImage(
                alignment: Alignment.bottomCenter,
                image: AssetImage("assets/images/onboard-background.png"),
                fit: BoxFit.fitWidth
            )
        ),
        child: _body(),
      ),
    );
  }

  Widget _body() {
    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: listTeamInfo == null
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
          : listTeamInfo[0] == 'CONNECTION ERROR'
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
                      child: Text(listTeamInfo[0]),
                    ),
                  ),
                )
              : Container(
                  margin:
                      const EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0),
                  child: Column(
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(
                            left: 5.0, right: 5.0, top: 5.0, bottom: 5.0),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 1.3,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.black38),
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0)),
                          ),
                          shadowColor: kAppSoftLightTeal,
                          elevation: 5.0,
                          child: Center(
                            child: listTeamInfo[0] == 'THERE IS NO DATA'
                                ? Center(
                                    child: Text(listTeamInfo[0]),
                                  )
                                : ListView.builder(
                                    addAutomaticKeepAlives: true,
                                    scrollDirection: Axis.vertical,
                                    itemCount: listTeamInfo.length,
                                    itemBuilder: (context, index) {
                                      objectTeamInfo = listTeamInfo[index];
                                      mapTeamInfo = Map<String, dynamic>.from(
                                          objectTeamInfo.toJson());
                                      facePhoto = mapTeamInfo['fotoWajah'];
                                      if (facePhoto != null) {
                                        mapFacePhoto =
                                            Map<String, dynamic>.from(
                                                facePhoto.toJson());
                                      } else {
                                        mapFacePhoto = {'url': null};
                                      }
                                      return Card(
                                        margin: EdgeInsets.only(
                                            top: 10.0,
                                            left: 10.0,
                                            right: 10.0,
                                            bottom: 10.0),
                                        elevation: 10.0,
                                        shape: RoundedRectangleBorder(
                                          side:
                                              BorderSide(color: Colors.black45),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15.0)),
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Container(
                                              margin: const EdgeInsets.all(5.0),
                                              child: Row(
                                                children: <Widget>[
                                                  Container(
                                                    child: CircleAvatar(
                                                      minRadius: 25.0,
                                                      maxRadius: 40.0,
                                                      backgroundImage:
                                                          mapFacePhoto['url'] ==
                                                                  null
                                                              ? null
                                                              : NetworkImage(
                                                                  mapFacePhoto[
                                                                      'url'],
                                                                ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 5.0),
                                                          child: Text(
                                                            mapTeamInfo['fullname'] ==
                                                                    null
                                                                ? '-'
                                                                : mapTeamInfo[
                                                                    'fullname'],
                                                            style: TextStyle(
                                                                fontSize: 16.0,
                                                                color: blue),
                                                            maxLines: 3,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 5.0),
                                                          child: Text(
                                                            mapTeamInfo['nik'] ==
                                                                    null
                                                                ? '-'
                                                                : mapTeamInfo[
                                                                    'nik'],
                                                            style: TextStyle(
                                                                fontSize: 14.0,
                                                                color: gray),
                                                            maxLines: 3,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            Divider(
                                              color: Colors.black,
                                              height: 5.0,
                                            ),
                                            Row(
                                              children: <Widget>[
                                                Expanded(
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
                                                          Expanded(
                                                              child: Text(
                                                                  'Detail',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white)))
                                                        ],
                                                      ),
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (_) =>
                                                              TeamDetailDialog(
                                                            objectDetailView:
                                                                listTeamInfo[
                                                                    index],
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    height: 40.0,
                                                    child: RaisedButton(
                                                      color: blue,
                                                      child: Row(
                                                        children: <Widget>[
                                                          Expanded(
                                                              child: Icon(
                                                                  Icons.create,
                                                                  color: Colors
                                                                      .white)),
                                                          Expanded(
                                                              child: Text(
                                                                  'Edit',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white)))
                                                        ],
                                                      ),
                                                      onPressed: () {
                                                        showDialog(
                                                          context: context,
                                                          builder: (_) =>
                                                              TeamEditDialog(
                                                            objectDetailView:
                                                                listTeamInfo[
                                                                    index],
                                                            listShift:
                                                                listShift,
                                                            listShiftObjectId:
                                                                listObjectIdShift,
                                                          ),
                                                        ).then((value) {
                                                          // if (value ==
                                                          //     'edited') {
                                                          //   setState(() {
                                                          //     _loadTeam();
                                                          //   });
                                                          // }
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}

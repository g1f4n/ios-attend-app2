import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import '../colors.dart';

class UnabsenceDialog extends StatefulWidget {
  final List listUnabsence;

  const UnabsenceDialog({Key key, this.listUnabsence}) : super(key: key);

  @override
  State<StatefulWidget> createState() => UnabsenceDialogState(listUnabsence);
}

class UnabsenceDialogState extends State<UnabsenceDialog> {
  final List listUnabsence;

  UnabsenceDialogState(this.listUnabsence);

  ParseObject objectUnabsence;
  ParseFile facePhoto;
  Map<String, dynamic> mapUnabsence, mapFacePhoto;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _body(),
    );
  }

  Widget _body() {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: EdgeInsets.all(20.0),
          padding: EdgeInsets.all(10.0),
          height: MediaQuery.of(context).size.height / 1.3,
          width: MediaQuery.of(context).size.width,
          decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0))),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(left: 10.0, top: 10.0),
                  child: Text(
                    "Daftar staff yang belum melakukan absensi",
                    style: TextStyle(
                      fontSize: 16.0,
                      color: info,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _listView(),
                SizedBox(height: 25.0),
                _okButton(),
                SizedBox(height: 20.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _listView() {
    return listUnabsence == null
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
        : listUnabsence[0] == 'CONNECTION ERROR'
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
                    child: Text(listUnabsence[0]),
                  ),
                ),
              )
            : Container(
                margin: const EdgeInsets.only(left: 5.0, right: 5.0, top: 5.0),
                child: Column(
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(
                          left: 5.0, right: 5.0, top: 5.0, bottom: 5.0),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height / 1.8,
                      child: Card(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(color: Colors.black38),
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                        ),
                        shadowColor: kAppSoftLightTeal,
                        elevation: 5.0,
                        child: Center(
                          child: listUnabsence[0] == 'THERE IS NO DATA'
                              ? Center(
                                  child: Text(listUnabsence[0]),
                                )
                              : ListView.builder(
                                  addAutomaticKeepAlives: true,
                                  scrollDirection: Axis.vertical,
                                  itemCount: listUnabsence.length,
                                  itemBuilder: (context, index) {
                                    objectUnabsence = listUnabsence[index];
                                    mapUnabsence = Map<String, dynamic>.from(
                                        objectUnabsence.toJson());
                                    facePhoto = mapUnabsence['fotoWajah'];
                                    if (facePhoto != null) {
                                      mapFacePhoto = Map<String, dynamic>.from(
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
                                        side: BorderSide(color: Colors.black45),
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
                                                        margin: const EdgeInsets
                                                            .only(left: 5.0),
                                                        child: Text(
                                                          mapUnabsence[
                                                                      'fullname'] ==
                                                                  null
                                                              ? '-'
                                                              : mapUnabsence[
                                                                  'fullname'],
                                                          style: TextStyle(
                                                              fontSize: 16.0,
                                                              color: blue),
                                                          maxLines: 3,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      Container(
                                                        margin: const EdgeInsets
                                                            .only(left: 5.0),
                                                        child: Text(
                                                          mapUnabsence['nik'] ==
                                                                  null
                                                              ? '-'
                                                              : mapUnabsence[
                                                                  'nik'],
                                                          style: TextStyle(
                                                              fontSize: 14.0,
                                                              color: gray),
                                                          maxLines: 3,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
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
              );
  }

  Widget _okButton() {
    return Container(
      child: Align(
        alignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.only(left: 10.0, right: 10.0),
          width: MediaQuery.of(context).size.width / 2.5,
          height: 50.0,
          child: RaisedButton(
            elevation: 10.0,
            child: Text("OK", style: TextStyle(color: Colors.white)),
            color: blueButton,
            onPressed: () {
              Navigator.of(context).pop();
            },
            shape: RoundedRectangleBorder(
                side: BorderSide(
                    style: BorderStyle.solid, color: blue, width: 2.0),
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
          ),
        ),
      ),
    );
  }
}

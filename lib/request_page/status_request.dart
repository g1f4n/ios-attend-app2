import 'package:attend_app/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

class StatusRequest extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => StatusRequestState();
}

class StatusRequestState extends State<StatusRequest> {
  List listStatusRequest;
  ParseObject objectStatusRequest;
  Map<String, dynamic> mapStatusRequest;

  TextEditingController editingController = TextEditingController();

  List listSearch = ['All', 'Nik', 'Nama Lengkap'];
  List<DropdownMenuItem<String>> listDropItem;
  String currentSearchItem;

  var items = List<String>();
  @override
  void initState() {
    super.initState();
    listDropItem = getDropDownMenuItems(listSearch);
    currentSearchItem = listDropItem[0].value;
    _loadStatusRequest();
  }

  void _loadStatusRequest() {
    dynamic user;
    ParseUser.currentUser().then((value) {
      user = value['objectId'];
      QueryBuilder<ParseObject> queryStatusRequest =
          QueryBuilder<ParseObject>(ParseObject(('ChangeRequest')))
            ..whereEqualTo('leaderId', {
              "__type": "Pointer",
              "className": "_User",
              "objectId": user,
            });

      queryStatusRequest.query().then((value) {
        setState(() {
          if (value.statusCode == 200) {
            if (value.results != null) {
              listStatusRequest = value.results;
            } else {
              listStatusRequest = ['THERE IS NO DATA'];
            }
          } else {
            listStatusRequest = ['CONNECTION ERROR'];
          }
        });
      }).catchError((e) {
        print(e);
        setState(() {
          listStatusRequest = ['CONNECTION ERROR'];
        });
      });
    });
  }

  void _queryStatusByValue(String field, String value) {
    QueryBuilder<ParseObject> queryStatusRequest =
        QueryBuilder<ParseObject>(ParseObject(('ChangeRequest')))
          ..whereContains(field, value);

    queryStatusRequest.query().then((value) {
      setState(() {
        if (value.statusCode == 200) {
          if (value.results != null) {
            listStatusRequest = value.results;
          } else {
            listStatusRequest = ['THERE IS NO DATA'];
          }
        } else {
          listStatusRequest = ['CONNECTION ERROR'];
        }
      });
    }).catchError((e) {
      print(e);
      setState(() {
        listStatusRequest = ['CONNECTION ERROR'];
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
      child: listStatusRequest == null
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
          : listStatusRequest[0] == 'CONNECTION ERROR'
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
                      child: Text(listStatusRequest[0]),
                    ),
                  ),
                )
              : Container(
                  margin: const EdgeInsets.only(
                    left: 5.0,
                    right: 5.0,
                    top: 5.0,
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).size.height / 100,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            _spinner(listDropItem, currentSearchItem),
                            Container(
                              height: 50.0,
                              width: MediaQuery.of(context).size.width / 2,
                              margin: const EdgeInsets.only(right: 5.0),
                              padding: const EdgeInsets.only(
                                  left: 10.0, right: 10.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15.0),
                                color: white,
                              ),
                              child: TextField(
                                controller: editingController,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  // labelStyle: TextStyle(color: blue),
                                  // labelText: "$currentSearchItem",
                                  hintText: "$currentSearchItem anda",
                                  suffixIcon: IconButton(
                                      icon: Icon(
                                        Icons.search,
                                        color: blue,
                                      ),
                                      onPressed: () {
                                        if (editingController.text.trim() !=
                                            '') {
                                          if (currentSearchItem == 'Nik') {
                                            _queryStatusByValue('nik',
                                                editingController.text.trim());
                                          } else if (currentSearchItem ==
                                              'Nama Lengkap') {
                                            _queryStatusByValue('fullname',
                                                editingController.text.trim());
                                          }
                                        }
                                        if (currentSearchItem == 'All') {
                                          _loadStatusRequest();
                                        }
                                      }),
                                ),
                                onSubmitted: (value) {
                                  if (editingController.text.trim() != '') {
                                    if (currentSearchItem == 'Nik') {
                                      _queryStatusByValue(
                                          'nik', editingController.text.trim());
                                    } else if (currentSearchItem ==
                                        'Nama Lengkap') {
                                      _queryStatusByValue('fullname',
                                          editingController.text.trim());
                                    }
                                  }
                                  if (currentSearchItem == 'All') {
                                    _loadStatusRequest();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            left: 5.0, right: 5.0, top: 5.0, bottom: 5.0),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 1.4,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.black38),
                            borderRadius:
                                BorderRadius.all(Radius.circular(15.0)),
                          ),
                          shadowColor: kAppSoftLightTeal,
                          elevation: 5.0,
                          child: Center(
                            child: listStatusRequest[0] == 'THERE IS NO DATA'
                                ? Center(
                                    child: Text(listStatusRequest[0]),
                                  )
                                : ListView.builder(
                                    scrollDirection: Axis.vertical,
                                    itemCount: listStatusRequest.length,
                                    itemBuilder: (context, index) {
                                      String statusApprove = '';
                                      Color statusApproveColor = Colors.white;
                                      objectStatusRequest =
                                          listStatusRequest[index];
                                      mapStatusRequest =
                                          Map<String, dynamic>.from(
                                              objectStatusRequest.toJson());
                                      if (mapStatusRequest['statusApprove'] ==
                                          0) {
                                        statusApprove = 'ON PROCESS';
                                        statusApproveColor = orange;
                                      } else if (mapStatusRequest[
                                              'statusApprove'] ==
                                          1) {
                                        statusApprove = 'APPROVED';
                                        statusApproveColor = success;
                                      } else {
                                        statusApprove = 'DENIED';
                                        statusApproveColor = red;
                                      }
                                      return Card(
                                        margin: EdgeInsets.only(
                                            top: 5.0,
                                            left: 10.0,
                                            right: 10.0,
                                            bottom: 10.0),
                                        elevation: 10.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15.0)),
                                        ),
                                        child: Container(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              10,
                                          margin: const EdgeInsets.only(
                                              left: 10.0, right: 10.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: <Widget>[
                                                  Container(
                                                    child: Text(
                                                        mapStatusRequest[
                                                                    'fullname'] ==
                                                                null
                                                            ? '-'
                                                            : mapStatusRequest[
                                                                'fullname'],
                                                        style: TextStyle(
                                                            fontSize: 16.0,
                                                            color: blue)),
                                                  ),
                                                  Container(
                                                    child: Text(
                                                        mapStatusRequest[
                                                                    'nik'] ==
                                                                null
                                                            ? '-'
                                                            : mapStatusRequest[
                                                                'nik'],
                                                        style: TextStyle(
                                                            fontSize: 16.0,
                                                            color: gray)),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                child: Text(
                                                    mapStatusRequest[
                                                                'statusApprove'] ==
                                                            null
                                                        ? '-'
                                                        : statusApprove,
                                                    style: TextStyle(
                                                        fontSize: 16.0,
                                                        color:
                                                            statusApproveColor)),
                                              ),
                                            ],
                                          ),
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

  List<DropdownMenuItem<String>> getDropDownMenuItems(List getItems) {
    List<DropdownMenuItem<String>> items = new List();
    for (String item in getItems) {
      items.add(
        new DropdownMenuItem(
            value: item,
            child: Container(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: Text(
                item,
                style: TextStyle(fontSize: 14.0, color: blue),
                overflow: TextOverflow.ellipsis,
                maxLines: 5,
              ),
            )),
      );
    }
    return items;
  }

  Widget _spinner(List<DropdownMenuItem<dynamic>> items, dynamic firstValue) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: white,
      ),
      width: MediaQuery.of(context).size.width / 2.5,
      margin: const EdgeInsets.only(left: 5.0),
      child: DropdownButton<String>(
        underline: Container(
          color: Colors.transparent,
        ),
        isExpanded: true,
        value: firstValue,
        items: items,
        iconEnabledColor: Colors.greenAccent,
        onChanged: (value) {
          setState(() {
            currentSearchItem = value;
          });
        },
      ),
    );
  }
}

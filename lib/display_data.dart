import 'package:attend_app/display_pages/req_absence_page.dart';
import 'package:attend_app/display_pages/req_cuti_page.dart';
import 'package:attend_app/display_pages/req_default_page.dart';
import 'package:attend_app/display_pages/req_early_page.dart';
import 'package:attend_app/display_pages/req_izin_page.dart';
import 'package:attend_app/display_pages/req_late_page.dart';
import 'package:attend_app/display_pages/req_overtime_page.dart';
import 'package:attend_app/utils/Theme.dart';
import 'package:attend_app/utils/colors.dart';
import 'package:attend_app/widgets/navbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DisplayData extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DisplayDataState();
}

class DisplayDataState extends State<DisplayData> {
  List listRequestCategory = [
    'Pilih Kategori Request...',
    'Absen',
    'Telat',
    'Pulang Cepat',
    'Lembur',
    'Izin',
    'Cuti'
  ];
  List<DropdownMenuItem<String>> dropdownRequestCategory;
  String currentRequestCategory;

  List listStatusCategory = [
    'Belum Terproses',
    'Approved',
    'Rejected',
  ];
  List<DropdownMenuItem<String>> dropdownStatusCategory;
  String currentStatustCategory;

  List listDateCategory = [
    'Pilih Waktu...',
    'Daily',
    'Weekly',
    'Monthly',
  ];
  List<DropdownMenuItem<String>> dropdownDateCategory;
  String currentDateCategory;

  bool reqCategory = false;
  String tanggal = 'dd/mm/yyyy';
  DateTime date;

  @override
  void initState() {
    super.initState();
    dropdownRequestCategory = getDropDownMenuItems(listRequestCategory);
    dropdownStatusCategory = getDropDownMenuItems(listStatusCategory);
    dropdownDateCategory = getDropDownMenuItems(listDateCategory);
    currentRequestCategory = dropdownRequestCategory[0].value;
    currentStatustCategory = dropdownStatusCategory[0].value;
    currentDateCategory = dropdownDateCategory[0].value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArgonColors.bgColorScreen,
      appBar: Navbar(
        title: "DAFTAR ABSENSI",
        backButton: true,
        rightOptions: false,
      ),
//      appBar: AppBar(
//        elevation: 10.0,
////        shape: RoundedRectangleBorder(
////          borderRadius: BorderRadius.only(
////              bottomLeft: Radius.circular(15.0),
////              bottomRight: Radius.circular(15.0)),
////        ),
//        backgroundColor: white,
//        title: Text(
//          "DAFTAR ABSENSI",
//          style: TextStyle(fontSize: 18.0, color: teal),
//          overflow: TextOverflow.ellipsis,
//        ),
//        centerTitle: true,
//      ),
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
      child: Container(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height / 100,
            ),
            Container(
              child: Card(
                elevation: 20.0,
                shadowColor: kAppSoftLightTeal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _spinnerDetailItem(0, 'Kategori Request',
                        dropdownRequestCategory, currentRequestCategory),
                    _filterSearch('Search By'),
                    currentRequestCategory == listRequestCategory[0]
                        ? Container()
                        : _searchButton(),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 100,
                    ),
                    Visibility(
                      visible: reqCategory,
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 5.0, right: 5.0, top: 5.0, bottom: 5.0),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 1.5,
                        child: listWidget(),
                      ),
                    ),
                    Visibility(
                      visible: !reqCategory,
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 10.0, right: 10.0, top: 5.0, bottom: 5.0),
                        width: MediaQuery.of(context).size.width,
                        child: Container(
                          margin: const EdgeInsets.only(left: 10.0, top: 10.0),
                          child: Text(
                            "Aktivitas Hari Ini",
                            style: TextStyle(
                              fontSize: 16.0,
                              color: info,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: !reqCategory,
                      child: Container(
                        margin: const EdgeInsets.only(
                            left: 5.0, right: 5.0, top: 5.0, bottom: 10.0),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height / 1.5,
                        child: DefaultPage(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget listWidget() {
    if (currentRequestCategory == 'Absen') {
      return AbsencePage(
        dateTime: date,
        timeCategory: currentDateCategory,
      );
    } else if (currentRequestCategory == 'Telat') {
      return LatePage(
        dateTime: date,
        timeCategory: currentDateCategory,
        status: currentStatustCategory,
      );
    } else if (currentRequestCategory == 'Pulang Cepat') {
      return EarlyLeavePage(
        dateTime: date,
        timeCategory: currentDateCategory,
        status: currentStatustCategory,
      );
    } else if (currentRequestCategory == 'Lembur') {
      return OvertimePage(
        dateTime: date,
        timeCategory: currentDateCategory,
        status: currentStatustCategory,
      );
    } else if (currentRequestCategory == 'Izin') {
      return IzinPage(
        dateTime: date,
        timeCategory: currentDateCategory,
        status: currentStatustCategory,
      );
    } else if (currentRequestCategory == 'Cuti') {
      return CutiPage(
        dateTime: date,
        timeCategory: currentDateCategory,
        status: currentStatustCategory,
      );
    } else {
      return Container();
    }
  }

  Widget _filterSearch(String label) {
    if (currentRequestCategory == listRequestCategory[0]) {
      return Container();
    } else {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(10.0),
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(left: 10.0, top: 10.0),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: info,
                  ),
                ),
              ),
              _filterItem(),
            ],
          ),
        ),
      );
    }
  }

  Widget _filterItem() {
    if (currentRequestCategory == listRequestCategory[0]) {
      return Container();
    } else if (currentRequestCategory == 'Absen') {
      return Container(
        margin: const EdgeInsets.only(left: 25.0, top: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _spinner(2, dropdownDateCategory, currentDateCategory),
            Container(
                width: MediaQuery.of(context).size.width / 2.5,
                margin: const EdgeInsets.only(right: 5.0),
                child: Row(
                  children: <Widget>[
                    Text(tanggal),
                    IconButton(
                        icon: Icon(
                          Icons.calendar_today,
                          color: blue,
                        ),
                        onPressed: () {
                          _showDatePicker(0, DateTime.now());
                        })
                  ],
                )),
          ],
        ),
      );
    } else {
      return Container(
          margin: const EdgeInsets.only(left: 25.0, top: 5.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _spinner(1, dropdownStatusCategory, currentStatustCategory),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  _spinner(2, dropdownDateCategory, currentDateCategory),
                  Container(
                      width: MediaQuery.of(context).size.width / 2.5,
                      margin: const EdgeInsets.only(right: 5.0),
                      child: Row(
                        children: <Widget>[
                          Text(tanggal),
                          IconButton(
                              icon: Icon(
                                Icons.calendar_today,
                                color: blue,
                              ),
                              onPressed: () {
                                _showDatePicker(0, DateTime.now());
                              })
                        ],
                      )),
                ],
              ),
            ],
          ));
    }
  }

  Widget _spinnerDetailItem(int id, String label,
      List<DropdownMenuItem<dynamic>> items, dynamic firstValue) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(10.0),
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 10.0, top: 10.0),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16.0,
                  color: info,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 25.0, top: 5.0),
              child: _spinner(id, items, firstValue),
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
            child: Text(
              item,
              style: TextStyle(fontSize: 12.0),
              overflow: TextOverflow.ellipsis,
              maxLines: 5,
            )),
      );
    }
    return items;
  }

  Widget _spinner(
      int id, List<DropdownMenuItem<dynamic>> items, dynamic firstValue) {
    return Container(
      width: id == 0
          ? MediaQuery.of(context).size.width / 1.5
          : MediaQuery.of(context).size.width / 3.0,
      child: DropdownButton<String>(
        isExpanded: true,
        value: firstValue,
        items: items,
        iconEnabledColor: Colors.greenAccent,
        underline: Divider(
          thickness: 2.0,
        ),
        onChanged: (value) {
          spinnerItemChangeO(id, value);
        },
      ),
    );
  }

  void spinnerItemChangeO(int id, String value) {
    setState(() {
      if (id == 0) {
        reqCategory = false;
        currentRequestCategory = value;
        currentStatustCategory = dropdownStatusCategory[0].value;
        currentDateCategory = dropdownDateCategory[0].value;
        tanggal = 'dd/mm/yyyy';
      } else if (id == 1) {
        reqCategory = false;
        currentStatustCategory = value;
      } else if (id == 2) {
        reqCategory = false;
        currentDateCategory = value;
      }
    });
  }

  Future<void> _showDatePicker(int id, DateTime time) async {
    final picked = await showDatePicker(
        context: context,
        initialDate: time,
        firstDate: DateTime(time.year),
        lastDate: DateTime(time.year + 10));
    if (picked != null) {
      setState(() {
        reqCategory = false;
        date = picked;
        tanggal = DateFormat("dd/MM/yyyy").format(picked);
      });
    }
  }

  Widget _searchButton() {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.only(left: 10.0, right: 25.0, bottom: 10.0),
          width: MediaQuery.of(context).size.width / 3.5,
          height: 50.0,
          child: RaisedButton(
            elevation: 5.0,
            child: Text(reqCategory ? "REFRESH" : "SEARCH",
                style: TextStyle(color: Colors.white)),
            color: blueButton,
            onPressed: () {
              setState(() {
                if (reqCategory) {
                  reqCategory = false;
                  currentStatustCategory = dropdownStatusCategory[0].value;
                  currentDateCategory = dropdownDateCategory[0].value;
                  tanggal = 'dd/mm/yyyy';
                } else {
                  if (currentDateCategory != listDateCategory[0] &&
                      tanggal != 'dd/mm/yyyy' &&
                      tanggal != null) {
                    reqCategory = true;
                  }
                }
              });
            },
            shape: RoundedRectangleBorder(
                side: BorderSide(
                    style: BorderStyle.solid, color: ArgonColors.primary, width: 2.0),
                borderRadius: BorderRadius.all(Radius.circular(4.0))),
          ),
        ),
      ),
    );
  }
}

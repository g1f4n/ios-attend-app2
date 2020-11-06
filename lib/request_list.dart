import 'package:attend_app/request_page/attend_request.dart';
import 'package:attend_app/request_page/change_team_info.dart';
import 'package:attend_app/request_page/status_request.dart';
import 'package:attend_app/utils/Theme.dart';
import 'package:attend_app/utils/colors.dart';
import 'package:attend_app/widgets/navbar.dart';
import 'package:flutter/material.dart';

class RequestList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RequestListState();
}

class RequestListState extends State<RequestList>
    with SingleTickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ArgonColors.bgColorScreen,
      appBar: Navbar(
        title: "DAFTAR REQUEST",
        rightOptions: false,
        backButton: true,
      ),
//      appBar: AppBar(
//        automaticallyImplyLeading: false,
//        elevation: 10.0,
//        shape: RoundedRectangleBorder(
//          borderRadius: BorderRadius.only(
//              bottomLeft: Radius.circular(15.0),
//              bottomRight: Radius.circular(15.0)),
//        ),
//        backgroundColor: white,
//        title: Text(
//          "DAFTAR REQUEST",
//          style: TextStyle(color: teal),
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
      bottomNavigationBar: Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0)),
        ),
        color: white,
        child: TabBar(
          tabs: <Tab>[
            Tab(
              iconMargin: const EdgeInsets.all(0),
              icon: Icon(
                Icons.view_list,
                color: purple,
              ),
              child: Text(
                'Request Absensi',
                style: TextStyle(fontSize: 12.0, color: purple),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
            Tab(
              iconMargin: const EdgeInsets.all(0),
              icon: Icon(
                Icons.supervisor_account,
                color: teal,
              ),
              child: Text(
                'Info Anggota',
                style: TextStyle(fontSize: 12.0, color: teal),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
            Tab(
              iconMargin: const EdgeInsets.all(0),
              icon: Icon(Icons.assignment, color: red),
              child: Text(
                'Status Request',
                style: TextStyle(fontSize: 12.0, color: red),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
              ),
            ),
          ],
          controller: tabController,
        ),
      ),
    );
  }

  Widget _body() {
    return TabBarView(
      controller: tabController,
      children: <Widget>[
        AttendRequest(),
        ChangeTeamInfo(),
        StatusRequest(),
      ],
    );
  }
}

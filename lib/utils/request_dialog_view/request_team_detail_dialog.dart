import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import '../colors.dart';

class TeamDetailDialog extends StatefulWidget {
  final ParseObject objectDetailView;

  const TeamDetailDialog({Key key, this.objectDetailView}) : super(key: key);
  @override
  State<StatefulWidget> createState() =>
      TeamDetailDialogState(objectDetailView);
}

class TeamDetailDialogState extends State<TeamDetailDialog>
    with SingleTickerProviderStateMixin {
  final ParseObject objectDetailView;

  TeamDetailDialogState(this.objectDetailView);

  ParseFile facePhoto;
  Map<String, dynamic> mapFacePhoto;
  Map<String, dynamic> mapDetailView;

  @override
  void initState() {
    super.initState();
    mapDetailView = Map<String, dynamic>.from(objectDetailView.toJson());

    facePhoto = mapDetailView['fotoWajah'];
    if (facePhoto != null) {
      mapFacePhoto = Map<String, dynamic>.from(facePhoto.toJson());
    } else {
      mapFacePhoto = {'url': null};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: EdgeInsets.all(20.0),
          padding: EdgeInsets.all(10.0),
          height: MediaQuery.of(context).size.height / 1.5,
          width: MediaQuery.of(context).size.width,
          decoration: ShapeDecoration(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0))),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _detailItem('FOTO :', mapFacePhoto['url'], 'image'),
                _detailItem('NIK :', mapDetailView['nik'], 'text'),
                _detailItem('NAMA :', mapDetailView['fullname'], 'text'),
                _detailItem('JAM KERJA :', mapDetailView['jamKerja'], 'text'),
                _detailItem('SISA CUTI :',
                    mapDetailView['jumlahCuti'].toString(), 'text'),
                _detailItem('LEMBUR :', mapDetailView['lembur'], 'text'),
                _detailItem(
                    'LOKASI KERJA :', mapDetailView['lokasiKerja'], 'text'),
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

  Widget _detailItem(String label, String value, String type) {
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
            type == 'image'
                ? Container(
                  alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height / 3,
                    width: MediaQuery.of(context).size.width,
                    child: value == null
                        ? Container()
                        : Image.network(
                            value,
                            fit: BoxFit.contain,
                          ),
                  )
                : Container(
                    margin: const EdgeInsets.only(left: 25.0, top: 5.0),
                    child: Text(
                      value == null ? '-' : value,
                      style: TextStyle(fontSize: 14.0),
                    ),
                  ),
          ],
        ),
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
                    style: BorderStyle.solid,
                    color: blue,
                    width: 2.0),
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
          ),
        ),
      ),
    );
  }
}

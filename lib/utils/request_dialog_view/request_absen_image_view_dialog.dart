import 'package:flutter/material.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';

import '../colors.dart';

class ImageViewDialog extends StatefulWidget {
  final ParseObject objectDetailView;
  final String type;

  const ImageViewDialog({Key key, this.objectDetailView, this.type})
      : super(key: key);
  @override
  State<StatefulWidget> createState() =>
      ImageViewDialogState(objectDetailView, type);
}

class ImageViewDialogState extends State<ImageViewDialog>
    with SingleTickerProviderStateMixin {
  final ParseObject objectDetailView;
  final String type;

  ImageViewDialogState(this.objectDetailView, this.type);

  ParseFile facePhoto;
  Map<String, dynamic> mapFacePhoto;
  Map<String, dynamic> mapDetailView;

  @override
  void initState() {
    super.initState();
    mapDetailView = Map<String, dynamic>.from(objectDetailView.toJson());

    if (type == 'LeaveCuti') {
      facePhoto = mapDetailView['attachFile'];
      if (facePhoto != null) {
        mapFacePhoto = Map<String, dynamic>.from(facePhoto.toJson());
      } else {
        mapFacePhoto = {'url': null};
      }
    } else {
      facePhoto = mapDetailView['imageSelfie'];
      if (facePhoto != null) {
        mapFacePhoto = Map<String, dynamic>.from(facePhoto.toJson());
      } else {
        mapFacePhoto = {'url': null};
      }
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
                _detailItem('FOTO :', mapFacePhoto['url']),
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

  Widget _detailItem(String label, String value) {
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
              height: MediaQuery.of(context).size.height / 3,
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(left: 25.0),
              child: value == null
                  ? Container()
                  : Image.network(
                      value,
                      fit: BoxFit.contain,
                    ),
            )
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
                    style: BorderStyle.solid, color: blue, width: 2.0),
                borderRadius: BorderRadius.all(Radius.circular(15.0))),
          ),
        ),
      ),
    );
  }
}

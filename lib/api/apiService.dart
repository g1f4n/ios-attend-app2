import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  Dio dio = Dio();
  SharedPreferences prefs;

  // String baseUrlAws = "http://52.77.8.120:4000/";
  String baseUrlAws = "http://34.126.96.126:4000/"; //gcloude address
  String uploadFaceImei = "api/v1/upload/dataset_imei";
  String attendFaceImei = "api/v1/face-db";
  String faceCheck = "api/face-check";

  String baseUrlGcloud5000 = "http://34.126.96.126:5000/";
  String checkLiveness = "/api/prediction";

  uploadData(String filepath, String filename, String imei) async {
    var jsonResponse;
    String filename;

    prefs = await SharedPreferences.getInstance();
    String fullName = prefs.getString("fullName");
    String nik = prefs.getString('inputNik');

    if (imei == "unknown" || imei == "returned null") {
      filename = nik + ".jpg";
    } else {
      filename = imei + ".jpg";
    }

    dio.options.connectTimeout = 300000;
    dio.options.receiveTimeout = 300000;
    dio.options.sendTimeout = 300000;
    FormData formData = FormData.fromMap({
      "name": fullName,
      "nip": nik,
      "imei": imei,
      "knax": await MultipartFile.fromFile(filepath,
          filename: filename, contentType: new MediaType('image', 'jpeg')),
    });

    try {
      await dio
          .post(
        baseUrlAws + uploadFaceImei,
        data: formData,
      )
          .then((value) async {
        jsonResponse = value.data;
      });
    } catch (e) {
      print(e);
      jsonResponse = {
        "status": 0,
        "error": "Terjadi kesalahan pada sistem. Mohon mengulang proses kembali"
      };
    }
    return jsonResponse;
  }

//API untuk reco absen membandingkan dataset user sesuai nip

  attendData(String filepath, String filename, String imei) async {
    var jsonResponse;
    String filename;

    prefs = await SharedPreferences.getInstance();
    String nik = prefs.getString('inputNik');

    if (imei == "unknown" || imei == "returned null") {
      filename = nik + ".jpg";
    } else {
      filename = imei + ".jpg";
    }

    dio.options.connectTimeout = 300000;
    dio.options.receiveTimeout = 300000;
    dio.options.sendTimeout = 300000;
    FormData formData = FormData.fromMap({
      "imei": imei,
      "knax": await MultipartFile.fromFile(filepath,
          filename: filename, contentType: new MediaType('image', 'jpeg')),
      // "knax" : File(filepath)
    });

    try {
      await dio
          .post(
        baseUrlAws + attendFaceImei,
        data: formData,
      )
          .then((value) async {
        jsonResponse = value.data;
      });
    } catch (e) {
      print(e);
      jsonResponse = {
        "status": 0,
        "message":
            "Terjadi kesalahan pada sistem. Mohon mengulang proses kembali"
      };
    }
    return jsonResponse;
  }

  validFaceCheck(String filepath, String filename) async {
    var jsonResponse;
    String filename;

    dio.options.connectTimeout = 300000;
    dio.options.receiveTimeout = 300000;
    dio.options.sendTimeout = 300000;
    FormData formData = FormData.fromMap({
      "knax": await MultipartFile.fromFile(filepath,
          filename: filename, contentType: new MediaType('image', 'jpeg')),
      // "knax" : File(filepath)
    });

    try {
      await dio
          .post(
        baseUrlAws + faceCheck,
        data: formData,
      )
          .then((value) async {
        jsonResponse = value.data;
      });
    } catch (e) {
      print(e);
      jsonResponse = {
        "status": 0,
        "message":
            "Terjadi kesalahan pada sistem. Mohon mengulang proses kembali"
      };
    }
    return jsonResponse;
  }

  // checkImageLiveness(String filepath) async {
  //   var jsonResponse;
  //   String filename;

  //   dio.options.connectTimeout = 300000;
  //   dio.options.receiveTimeout = 300000;
  //   dio.options.sendTimeout = 300000;
  //   FormData formData = FormData.fromMap({
  //     "knax": await MultipartFile.fromFile(filepath,
  //         filename: filename, contentType: new MediaType('image', 'jpeg')),
  //     // "knax" : File(filepath)
  //   });

  //   try {
  //     await dio
  //         .post(
  //       baseUrlGcloud5000 + checkLiveness,
  //       data: formData,
  //     )
  //         .then((value) async {
  //       jsonResponse = value.data;
  //     });
  //   } catch (e) {
  //     print(e);
  //     jsonResponse = {
  //       "status": 0,
  //       "message":
  //           "Terjadi kesalahan pada sistem. Mohon mengulang proses kembali"
  //     };
  //   }
  //   return jsonResponse;
  // }
}

//API untuk reco absen membandingkan dengan seluruh dataset

//   attendData(String filepath, String filename) async {
//     var jsonResponse;

//     prefs = await SharedPreferences.getInstance();
//     String nik = prefs.getString('inputNik');

//     String filename = nik + ".jpg";

//     dio.options.connectTimeout = 300000;
//     dio.options.receiveTimeout = 300000;
//     dio.options.sendTimeout = 300000;
//     FormData formData = FormData.fromMap({
//       "knax": await MultipartFile.fromFile(filepath,
//           filename: filename, contentType: new MediaType('image', 'jpeg')),
//       // "knax" : File(filepath)
//     });

//     try {
//       await dio
//           .post(
//         "http://52.77.8.120:4000/api/v1/face-x",
//         data: formData,
//       )
//           .then((value) async {
//         jsonResponse = value.data;
//       });
//     } catch (e) {
//       print(e);
//       jsonResponse = {
//         "status": 0,
//         "message": "Terjadi kesalahan pada sistem. Mohon mengulang proses kembali"
//       };
//     }
//     return jsonResponse;
//   }
// }

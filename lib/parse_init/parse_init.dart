import 'package:parse_server_sdk/parse_server_sdk.dart';

class ParseInit {
  // test deploy database
  // final String appId = "4AEOa4TwHis5BglLYwnQPLUVtCz6r9n4fvYj0OIE";
  // final String clientKey = "w0zAEv4NnvnTZEw4KGmm8zRqT3DqEM4OOfTaqRkr";
  // final String masterKey = "8HI7u9w7CkqjAEJ4tLR05RYXzgfERyfbGRrKZqWz";

  // testing database
  final String appId = "swzEgrhYeoSIEyVx3DoF5b1rqMUZxpDFz8oAUErr";
  final String clientKey = "T2satL1Dj1QAvFiPnr1ri4POPXyDw4kKJu8O4dTx";
  final String masterKey = "A5VTmrJQKFx7usZLLMIdG5HsGZ400PFlwcsZAjRI";

  final String baseUrl = "https://parseapi.back4app.com/";
  // final String contentType = "application/json";

  Future<void> initialize() async {
    Parse().initialize(
      appId,
      baseUrl,
      debug: true,
      clientKey: clientKey,
      masterKey: masterKey,
      coreStore: await CoreStoreSharedPrefsImp.getInstance(),
    );
  }
}

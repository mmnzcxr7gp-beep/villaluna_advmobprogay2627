import 'package:flutter_dotenv/flutter_dotenv.dart';

var host = dotenv.env['HOST'] ?? 'https://dummyjson.com';

/// Authentication source type indicator for dual login workflows.
enum LoginType {
  dummyJson,
  firebase,
}

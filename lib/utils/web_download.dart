import 'dart:typed_data';

import 'web_download_stub.dart' if (dart.library.html) 'web_download_web.dart' as impl;

void downloadBytesWeb(Uint8List bytes, String fileName) {
  impl.downloadBytesWeb(bytes, fileName);
}

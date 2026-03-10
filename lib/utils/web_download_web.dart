import 'dart:convert';
import 'dart:typed_data';
import 'dart:html' as html;

void downloadBytesWeb(Uint8List bytes, String fileName) {
  final base64 = base64Encode(bytes);
  final dataUrl = 'data:application/pdf;base64,$base64';
  final anchor = html.AnchorElement()
    ..href = dataUrl
    ..style.display = 'none'
    ..download = fileName;
  html.document.body?.children.add(anchor);
  anchor.click();
  html.document.body?.children.remove(anchor);
}

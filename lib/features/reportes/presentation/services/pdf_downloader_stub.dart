import 'dart:typed_data';

import 'package:printing/printing.dart';

Future<void> downloadPdf(String fileName, Uint8List bytes) =>
    Printing.sharePdf(bytes: bytes, filename: fileName);

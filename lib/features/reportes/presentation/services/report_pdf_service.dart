import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<Uint8List> generateReportPdf({
  required String institution,
  required String title,
  required Map<String, String> metadata,
  required List<String> columns,
  required List<List<String>> rows,
  required String summary,
}) async {
  final document = pw.Document(
    title: title,
    author: institution,
    creator: 'Sistema académico',
  );
  document.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4.landscape,
    margin: const pw.EdgeInsets.all(28),
    header: (context) => pw.Column(children: [
      pw.Text(institution,
          textAlign: pw.TextAlign.center,
          style:
              const pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 4),
      pw.Text(title.toUpperCase(),
          textAlign: pw.TextAlign.center,
          style:
              const pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 12),
    ]),
    footer: (context) => pw.Align(
      alignment: pw.Alignment.centerRight,
      child: pw.Text('Página ${context.pageNumber} de ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 8)),
    ),
    build: (context) => [
      pw.Wrap(
        spacing: 18,
        runSpacing: 5,
        children: [
          for (final entry in metadata.entries)
            pw.RichText(
              text: pw.TextSpan(children: [
                pw.TextSpan(
                    text: '${entry.key}: ',
                    style: const pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.TextSpan(text: entry.value),
              ]),
            ),
        ],
      ),
      pw.SizedBox(height: 14),
      pw.TableHelper.fromTextArray(
        headers: columns,
        data: rows,
        headerStyle:
            const pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
        cellStyle: const pw.TextStyle(fontSize: 7.5),
        headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
        border: pw.TableBorder.all(color: PdfColors.grey500, width: .5),
        cellPadding: const pw.EdgeInsets.all(4),
      ),
      pw.SizedBox(height: 12),
      pw.Text(summary,
          style:
              const pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
    ],
  ));
  return document.save();
}

Future<void> printReportPdf(Uint8List bytes) => Printing.layoutPdf(
      name: 'reporte_academico.pdf',
      onLayout: (_) async => bytes,
    );

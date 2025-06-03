import 'package:http/http.dart' as http;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// import 'package:flutter/material.dart';
// import 'dart:io';
import 'package:printing/printing.dart';

String uri(id) {
  final url =
      'https://bwipjs-api.metafloor.com/?bcid=code128&text=$id&scale=2&height=12&includetext';
  return url;
}

Future<void> eticketa(id, title, description) async {
  final response = await http.get(Uri.parse(uri(id)));
  final pdf = pw.Document();
  final img = pw.MemoryImage(response.bodyBytes);

  pdf.addPage(pw.Page(
    pageFormat:
        const PdfPageFormat(80 * PdfPageFormat.mm, 15 * PdfPageFormat.cm),
    build: (pw.Context context) {
      return pw.ListView(children: [pw.Padding(padding: const pw.EdgeInsets.only(left: 10,top: 8),child: pw.Text(title)),pw.Image(img,width: 100)]);
    },
  ));
  await Printing.layoutPdf(
    onLayout: (PdfPageFormat format) async => pdf.save(),
  );
}

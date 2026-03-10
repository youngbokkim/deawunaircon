import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../models/estimate.dart';
import '../providers/estimate_provider.dart';
import '../utils/file_saver.dart';
import '../utils/pdf_generator.dart';
import '../utils/web_download.dart';

/// PDF 출력물을 실제 PDF 형태로 미리보기하고, 인쇄/공유할 수 있는 화면
class PdfPreviewScreen extends StatelessWidget {
  const PdfPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final estimate = context.watch<EstimateProvider>().currentEstimate;

    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF 미리보기'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt_outlined),
            tooltip: 'PDF 파일로 저장',
            onPressed: () => _savePdfFile(context, estimate),
          ),
        ],
      ),
      body: PdfPreview(
        build: (format) =>
            PdfGenerator.generateEstimatePdf(estimate),
        allowSharing: !kIsWeb,
        allowPrinting: true,
        initialPageFormat: PdfPageFormat.a4,
        pdfFileName: '견적서_${estimate.projectName}.pdf',
      ),
    );
  }

  Future<void> _savePdfFile(
      BuildContext context, Estimate estimate) async {
    final fileName = _sanitizeFileName('견적서_${estimate.projectName}.pdf');

    try {
      final bytes = await PdfGenerator.generateEstimatePdf(estimate);
      String? path;
      try {
        downloadBytesWeb(bytes, fileName);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF가 다운로드되었습니다.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      } on UnsupportedError {
        try {
          path = await FilePicker.platform.saveFile(
            bytes: bytes,
            fileName: fileName,
            type: FileType.custom,
            allowedExtensions: ['pdf'],
          );
        } catch (_) {
          path = await FilePicker.platform.saveFile(
            fileName: fileName,
            type: FileType.custom,
            allowedExtensions: ['pdf'],
          );
        }
        if (path != null && path.isNotEmpty) {
          await saveBytesToFile(path, bytes);
        }
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              path != null && path.isNotEmpty
                  ? 'PDF가 저장되었습니다.\n$path'
                  : '저장이 취소되었습니다.',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF 저장 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static String _sanitizeFileName(String name) {
    return name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
  }
}

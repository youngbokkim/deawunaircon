import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import '../models/estimate.dart';
import '../providers/estimate_provider.dart';
import '../utils/pdf_generator.dart';

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
        allowSharing: true,
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
      final path = await FilePicker.platform.saveFile(
        bytes: bytes,
        fileName: fileName,
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              path != null && path.isNotEmpty
                  ? 'PDF가 저장되었습니다.\n$path'
                  : 'PDF 파일이 저장되었습니다.',
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

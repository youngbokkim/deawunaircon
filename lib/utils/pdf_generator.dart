import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/estimate.dart';
import 'currency_formatter.dart';

class PdfGenerator {
  static ByteData _copyByteData(ByteData source) {
    return source.buffer.asUint8List().buffer.asByteData(0, source.lengthInBytes);
  }

  static Future<Uint8List> generateEstimatePdf(Estimate estimate) async {
    pw.Font fontBase;
    pw.Font fontBold;
    try {
      final data = await rootBundle.load('assets/fonts/NotoSansKR-Variable.ttf');
      final copy = _copyByteData(data);
      fontBase = pw.Font.ttf(copy);
      fontBold = fontBase;
    } catch (_) {
      if (kIsWeb) {
        // 웹: Google Fonts 네트워크 요청이 실패할 수 있으므로 기본 폰트 사용
        fontBase = pw.Font.helvetica();
        fontBold = pw.Font.helveticaBold();
      } else {
        fontBase = await PdfGoogleFonts.notoSansKRRegular();
        fontBold = await PdfGoogleFonts.notoSansKRBold();
      }
    }
    final theme = pw.ThemeData.withFont(
      base: fontBase,
      bold: fontBold,
    );

    final pdf = pw.Document(theme: theme);

    // 견적서 페이지
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => _buildEstimatePage(estimate, fontBase, fontBold),
      ),
    );

    // 내역서 페이지 (항목이 있을 경우)
    if (estimate.detailItems.isNotEmpty) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          orientation: pw.PageOrientation.landscape,
          margin: const pw.EdgeInsets.all(30),
          build: (context) => _buildDetailPage(estimate, fontBase, fontBold),
        ),
      );
    }

    return pdf.save();
  }

  static pw.Widget _buildEstimatePage(
      Estimate estimate, pw.Font fontBase, pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // 회사 정보 헤더
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.end,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  estimate.companyInfo.name,
                  style: pw.TextStyle(font: fontBold, fontSize: 20),
                ),
                pw.SizedBox(height: 4),
                _buildInfoText('주소: ${estimate.companyInfo.address}', fontBase),
                _buildInfoText('담당HP: ${estimate.companyInfo.mobile}', fontBase),
                _buildInfoText('TEL: ${estimate.companyInfo.phone}', fontBase),
                _buildInfoText('FAX: ${estimate.companyInfo.fax}', fontBase),
                _buildInfoText('E-mail: ${estimate.companyInfo.email}', fontBase),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),

        // 제목
        pw.Center(
          child: pw.Text(
            '견   적   서',
            style: pw.TextStyle(font: fontBold, fontSize: 24),
          ),
        ),
        pw.SizedBox(height: 20),

        // 공사명
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(),
          ),
          child: pw.Row(
            children: [
              pw.Text('■ 공사: ', style: pw.TextStyle(font: fontBold)),
              pw.Text(estimate.projectName, style: pw.TextStyle(font: fontBase)),
            ],
          ),
        ),
        pw.SizedBox(height: 12),

        // 금액
        pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(width: 2),
          ),
          child: pw.Column(
            children: [
              pw.Text('금  액', style: pw.TextStyle(font: fontBold)),
              pw.SizedBox(height: 4),
              pw.Text(
                estimate.amountInKorean,
                style: pw.TextStyle(font: fontBold, fontSize: 14),
              ),
              pw.Text(
                CurrencyFormatter.formatWithWon(estimate.totalAmount),
                style: pw.TextStyle(font: fontBold, fontSize: 18),
              ),
            ],
          ),
        ),
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Padding(
            padding: const pw.EdgeInsets.only(top: 4),
            child: pw.Text(
              DateFormatter.format(estimate.estimateDate),
              style: pw.TextStyle(font: fontBase, fontSize: 10),
            ),
          ),
        ),
        pw.SizedBox(height: 12),

        // 공사 제목
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 8),
          decoration: pw.BoxDecoration(border: pw.Border.all()),
          child: pw.Center(
            child: pw.Text(
              estimate.projectName,
              style: pw.TextStyle(font: fontBold),
            ),
          ),
        ),
        pw.SizedBox(height: 12),

        // 견적 테이블
        _buildEstimateTable(estimate, fontBase, fontBold),
        pw.SizedBox(height: 16),

        // 조건
        _buildConditions(estimate, fontBase, fontBold),
        pw.SizedBox(height: 12),

        // 입금 계좌
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
          ),
          child: pw.Text(
            '입금계좌번호: ${estimate.companyInfo.bankAccount}',
            style: pw.TextStyle(font: fontBase, fontSize: 10),
          ),
        ),
        pw.SizedBox(height: 8),

        // 안내문
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey200,
          ),
          child: pw.Center(
            child: pw.Text(
              '본 견적서는 필요시 약식 계약서 내지는 설치의뢰로 갈음합니다.',
              style: pw.TextStyle(font: fontBase, fontSize: 9),
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildInfoText(String text, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Text(text, style: pw.TextStyle(font: font, fontSize: 9)),
    );
  }

  static pw.Widget _buildEstimateTable(
      Estimate estimate, pw.Font fontBase, pw.Font fontBold) {
    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(2),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
        4: const pw.FlexColumnWidth(2),
        5: const pw.FlexColumnWidth(2),
        6: const pw.FlexColumnWidth(1.5),
      },
      children: [
        // 헤더
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey800),
          children: [
            _buildTableHeader('품  명', fontBold),
            _buildTableHeader('규  격', fontBold),
            _buildTableHeader('단위', fontBold),
            _buildTableHeader('수량', fontBold),
            _buildTableHeader('단  가', fontBold),
            _buildTableHeader('금  액', fontBold),
            _buildTableHeader('비고', fontBold),
          ],
        ),
        // 데이터
        ...estimate.items.map((item) {
          return pw.TableRow(
            children: [
              _buildTableCell(item.productName, fontBase),
              _buildTableCell(item.specification, fontBase),
              _buildTableCell(item.unit, fontBase, center: true),
              _buildTableCell(item.quantity.toString(), fontBase, center: true),
              _buildTableCell(CurrencyFormatter.format(item.unitPrice), fontBase, right: true),
              _buildTableCell(CurrencyFormatter.format(item.amount), fontBase, right: true),
              _buildTableCell(item.note, fontBase),
            ],
          );
        }),
        // 합계
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('합  계', fontBold, center: true),
            _buildTableCell('', fontBase),
            _buildTableCell('', fontBase),
            _buildTableCell('', fontBase),
            _buildTableCell('', fontBase),
            _buildTableCell('', fontBase),
            _buildTableCell(
              CurrencyFormatter.format(estimate.totalAmount),
              fontBold,
              right: true,
            ),
            _buildTableCell(estimate.includeVat ? '' : 'VAT별도', fontBase),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTableHeader(String text, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          font: font,
          color: PdfColors.white,
          fontSize: 10,
        ),
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, pw.Font font,
      {bool center = false, bool right = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: right
            ? pw.TextAlign.right
            : center
                ? pw.TextAlign.center
                : pw.TextAlign.left,
        style: pw.TextStyle(font: font, fontSize: 9),
      ),
    );
  }

  static pw.Widget _buildConditions(
      Estimate estimate, pw.Font fontBase, pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildConditionRow('견적유효기간', estimate.validityPeriod, fontBase, fontBold),
        _buildConditionRow('제품인수장소', estimate.deliveryPlace, fontBase, fontBold),
        _buildConditionRow('납 기', estimate.deliveryDate, fontBase, fontBold),
        _buildConditionRow('계약조건', estimate.paymentTerms, fontBase, fontBold),
        pw.SizedBox(height: 8),
        ...estimate.notes.asMap().entries.map((entry) {
          return pw.Padding(
            padding: const pw.EdgeInsets.only(left: 12, bottom: 2),
            child: pw.Text(
              '${entry.key + 1}) ${entry.value}',
              style: pw.TextStyle(font: fontBase, fontSize: 9),
            ),
          );
        }),
      ],
    );
  }

  static pw.Widget _buildConditionRow(
      String label, String value, pw.Font fontBase, pw.Font fontBold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              '$label :',
              style: pw.TextStyle(font: fontBold, fontSize: 9),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
                value, style: pw.TextStyle(font: fontBase, fontSize: 9)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDetailPage(
      Estimate estimate, pw.Font fontBase, pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // 제목
        pw.Center(
          child: pw.Text(
            '내   역   서',
            style: pw.TextStyle(font: fontBold, fontSize: 20),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Center(
          child: pw.Text(
            estimate.projectName,
            style: pw.TextStyle(font: fontBase, fontSize: 12),
          ),
        ),
        pw.SizedBox(height: 16),
        // A4 가로(landscape) 내용 영역에 맞춘 비율 열 너비 - 페이지 넘침 없이 가독성 확보
        pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: const pw.FlexColumnWidth(0.5),
            1: const pw.FlexColumnWidth(2.5),
            2: const pw.FlexColumnWidth(1.5),
            3: const pw.FlexColumnWidth(0.5),
            4: const pw.FlexColumnWidth(0.5),
            5: const pw.FlexColumnWidth(1),
            6: const pw.FlexColumnWidth(1),
            7: const pw.FlexColumnWidth(1),
            8: const pw.FlexColumnWidth(1),
            9: const pw.FlexColumnWidth(1),
            10: const pw.FlexColumnWidth(1),
            11: const pw.FlexColumnWidth(0.5),
          },
          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey800),
              children: [
                _buildDetailHeader('No', fontBold),
                _buildDetailHeader('품명', fontBold),
                _buildDetailHeader('규격', fontBold),
                _buildDetailHeader('단위', fontBold),
                _buildDetailHeader('수량', fontBold),
                _buildDetailHeader('재료비\n단가', fontBold),
                _buildDetailHeader('재료비\n금액', fontBold),
                _buildDetailHeader('노무비\n단가', fontBold),
                _buildDetailHeader('노무비\n금액', fontBold),
                _buildDetailHeader('합계\n단가', fontBold),
                _buildDetailHeader('합계\n금액', fontBold),
                _buildDetailHeader('비고', fontBold),
              ],
            ),
            ...estimate.detailItems.map((item) {
              return pw.TableRow(
                children: [
                  _buildDetailCell(item.no.toString(), fontBase, center: true),
                  _buildDetailCell(item.productName, fontBase),
                  _buildDetailCell(item.specification, fontBase),
                  _buildDetailCell(item.unit, fontBase, center: true),
                  _buildDetailCell(item.quantity.toString(), fontBase, center: true),
                  _buildDetailCell(
                      CurrencyFormatter.format(item.materialUnitPrice),
                      fontBase,
                      right: true),
                  _buildDetailCell(
                      CurrencyFormatter.format(item.materialAmount),
                      fontBase,
                      right: true),
                  _buildDetailCell(
                      CurrencyFormatter.format(item.laborUnitPrice),
                      fontBase,
                      right: true),
                  _buildDetailCell(
                      CurrencyFormatter.format(item.laborAmount),
                      fontBase,
                      right: true),
                  _buildDetailCell(
                      CurrencyFormatter.format(item.totalUnitPrice),
                      fontBase,
                      right: true),
                  _buildDetailCell(
                      CurrencyFormatter.format(item.totalAmount),
                      fontBase,
                      right: true),
                  _buildDetailCell(item.note, fontBase),
                ],
              );
            }),
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildDetailCell('', fontBase),
                _buildDetailCell('합계', fontBold, center: true),
                _buildDetailCell('', fontBase),
                _buildDetailCell('', fontBase),
                _buildDetailCell('', fontBase),
                _buildDetailCell('', fontBase),
                _buildDetailCell(
                  CurrencyFormatter.format(
                    estimate.detailItems.fold(
                        0.0, (sum, item) => sum + item.materialAmount),
                  ),
                  fontBold,
                  right: true,
                ),
                _buildDetailCell('', fontBase),
                _buildDetailCell(
                  CurrencyFormatter.format(
                    estimate.detailItems.fold(
                        0.0, (sum, item) => sum + item.laborAmount),
                  ),
                  fontBold,
                  right: true,
                ),
                _buildDetailCell('', fontBase),
                _buildDetailCell(
                  CurrencyFormatter.format(estimate.detailTotalAmount),
                  fontBold,
                  right: true,
                ),
                _buildDetailCell('', fontBase),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildDetailHeader(String text, pw.Font font) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          font: font,
          color: PdfColors.white,
          fontSize: 9,
        ),
      ),
    );
  }

  static pw.Widget _buildDetailCell(String text, pw.Font font,
      {bool center = false, bool right = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: pw.Text(
        text,
        textAlign: right
            ? pw.TextAlign.right
            : center
                ? pw.TextAlign.center
                : pw.TextAlign.left,
        style: pw.TextStyle(font: font, fontSize: 9),
      ),
    );
  }
}



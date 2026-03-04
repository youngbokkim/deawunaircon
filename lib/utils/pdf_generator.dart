import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/estimate.dart';
import 'currency_formatter.dart';

class PdfGenerator {
  static Future<Uint8List> generateEstimatePdf(Estimate estimate) async {
    final pdf = pw.Document();

    // 견적서 페이지
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => _buildEstimatePage(estimate),
      ),
    );

    // 내역서 페이지 (항목이 있을 경우)
    if (estimate.detailItems.isNotEmpty) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          orientation: pw.PageOrientation.landscape,
          margin: const pw.EdgeInsets.all(30),
          build: (context) => _buildDetailPage(estimate),
        ),
      );
    }

    return pdf.save();
  }

  static pw.Widget _buildEstimatePage(Estimate estimate) {
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
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                _buildInfoText('주소: ${estimate.companyInfo.address}'),
                _buildInfoText('담당HP: ${estimate.companyInfo.mobile}'),
                _buildInfoText('TEL: ${estimate.companyInfo.phone}'),
                _buildInfoText('FAX: ${estimate.companyInfo.fax}'),
                _buildInfoText('E-mail: ${estimate.companyInfo.email}'),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 20),

        // 제목
        pw.Center(
          child: pw.Text(
            '견   적   서',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
            ),
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
              pw.Text('■ 공사: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(estimate.projectName),
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
              pw.Text('금  액', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 4),
              pw.Text(
                estimate.amountInKorean,
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                CurrencyFormatter.formatWithWon(estimate.totalAmount),
                style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
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
              style: const pw.TextStyle(fontSize: 10),
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
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
        ),
        pw.SizedBox(height: 12),

        // 견적 테이블
        _buildEstimateTable(estimate),
        pw.SizedBox(height: 16),

        // 조건
        _buildConditions(estimate),
        pw.SizedBox(height: 12),

        // 입금 계좌
        pw.Container(
          padding: const pw.EdgeInsets.all(8),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
          ),
          child: pw.Text(
            '입금계좌번호: ${estimate.companyInfo.bankAccount}',
            style: const pw.TextStyle(fontSize: 10),
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
              style: const pw.TextStyle(fontSize: 9),
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildInfoText(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
    );
  }

  static pw.Widget _buildEstimateTable(Estimate estimate) {
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
            _buildTableHeader('품  명'),
            _buildTableHeader('규  격'),
            _buildTableHeader('단위'),
            _buildTableHeader('수량'),
            _buildTableHeader('단  가'),
            _buildTableHeader('금  액'),
            _buildTableHeader('비고'),
          ],
        ),
        // 데이터
        ...estimate.items.map((item) {
          return pw.TableRow(
            children: [
              _buildTableCell(item.productName),
              _buildTableCell(item.specification),
              _buildTableCell(item.unit, center: true),
              _buildTableCell(item.quantity.toString(), center: true),
              _buildTableCell(CurrencyFormatter.format(item.unitPrice), right: true),
              _buildTableCell(CurrencyFormatter.format(item.amount), right: true),
              _buildTableCell(item.note),
            ],
          );
        }),
        // 합계
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _buildTableCell('합  계', bold: true, center: true),
            _buildTableCell(''),
            _buildTableCell(''),
            _buildTableCell(''),
            _buildTableCell(''),
            _buildTableCell(
              CurrencyFormatter.format(estimate.totalAmount),
              right: true,
              bold: true,
            ),
            _buildTableCell(estimate.includeVat ? '' : 'VAT별도'),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildTableHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  static pw.Widget _buildTableCell(String text,
      {bool center = false, bool right = false, bool bold = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(
        text,
        textAlign: right
            ? pw.TextAlign.right
            : center
                ? pw.TextAlign.center
                : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 9,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _buildConditions(Estimate estimate) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildConditionRow('견적유효기간', estimate.validityPeriod),
        _buildConditionRow('제품인수장소', estimate.deliveryPlace),
        _buildConditionRow('납 기', estimate.deliveryDate),
        _buildConditionRow('계약조건', estimate.paymentTerms),
        pw.SizedBox(height: 8),
        ...estimate.notes.asMap().entries.map((entry) {
          return pw.Padding(
            padding: const pw.EdgeInsets.only(left: 12, bottom: 2),
            child: pw.Text(
              '${entry.key + 1}) ${entry.value}',
              style: const pw.TextStyle(fontSize: 9),
            ),
          );
        }),
      ],
    );
  }

  static pw.Widget _buildConditionRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 2),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 80,
            child: pw.Text(
              '$label :',
              style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(fontSize: 9)),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildDetailPage(Estimate estimate) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // 제목
        pw.Center(
          child: pw.Text(
            '내   역   서',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Center(
          child: pw.Text(
            estimate.projectName,
            style: const pw.TextStyle(fontSize: 12),
          ),
        ),
        pw.SizedBox(height: 16),

        // 테이블
        pw.Table(
          border: pw.TableBorder.all(),
          columnWidths: {
            0: const pw.FlexColumnWidth(0.5),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(1.5),
            3: const pw.FlexColumnWidth(0.5),
            4: const pw.FlexColumnWidth(0.5),
            5: const pw.FlexColumnWidth(1),
            6: const pw.FlexColumnWidth(1),
            7: const pw.FlexColumnWidth(1),
            8: const pw.FlexColumnWidth(1),
            9: const pw.FlexColumnWidth(1),
            10: const pw.FlexColumnWidth(1),
            11: const pw.FlexColumnWidth(1),
          },
          children: [
            // 헤더
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey800),
              children: [
                _buildDetailHeader('No'),
                _buildDetailHeader('품명'),
                _buildDetailHeader('규격'),
                _buildDetailHeader('단위'),
                _buildDetailHeader('수량'),
                _buildDetailHeader('재료비\n단가'),
                _buildDetailHeader('재료비\n금액'),
                _buildDetailHeader('노무비\n단가'),
                _buildDetailHeader('노무비\n금액'),
                _buildDetailHeader('합계\n단가'),
                _buildDetailHeader('합계\n금액'),
                _buildDetailHeader('비고'),
              ],
            ),
            // 데이터
            ...estimate.detailItems.map((item) {
              return pw.TableRow(
                children: [
                  _buildDetailCell(item.no.toString(), center: true),
                  _buildDetailCell(item.productName),
                  _buildDetailCell(item.specification),
                  _buildDetailCell(item.unit, center: true),
                  _buildDetailCell(item.quantity.toString(), center: true),
                  _buildDetailCell(
                      CurrencyFormatter.format(item.materialUnitPrice),
                      right: true),
                  _buildDetailCell(CurrencyFormatter.format(item.materialAmount),
                      right: true),
                  _buildDetailCell(CurrencyFormatter.format(item.laborUnitPrice),
                      right: true),
                  _buildDetailCell(CurrencyFormatter.format(item.laborAmount),
                      right: true),
                  _buildDetailCell(CurrencyFormatter.format(item.totalUnitPrice),
                      right: true),
                  _buildDetailCell(CurrencyFormatter.format(item.totalAmount),
                      right: true),
                  _buildDetailCell(item.note),
                ],
              );
            }),
            // 합계
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey200),
              children: [
                _buildDetailCell(''),
                _buildDetailCell('합계', bold: true, center: true),
                _buildDetailCell(''),
                _buildDetailCell(''),
                _buildDetailCell(''),
                _buildDetailCell(''),
                _buildDetailCell(
                  CurrencyFormatter.format(
                    estimate.detailItems
                        .fold(0.0, (sum, item) => sum + item.materialAmount),
                  ),
                  right: true,
                  bold: true,
                ),
                _buildDetailCell(''),
                _buildDetailCell(
                  CurrencyFormatter.format(
                    estimate.detailItems
                        .fold(0.0, (sum, item) => sum + item.laborAmount),
                  ),
                  right: true,
                  bold: true,
                ),
                _buildDetailCell(''),
                _buildDetailCell(
                  CurrencyFormatter.format(estimate.detailTotalAmount),
                  right: true,
                  bold: true,
                ),
                _buildDetailCell(''),
              ],
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildDetailHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
          fontSize: 8,
        ),
      ),
    );
  }

  static pw.Widget _buildDetailCell(String text,
      {bool center = false, bool right = false, bool bold = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(
        text,
        textAlign: right
            ? pw.TextAlign.right
            : center
                ? pw.TextAlign.center
                : pw.TextAlign.left,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}



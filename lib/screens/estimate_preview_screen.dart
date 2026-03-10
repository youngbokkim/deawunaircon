import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/estimate_provider.dart';
import '../utils/app_theme.dart';
import '../utils/currency_formatter.dart';
import '../utils/file_saver.dart';
import '../utils/pdf_generator.dart';
import '../utils/web_download.dart';
import 'pdf_preview_screen.dart';

class EstimatePreviewScreen extends StatelessWidget {
  const EstimatePreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('견적서 미리보기'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '견적서'),
              Tab(text: '내역서'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.picture_as_pdf_outlined),
              tooltip: 'PDF 미리보기',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PdfPreviewScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.save_alt_outlined),
              tooltip: 'PDF 파일로 저장',
              onPressed: () => _savePdfFile(context),
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            _EstimatePreview(),
            _DetailPreview(),
          ],
        ),
      ),
    );
  }

  Future<void> _savePdfFile(BuildContext context) async {
    final provider = context.read<EstimateProvider>();
    final estimate = provider.currentEstimate;
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

class _EstimatePreview extends StatelessWidget {
  const _EstimatePreview();

  @override
  Widget build(BuildContext context) {
    return Consumer<EstimateProvider>(
      builder: (context, provider, child) {
        final estimate = provider.currentEstimate;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 헤더 - 회사명
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            estimate.companyInfo.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildCompanyInfoRow(
                              '주소', estimate.companyInfo.address),
                          _buildCompanyInfoRow(
                              '담당HP', estimate.companyInfo.mobile),
                          _buildCompanyInfoRow(
                              'TEL', estimate.companyInfo.phone),
                          _buildCompanyInfoRow(
                              'FAX', estimate.companyInfo.fax),
                          _buildCompanyInfoRow(
                              'E-mail', estimate.companyInfo.email),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 견적서 제목
                  const Center(
                    child: Text(
                      '견   적   서',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 공사명
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.borderColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Text(
                          '■ 공사:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 16),
                        Text(estimate.projectName),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 금액
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.05),
                      border: Border.all(color: AppTheme.primaryColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '금  액',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          estimate.amountInKorean,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyFormatter.formatWithWon(estimate.totalAmount),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      DateFormatter.format(estimate.estimateDate),
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 공사 제목
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppTheme.borderColor),
                    ),
                    child: Center(
                      child: Text(
                        estimate.projectName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 견적 테이블
                  _buildEstimateTable(estimate),
                  const SizedBox(height: 24),

                  // 조건 및 비고
                  _buildConditionsSection(estimate),
                  const SizedBox(height: 16),

                  // 입금 계좌
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.warningColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance,
                            size: 20, color: AppTheme.warningColor),
                        const SizedBox(width: 8),
                        Text(
                          '입금계좌번호: ${estimate.companyInfo.bankAccount}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 안내 문구
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '본 견적서는 필요시 약식 계약서 내지는 설치의뢰로 갈음합니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompanyInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEstimateTable(dynamic estimate) {
    return Table(
      border: TableBorder.all(color: AppTheme.borderColor),
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(2),
        5: FlexColumnWidth(2),
        6: FlexColumnWidth(1.5),
      },
      children: [
        // 헤더
        TableRow(
          decoration: BoxDecoration(color: AppTheme.tableHeaderColor),
          children: [
            _buildHeaderCell('품  명'),
            _buildHeaderCell('규  격'),
            _buildHeaderCell('단위'),
            _buildHeaderCell('수량'),
            _buildHeaderCell('단  가'),
            _buildHeaderCell('금  액'),
            _buildHeaderCell('비고'),
          ],
        ),
        // 데이터 행
        ...estimate.items.asMap().entries.map<TableRow>((entry) {
          final index = entry.key;
          final item = entry.value;
          final isEven = index % 2 == 0;
          return TableRow(
            decoration: BoxDecoration(
              color: isEven
                  ? AppTheme.tableRowEvenColor
                  : AppTheme.tableRowOddColor,
            ),
            children: [
              _buildDataCell(item.productName),
              _buildDataCell(item.specification),
              _buildDataCell(item.unit, center: true),
              _buildDataCell(item.quantity.toString(), center: true),
              _buildDataCell(CurrencyFormatter.format(item.unitPrice),
                  right: true),
              _buildDataCell(CurrencyFormatter.format(item.amount), right: true),
              _buildDataCell(item.note),
            ],
          );
        }),
        // 합계
        TableRow(
          decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
          children: [
            _buildDataCell('합  계', bold: true, center: true),
            _buildDataCell(''),
            _buildDataCell(''),
            _buildDataCell(''),
            _buildDataCell(''),
            _buildDataCell(
              CurrencyFormatter.format(estimate.totalAmount),
              right: true,
              bold: true,
            ),
            _buildDataCell(estimate.includeVat ? '' : 'VAT별도'),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text,
      {bool center = false, bool right = false, bool bold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(
        text,
        textAlign: right
            ? TextAlign.right
            : center
                ? TextAlign.center
                : TextAlign.left,
        style: TextStyle(
          fontSize: 12,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildConditionsSection(dynamic estimate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildConditionRow('견적유효기간', estimate.validityPeriod),
        _buildConditionRow('제품인수장소', estimate.deliveryPlace),
        _buildConditionRow('납 기', estimate.deliveryDate),
        _buildConditionRow('계약조건', estimate.paymentTerms),
        const SizedBox(height: 12),
        ...estimate.notes.asMap().entries.map<Widget>((entry) {
          final index = entry.key;
          final note = entry.value;
          return Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 4),
            child: Text(
              '${index + 1}) $note',
              style: const TextStyle(fontSize: 13),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildConditionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label :',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailPreview extends StatelessWidget {
  const _DetailPreview();

  @override
  Widget build(BuildContext context) {
    return Consumer<EstimateProvider>(
      builder: (context, provider, child) {
        final estimate = provider.currentEstimate;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 내역서 제목
                  const Center(
                    child: Text(
                      '내   역   서',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 8,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      estimate.projectName,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 내역 테이블
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: _buildDetailTable(estimate),
                  ),
                  const SizedBox(height: 24),

                  // 합계
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withValues(alpha: 0.05),
                      border: Border.all(color: AppTheme.primaryColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSummaryColumn(
                          '재료비 합계',
                          CurrencyFormatter.formatWithWon(
                            estimate.detailItems.fold(
                              0.0,
                              (sum, item) => sum + item.materialAmount,
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppTheme.borderColor,
                        ),
                        _buildSummaryColumn(
                          '노무비 합계',
                          CurrencyFormatter.formatWithWon(
                            estimate.detailItems.fold(
                              0.0,
                              (sum, item) => sum + item.laborAmount,
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppTheme.borderColor,
                        ),
                        _buildSummaryColumn(
                          '총 합계',
                          CurrencyFormatter.formatWithWon(
                              estimate.detailTotalAmount),
                          highlight: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailTable(dynamic estimate) {
    // 항목별 가독성을 위해 열마다 충분한 최소 너비 부여 (가로 스크롤로 전체 확인)
    const colNo = 44.0;
    const colProduct = 140.0;
    const colSpec = 110.0;
    const colUnit = 52.0;
    const colQty = 52.0;
    const colMoney = 88.0; // 단가/금액 열 각각
    const colNote = 100.0;

    return Table(
      border: TableBorder.all(color: AppTheme.borderColor),
      columnWidths: const {
        0: FixedColumnWidth(colNo),
        1: FixedColumnWidth(colProduct),
        2: FixedColumnWidth(colSpec),
        3: FixedColumnWidth(colUnit),
        4: FixedColumnWidth(colQty),
        5: FixedColumnWidth(colMoney),
        6: FixedColumnWidth(colMoney),
        7: FixedColumnWidth(colMoney),
        8: FixedColumnWidth(colMoney),
        9: FixedColumnWidth(colMoney),
        10: FixedColumnWidth(colMoney),
        11: FixedColumnWidth(colNote),
      },
      children: [
        // 헤더 1 (모든 행은 12열로 통일)
        TableRow(
          decoration: BoxDecoration(color: AppTheme.tableHeaderColor),
          children: [
            _buildHeaderCell('No'),
            _buildHeaderCell('품명'),
            _buildHeaderCell('규격'),
            _buildHeaderCell('단위'),
            _buildHeaderCell('수량'),
            _buildHeaderCell('재료비'),
            _buildHeaderCell(''),
            _buildHeaderCell('노무비'),
            _buildHeaderCell(''),
            _buildHeaderCell('합계'),
            _buildHeaderCell(''),
            _buildHeaderCell('비고'),
          ],
        ),
        // 헤더 2
        TableRow(
          decoration: BoxDecoration(color: AppTheme.tableHeaderColor.withValues(alpha: 0.8)),
          children: [
            _buildSubHeaderCell(''),
            _buildSubHeaderCell(''),
            _buildSubHeaderCell(''),
            _buildSubHeaderCell(''),
            _buildSubHeaderCell(''),
            _buildSubHeaderCell('단가'),
            _buildSubHeaderCell('금액'),
            _buildSubHeaderCell('단가'),
            _buildSubHeaderCell('금액'),
            _buildSubHeaderCell('단가'),
            _buildSubHeaderCell('금액'),
            _buildSubHeaderCell(''),
          ],
        ),
        // 데이터 행
        ...estimate.detailItems.asMap().entries.map<TableRow>((entry) {
          final index = entry.key;
          final item = entry.value;
          final isEven = index % 2 == 0;
          return TableRow(
            decoration: BoxDecoration(
              color: isEven
                  ? AppTheme.tableRowEvenColor
                  : AppTheme.tableRowOddColor,
            ),
            children: [
              _buildDataCell(item.no.toString(), center: true),
              _buildDataCell(item.productName),
              _buildDataCell(item.specification),
              _buildDataCell(item.unit, center: true),
              _buildDataCell(item.quantity.toString(), center: true),
              _buildDataCell(CurrencyFormatter.format(item.materialUnitPrice),
                  right: true),
              _buildDataCell(CurrencyFormatter.format(item.materialAmount),
                  right: true),
              _buildDataCell(CurrencyFormatter.format(item.laborUnitPrice),
                  right: true),
              _buildDataCell(CurrencyFormatter.format(item.laborAmount),
                  right: true),
              _buildDataCell(CurrencyFormatter.format(item.totalUnitPrice),
                  right: true),
              _buildDataCell(CurrencyFormatter.format(item.totalAmount),
                  right: true),
              _buildDataCell(item.note),
            ],
          );
        }),
        // 합계
        TableRow(
          decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
          children: [
            _buildDataCell('', center: true),
            _buildDataCell('합계', bold: true, center: true),
            _buildDataCell(''),
            _buildDataCell(''),
            _buildDataCell(''),
            _buildDataCell(''),
            _buildDataCell(
              CurrencyFormatter.format(
                estimate.detailItems.fold(
                  0.0,
                  (sum, item) => sum + item.materialAmount,
                ),
              ),
              right: true,
              bold: true,
            ),
            _buildDataCell(''),
            _buildDataCell(
              CurrencyFormatter.format(
                estimate.detailItems.fold(
                  0.0,
                  (sum, item) => sum + item.laborAmount,
                ),
              ),
              right: true,
              bold: true,
            ),
            _buildDataCell(''),
            _buildDataCell(
              CurrencyFormatter.format(estimate.detailTotalAmount),
              right: true,
              bold: true,
            ),
            _buildDataCell(''),
          ],
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSubHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildDataCell(String text,
      {bool center = false, bool right = false, bool bold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      alignment: right
          ? Alignment.centerRight
          : center
              ? Alignment.center
              : Alignment.centerLeft,
      child: Text(
        text,
        textAlign: right
            ? TextAlign.right
            : center
                ? TextAlign.center
                : TextAlign.left,
        softWrap: true,
        overflow: TextOverflow.visible,
        style: TextStyle(
          fontSize: 12,
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildSummaryColumn(String label, String value,
      {bool highlight = false}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: highlight ? AppTheme.accentColor : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}


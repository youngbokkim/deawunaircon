import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/estimate_provider.dart';
import '../models/detail_item.dart';
import '../utils/app_theme.dart';
import '../utils/currency_formatter.dart';

class DetailFormScreen extends StatelessWidget {
  const DetailFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내역서'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: '저장',
            onPressed: () {
              context.read<EstimateProvider>().saveEstimate();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('내역서가 저장되었습니다'),
                  backgroundColor: AppTheme.successColor,
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<EstimateProvider>(
        builder: (context, provider, child) {
          final estimate = provider.currentEstimate;
          return Column(
            children: [
              // 합계 헤더
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2C5282), Color(0xFF3D5A80)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      '내역서 합계',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyFormatter.formatWithWon(estimate.detailTotalAmount),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildSummaryItem(
                          '재료비',
                          CurrencyFormatter.format(
                            estimate.detailItems.fold(
                              0.0,
                              (sum, item) => sum + item.materialAmount,
                            ),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white24,
                        ),
                        _buildSummaryItem(
                          '노무비',
                          CurrencyFormatter.format(
                            estimate.detailItems.fold(
                              0.0,
                              (sum, item) => sum + item.laborAmount,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 항목 추가 버튼
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '내역 항목 (${estimate.detailItems.length}개)',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showDetailItemDialog(context, provider),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('항목 추가'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // 항목 리스트
              Expanded(
                child: estimate.detailItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.list_alt_outlined,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '내역 항목을 추가해 주세요',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: estimate.detailItems.length,
                        itemBuilder: (context, index) {
                          final item = estimate.detailItems[index];
                          return _buildDetailItemCard(
                              context, provider, item, index);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItemCard(BuildContext context, EstimateProvider provider,
      DetailItem item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () =>
            _showDetailItemDialog(context, provider, item: item, index: index),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${item.no}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.productName.isEmpty
                              ? '(품명 없음)'
                              : item.productName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        if (item.specification.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.specification,
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppTheme.errorColor, size: 20),
                    onPressed: () => provider.removeDetailItem(index),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoColumn('수량', '${item.quantity} ${item.unit}'),
                  ),
                  Expanded(
                    child: _buildInfoColumn(
                        '재료비', CurrencyFormatter.format(item.materialAmount)),
                  ),
                  Expanded(
                    child: _buildInfoColumn(
                        '노무비', CurrencyFormatter.format(item.laborAmount)),
                  ),
                  Expanded(
                    child: _buildInfoColumn(
                      '합계',
                      CurrencyFormatter.format(item.totalAmount),
                      highlight: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value, {bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            color: highlight ? AppTheme.accentColor : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  void _showDetailItemDialog(BuildContext context, EstimateProvider provider,
      {DetailItem? item, int? index}) {
    final isEditing = item != null;
    final productNameController =
        TextEditingController(text: item?.productName ?? '');
    final specController =
        TextEditingController(text: item?.specification ?? '');
    final unitController = TextEditingController(text: item?.unit ?? '대');
    final quantityController =
        TextEditingController(text: (item?.quantity ?? 1).toString());
    final materialPriceController = TextEditingController(
        text: item != null ? item.materialUnitPrice.toStringAsFixed(0) : '');
    final laborPriceController = TextEditingController(
        text: item != null ? item.laborUnitPrice.toStringAsFixed(0) : '');
    final noteController = TextEditingController(text: item?.note ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? '내역 수정' : '내역 추가'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: productNameController,
                decoration: const InputDecoration(labelText: '품명'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: specController,
                decoration: const InputDecoration(labelText: '규격'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: unitController,
                      decoration: const InputDecoration(labelText: '단위'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: quantityController,
                      decoration: const InputDecoration(labelText: '수량'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: materialPriceController,
                decoration: const InputDecoration(labelText: '재료비 단가'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: laborPriceController,
                decoration: const InputDecoration(labelText: '노무비 단가'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(labelText: '비고'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              final newItem = DetailItem(
                id: item?.id,
                no: item?.no ?? 0,
                productName: productNameController.text,
                specification: specController.text,
                unit: unitController.text,
                quantity: int.tryParse(quantityController.text) ?? 1,
                materialUnitPrice:
                    double.tryParse(materialPriceController.text) ?? 0,
                laborUnitPrice:
                    double.tryParse(laborPriceController.text) ?? 0,
                note: noteController.text,
              );

              if (isEditing && index != null) {
                provider.updateDetailItem(index, newItem);
              } else {
                provider.addDetailItem(newItem);
              }
              Navigator.pop(context);
            },
            child: Text(isEditing ? '수정' : '추가'),
          ),
        ],
      ),
    );
  }
}



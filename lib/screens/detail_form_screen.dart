import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/estimate_provider.dart';
import '../providers/detail_template_provider.dart';
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
            onPressed: () async {
              final ok = await context.read<EstimateProvider>().saveEstimate();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ok ? '내역서가 서버에 저장되었습니다' : '저장 실패. 서버 연결을 확인해 주세요.',
                  ),
                  backgroundColor: ok ? AppTheme.successColor : Colors.red,
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
    showDialog(
      context: context,
      builder: (context) => _DetailItemDialog(
        estimateProvider: provider,
        item: item,
        index: index,
      ),
    );
  }
}

/// 내역 추가/수정 다이얼로그: 이전 항목 검색 + 선택 후 폼에 채우기
class _DetailItemDialog extends StatefulWidget {
  const _DetailItemDialog({
    required this.estimateProvider,
    this.item,
    this.index,
  });

  final EstimateProvider estimateProvider;
  final DetailItem? item;
  final int? index;

  @override
  State<_DetailItemDialog> createState() => _DetailItemDialogState();
}

class _DetailItemDialogState extends State<_DetailItemDialog> {
  late final TextEditingController _productNameController;
  late final TextEditingController _specController;
  late final TextEditingController _unitController;
  late final TextEditingController _quantityController;
  late final TextEditingController _materialPriceController;
  late final TextEditingController _laborPriceController;
  late final TextEditingController _noteController;

  List<DetailItem> _searchResults = [];
  bool _searching = false;
  Timer? _searchDebounce;
  DetailTemplateProvider? _templateProvider;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _productNameController =
        TextEditingController(text: item?.productName ?? '');
    _specController = TextEditingController(text: item?.specification ?? '');
    _unitController = TextEditingController(text: item?.unit ?? '대');
    _quantityController =
        TextEditingController(text: (item?.quantity ?? 1).toString());
    _materialPriceController = TextEditingController(
        text: item != null ? item.materialUnitPrice.toStringAsFixed(0) : '');
    _laborPriceController = TextEditingController(
        text: item != null ? item.laborUnitPrice.toStringAsFixed(0) : '');
    _noteController = TextEditingController(text: item?.note ?? '');

    _productNameController.addListener(_onProductNameOrSpecChanged);
    _specController.addListener(_onProductNameOrSpecChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _productNameController.removeListener(_onProductNameOrSpecChanged);
    _specController.removeListener(_onProductNameOrSpecChanged);
    _productNameController.dispose();
    _specController.dispose();
    _unitController.dispose();
    _quantityController.dispose();
    _materialPriceController.dispose();
    _laborPriceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onProductNameOrSpecChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 200), _runSearch);
  }

  Future<void> _runSearch() async {
    if (!mounted) return;
    _templateProvider ??= context.read<DetailTemplateProvider>();
    final provider = _templateProvider;
    if (provider == null) return;
    setState(() => _searching = true);
    try {
      final results = await provider.searchByProductNameAndSpec(
        _productNameController.text,
        _specController.text,
      );
      if (mounted) {
        setState(() {
          _searchResults = results;
          _searching = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _searching = false;
        });
      }
    }
  }

  void _applyTemplate(DetailItem t) {
    setState(() {
      _productNameController.text = t.productName;
      _specController.text = t.specification;
      _unitController.text = t.unit;
      _quantityController.text = t.quantity.toString();
      _materialPriceController.text = t.materialUnitPrice.toStringAsFixed(0);
      _laborPriceController.text = t.laborUnitPrice.toStringAsFixed(0);
      _noteController.text = t.note;
      _searchResults = [];
    });
  }

  void _submit() {
    final newItem = DetailItem(
      id: widget.item?.id,
      no: widget.item?.no ?? 0,
      productName: _productNameController.text,
      specification: _specController.text,
      unit: _unitController.text,
      quantity: int.tryParse(_quantityController.text) ?? 1,
      materialUnitPrice:
          double.tryParse(_materialPriceController.text) ?? 0,
      laborUnitPrice: double.tryParse(_laborPriceController.text) ?? 0,
      note: _noteController.text,
    );

    if (widget.item != null && widget.index != null) {
      widget.estimateProvider.updateDetailItem(widget.index!, newItem);
    } else {
      widget.estimateProvider.addDetailItem(newItem);
    }
    context.read<DetailTemplateProvider>().addTemplate(newItem);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;

    return AlertDialog(
      title: Text(isEditing ? '내역 수정' : '내역 추가'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 품명 + 하단 콤보
            TextField(
              controller: _productNameController,
              decoration: InputDecoration(
                labelText: '품명',
                hintText: '입력 시 저장된 항목이 아래에 표시됩니다',
                suffixIcon: _searching
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : null,
              ),
            ),
            if (_searchResults.isNotEmpty &&
                (_productNameController.text.isNotEmpty ||
                    _specController.text.isNotEmpty)) ...[
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border.all(color: AppTheme.borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _searchResults.take(5).map((t) {
                    return ListTile(
                      dense: true,
                      title: Text(
                        t.productName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w500, fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: t.specification.isEmpty
                          ? null
                          : Text(
                              t.specification,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12),
                            ),
                      trailing: Text(
                        '${t.unit} · ${CurrencyFormatter.format(t.materialUnitPrice)}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      onTap: () => _applyTemplate(t),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 12),
            ],
            // 규격 + 동일 콤보(품명/규격 둘 다 반영되어 위 리스트에 표시됨)
            TextField(
              controller: _specController,
              decoration: const InputDecoration(
                labelText: '규격',
                hintText: '입력 시 품명·규격 기준으로 위 목록이 필터됩니다',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _unitController,
                    decoration: const InputDecoration(labelText: '단위'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    decoration: const InputDecoration(labelText: '수량'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _materialPriceController,
              decoration: const InputDecoration(labelText: '재료비 단가'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _laborPriceController,
              decoration: const InputDecoration(labelText: '노무비 단가'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _noteController,
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
          onPressed: _submit,
          child: Text(isEditing ? '수정' : '추가'),
        ),
      ],
    );
  }
}



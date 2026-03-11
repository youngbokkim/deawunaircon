import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/estimate_provider.dart';
import '../providers/estimate_template_provider.dart';
import '../models/estimate_item.dart';
import '../utils/app_theme.dart';
import '../utils/currency_formatter.dart';
import 'detail_form_screen.dart';
import 'estimate_preview_screen.dart';

class EstimateFormScreen extends StatefulWidget {
  const EstimateFormScreen({super.key});

  @override
  State<EstimateFormScreen> createState() => _EstimateFormScreenState();
}

class _EstimateFormScreenState extends State<EstimateFormScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('견적서 작성'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '기본정보'),
            Tab(text: '견적항목'),
            Tab(text: '기타사항'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.preview_outlined),
            tooltip: '미리보기',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EstimatePreviewScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.save_outlined),
            tooltip: '저장',
            onPressed: () async {
              final ok = await context.read<EstimateProvider>().saveEstimate();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ok ? '견적서가 서버에 저장되었습니다' : '저장 실패. 서버 연결을 확인해 주세요.',
                  ),
                  backgroundColor: ok ? AppTheme.successColor : Colors.red,
                ),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _BasicInfoTab(),
          _ItemsTab(),
          _NotesTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DetailFormScreen(),
            ),
          );
        },
        icon: const Icon(Icons.list_alt_outlined),
        label: const Text('내역서'),
      ),
    );
  }
}

class _BasicInfoTab extends StatelessWidget {
  const _BasicInfoTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<EstimateProvider>(
      builder: (context, provider, child) {
        final estimate = provider.currentEstimate;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard(
                title: '공사 정보',
                icon: Icons.construction_outlined,
                children: [
                  _buildTextField(
                    label: '공사명',
                    value: estimate.projectName,
                    onChanged: (value) => provider.updateProjectName(value),
                  ),
                  const SizedBox(height: 16),
                  _buildDateField(
                    context: context,
                    label: '견적일자',
                    value: estimate.estimateDate,
                    onChanged: (date) => provider.updateEstimateDate(date),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: '회사 정보',
                icon: Icons.business_outlined,
                children: [
                  _buildTextField(
                    label: '회사명',
                    value: estimate.companyInfo.name,
                    onChanged: (value) {
                      estimate.companyInfo.name = value;
                      provider.updateCompanyInfo(estimate.companyInfo);
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: '주소',
                    value: estimate.companyInfo.address,
                    onChanged: (value) {
                      estimate.companyInfo.address = value;
                      provider.updateCompanyInfo(estimate.companyInfo);
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: '전화번호',
                          value: estimate.companyInfo.phone,
                          onChanged: (value) {
                            estimate.companyInfo.phone = value;
                            provider.updateCompanyInfo(estimate.companyInfo);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: 'FAX',
                          value: estimate.companyInfo.fax,
                          onChanged: (value) {
                            estimate.companyInfo.fax = value;
                            provider.updateCompanyInfo(estimate.companyInfo);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: '담당자 HP',
                          value: estimate.companyInfo.mobile,
                          onChanged: (value) {
                            estimate.companyInfo.mobile = value;
                            provider.updateCompanyInfo(estimate.companyInfo);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: '이메일',
                          value: estimate.companyInfo.email,
                          onChanged: (value) {
                            estimate.companyInfo.email = value;
                            provider.updateCompanyInfo(estimate.companyInfo);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: '입금계좌',
                    value: estimate.companyInfo.bankAccount,
                    onChanged: (value) {
                      estimate.companyInfo.bankAccount = value;
                      provider.updateCompanyInfo(estimate.companyInfo);
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.accentColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
  }) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildDateField({
    required BuildContext context,
    required String label,
    required DateTime value,
    required ValueChanged<DateTime> onChanged,
  }) {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (date != null) {
          onChanged(date);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          suffixIcon: const Icon(Icons.calendar_today, size: 20),
        ),
        child: Text(DateFormatter.format(value)),
      ),
    );
  }
}

class _ItemsTab extends StatelessWidget {
  const _ItemsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<EstimateProvider>(
      builder: (context, provider, child) {
        final estimate = provider.currentEstimate;
        return Column(
          children: [
            // 합계 카드
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '견적 합계',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyFormatter.formatWithWon(estimate.totalAmount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    estimate.amountInKorean,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: estimate.includeVat,
                        onChanged: (value) =>
                            provider.toggleVat(value ?? false),
                        fillColor: WidgetStateProperty.all(Colors.white),
                        checkColor: AppTheme.primaryColor,
                      ),
                      const Text(
                        'VAT 별도',
                        style: TextStyle(color: Colors.white),
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
                    '견적 항목 (${estimate.items.length}개)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showItemDialog(context, provider),
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
              child: estimate.items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_box_outlined,
                            size: 64,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '견적 항목을 추가해 주세요',
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
                      itemCount: estimate.items.length,
                      itemBuilder: (context, index) {
                        final item = estimate.items[index];
                        return _buildItemCard(
                            context, provider, item, index);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildItemCard(BuildContext context, EstimateProvider provider,
      EstimateItem item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _showItemDialog(context, provider, item: item, index: index),
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
                      color: AppTheme.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentColor,
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
                          item.productName.isEmpty ? '(품명 없음)' : item.productName,
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
                    onPressed: () => provider.removeItem(index),
                  ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildItemInfo('수량', '${item.quantity} ${item.unit}'),
                  _buildItemInfo('단가', CurrencyFormatter.format(item.unitPrice)),
                  _buildItemInfo(
                    '금액',
                    CurrencyFormatter.format(item.amount),
                    highlight: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemInfo(String label, String value, {bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: highlight ? FontWeight.bold : FontWeight.normal,
            color: highlight ? AppTheme.accentColor : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  void _showItemDialog(BuildContext context, EstimateProvider provider,
      {EstimateItem? item, int? index}) {
    showDialog(
      context: context,
      builder: (context) => _EstimateItemDialog(
        estimateProvider: provider,
        item: item,
        index: index,
      ),
    );
  }
}

class _EstimateItemDialog extends StatefulWidget {
  const _EstimateItemDialog({
    required this.estimateProvider,
    this.item,
    this.index,
  });

  final EstimateProvider estimateProvider;
  final EstimateItem? item;
  final int? index;

  @override
  State<_EstimateItemDialog> createState() => _EstimateItemDialogState();
}

class _EstimateItemDialogState extends State<_EstimateItemDialog> {
  late final TextEditingController _productNameController;
  late final TextEditingController _specController;
  late final TextEditingController _unitController;
  late final TextEditingController _quantityController;
  late final TextEditingController _priceController;
  late final TextEditingController _noteController;

  List<EstimateItem> _searchResults = [];
  bool _searching = false;
  Timer? _searchDebounce;
  EstimateTemplateProvider? _templateProvider;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _productNameController =
        TextEditingController(text: item?.productName ?? '');
    _specController =
        TextEditingController(text: item?.specification ?? '');
    _unitController = TextEditingController(text: item?.unit ?? '대');
    _quantityController =
        TextEditingController(text: (item?.quantity ?? 1).toString());
    _priceController = TextEditingController(
        text: item != null ? item.unitPrice.toStringAsFixed(0) : '');
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
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onProductNameOrSpecChanged() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 200), _runSearch);
  }

  Future<void> _runSearch() async {
    if (!mounted) return;
    _templateProvider ??= context.read<EstimateTemplateProvider>();
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

  void _applyTemplate(EstimateItem t) {
    setState(() {
      _productNameController.text = t.productName;
      _specController.text = t.specification;
      _unitController.text = t.unit;
      _quantityController.text = t.quantity.toString();
      _priceController.text = t.unitPrice.toStringAsFixed(0);
      _noteController.text = t.note;
      _searchResults = [];
    });
  }

  void _submit() {
    final newItem = EstimateItem(
      id: widget.item?.id,
      productName: _productNameController.text,
      specification: _specController.text,
      unit: _unitController.text,
      quantity: int.tryParse(_quantityController.text) ?? 1,
      unitPrice: double.tryParse(_priceController.text) ?? 0,
      note: _noteController.text,
    );

    if (widget.item != null && widget.index != null) {
      widget.estimateProvider.updateItem(widget.index!, newItem);
    } else {
      widget.estimateProvider.addItem(newItem);
    }
    context.read<EstimateTemplateProvider>().addTemplate(newItem);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.item != null;

    return AlertDialog(
      title: Text(isEditing ? '항목 수정' : '항목 추가'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
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
                constraints: const BoxConstraints(maxHeight: 140),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  border: Border.all(color: AppTheme.borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _searchResults.length,
                  itemBuilder: (context, i) {
                    final t = _searchResults[i];
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
                        '${t.unit} · ${CurrencyFormatter.format(t.unitPrice)}',
                        style: const TextStyle(fontSize: 11),
                      ),
                      onTap: () => _applyTemplate(t),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
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
              controller: _priceController,
              decoration: const InputDecoration(labelText: '단가'),
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

class _NotesTab extends StatelessWidget {
  const _NotesTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<EstimateProvider>(
      builder: (context, provider, child) {
        final estimate = provider.currentEstimate;
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionCard(
                title: '계약 조건',
                icon: Icons.description_outlined,
                children: [
                  _buildTextField(
                    label: '견적 유효기간',
                    value: estimate.validityPeriod,
                    onChanged: (value) => provider.updateValidityPeriod(value),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: '제품 인수장소',
                    value: estimate.deliveryPlace,
                    onChanged: (value) => provider.updateDeliveryPlace(value),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: '납기',
                    value: estimate.deliveryDate,
                    onChanged: (value) => provider.updateDeliveryDate(value),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    label: '계약 조건',
                    value: estimate.paymentTerms,
                    onChanged: (value) => provider.updatePaymentTerms(value),
                    maxLines: 2,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSectionCard(
                title: '참고 사항',
                icon: Icons.note_outlined,
                trailing: IconButton(
                  icon: const Icon(Icons.add_circle_outline,
                      color: AppTheme.accentColor),
                  onPressed: () {
                    provider.addNote('');
                  },
                ),
                children: [
                  ...estimate.notes.asMap().entries.map((entry) {
                    final index = entry.key;
                    final note = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            child: Text(
                              '${index + 1})',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextFormField(
                              initialValue: note,
                              decoration: const InputDecoration(
                                isDense: true,
                                hintText: '참고 사항 입력',
                              ),
                              onChanged: (value) =>
                                  provider.updateNote(index, value),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: AppTheme.errorColor, size: 20),
                            onPressed: () => provider.removeNote(index),
                          ),
                        ],
                      ),
                    );
                  }),
                  if (estimate.notes.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          '참고 사항을 추가해 주세요',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.warningColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.warningColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '본 견적서는 필요시 약식 계약서 내지는 설치의뢰로 갈음합니다.',
                        style: TextStyle(
                          color: AppTheme.warningColor.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    Widget? trailing,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.accentColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required ValueChanged<String> onChanged,
    int maxLines = 1,
  }) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
      ),
      maxLines: maxLines,
      onChanged: onChanged,
    );
  }
}


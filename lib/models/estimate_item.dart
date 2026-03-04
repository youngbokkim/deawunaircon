import 'package:uuid/uuid.dart';

class EstimateItem {
  final String id;
  String productName;
  String specification;
  String unit;
  int quantity;
  double unitPrice;
  String note;

  EstimateItem({
    String? id,
    this.productName = '',
    this.specification = '',
    this.unit = '대',
    this.quantity = 1,
    this.unitPrice = 0,
    this.note = '',
  }) : id = id ?? const Uuid().v4();

  double get amount => quantity * unitPrice;

  EstimateItem copyWith({
    String? id,
    String? productName,
    String? specification,
    String? unit,
    int? quantity,
    double? unitPrice,
    String? note,
  }) {
    return EstimateItem(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      specification: specification ?? this.specification,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productName': productName,
      'specification': specification,
      'unit': unit,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'note': note,
    };
  }

  factory EstimateItem.fromJson(Map<String, dynamic> json) {
    return EstimateItem(
      id: json['id'],
      productName: json['productName'] ?? '',
      specification: json['specification'] ?? '',
      unit: json['unit'] ?? '대',
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      note: json['note'] ?? '',
    );
  }
}



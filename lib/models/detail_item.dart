import 'package:uuid/uuid.dart';

class DetailItem {
  final String id;
  int no;
  String productName;
  String specification;
  String unit;
  int quantity;
  double materialUnitPrice;
  double laborUnitPrice;
  String note;

  DetailItem({
    String? id,
    this.no = 0,
    this.productName = '',
    this.specification = '',
    this.unit = '대',
    this.quantity = 1,
    this.materialUnitPrice = 0,
    this.laborUnitPrice = 0,
    this.note = '',
  }) : id = id ?? const Uuid().v4();

  double get materialAmount => quantity * materialUnitPrice;
  double get laborAmount => quantity * laborUnitPrice;
  double get totalUnitPrice => materialUnitPrice + laborUnitPrice;
  double get totalAmount => quantity * totalUnitPrice;

  DetailItem copyWith({
    String? id,
    int? no,
    String? productName,
    String? specification,
    String? unit,
    int? quantity,
    double? materialUnitPrice,
    double? laborUnitPrice,
    String? note,
  }) {
    return DetailItem(
      id: id ?? this.id,
      no: no ?? this.no,
      productName: productName ?? this.productName,
      specification: specification ?? this.specification,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      materialUnitPrice: materialUnitPrice ?? this.materialUnitPrice,
      laborUnitPrice: laborUnitPrice ?? this.laborUnitPrice,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'no': no,
      'productName': productName,
      'specification': specification,
      'unit': unit,
      'quantity': quantity,
      'materialUnitPrice': materialUnitPrice,
      'laborUnitPrice': laborUnitPrice,
      'note': note,
    };
  }

  factory DetailItem.fromJson(Map<String, dynamic> json) {
    return DetailItem(
      id: json['id'],
      no: json['no'] ?? 0,
      productName: json['productName'] ?? '',
      specification: json['specification'] ?? '',
      unit: json['unit'] ?? '대',
      quantity: json['quantity'] ?? 1,
      materialUnitPrice: (json['materialUnitPrice'] ?? 0).toDouble(),
      laborUnitPrice: (json['laborUnitPrice'] ?? 0).toDouble(),
      note: json['note'] ?? '',
    );
  }
}



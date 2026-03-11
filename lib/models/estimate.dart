import 'package:uuid/uuid.dart';
import 'estimate_item.dart';
import 'detail_item.dart';

class CompanyInfo {
  String name;
  String address;
  String phone;
  String fax;
  String mobile;
  String email;
  String bankAccount;

  CompanyInfo({
    this.name = '대운공조시스템',
    this.address = '경기도하남시 감이남로66-2',
    this.phone = '02-483-4148',
    this.fax = '02-483-4147',
    this.mobile = '010-5484-3315',
    this.email = 'hituch@naver.com',
    this.bankAccount = '농협: 204075-51-058369 김대운',
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'fax': fax,
      'mobile': mobile,
      'email': email,
      'bankAccount': bankAccount,
    };
  }

  factory CompanyInfo.fromJson(Map<String, dynamic> json) {
    return CompanyInfo(
      name: json['name'] ?? '대운공조시스템',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      fax: json['fax'] ?? '',
      mobile: json['mobile'] ?? '',
      email: json['email'] ?? '',
      bankAccount: json['bankAccount'] ?? '',
    );
  }
}

class Estimate {
  final String id;
  String projectName;
  DateTime estimateDate;
  CompanyInfo companyInfo;
  List<EstimateItem> items;
  List<DetailItem> detailItems;
  String validityPeriod;
  String deliveryPlace;
  String deliveryDate;
  String paymentTerms;
  List<String> notes;
  bool includeVat;

  Estimate({
    String? id,
    this.projectName = 'LG시스템에어컨 설치공사',
    DateTime? estimateDate,
    CompanyInfo? companyInfo,
    List<EstimateItem>? items,
    List<DetailItem>? detailItems,
    this.validityPeriod = '견적일로 부터 15일',
    this.deliveryPlace = '추후협의',
    this.deliveryDate = '추후협의',
    this.paymentTerms = '추후협의 : 계약금30% 중도금60% 시운전완료후10%',
    List<String>? notes,
    this.includeVat = false,
  })  : id = id ?? const Uuid().v4(),
        estimateDate = estimateDate ?? DateTime.now(),
        companyInfo = companyInfo ?? CompanyInfo(),
        items = items ?? [],
        detailItems = detailItems ?? [],
        notes = notes ??
            [
              '반입, 설치 및 시운전 포함',
              '(1, 2차 전기공사 제외)- 발주처 시행',
              '천장마감이 텍스가 아닌경우 점검구 설치비용 발생',
              '기타 견적외 사항은 별도임.',
            ];

  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.amount);
  double get totalWithVat => includeVat ? totalAmount * 1.1 : totalAmount;
  double get detailTotalAmount =>
      detailItems.fold(0.0, (sum, item) => sum + item.totalAmount);

  String get amountInKorean {
    return _numberToKorean(totalAmount.round());
  }

  String _numberToKorean(int number) {
    if (number == 0) return '영';

    const units = ['', '만', '억', '조'];
    const digits = ['', '일', '이', '삼', '사', '오', '육', '칠', '팔', '구'];
    const subUnits = ['', '십', '백', '천'];

    String result = '';
    int unitIndex = 0;

    while (number > 0) {
      int part = number % 10000;
      if (part > 0) {
        String partStr = '';
        int subIndex = 0;
        while (part > 0) {
          int digit = part % 10;
          if (digit > 0) {
            String digitStr = (digit == 1 && subIndex > 0) ? '' : digits[digit];
            partStr = digitStr + subUnits[subIndex] + partStr;
          }
          part ~/= 10;
          subIndex++;
        }
        result = partStr + units[unitIndex] + result;
      }
      number ~/= 10000;
      unitIndex++;
    }

    return '일금 $result원정';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectName': projectName,
      'estimateDate': estimateDate.toIso8601String(),
      'companyInfo': companyInfo.toJson(),
      'items': items.map((e) => e.toJson()).toList(),
      'detailItems': detailItems.map((e) => e.toJson()).toList(),
      'validityPeriod': validityPeriod,
      'deliveryPlace': deliveryPlace,
      'deliveryDate': deliveryDate,
      'paymentTerms': paymentTerms,
      'notes': notes,
      'includeVat': includeVat,
    };
  }

  factory Estimate.fromJson(Map<String, dynamic> json) {
    return Estimate(
      id: json['id'],
      projectName: json['projectName'] ?? '',
      estimateDate: json['estimateDate'] != null
          ? DateTime.parse(json['estimateDate'].toString())
          : DateTime.now(),
      companyInfo: CompanyInfo.fromJson(json['companyInfo'] ?? {}),
      items: (json['items'] as List?)
              ?.map((e) => EstimateItem.fromJson(e))
              .toList() ??
          [],
      detailItems: (json['detailItems'] as List?)
              ?.map((e) => DetailItem.fromJson(e))
              .toList() ??
          [],
      validityPeriod: json['validityPeriod'] ?? '',
      deliveryPlace: json['deliveryPlace'] ?? '',
      deliveryDate: json['deliveryDate'] ?? '',
      paymentTerms: json['paymentTerms'] ?? '',
      notes: (json['notes'] as List?)?.cast<String>() ?? [],
      includeVat: json['includeVat'] ?? false,
    );
  }
}



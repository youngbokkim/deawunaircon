import '../models/estimate.dart';
import '../models/estimate_item.dart';
import '../models/detail_item.dart';

/// 앱에서 사용할 견적서 샘플 데이터
class SampleEstimates {
  static List<Estimate> get list => [
        _sample1(),
        _sample2(),
        _sample3(),
      ];

  static Estimate _sample1() {
    final e = Estimate(
      projectName: 'LG시스템에어컨 설치공사 - A동 사무실',
      estimateDate: DateTime.now().subtract(const Duration(days: 5)),
      items: [
        EstimateItem(
          productName: '실내기',
          specification: 'LP-S306AL2 (3마력)',
          unit: '대',
          quantity: 2,
          unitPrice: 1850000,
          note: '벽걸이형',
        ),
        EstimateItem(
          productName: '실외기',
          specification: 'LP-A306AL2 (3마력)',
          unit: '대',
          quantity: 1,
          unitPrice: 2100000,
          note: '2대 연결',
        ),
        EstimateItem(
          productName: '배관 및 부자재',
          specification: 'R410A 5m 이내',
          unit: '식',
          quantity: 1,
          unitPrice: 850000,
          note: '실내기 2대 기준',
        ),
      ],
      detailItems: [
        DetailItem(
          no: 1,
          productName: '실내기',
          specification: 'LP-S306AL2',
          unit: '대',
          quantity: 2,
          materialUnitPrice: 1600000,
          laborUnitPrice: 250000,
          note: '벽걸이',
        ),
        DetailItem(
          no: 2,
          productName: '실외기',
          specification: 'LP-A306AL2',
          unit: '대',
          quantity: 1,
          materialUnitPrice: 1900000,
          laborUnitPrice: 200000,
          note: '',
        ),
      ],
      validityPeriod: '견적일로 부터 15일',
      deliveryPlace: '현장 인도',
      deliveryDate: '계약일로부터 10일 이내',
      paymentTerms: '계약금 30% / 중도금 60% / 잔금 10%',
      includeVat: false,
    );
    return e;
  }

  static Estimate _sample2() {
    final e = Estimate(
      projectName: '삼성 멀티에어컨 설치 - B동 회의실',
      estimateDate: DateTime.now().subtract(const Duration(days: 12)),
      items: [
        EstimateItem(
          productName: '멀티 실내기',
          specification: 'AR12T5140HZ (1.5마력)',
          unit: '대',
          quantity: 4,
          unitPrice: 420000,
          note: '카세트 2구',
        ),
        EstimateItem(
          productName: '멀티 실외기',
          specification: 'AR36T5140HZ (6마력)',
          unit: '대',
          quantity: 1,
          unitPrice: 2850000,
          note: '4실 연결',
        ),
        EstimateItem(
          productName: '설치 및 시운전',
          specification: '배관 15m 이내',
          unit: '식',
          quantity: 1,
          unitPrice: 1200000,
          note: '',
        ),
      ],
      detailItems: [
        DetailItem(
          no: 1,
          productName: '카세트 실내기',
          specification: 'AR12T5140HZ',
          unit: '대',
          quantity: 4,
          materialUnitPrice: 380000,
          laborUnitPrice: 40000,
          note: '2구',
        ),
        DetailItem(
          no: 2,
          productName: '멀티 실외기',
          specification: 'AR36T5140HZ',
          unit: '대',
          quantity: 1,
          materialUnitPrice: 2650000,
          laborUnitPrice: 200000,
          note: '6마력',
        ),
      ],
      validityPeriod: '견적일로 부터 20일',
      deliveryPlace: '추후협의',
      deliveryDate: '추후협의',
      paymentTerms: '계약금 30% 중도금 60% 시운전완료후 10%',
      includeVat: true,
    );
    return e;
  }

  static Estimate _sample3() {
    final e = Estimate(
      projectName: '일반 스탠드 에어컨 교체 공사',
      estimateDate: DateTime.now().subtract(const Duration(days: 2)),
      items: [
        EstimateItem(
          productName: '스탠드형 에어컨',
          specification: 'LW-D2511ES (10평형)',
          unit: '대',
          quantity: 1,
          unitPrice: 1650000,
          note: '전기포함',
        ),
        EstimateItem(
          productName: '철거 및 설치',
          specification: '기존기 철거 포함',
          unit: '식',
          quantity: 1,
          unitPrice: 350000,
          note: '',
        ),
      ],
      detailItems: [],
      validityPeriod: '견적일로 부터 15일',
      deliveryPlace: '현장',
      deliveryDate: '계약후 7일',
      paymentTerms: '현금 결제',
      includeVat: false,
    );
    return e;
  }
}

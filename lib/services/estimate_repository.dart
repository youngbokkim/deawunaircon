import '../models/estimate.dart';

/// 견적서 저장소 인터페이스 (Firestore 등 구현체 주입용)
abstract class EstimateRepository {
  Future<List<Estimate>> getEstimates();
  Future<Estimate> saveEstimate(Estimate estimate);
  Future<void> deleteEstimate(String id);
}

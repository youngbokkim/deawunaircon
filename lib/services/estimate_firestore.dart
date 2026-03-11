import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/estimate.dart';
import 'estimate_repository.dart';

const String _collectionName = 'estimates';

/// Firestore로 견적서를 저장·조회·삭제합니다.
class EstimateFirestore implements EstimateRepository {
  EstimateFirestore({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(_collectionName);

  @override
  Future<List<Estimate>> getEstimates() async {
    final snapshot = await _col.orderBy('estimateDate', descending: true).get();
    return snapshot.docs.map((doc) => _docToEstimate(doc)).toList();
  }

  @override
  Future<Estimate> saveEstimate(Estimate estimate) async {
    final data = estimate.toJson();
    await _col.doc(estimate.id).set(data);
    return estimate;
  }

  @override
  Future<void> deleteEstimate(String id) async {
    await _col.doc(id).delete();
  }

  Estimate _docToEstimate(DocumentSnapshot<Map<String, dynamic>> doc) {
    final map = Map<String, dynamic>.from(doc.data() ?? {});
    // Firestore Timestamp → ISO 문자열
    final date = map['estimateDate'];
    if (date is Timestamp) {
      map['estimateDate'] = date.toDate().toIso8601String();
    } else if (date is DateTime) {
      map['estimateDate'] = date.toIso8601String();
    }
    return Estimate.fromJson(map);
  }
}

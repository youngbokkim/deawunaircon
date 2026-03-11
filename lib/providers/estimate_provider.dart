import 'package:flutter/foundation.dart';
import '../data/sample_estimates.dart';
import '../models/estimate.dart';
import '../models/estimate_item.dart';
import '../models/detail_item.dart';
import '../services/estimate_repository.dart';
import '../services/estimate_firestore.dart';

class EstimateProvider with ChangeNotifier {
  EstimateProvider({EstimateRepository? repository})
      : _repo = repository ?? EstimateFirestore();

  final EstimateRepository _repo;
  Estimate _currentEstimate = Estimate();
  final List<Estimate> _estimates = [];
  bool _loadedFromServer = false;
  String? _loadError;

  /// 서버에서 견적서 목록을 불러옵니다. 비어 있으면 샘플 3건을 Firestore에 저장합니다.
  Future<void> loadFromServerIfNeeded() async {
    if (_loadedFromServer) return;
    _loadError = null;
    try {
      final list = await _repo.getEstimates();
      _estimates.clear();
      _estimates.addAll(list);
      // 서버에 데이터가 없으면 샘플 3건을 Firestore에 저장
      if (_estimates.isEmpty) {
        for (final sample in SampleEstimates.list) {
          await _repo.saveEstimate(sample);
          _estimates.add(sample);
        }
      }
      _loadedFromServer = true;
    } catch (e) {
      _loadError = e.toString();
      if (_estimates.isEmpty) {
        _estimates.addAll(SampleEstimates.list);
      }
      _loadedFromServer = true;
    }
    notifyListeners();
  }

  /// 저장된 견적이 없을 때만 샘플 견적서를 목록에 추가합니다.
  /// (서버 미사용 시 호출용)
  void loadSampleEstimatesIfEmpty() {
    if (_estimates.isNotEmpty) return;
    _estimates.addAll(SampleEstimates.list);
    notifyListeners();
  }

  String? get loadError => _loadError;
  bool get loadedFromServer => _loadedFromServer;

  Estimate get currentEstimate => _currentEstimate;
  List<Estimate> get estimates => _estimates;

  void createNewEstimate() {
    _currentEstimate = Estimate();
    notifyListeners();
  }

  void setCurrentEstimate(Estimate estimate) {
    _currentEstimate = estimate;
    notifyListeners();
  }

  void updateProjectName(String name) {
    _currentEstimate.projectName = name;
    notifyListeners();
  }

  void updateEstimateDate(DateTime date) {
    _currentEstimate.estimateDate = date;
    notifyListeners();
  }

  void updateCompanyInfo(CompanyInfo info) {
    _currentEstimate.companyInfo = info;
    notifyListeners();
  }

  void addItem(EstimateItem item) {
    _currentEstimate.items.add(item);
    notifyListeners();
  }

  void updateItem(int index, EstimateItem item) {
    if (index >= 0 && index < _currentEstimate.items.length) {
      _currentEstimate.items[index] = item;
      notifyListeners();
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < _currentEstimate.items.length) {
      _currentEstimate.items.removeAt(index);
      notifyListeners();
    }
  }

  void addDetailItem(DetailItem item) {
    item.no = _currentEstimate.detailItems.length + 1;
    _currentEstimate.detailItems.add(item);
    notifyListeners();
  }

  void updateDetailItem(int index, DetailItem item) {
    if (index >= 0 && index < _currentEstimate.detailItems.length) {
      _currentEstimate.detailItems[index] = item;
      notifyListeners();
    }
  }

  void removeDetailItem(int index) {
    if (index >= 0 && index < _currentEstimate.detailItems.length) {
      _currentEstimate.detailItems.removeAt(index);
      _renumberDetailItems();
      notifyListeners();
    }
  }

  void _renumberDetailItems() {
    for (int i = 0; i < _currentEstimate.detailItems.length; i++) {
      _currentEstimate.detailItems[i].no = i + 1;
    }
  }

  void updateValidityPeriod(String value) {
    _currentEstimate.validityPeriod = value;
    notifyListeners();
  }

  void updateDeliveryPlace(String value) {
    _currentEstimate.deliveryPlace = value;
    notifyListeners();
  }

  void updateDeliveryDate(String value) {
    _currentEstimate.deliveryDate = value;
    notifyListeners();
  }

  void updatePaymentTerms(String value) {
    _currentEstimate.paymentTerms = value;
    notifyListeners();
  }

  void updateNotes(List<String> notes) {
    _currentEstimate.notes = notes;
    notifyListeners();
  }

  void addNote(String note) {
    _currentEstimate.notes.add(note);
    notifyListeners();
  }

  void updateNote(int index, String note) {
    if (index >= 0 && index < _currentEstimate.notes.length) {
      _currentEstimate.notes[index] = note;
      notifyListeners();
    }
  }

  void removeNote(int index) {
    if (index >= 0 && index < _currentEstimate.notes.length) {
      _currentEstimate.notes.removeAt(index);
      notifyListeners();
    }
  }

  void toggleVat(bool value) {
    _currentEstimate.includeVat = value;
    notifyListeners();
  }

  /// 견적서를 서버에 저장합니다. 성공 시 true, 실패 시 false.
  Future<bool> saveEstimate() async {
    try {
      final saved = await _repo.saveEstimate(_currentEstimate);
      final existingIndex = _estimates.indexWhere((e) => e.id == saved.id);
      if (existingIndex >= 0) {
        _estimates[existingIndex] = saved;
      } else {
        _estimates.add(saved);
      }
      _currentEstimate = saved;
      notifyListeners();
      return true;
    } catch (_) {
      notifyListeners();
      return false;
    }
  }

  /// 견적서를 서버에서 삭제합니다. 성공 시 true, 실패 시 false.
  Future<bool> deleteEstimate(String id) async {
    try {
      await _repo.deleteEstimate(id);
      _estimates.removeWhere((e) => e.id == id);
      notifyListeners();
      return true;
    } catch (_) {
      notifyListeners();
      return false;
    }
  }
}

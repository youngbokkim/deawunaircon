import 'package:flutter/foundation.dart';
import '../data/sample_estimates.dart';
import '../models/estimate.dart';
import '../models/estimate_item.dart';
import '../models/detail_item.dart';

class EstimateProvider with ChangeNotifier {
  Estimate _currentEstimate = Estimate();
  final List<Estimate> _estimates = [];

  /// 저장된 견적이 없을 때만 샘플 견적서를 목록에 추가합니다.
  void loadSampleEstimatesIfEmpty() {
    if (_estimates.isNotEmpty) return;
    _estimates.addAll(SampleEstimates.list);
    notifyListeners();
  }

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

  void saveEstimate() {
    final existingIndex = _estimates.indexWhere(
      (e) => e.id == _currentEstimate.id,
    );
    if (existingIndex >= 0) {
      _estimates[existingIndex] = _currentEstimate;
    } else {
      _estimates.add(_currentEstimate);
    }
    notifyListeners();
  }

  void deleteEstimate(String id) {
    _estimates.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}

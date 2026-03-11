import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/estimate.dart';

/// 견적서 목록 조회 / 저장 / 삭제를 서버 API로 수행합니다.
class EstimateApi {
  EstimateApi({String? baseUrl}) : _baseUrl = baseUrl ?? kEstimateApiBaseUrl;

  final String _baseUrl;

  String get baseUrl => _baseUrl;

  /// 전체 견적서 목록 조회
  Future<List<Estimate>> getEstimates() async {
    final uri = Uri.parse('$_baseUrl/estimates');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw EstimateApiException(
        '목록 조회 실패 (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }

    final list = jsonDecode(response.body) as List<dynamic>?;
    if (list == null) return [];

    return list
        .map((e) => Estimate.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 견적서 한 건 저장 (생성 또는 수정)
  Future<Estimate> saveEstimate(Estimate estimate) async {
    final uri = Uri.parse('$_baseUrl/estimates');
    final body = utf8.encode(jsonEncode(estimate.toJson()));
    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
      },
      body: body,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw EstimateApiException(
        '저장 실패 (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }

    final map = jsonDecode(response.body) as Map<String, dynamic>?;
    if (map == null) return estimate;
    return Estimate.fromJson(map);
  }

  /// 견적서 한 건 삭제
  Future<void> deleteEstimate(String id) async {
    final uri = Uri.parse('$_baseUrl/estimates/$id');
    final response = await http.delete(uri);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw EstimateApiException(
        '삭제 실패 (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }
  }
}

class EstimateApiException implements Exception {
  EstimateApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'EstimateApiException: $message';
}

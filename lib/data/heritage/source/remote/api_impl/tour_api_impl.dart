import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../../core/result/failure.dart';
import '../../../dto/dto_tour.dart';
import '../api/tour_api.dart';

class TourApiImpl implements TourApi {
  final http.Client _client;
  final String _serviceKey;

  static const String _host = 'apis.data.go.kr';
  static const String _basePath = '/B551011/KorService2';
  static const String _mobileApp = '유적담';
  static const String _mobileOs = 'AND';
  static const String _responseType = 'json';
  static const String _defaultRows = '10';
  static const String _firstPage = '1';

  /// 거리순 정렬(TourAPI arrange 코드).
  static const String _sortByDistance = 'E';

  /// resultCode 성공값.
  static const String _successCode = '0000';

  /// 인증키는 디코딩 형태로 보관한다. `.env` 에 URL 인코딩 키(`%2B` 등)를 넣어도
  /// 한 번 디코딩해 두면 [Uri.https] 가 쿼리 인코딩을 정확히 한 번만 적용한다.
  TourApiImpl(this._client, String serviceKey)
      : _serviceKey = Uri.decodeComponent(serviceKey);

  @override
  Future<TourCommonDto?> fetchCommon(String contentId) async {
    final items = await _get('detailCommon2', {'contentId': contentId});
    if (items.isEmpty) {
      return null;
    }
    return TourCommonDto.fromJson(items.first);
  }

  @override
  Future<TourIntroDto?> fetchIntro(
    String contentId,
    String contentTypeId,
  ) async {
    final items = await _get('detailIntro2', {
      'contentId': contentId,
      'contentTypeId': contentTypeId,
    });
    if (items.isEmpty) {
      return null;
    }
    return TourIntroDto.fromJson(items.first);
  }

  @override
  Future<List<TourImageDto>> fetchImages(String contentId) async {
    final items = await _get('detailImage2', {
      'contentId': contentId,
      'imageYN': 'Y',
    });
    return items.map(TourImageDto.fromJson).toList();
  }

  @override
  Future<List<TourNearbyDto>> fetchNearby({
    required String mapX,
    required String mapY,
    required int radiusMeters,
  }) async {
    // numOfRows 는 _get 기본값(_defaultRows)과 동일하므로 중복 지정하지 않는다.
    final items = await _get('locationBasedList2', {
      'mapX': mapX,
      'mapY': mapY,
      'radius': '$radiusMeters',
      'arrange': _sortByDistance,
    });
    return items.map(TourNearbyDto.fromJson).toList();
  }

  /// 오퍼레이션을 호출하고 정규화된 item 목록을 반환한다.
  ///
  /// `resultCode != _successCode` 이면 [ServerFailure] 를 던진다.
  Future<List<Map<String, dynamic>>> _get(
    String operation,
    Map<String, String> params,
  ) async {
    final uri = Uri.https(_host, '$_basePath/$operation', {
      'serviceKey': _serviceKey,
      'MobileOS': _mobileOs,
      'MobileApp': _mobileApp,
      '_type': _responseType,
      'numOfRows': _defaultRows,
      'pageNo': _firstPage,
      ...params,
    });

    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw ServerFailure(
        'TourAPI 응답 오류 (HTTP ${response.statusCode})',
        code: '${response.statusCode}',
      );
    }
    return _parseItems(response.body);
  }

  List<Map<String, dynamic>> _parseItems(String body) {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw const ParseFailure('TourAPI 응답 형식이 올바르지 않습니다.');
    }
    final response = decoded['response'];
    if (response is! Map<String, dynamic>) {
      throw const ParseFailure('TourAPI 응답에 response 가 없습니다.');
    }

    final header = response['header'];
    final resultCode =
        header is Map<String, dynamic> ? header['resultCode'] as String? : null;
    if (resultCode != _successCode) {
      final msg = header is Map<String, dynamic>
          ? (header['resultMsg'] as String? ?? '알 수 없는 오류')
          : '헤더 없음';
      throw ServerFailure('TourAPI: $msg', code: resultCode);
    }

    final bodyMap = response['body'];
    if (bodyMap is! Map<String, dynamic>) {
      return [];
    }
    // totalCount 0 이면 items 가 빈 문자열로 오는 경우가 있다.
    final items = bodyMap['items'];
    if (items is! Map<String, dynamic>) {
      return [];
    }
    final item = items['item'];
    if (item == null) {
      return [];
    }
    if (item is List) {
      return item.cast<Map<String, dynamic>>();
    }
    if (item is Map<String, dynamic>) {
      return [item];
    }
    return [];
  }
}

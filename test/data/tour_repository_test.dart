import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:yujeokdam/core/result/result.dart';
import 'package:yujeokdam/data/heritage/dto/dto_heritage_detail.dart';
import 'package:yujeokdam/data/heritage/mapper/mapper_heritage_detail.dart';
import 'package:yujeokdam/data/heritage/mapper/mapper_heritage_site.dart';
import 'package:yujeokdam/data/heritage/repository_impl/repository_impl_heritage.dart';
import 'package:yujeokdam/data/heritage/source/local/asset/heritage_asset_source_impl.dart';
import 'package:yujeokdam/data/heritage/source/local/cache/tour_cache_source.dart';
import 'package:yujeokdam/data/heritage/source/remote/api_impl/tour_api_impl.dart';
import 'package:yujeokdam/domain/heritage/model/model_heritage_detail.dart';
import 'package:yujeokdam/domain/heritage/model/model_heritage_site.dart';

/// 메모리 기반 캐시.
class _MemoryCache implements TourCacheSource {
  final Map<String, HeritageDetailDto> _store = {};
  @override
  Future<HeritageDetailDto?> read(String contentId) async => _store[contentId];
  @override
  Future<void> save(String contentId, HeritageDetailDto detail) async =>
      _store[contentId] = detail;
}

/// 한글이 깨지지 않도록 UTF-8 content-type 을 명시한 JSON 응답.
http.Response _ok(String body) =>
    http.Response(body, 200, headers: const {
      'content-type': 'application/json; charset=utf-8',
    });

String _envelope(Object itemOrList) {
  return jsonEncode({
    'response': {
      'header': {'resultCode': '0000', 'resultMsg': 'OK'},
      'body': {
        'items': {'item': itemOrList},
        'numOfRows': 10,
        'pageNo': 1,
        'totalCount': 1,
      },
    },
  });
}

const _site = HeritageSiteModel(
  id: 'site_x',
  name: '테스트유적',
  tourApiContentId: '126312',
  tourApiContentTypeId: '12',
);

HeritageRepositoryImpl _repo(http.Client client, TourCacheSource cache) {
  return HeritageRepositoryImpl(
    HeritageAssetSourceImpl(rootBundle),
    const HeritageSiteMapper(),
    TourApiImpl(client, 'TEST_KEY'),
    cache,
    const HeritageDetailMapper(),
  );
}

http.Response _route(http.Request request) {
  final path = request.url.path;
  if (path.endsWith('detailCommon2')) {
    return _ok(_envelope([
      {
        'contentid': '126312',
        'title': '서출지',
        'addr1': '경북 경주시',
        'mapx': '129.2',
        'mapy': '35.8',
        'firstimage': 'http://img/main.jpg',
        'overview': '연못 설명',
      },
    ]));
  }
  if (path.endsWith('detailIntro2')) {
    // item 이 단일 객체로 오는 경우도 정규화되는지 확인.
    return _ok(_envelope({
      'usetime': '상시 개방',
      'restdate': '연중무휴',
      'heritage1': '1',
    }));
  }
  if (path.endsWith('detailImage2')) {
    return _ok(_envelope([
      {'originimgurl': 'http://img/g1.jpg'},
    ]));
  }
  if (path.endsWith('locationBasedList2')) {
    return _ok(_envelope([
      {'contentid': '999', 'title': '근처 관광지', 'dist': '500.5'},
    ]));
  }
  return http.Response('not found', 404);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('정상 응답을 상세 모델로 합치고 유네스코 배지를 켠다', () async {
    final cache = _MemoryCache();
    final repo = _repo(MockClient((r) async => _route(r)), cache);

    final result = await repo.getHeritageDetail(_site);

    expect(result, isA<Succeed<HeritageDetailModel>>());
    final detail = (result as Succeed<HeritageDetailModel>).data;
    expect(detail.title, '서출지');
    expect(detail.address, '경북 경주시');
    expect(detail.isWorldHeritage, isTrue);
    expect(detail.useTime, '상시 개방');
    expect(detail.galleryImageUrls, contains('http://img/g1.jpg'));
    expect(detail.nearbyPlaces.single.distanceMeters, 500.5);
    // 캐시에 저장되었는지 확인.
    expect(await cache.read('126312'), isNotNull);
  });

  test('resultCode 가 0000 이 아니면 Failed', () async {
    final client = MockClient((r) async {
      return http.Response(
        jsonEncode({
          'response': {
            'header': {'resultCode': '03', 'resultMsg': 'NODATA_ERROR'},
            'body': {},
          },
        }),
        200,
      );
    });
    final result = await _repo(client, _MemoryCache()).getHeritageDetail(_site);
    expect(result, isA<Failed<HeritageDetailModel>>());
  });

  test('원격 실패 시 캐시로 폴백한다', () async {
    final cache = _MemoryCache();
    // 1) 성공 호출로 캐시를 채운다.
    await _repo(MockClient((r) async => _route(r)), cache)
        .getHeritageDetail(_site);

    // 2) 항상 실패하는 클라이언트로 다시 호출 → 캐시 폴백.
    final failingClient = MockClient((r) async => http.Response('boom', 500));
    final result = await _repo(failingClient, cache).getHeritageDetail(_site);

    expect(result, isA<Succeed<HeritageDetailModel>>());
    expect((result as Succeed<HeritageDetailModel>).data.title, '서출지');
  });
}

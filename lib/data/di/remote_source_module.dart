import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../heritage/source/remote/api/tour_api.dart';
import '../heritage/source/remote/api_impl/tour_api_impl.dart';

/// 원격 소스(TourAPI) 등록.
///
/// 서비스 키는 `.env` 의 `TOUR_API_KEY` 에서 읽는다(`.env.example` 참고).
/// 키가 비어 있어도 앱은 동작하며, '이야기의 무대' 화면 호출만 인증 실패한다.
class RemoteSourceModule {
  void registerAll() {
    final serviceKey = dotenv.env['TOUR_API_KEY'] ?? '';
    if (serviceKey.isEmpty) {
      debugPrint(
        'TOUR_API_KEY 가 비어 있습니다. .env 에 키를 채우면 무대 화면이 동작합니다.',
      );
    }

    final getIt = GetIt.I;
    getIt.registerSingleton<http.Client>(
      http.Client(),
      dispose: (c) => c.close(),
    );
    getIt.registerSingleton<TourApi>(
      TourApiImpl(getIt.get<http.Client>(), serviceKey),
    );
  }
}

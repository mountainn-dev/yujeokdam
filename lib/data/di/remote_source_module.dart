import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../heritage/source/remote/api/tour_api.dart';
import '../heritage/source/remote/api_impl/tour_api_impl.dart';

/// 원격 소스(TourAPI) 등록.
///
/// 서비스 키는 빌드 시 `--dart-define=TOUR_API_KEY=...` 로 주입한다.
class RemoteSourceModule {
  static const String _serviceKey = String.fromEnvironment('TOUR_API_KEY');

  void registerAll() {
    final getIt = GetIt.I;
    getIt.registerSingleton<http.Client>(http.Client());
    getIt.registerSingleton<TourApi>(
      TourApiImpl(getIt.get<http.Client>(), _serviceKey),
    );
  }
}

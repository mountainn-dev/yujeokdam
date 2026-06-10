import 'dart:async';
import 'dart:io';

import '../result/failure.dart';
import '../result/result.dart';

/// 모든 repository 구현체의 베이스.
///
/// 저수준 예외를 도메인 친화적 [Failure] 로 변환하는 단일 지점이다.
/// **프로젝트에서 try-catch 가 허용되는 유일한 곳.**
abstract class BaseRepository {
  /// [body] 를 실행해 결과를 [Result] 로 감싼다.
  ///
  /// - 도메인 모델 값 `T` 반환 → [Succeed]
  /// - `null` 반환 → [NotFound]
  /// - 예외 throw → [Failed] (예외 종류별로 [Failure] 변환)
  ///
  /// [body] 안에서 [Result] 를 직접 만들지 않는다. 값을 반환하거나 throw 만 한다.
  Future<Result<T>> execute<T>(FutureOr<T?> Function() body) async {
    try {
      final data = await body();
      if (data == null) {
        return NotFound<T>();
      }
      return Succeed<T>(data);
    } on SocketException {
      return const Failed(NetworkFailure());
    } on TimeoutException {
      return const Failed(TimeoutFailure());
    } on HttpException catch (e) {
      return Failed(ServerFailure(e.message));
    } on FormatException {
      return const Failed(ParseFailure());
    } on Failure catch (failure) {
      // 소스/매퍼가 의도적으로 던진 도메인 실패 (예: TourAPI resultCode != 0000).
      return Failed(failure);
    } catch (_) {
      return const Failed(UnknownFailure());
    }
  }
}

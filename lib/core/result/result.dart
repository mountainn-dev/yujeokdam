import 'failure.dart';

/// 도메인 대면 연산의 결과.
///
/// 데이터가 있으면 [Succeed], 실패면 [Failed], 부재면 [NotFound] 로 표현한다.
/// 도메인 경계 밖으로 raw future·예외·DTO 를 흘리지 않고 항상 이 타입으로 감싼다.
sealed class Result<T> {
  const Result();

  factory Result.succeed(T data) = Succeed<T>;
  factory Result.failed(Failure failure) = Failed<T>;
  factory Result.notFound() = NotFound<T>;
}

class Succeed<T> extends Result<T> {
  final T data;
  const Succeed(this.data);
}

class Failed<T> extends Result<T> {
  final Failure failure;
  const Failed(this.failure);
}

class NotFound<T> extends Result<T> {
  const NotFound();
}

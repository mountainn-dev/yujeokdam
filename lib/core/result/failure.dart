/// 도메인 친화적 실패 타입.
///
/// `BaseRepository.execute` 가 저수준 예외(Socket/Timeout/포맷/HTTP 등)를
/// 이 타입으로 변환한다. UseCase 는 이 사실을 화면 의미의 [FeatureFailure] 로
/// 재해석할 수 있다.
sealed class Failure {
  final String message;
  const Failure(this.message);
}

/// 네트워크 연결 자체가 안 되는 경우 (SocketException 등).
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = '네트워크에 연결할 수 없습니다.']);
}

/// 요청이 시간 내에 끝나지 않은 경우.
class TimeoutFailure extends Failure {
  const TimeoutFailure([super.message = '요청 시간이 초과되었습니다.']);
}

/// 서버/외부 API 가 비정상 응답을 준 경우. [code] 로 세부 구분.
///
/// 예: HTTP 상태 코드, TourAPI `resultCode`.
class ServerFailure extends Failure {
  final String? code;
  const ServerFailure(super.message, {this.code});
}

/// 응답 파싱/포맷 변환에 실패한 경우.
class ParseFailure extends Failure {
  const ParseFailure([super.message = '데이터를 해석하지 못했습니다.']);
}

/// 분류되지 않은 실패.
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = '알 수 없는 오류가 발생했습니다.']);
}

/// 기능(UseCase)이 raw [Failure] 를 화면 의미로 재해석한 실패.
///
/// 각 기능은 이 클래스를 상속해 자신의 실패 종류를 정의한다.
abstract class FeatureFailure extends Failure {
  const FeatureFailure(super.message);
}

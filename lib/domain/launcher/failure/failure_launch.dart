import '../../../core/result/failure.dart';

/// 외부 앱 실행이 불가능하거나 실패했을 때의 기능 실패.
class LaunchFailure extends FeatureFailure {
  const LaunchFailure([super.message = '앱을 열 수 없습니다.']);
}

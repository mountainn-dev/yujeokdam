import 'package:url_launcher/url_launcher.dart';

import '../../../domain/launcher/failure/failure_launch.dart';
import 'external_link_source.dart';

/// `url_launcher` 로 외부 앱을 여는 [ExternalLinkSource] 구현.
///
/// 좌표 정보가 없으므로 장소명/주소를 구글 지도 검색 URL 로 연다. https 스킴이라
/// iOS·Android·웹에서 동작하며, 열 수 없으면 [LaunchFailure] 를 던진다.
class ExternalLinkSourceImpl implements ExternalLinkSource {
  const ExternalLinkSourceImpl();

  @override
  Future<bool> openMapSearch(String query) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query='
      '${Uri.encodeComponent(query)}',
    );
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      throw const LaunchFailure('지도 앱을 열 수 없습니다.');
    }
    return true;
  }
}

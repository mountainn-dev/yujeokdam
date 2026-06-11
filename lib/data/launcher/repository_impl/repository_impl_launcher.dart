import '../../../core/data/base_repository.dart';
import '../../../core/result/result.dart';
import '../../../domain/launcher/repository/repository_launcher.dart';
import '../source/external_link_source.dart';

class LauncherRepositoryImpl extends BaseRepository
    implements LauncherRepository {
  final ExternalLinkSource _source;

  LauncherRepositoryImpl(this._source);

  @override
  Future<Result<bool>> openMapSearch(String query) {
    return execute(() => _source.openMapSearch(query));
  }
}

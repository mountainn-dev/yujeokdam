import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/di/local_source_module.dart';
import '../data/di/remote_source_module.dart';
import '../data/di/repository_module.dart';
import '../view/app/store_content.dart';
import '../view/di/state_holder_module.dart';
import '../view/di/store_module.dart';
import '../view/di/view_model_factory_module.dart';
import '../view/read_status/state_holder/state_holder_read_status.dart';

/// 앱 전체 의존성 배선.
///
/// 등록 순서: Local → Remote → Repository → UseCase → Store → StateHolder → ViewModel.
/// 각 단계는 해당 레이어의 DI 모듈을 호출한다.
Future<void> configureDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  // Data layer
  LocalSourceModule(prefs).registerAll();
  RemoteSourceModule().registerAll();
  RepositoryModule().registerAll();

  // View layer
  StoreModule().registerAll();
  StateHolderModule().registerAll();
  ViewModelFactoryModule().registerAll();

  // 공유 상태 초기 로드 (repository 등록 이후).
  await GetIt.I.get<ContentStore>().initialize();
  await GetIt.I.get<ReadStatusStateHolder>().initialize();
}

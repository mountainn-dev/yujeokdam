import 'package:get_it/get_it.dart';

import '../../domain/read_status/repository/repository_read_status.dart';
import '../read_status/state_holder/state_holder_read_status.dart';

/// 공유 가변 상태 `StateHolder` 등록. Store 이후에 호출한다.
class StateHolderModule {
  void registerAll() {
    final getIt = GetIt.I;
    getIt.registerSingleton<ReadStatusStateHolder>(
      ReadStatusStateHolder(getIt.get<ReadStatusRepository>()),
    );
  }
}

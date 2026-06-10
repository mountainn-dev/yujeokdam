import '../../../domain/heritage/model/model_heritage_site.dart';
import '../dto/dto_heritage_site.dart';

class HeritageSiteMapper {
  const HeritageSiteMapper();

  HeritageSiteModel toDomain(HeritageSiteDto dto) {
    return HeritageSiteModel(
      id: dto.id,
      name: dto.name,
      tourApiContentId: dto.tourApiContentId,
      tourApiContentTypeId: dto.tourApiContentTypeId,
    );
  }
}

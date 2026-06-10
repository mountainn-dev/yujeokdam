// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dto_heritage_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HeritageDetailDto _$HeritageDetailDtoFromJson(Map<String, dynamic> json) =>
    HeritageDetailDto(
      contentId: json['content_id'] as String,
      title: json['title'] as String,
      isWorldHeritage: json['is_world_heritage'] as bool,
      galleryImageUrls: (json['gallery_image_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      nearbyPlaces: (json['nearby_places'] as List<dynamic>?)
              ?.map((e) => NearbyPlaceDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      overview: json['overview'] as String?,
      address: json['address'] as String?,
      firstImageUrl: json['first_image_url'] as String?,
      homepage: json['homepage'] as String?,
      tel: json['tel'] as String?,
      useTime: json['use_time'] as String?,
      restDate: json['rest_date'] as String?,
    );

Map<String, dynamic> _$HeritageDetailDtoToJson(HeritageDetailDto instance) =>
    <String, dynamic>{
      'content_id': instance.contentId,
      'title': instance.title,
      'overview': instance.overview,
      'address': instance.address,
      'first_image_url': instance.firstImageUrl,
      'homepage': instance.homepage,
      'tel': instance.tel,
      'use_time': instance.useTime,
      'rest_date': instance.restDate,
      'is_world_heritage': instance.isWorldHeritage,
      'gallery_image_urls': instance.galleryImageUrls,
      'nearby_places': instance.nearbyPlaces.map((e) => e.toJson()).toList(),
    };

NearbyPlaceDto _$NearbyPlaceDtoFromJson(Map<String, dynamic> json) =>
    NearbyPlaceDto(
      contentId: json['content_id'] as String,
      name: json['name'] as String,
      imageUrl: json['image_url'] as String?,
      distanceMeters: (json['distance_meters'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$NearbyPlaceDtoToJson(NearbyPlaceDto instance) =>
    <String, dynamic>{
      'content_id': instance.contentId,
      'name': instance.name,
      'image_url': instance.imageUrl,
      'distance_meters': instance.distanceMeters,
    };

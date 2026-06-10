import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../../../core/view/ui_event.dart';
import '../../../domain/heritage/model/model_heritage_detail.dart';
import '../../../domain/heritage/model/model_heritage_site.dart';
import '../../../domain/story/model/model_story.dart';
import '../view_model/view_model_stage.dart';

/// 이야기의 무대 — 유적지 상세 화면.
class StageScreen extends StatefulWidget {
  const StageScreen({super.key, required this.site, this.story});

  final HeritageSiteModel site;

  /// 무대로 넘어온 이야기. 있으면 하단에 출처를 표기한다.
  final StoryModel? story;

  @override
  State<StageScreen> createState() => _StageScreenState();
}

class _StageScreenState extends State<StageScreen> {
  late final StageViewModel _viewModel;
  late final StreamSubscription<UiEvent> _eventSub;

  @override
  void initState() {
    super.initState();
    _viewModel = GetIt.I.get<StageViewModel>()..bindAndLoad(widget.site);
    _eventSub = _viewModel.eventStream.listen((event) {
      if (!mounted) return;
      if (event is ShowToast) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(event.message)));
      }
    });
  }

  @override
  void dispose() {
    _eventSub.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<StageViewModel>.value(
      value: _viewModel,
      child: _StageBody(site: widget.site, story: widget.story),
    );
  }
}

class _StageBody extends StatelessWidget {
  const _StageBody({required this.site, this.story});

  final HeritageSiteModel site;
  final StoryModel? story;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(site.name)),
      body: Consumer<StageViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.hasError) {
            return _ErrorRetry(onRetry: viewModel.load);
          }
          final detail = viewModel.detail;
          if (detail == null) {
            return Center(
              child: Text(viewModel.emptyMessage ?? '정보가 없습니다.'),
            );
          }
          return _DetailContent(detail: detail, story: story);
        },
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('정보를 불러오지 못했습니다.'),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent({required this.detail, this.story});

  final HeritageDetailModel detail;
  final StoryModel? story;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      children: [
        if (detail.firstImageUrl != null)
          Image.network(
            detail.firstImageUrl!,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 220,
              color: theme.colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.image_not_supported, size: 48),
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(detail.title, style: theme.textTheme.headlineSmall),
                  ),
                  if (detail.isWorldHeritage) const _WorldHeritageBadge(),
                ],
              ),
              const SizedBox(height: 12),
              if (detail.address != null)
                _InfoRow(icon: Icons.place, label: detail.address!),
              if (detail.useTime != null)
                _InfoRow(icon: Icons.schedule, label: detail.useTime!),
              if (detail.restDate != null)
                _InfoRow(icon: Icons.event_busy, label: detail.restDate!),
              if (detail.address != null) ...[
                const SizedBox(height: 8),
                Text(
                  '지도 앱에서 위 주소로 검색하세요.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
              if (detail.overview != null) ...[
                const SizedBox(height: 16),
                Text(detail.overview!),
              ],
              if (detail.galleryImageUrls.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('갤러리', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                _Gallery(urls: detail.galleryImageUrls),
              ],
              if (detail.nearbyPlaces.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text('주변 장소', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final place in detail.nearbyPlaces)
                  _NearbyTile(place: place),
              ],
              if (story != null && story!.sources.isNotEmpty) ...[
                const SizedBox(height: 24),
                Divider(color: theme.dividerColor),
                const SizedBox(height: 8),
                Text('이야기 출처', style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                for (final source in story!.sources)
                  Text(
                    '• $source',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _WorldHeritageBadge extends StatelessWidget {
  const _WorldHeritageBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.public, size: 16),
          const SizedBox(width: 4),
          Text(
            '유네스코 세계유산',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onTertiaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}

class _Gallery extends StatelessWidget {
  const _Gallery({required this.urls});

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) => ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            urls[index],
            width: 140,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 140,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: const Icon(Icons.image_not_supported),
            ),
          ),
        ),
      ),
    );
  }
}

class _NearbyTile extends StatelessWidget {
  const _NearbyTile({required this.place});

  final NearbyPlace place;

  @override
  Widget build(BuildContext context) {
    final distance = place.distanceMeters;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.near_me),
      title: Text(place.name),
      trailing: distance == null
          ? null
          : Text('${distance.round()}m'),
    );
  }
}

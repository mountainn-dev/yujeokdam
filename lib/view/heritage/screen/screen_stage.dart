import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

import '../../../core/view/ui_event.dart';
import '../../../domain/heritage/model/model_heritage_detail.dart';
import '../../../domain/heritage/model/model_heritage_site.dart';
import '../../../domain/story/model/model_story.dart';
import '../../app/app_motion.dart';
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
    _viewModel = GetIt.I.get<StageViewModel>(param1: widget.site)..load();
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
          // 로딩 인디케이터→상세 콘텐츠 전환을 fade 로 크로스페이드한다.
          return AnimatedSwitcher(
            duration: AppMotion.medium,
            switchInCurve: AppMotion.curve,
            switchOutCurve: AppMotion.curve,
            child: _buildContent(viewModel, story),
          );
        },
      ),
    );
  }

  /// AnimatedSwitcher 가 크로스페이드할 수 있도록 상태별로 keyed 위젯을 만든다.
  Widget _buildContent(StageViewModel viewModel, StoryModel? story) {
    if (viewModel.isLoading) {
      return const Center(
        key: ValueKey('loading'),
        child: CircularProgressIndicator(),
      );
    }
    if (viewModel.hasError) {
      return _ErrorRetry(key: const ValueKey('error'), onRetry: viewModel.load);
    }
    final detail = viewModel.detail;
    if (detail == null) {
      return Center(
        key: const ValueKey('empty'),
        child: Text(viewModel.emptyMessage ?? '정보가 없습니다.'),
      );
    }
    return _DetailContent(
      key: const ValueKey('content'),
      detail: detail,
      story: story,
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({super.key, required this.onRetry});

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

/// 무대 상세를 '호기심 점화' 순서로 보여준다.
///
/// 큰 사진 위에 "「이야기」의 무대" 프레이밍 → 개요를 리드 카피로 → 실용 정보는
/// '가는 길' 카드로 2순위 → 갤러리·주변·출처. 행정 정보 시트가 아니라 "가보고
/// 싶다"를 만드는 페이지를 목표로 한다.
class _DetailContent extends StatelessWidget {
  const _DetailContent({super.key, required this.detail, this.story});

  final HeritageDetailModel detail;
  final StoryModel? story;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFacts = detail.address != null ||
        detail.useTime != null ||
        detail.restDate != null;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _HeroHeader(detail: detail, storyTitle: story?.title),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (detail.overview != null)
                Text(
                  detail.overview!,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                ),
              if (hasFacts) ...[
                const SizedBox(height: 20),
                _FactsCard(detail: detail),
              ],
              if (detail.galleryImageUrls.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('갤러리', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                _Gallery(urls: detail.galleryImageUrls),
              ],
              if (detail.nearbyPlaces.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('주변에 더', style: theme.textTheme.titleMedium),
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

/// 대표 사진 + "「이야기」의 무대" 프레이밍을 얹은 히어로.
///
/// 사진이 없으면 흙빛 폴백 위에 어두운 글자로, 사진이 있으면 하단 스크림 위에
/// 흰 글자로 제목을 얹어 어느 경우든 가독성을 보장한다.
class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.detail, this.storyTitle});

  static const double _height = 260;

  final HeritageDetailModel detail;
  final String? storyTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage = detail.firstImageUrl != null;
    final onHero = hasImage ? Colors.white : theme.colorScheme.onSurface;
    const shadows = [Shadow(color: Colors.black54, blurRadius: 8)];

    return SizedBox(
      height: _height,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasImage)
            Image.network(
              detail.firstImageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _fallback(theme),
            )
          else
            _fallback(theme),
          if (hasImage)
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (storyTitle != null)
                  Text(
                    '「$storyTitle」의 무대',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: onHero,
                      fontWeight: FontWeight.w600,
                      shadows: hasImage ? shadows : null,
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  detail.title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: onHero,
                    fontWeight: FontWeight.w700,
                    shadows: hasImage ? shadows : null,
                  ),
                ),
                if (detail.isWorldHeritage) ...[
                  const SizedBox(height: 10),
                  const _WorldHeritageBadge(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _fallback(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.account_balance,
        size: 56,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// 주소·운영시간·휴무와 '지도에서 보기'를 묶은 실용 정보 카드.
class _FactsCard extends StatelessWidget {
  const _FactsCard({required this.detail});

  final HeritageDetailModel detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final address = detail.address;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.near_me, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text('가는 길 · 실용 정보', style: theme.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 12),
            if (address != null) ...[
              _InfoRow(icon: Icons.place, label: address),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: _MapButton(query: address),
              ),
            ] else
              Align(
                alignment: Alignment.centerLeft,
                child: _MapButton(query: detail.title),
              ),
            if (detail.useTime != null) ...[
              const SizedBox(height: 8),
              _InfoRow(icon: Icons.schedule, label: detail.useTime!),
            ],
            if (detail.restDate != null) ...[
              const SizedBox(height: 8),
              _InfoRow(icon: Icons.event_busy, label: detail.restDate!),
            ],
          ],
        ),
      ),
    );
  }
}

/// 외부 지도 앱에서 장소를 여는 버튼. 실패 시 ViewModel 이 토스트로 안내한다.
class _MapButton extends StatelessWidget {
  const _MapButton({required this.query});

  final String query;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      icon: const Icon(Icons.map_outlined, size: 18),
      label: const Text('지도에서 보기'),
      onPressed: () => context.read<StageViewModel>().openMap(query),
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

  static const double _galleryHeight = 100;
  static const double _thumbnailWidth = 140;

  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _galleryHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) => ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            urls[index],
            width: _thumbnailWidth,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: _thumbnailWidth,
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

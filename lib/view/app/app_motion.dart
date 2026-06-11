import 'package:flutter/material.dart';

/// 앱 전역에서 공유하는 모션 토큰.
///
/// 새 duration/curve 를 화면에 흩뿌리지 말고 전부 이 클래스를 참조한다.
class AppMotion {
  const AppMotion._();

  /// 빠른 등장(말풍선 등).
  static const Duration short = Duration(milliseconds: 250);

  /// 일반 전환(크로스페이드 등).
  static const Duration medium = Duration(milliseconds: 400);

  /// 공통 커브.
  static const Curve curve = Curves.easeOut;
}

/// 등장용 fade + slide(아래→위) 트랜지션.
///
/// 세 화면이 동일 토큰([AppMotion.short], [AppMotion.curve])을 쓰도록
/// 공통 위젯으로 둔다. [AnimatedList] 의 itemBuilder 가 넘겨주는
/// [animation] 을 그대로 받아 적용한다.
class AppFadeSlideIn extends StatelessWidget {
  const AppFadeSlideIn({
    super.key,
    required this.animation,
    required this.child,
  });

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: animation, curve: AppMotion.curve);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

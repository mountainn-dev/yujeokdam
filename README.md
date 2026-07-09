# 유적담 (遺跡談)

경주 유적지에 얽힌 이야기를 **역사 인물 간 채팅 형식**으로 풀어내고, 이야기 완독 후
'이야기의 무대' 화면에서 한국관광공사 TourAPI 로 실제 관광정보를 연결하는 Flutter 앱.

> 한국관광공사 관광데이터 활용 공모전(웹/앱) 출품작.

## 구조

레이어드 아키텍처(data / domain / view) + GetIt·Provider. 백엔드 없음 — 콘텐츠는
앱 내장 JSON(`assets/content/`), TourAPI 만 런타임 호출한다.

- `lib/core` — `Result<T>`/`Failure`, `BaseRepository.execute`, `BaseViewModel`
- `lib/data` — story·character·heritage·read_status (에셋 로더, TourAPI http, 캐시)
- `lib/domain` — 모델·repository 인터페이스
- `lib/view` — 5개 화면(이야기 목록·채팅 뷰어·이야기의 무대·인물 프로필·인물 도감)

설계 문서: `docs/superpowers/specs/2026-06-08-유적담-design.md`

## 실행

TourAPI 서비스 키(공공데이터포털 KorService2)는 `.env` 에서 읽는다.

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # 또는 flutter pub run build_runner build
cp .env.example .env        # 최초 1회. .env 의 TOUR_API_KEY 에 발급키를 채운다
flutter run                 # 매번 키를 넘길 필요 없음
```

`.env` 는 git 에 올리지 않는다(`.env.example` 만 추적). 키 없이도 앱은 동작한다
(이야기 읽기는 오프라인). '이야기의 무대' 화면만 키가 있어야 실제 관광정보가 표시되고,
실패 시 캐시/재시도 빈 상태로 폴백한다.

> IDE 의 Run 버튼은 `.env` 를 자동으로 읽으므로 별도 실행 인자 설정이 필요 없다.

> 개발계정은 일 1,000 호출 제한. contentId 검증·콘텐츠 감수 사항은
> `assets/content/CONTENT_NOTES.md` 참고.

## 검증

```bash
flutter analyze
flutter test
```

## 빌드 환경 주의 (Android)

이 프로젝트(AGP 8.1)는 **JDK 17**로 빌드해야 한다. Android Studio 번들 JDK가
21이면 `JdkImageTransform`(jlink) 단계에서 `core-for-system-modules.jar` 변환이
실패한다. JDK 17을 가리키도록 한 번 설정하면 된다.

```bash
flutter config --jdk-dir <JDK17_홈경로>
# 예: .../Library/Java/JavaVirtualMachines/jbr-17.0.8.1/Contents/Home
```

확인됨: 위 설정 후 `flutter build apk --debug` 정상 빌드(app-debug.apk 생성).

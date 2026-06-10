# 콘텐츠 제작 노트 (Phase 4 초안)

이 폴더의 `stories.json` / `characters.json` / `sites.json` 는 **LLM 초안** 단계 산출물이다.
스펙의 "LLM 초안 → 사람 감수" 워크플로우에서 **감수 전 상태**이므로, 배포 전 아래를 반드시 확인한다.

## TourAPI contentId (검증 완료)

`searchKeyword2` 실호출로 경주 유적지의 실제 `contentId` 를 확인해 `sites.json` 에 반영했다.
모두 `contentTypeId=12`(관광지).

| site id | 이름 | content_id | 상태 |
|---|---|---|---|
| site_seochulji | 서출지 | 128612 | ✅ 검증됨 |
| site_bulguksa | 불국사 | 126166 | ✅ 검증됨 (유네스코 세계유산) |
| site_cheomseongdae | 첨성대 | 126207 | ✅ 검증됨 |
| site_donggung_wolji | 동궁과 월지 | 128526 | ✅ 검증됨 |
| site_poseokjeong | 포석정 | 126208 | ✅ 검증됨 |

불국사 `detailIntro2` 의 `heritage1=1` 확인 — 무대 화면 유네스코 배지가 켜진다.

## 감수 체크리스트 (사람)

- [ ] 각 이야기의 **사실 vs 각색** 경계 확인 — 대사는 모두 각색이며, 사건/인물은 출처(`sources`) 기반인지 검토
- [ ] `sources` 표기가 실제 출전과 일치하는지 확인 (삼국유사/삼국사기 편명)
- [ ] 인물 생몰년·관계 라벨의 정확성 확인 (예: 경애왕·견훤 연대)
- [ ] 역사 왜곡 소지가 없는지, 민감한 해석을 단정적으로 적지 않았는지 확인

## 인물 초상 이미지

`characters.json` 의 `portrait` 경로(`assets/portraits/*.png`)에 해당하는 이미지는 아직 없다.
UI 는 이미지 로드 실패 시 **이름 첫 글자 아바타**로 폴백하므로 앱은 정상 동작한다.
배포 전 일러스트/아이콘을 `assets/portraits/` 에 채우면 된다.

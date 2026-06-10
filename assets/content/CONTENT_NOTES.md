# 콘텐츠 제작 노트 (Phase 4 초안)

이 폴더의 `stories.json` / `characters.json` / `sites.json` 는 **LLM 초안** 단계 산출물이다.
스펙의 "LLM 초안 → 사람 감수" 워크플로우에서 **감수 전 상태**이므로, 배포 전 아래를 반드시 확인한다.

## ⚠️ TourAPI contentId 검증 필요 (최우선)

서비스 키 발급 후 `searchKeyword2`(또는 `areaBasedList2`, 경주 지역코드)로 각 유적지의 실제
`contentId` / `contentTypeId` 를 확인해 `sites.json` 을 갱신한다. 아래 값은 **미검증 추정치**다.

| site id | 이름 | 기재된 content_id | 상태 |
|---|---|---|---|
| site_seochulji | 서출지 | 126312 | ❓ 검증 필요 |
| site_bulguksa | 불국사 | 126508 | ❓ 검증 필요 |
| site_cheomseongdae | 첨성대 | 126230 | ❓ 검증 필요 |
| site_donggung_wolji | 동궁과 월지 | 126496 | ❓ 검증 필요 |
| site_poseokjeong | 포석정 | 126509 | ❓ 검증 필요 |

검증 방법 예시(키 발급 후):
```
GET https://apis.data.go.kr/B551011/KorService2/searchKeyword2
  ?serviceKey=...&MobileOS=AND&MobileApp=유적담&_type=json
  &keyword=불국사&numOfRows=10&pageNo=1
```
응답의 `contentid`, `contenttypeid` 를 sites.json 에 반영.

## 감수 체크리스트 (사람)

- [ ] 각 이야기의 **사실 vs 각색** 경계 확인 — 대사는 모두 각색이며, 사건/인물은 출처(`sources`) 기반인지 검토
- [ ] `sources` 표기가 실제 출전과 일치하는지 확인 (삼국유사/삼국사기 편명)
- [ ] 인물 생몰년·관계 라벨의 정확성 확인 (예: 경애왕·견훤 연대)
- [ ] 역사 왜곡 소지가 없는지, 민감한 해석을 단정적으로 적지 않았는지 확인

## 인물 초상 이미지

`characters.json` 의 `portrait` 경로(`assets/portraits/*.png`)에 해당하는 이미지는 아직 없다.
UI 는 이미지 로드 실패 시 **이름 첫 글자 아바타**로 폴백하므로 앱은 정상 동작한다.
배포 전 일러스트/아이콘을 `assets/portraits/` 에 채우면 된다.

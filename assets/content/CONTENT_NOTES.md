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
| site_seokguram | 석굴암 | 126216 | ✅ 검증됨 (유네스코 세계유산) |
| site_gameunsa | 감은사지 | 128637 | ✅ 검증됨 |
| site_igyeondae | 이견대 | 128651 | ✅ 검증됨 |
| site_munmu_tomb | 문무대왕릉 | 126218 | ✅ 검증됨 |
| site_gyerim | 계림 | 128116 | ✅ 검증됨 |
| site_wolseong | 월성 | 128117 | ✅ 검증됨 |
| site_talhae_tomb | 탈해왕릉 | 129523 | ✅ 검증됨 |
| site_bunhwangsa | 분황사 | 317503 | ✅ 검증됨 |
| site_oreung | 오릉 | 126213 | ✅ 검증됨 |
| site_najeong | 나정 | 128635 | ✅ 검증됨 |
| site_muyeol_tomb | 태종무열왕릉 | 126210 | ✅ 검증됨 |
| site_kim_yusin_tomb | 김유신묘 | 126203 | ✅ 검증됨 |
| site_daereungwon | 대릉원 | 126214 | ✅ 검증됨 (TourAPI 표제는 "천마총(대릉원)") |
| site_hwangnyongsa | 황룡사지 | 127985 | ✅ 검증됨 |
| site_seondeok_tomb | 선덕여왕릉 | 126211 | ✅ 검증됨 |
| site_wonseong_tomb | 원성왕릉(괘릉) | 128638 | ✅ 검증됨 |
| site_yeongji | 영지 | 3090456 | ✅ 검증됨 |
| site_jinpyeong_tomb | 진평왕릉 | 2756726 | ✅ 검증됨 |

불국사 `detailIntro2` 의 `heritage1=1` 확인 — 무대 화면 유네스코 배지가 켜진다.

2026-08-31 확장분(석굴암~진평왕릉 18곳)은 `searchKeyword2` + `detailCommon2` 실호출로
검증했다(전부 `contentTypeId=12`, 좌표·대표 이미지 존재 확인). 확장분 특이사항:

- **대릉원(126214)** — TourAPI 항목명이 "천마총(대릉원)"이다. 이야기(미추왕 죽엽군)의
  무대인 미추왕릉(죽현릉)은 대릉원 경내에 있으므로 같은 항목에 연결했다.
- **영지(3090456)** — 아사달·아사녀 이야기는 삼국유사에 없는 **근대에 정착된 전설**이다.
  인물명은 현진건 소설 '무영탑'(1939)에서 굳어진 것으로, `sources` 와 인물 설명에
  명시해 두었다. 감수 시 표기 수위를 확인할 것.
- **문무왕 관계 보정** — 기존 `king_munmu` 의 "을제 신하" 관계는 연대가 맞지 않아
  (을제는 선덕여왕대 재상) 김춘추·문희·신문왕 가족 관계로 교체했다.

## 감수 체크리스트 (사람)

- [ ] 각 이야기의 **사실 vs 각색** 경계 확인 — 대사는 모두 각색이며, 사건/인물은 출처(`sources`) 기반인지 검토
- [ ] `sources` 표기가 실제 출전과 일치하는지 확인 (삼국유사/삼국사기 편명)
- [ ] 인물 생몰년·관계 라벨의 정확성 확인 (예: 경애왕·견훤 연대)
- [ ] 역사 왜곡 소지가 없는지, 민감한 해석을 단정적으로 적지 않았는지 확인

## 인물 초상 이미지

`characters.json` 의 `portrait` 경로(`assets/portraits/*.png`)에 해당하는 이미지는 아직 없다.
UI 는 이미지 로드 실패 시 **이름 첫 글자 아바타**로 폴백하므로 앱은 정상 동작한다.
배포 전 일러스트/아이콘을 `assets/portraits/` 에 채우면 된다.

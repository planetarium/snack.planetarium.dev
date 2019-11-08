---
title: Hacktoberfest를 돌아보며
date: 2019-11-08
authors: [swen.mun]
---

안녕하세요. 오늘은 저희 [플라네타리움] 팀이 지난 10월 한 달간 [Hacktoberfest]에 참가하여 받은 기여들을 소개해보려 합니다.


# 둘러보기

Hacktoberfest를 맞아 저희는 36개의 이슈를 준비했고, 그중 15개의 이슈가 기여를 통해 처리되었습니다.

{{<
figure
  src="1.png"
  caption="처리된 이슈들"
>}}

한 달간 기여를 받아보니 다음과 같은 재밌는 사실도 알게 되었습니다.

- 절반 정도의 기여가 월초에 집중되었습니다. 초반 스퍼트가 중요해 보이네요. 🏃
- 대부분의 이슈가 초심자를 위한 이슈(`label:"good first issue"`)였습니다.
- [Libplanet], [Libplanet Explorer], [Libplanet Explorer Frontend] 3개 프로젝트가 고르게 기여를 받았습니다.


# 기억에 남는 기여들

- [@MaxStalker] 님이 작업해 주신 [Auto refresh when block mined][planetarium/libplanet-explorer-frontend#37]는 코멘트 숫자에서도 알 수 있듯이, 꽤 난항을 겪은 이슈였습니다. Libplanet Explorer Frontend는 특성상 GraphQL 백엔드인 Libplanet Explorer가 있어야 하는데, 저희가 준비한 GraphQL 백엔드가 계속 내려가는 문제가 있어서 꽤 기다리셔야 했거든요. 😢 서비스가 정상화된 뒤에도 [저희 디스코드 서버][2]에서 이런저런 트러블슈팅을 함께 해가면서 기여를 마무리해 주신 @MaxStalker 님께 이 자리를 빌려 감사의 말씀을 전합니다. 🙇

- [@RozzaysRed] 님은 Hackoberfest 기간 중, *hacktoberfest* 레이블이 붙어있는 이슈뿐만 아니라 그렇지 않은 이슈들에도 [많은 기여][3]를 해주셨습니다. 이럴 줄 알았으면 저희가 *hacktoberfest* 레이블을 좀 더 빨리, 많이 붙여둘 걸 그랬네요. 😊

- [Rename “maxValue” parameters in IRandom.Next() methods][planetarium/libplanet#555] 이슈에서는 [@pBouillon] 님께 기여뿐 아니라 적당한 파라미터 명(`lowerBound`, `upperBound`)을 제안받기도 했습니다. 💬

# 마치며

그 밖에도 Hacktoberfest 기간 중 저희가 준비한 프로젝트에 관심과 기여를 보내 주신 모든 분들께 다시 한번 감사의 말씀 드립니다. 

Hacktoberfest는 끝났지만, 저희는 언제나 여러분을 기다리고 있습니다. 혹시 저희가 풀고 있는 문제에 관심이 있거나 함께 하고 싶으신 분은 언제라도 [디스코드 대화방][2]에서 알려주세요!


[플라네타리움]: https://planetariumhq.com
[Hacktoberfest]: https://hacktoberfest.digitalocean.com/
[Libplanet]: https://github.com/planetarium/libplanet/
[Libplanet Explorer]: https://github.com/planetarium/libplanet-explorer/
[Libplanet Explorer Frontend]: https://github.com/planetarium/libplanet-explorer-frontend/
[planetarium/libplanet-explorer-frontend#37]: https://github.com/planetarium/libplanet-explorer-frontend/issues/37
[planetarium/libplanet#555]: https://github.com/planetarium/libplanet/issues/555
[@MaxStalker]: https://github.com/MaxStalker
[@RozzaysRed]: https://github.com/RozzaysRed
[@pBouillon]: https://github.com/pBouillon
[1]: https://github.com/issues?page=2&q=archived%3Afalse+label%3Ahacktoberfest+org%3Aplanetarium+updated%3A%3C%3D2019-11-01&utf8=%E2%9C%93
[2]: https://discord.gg/planetarium
[3]: https://github.com/issues?q=assignee%3ARozzaysRed+is%3Aclosed

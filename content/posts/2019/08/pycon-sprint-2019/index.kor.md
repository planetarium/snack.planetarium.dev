---
title: 파이콘 스프린트에 다녀오다
date: 2019-08-21
authors: [dogeon.lee]
---

안녕하세요 플라네타리움 개발팀에서 [Libplanet]을 개발하고 있는 이도건입니다!

지난 8월 15일 부터 8월 16일까지 2일간 열린 [파이콘 2019 스프린트]에
[Libplanet] 프로젝트의 리더로 저희 팀이 참가했었습니다.
이 글에서는 파이콘 스프린트에서 받았던 기여들에 대해 간략히 이야기 해보고자 합니다.

[파이콘 2019 스프린트]: https://archive.pycon.kr/2019/program/sprint

## 기여 소개

스프린트에 참여해 주신 분들 덕분에 [Libplanet] 프로젝트를 비롯하여 [Libplanet Explorer] 프로젝트와 [Libplanet Explorer 웹 프론트엔드] 프로젝트에 추가된 기능들이 정말 많습니다!

[Libplanet Explorer]는 Libplanet을 이용한 게임에서 생성된 블록들을 [GraphQL]을 통하여 쉽게 탐색할 수 있도록 도와주는 프로젝트이고
[Libplanet Explorer 웹 프론트엔드]는 이를 브라우저에서 쉽게 볼 수 있게 하기 위한 TypeScript + React 프로젝트입니다.

![balloon](./balloon.jpg)

파이콘 준비 위원회 분들께서 PR을 올릴 때마다 풍선을 선물해 주셨는데요.
저 많은 풍선들을 있게 한 기여 받은 PR들 중 일부를 공유해보고자 합니다!

[GraphQL]: https://graphql.org/

### 수상한 블록 다운로드 개수

다른 노드로부터 해당 노드가 갖고 있지 않은 블록에 어떤 것이 있는 지에 대한 질의를 받았을 때
일정한 개수로 나누어 블록 해시들을 질의한 노드에게 전달하게 됩니다.

하지만 블록 해시를 보내줄 때 첫 응답을 제외하고는 기대와는 다르게 하나 적게 전달해 주는 문제가 있었는데요.
이 문제의 해결을 위해 [백대현][gurrpi] 님께서 기여해 주셨습니다.

이를 통해 원래 기대한 만큼의 블록 해시들을 보내고 받을 수 있게 되었습니다.

[gurrpi]: https://github.com/gurrpi

### 빈 블록 숨기기!

[Libplanet]은 [작업 증명(proof of work)][PoW] 기반의 가장 긴 체인만을 인정하는 방식을 따르고 있으므로
트랜잭션이 아무것도 들어있지 않더라도 꾸준히 블록을 생성하게 되는데요.
블록 자체보다는 그 안에 들어간 트랜잭션들을 살펴봐야 할 때에는 쿼리 결과에 빈 블록들이 섞여 있어서 거추장스러울 수 있습니다.

하지만 저희가 관심있는 블록들은 주로 트랜잭션이 들어 있는 블록들이고
이를 위한 옵션을 [하혜미][hyeguiee] 님께서 기여를 통해 추가해 주셨습니다!

이를 통해서 원한다면 트랜잭션이 포함되어 있는 블록들만 볼 수 있게 되었습니다.

[PoW]: https://en.bitcoin.it/wiki/Proof_of_work
[hyeguiee]: https://github.com/hyeguiee

### 프론트엔드 도커화!

도커([Docker])는 애플리케이션을 컨테이너를 이용하여 쉽게 만들고 배포하고 실행할 수 있도록 도와주는 도구입니다.

[양민호][minhoryang] 님께서 해주신 기여를 통하여 [Libplanet Explorer 웹 프론트엔드]에 도커파일을 만들어 주신 덕분에
어디든 쉽게 배포하거나 로컬에서 쉽게 돌려볼 수 있는 환경이 마련되었습니다.

[Docker]: https://docker.io/
[minhoryang]: https://github.com/minhoryang

### 프론트엔드 변경 사항!

[Libplanet Explorer]의 변경 사항에 따라 혹은 별개로 프론트엔드에도 여러 기능이 추가되었습니다.

[안기욱][AiOO] 님과 [강효준][kanghyojun] 님 그리고 [aucch] 님 의 기여로 이제는 트랜잭션들이 없는
블록들을 필터링하는 옵션, 블록 생성 시간, 난이도 평균 등을 보여줍니다!

![frontend-screeshot](./frontend-screenshot.png)

또한 트랜잭션의 세부 사항을 볼 수 있도록 개별 트랜잭션 페이지가 생겼습니다!

![frontend-screenshot](./frontend-screenshot-transaction.png)

[AiOO]: https://github.com/AiOO
[kanghyojun]: https://github.com/kanghyojun
[aucch]: https://github.com/aucch

## 기여는 언제든지 환영입니다!

스프린트 기간이 아니더라도 저희 프로젝트에 대한 질문 혹은 기여는 언제든 환영입니다!
[GitHub 저장소][libplanet]로 찾아오셔서 이슈에 코멘트를 남겨주셔도 좋고 [저희 디스코드 서버]에 오셔서 물어봐주셔도 좋습니다.

[저희 디스코드 서버]: https://discord.gg/wUgwkYW

[Libplanet]: https://github.com/planetarium/libplanet
[Libplanet Explorer]: https://github.com/planetarium/libplanet-explorer
[Libplanet Explorer 웹 프론트엔드]: https://github.com/planetarium/libplanet-explorer-frontend

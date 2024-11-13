---
title: "Hacktoberfest 2024 후기"
date: 2024-11-12
authors: [dogeon.lee]
ogimage: images/og.kor.png
---

안녕하세요! 저희 DX팀은 2024년 10월 25일부터 27일까지 3일 동안 Hacktoberfest 스프린트 행사를 진행했어요.

이 글에서는 Hacktoberfest가 어떤 행사인지 간략히 소개하고, 이번 온/오프라인 스프린트가 어떻게 진행되었는지, 그리고 Hacktoberfest를 통해 받은 소중한 기여 내용을 공유하려고 해요.

## 📝 Hacktoberfest에 대하여

혹시 <dfn>Hacktoberfest</dfn>라는 행사를 들어보셨나요? Hacktoberfest는 매년 10월 1일부터 31일까지 한 달간 진행되는 오픈 소스 행사예요. 전 세계 누구나 참여할 수 있으며, 10월 동안 공개 저장소에 4개의 풀 리퀘스트를 제출하면 목표를 달성한 것으로 인정되고 보상이 주어지는 방식이에요. 예전에는 굿즈를 제공했지만, 요즘은 디지털 뱃지를 주는 것 같아요.

오픈 소스 저장소 메인테이너 입장에서는 Hacktoberfest에 참여하려면 저장소의 토픽에 `hacktoberfest`를 추가하거나, 특정 이슈에 `hacktoberfest` 라벨을 달아야 해요. 기여자는 이 `hacktoberfest` 라벨이 달린 이슈들을 찾아 해결함으로써 행사에 참여할 수 있어요.

{{<
figure
  src="images/hacktoberfest-issues.png"
  width="500"
  caption="<q>hacktoberfest</q> 라벨이 붙은 이슈들"
>}}

[hacktoberfest]: https://hacktoberfest.digitalocean.com/

## 🙌 온/오프라인 스프린트 행사

Hacktoberfest는 기본적으로 어디서든 GitHub나 GitLab 등을 통해 참가할 수 있는 프로젝트예요. 하지만 온라인 또는 오프라인으로 별도의 행사를 열 수도 있어요.

그래서 제가 속해 있는 DX 팀에서는 오픈 소스 기여를 어려워하는 분들을 돕기 위해 Planetarium의 저장소들을 대상으로 기여를 돕는 온/오프라인 행사를 기획했어요. Google Form을 통해 참가 신청을 받고 홍보한 덕분에 많은 분이 참가해 주셨고, 저희는 준비를 시작했어요.

먼저, 10월 25일과 26일에 진행된 온라인 행사는 [디스코드 서버][pl-dev-discord]에서 열렸어요. 디스코드의 "메인 스테이지" 음성 채널에서 오프닝 발표를 진행한 뒤, Git과 GitHub에 익숙하지 않은 분들을 위해 Git 세션을 준비해 진행했어요.

{{<
figure
  src="images/hacktoberfest-discord-1.png"
  width="500"
  caption="메인 스테이지 채널에서 오프닝 발표 진행"
>}}


이후에는 DX 팀원들이 각자의 채널에서 참가자분들이 관심 있는 이슈에 대해 이야기를 나누고, 적절한 이슈를 배정해 드렸어요. 디스코드를 통해 실시간으로 소통하며 어려운 부분을 해결하실수 있도록 돕고, 기여 내용이 머지되어 업스트림에 반영될 수 있도록 도와드렸어요.

{{<
figure
  src="images/hacktoberfest-discord-2.png"
  height="500"
  caption="기여자분 마다 메인테이너가 배정되어 기여를 도와드렸어요"
>}}

10월 27일에 진행된 오프라인 행사에서도 온라인 행사와 마찬가지로 오프닝 발표와 Git 세션이 진행되었어요.

{{<
figure
  src="images/hacktoberfest-offline-git.png"
  width="500"
  caption="오프라인 행사장에서 DX팀 [지원](https://github.com/Atralupus)님이 Git 세션을 진행해주셨어요"
>}}

사무실에서 열린 덕분에 Planetarium 엔지니어들이 참가자들과 직접 만나 함께 기여 활동을 할 수 있었어요.

{{<
figure
  src="images/hacktoberfest-offline-contribution.jpg"
  width="500"
  caption="회의실에서 DX팀 [승민](https://github.com/boscohyun)님이 기여를 도와드리는 중"
>}}

## 🙏 기여받은 부분들

앞서 사진과 함께 보여드린 온/오프라인 행사를 포함해, 10월 동안 많은 기여가 있었습니다. 그중 몇 가지 주요 기여를 소개해 드리려고 해요.

-----

블록체인 라이브러리인 [Libplanet][libplanet]은 .NET 패키지 레지스트리인 NuGet에 배포되고 있어요. 버전 목록에서 최신 버전을 쉽게 찾을 수 있도록 dev 릴리스에는 `-dev.<timestamp>`와 같은 타임스탬프 기반의 suffix를 붙이고 있는데요, 타임스탬프가 zerofill 없이 발행되면서 버전들이 릴리스 시간 순서대로 정렬되지 않는 문제가 있었어요.

다행히 [uday-rana](https://github.com/uday-rana) 님의 기여로 이제는 릴리스 시간 순서대로 정렬되어 최신 dev 릴리스를 쉽게 찾을 수 있게 되었어요. ([PR][libplanet-nuget-pr])

[libplanet-nuget-pr]: https://github.com/planetarium/libplanet/pull/3957

{{<
figure
  src="images/libplanet-nuget-versions.png"
  width="500"
  caption="시간 순서대로 정렬된 Libplanet dev 릴리스들"
>}}

Planetarium에서 오픈소스로 개발 중인 게임 [Nine Chronicles][9c-dev-portal]에는 게임의 프로토콜 로직을 포함한 [lib9c][lib9c]라는 라이브러리가 있어요. 이 라이브러리에는 블록체인에 트랜잭션이 어떻게 생겨야 하는지, 전투가 어떤 규칙으로 이루어지는지, 그리고 마켓 관련 동작이 어떻게 이루어져야 하는지에 대한 코드가 작성되어 있어요. 하지만 C#으로 작성되어 있어 JavaScript로 개발된 사내 프로젝트에서 활용하기에 어려움이 있었어요. 이에 JavaScript로 쉽게 트랜잭션을 만들 수 있는 라이브러리를 만들었지만, 기능이 부족한 상태였어요.

다행히 [kanade012](https://github.com/kanade012)님과 [originchoi](https://github.com/originchoi)님의 기여로 **액션 포인트 리필**, **아레나 참가**, **그라인딩**과 같은 게임 내 행동을 위한 트랜잭션을 이제는 C#이 아닌 JavaScript만으로도 만들 수 있게 되었어요. ([“액션 포인트 리필” PR](https://github.com/planetarium/lib9c/pull/2941), [“아레나 참가” PR](https://github.com/planetarium/lib9c/pull/2946), [“그라인딩” PR](https://github.com/planetarium/lib9c/pull/2949))

{{<
figure
  src="images/lib9cjs-prs.png"
  width="500"
  caption="자바스크립트 라이브러리에 기능을 추가한 PR들"
>}}

라이브러리뿐만 아니라, Planetarium에서 오픈소스로 개발 중인 게임 [Nine Chronicles][9c-dev-portal]의 [유니티 클라이언트][9c-unity]에도 기여해주신 분이 계셨어요. 게임의 월드 보스 콘텐츠를 플레이할 때, 우측 상단의 플레이 버튼이 언어 설정과 상관없이 영어로 표시되는 문제가 있었어요.

[HohyunKim-kr](https://github.com/HohyunKim-kr)님의 기여로 이제 버튼이 의도한 언어로 제대로 표시되도록 수정되었어요. ([PR][unity-bugfix-pr])

{{<
figure
  src="images/9c-unity-bugfix.png"
  width="500"
  caption="HohyunKim-kr 님이 올려주신 PR"
>}}

[unity-bugfix-pr]: https://github.com/planetarium/NineChronicles/pull/6232

외에도 정말 많은 분들이 기여를 해주신 덕분에 많은 기능이 생기고, 많은 버그 및 오타들이 수정될 수 있었어요. 🙏


[libplanet]: https://github.com/planetarium/libplanet
[lib9c]: https://github.com/planetarium/lib9c
[9c-dev-portal]: https://nine-chronicles.dev/
[9c-unity]: https://github.com/planetarium/NineChronicles

## 🔍 끝마치며

Hacktoberfest 스프린트 행사를 급하게 준비하느라 부족한 점도 많았지만, 사내에서 많은 도움을 주신 덕분에 잘 준비할 수 있었어요. 많은 분들이 참가해 주시고 다양한 기여를 해주셔서 정말 감사드립니다. 🙏

또한, 이런 오픈 소스 행사에 관심이 있고 한국에서 활동하며 직접 기여해보고 싶으신 분들께 다음과 같은 행사들을 추천드리고 싶어요:

 - [Open Contribution Jam 2024](https://festa.io/events/6342)
 - [SprintSeoul](https://x.com/sprintseoul)
 - [Open Source Contribution Academy](https://www.contribution.ac/)
 - PyCon Sprint ([파이콘 한국 2024 스프린트](https://2024.pycon.kr/program/sprint))

혹시 제가 모르는 다른 행사들도 있다면 [Planetarium Dev 디스코드 서버][pl-dev-discord]에 들어와 알려주세요! 😉

[pl-dev-discord]: https://planetarium.dev/discord

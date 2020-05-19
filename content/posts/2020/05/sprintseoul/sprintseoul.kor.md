---
title: Libplanet 팀이 2020 스프린트서울에도 참여합니다!
date: 2020-05-19
authors: [suho.lee]
---

오랜만입니다! [스프린트서울][1]에 프로젝트 리더로 참가하게 된
[Libplanet] 팀입니다.

저희 팀은 꾸준히 행사에 참여하고 있으며, 이번 스프린트에도 참여했습니다!
그동안 스프린트서울은 하루라는 짧은 시간동안 함께 문제를 해결해 나가는 행사였지만,
이번 스프린트서울은 5월 한 달 내내 진행됩니다.

그에 맞춰 저희도 이번엔 조금 더 긴 시간동안 도전적인 문제를 해결해 보고 싶은 분들이
관심이 있어할 만한 이슈들과, 처음 기여하시는 분들이 부담 없이 기여하실 수 있는 이슈
두 가지 모두 준비해 보았습니다.

또한 스프린트에 참가하여 저희 저장소에 기여해 주신 분들에 대해 **소정의 상품**도 준비하고 있으니,
많은 참여 부탁드립니다!

[1]: https://sprintseoul.org/
[Libplanet]: https://libplanet.io/


프로젝트 소개
-------------

[Libplanet]은 BitTorrent처럼 서버 없이 돌아가는 P2P 멀티플레이 게임을 만들기
위한 네트워킹・스토리지 라이브러리로, 이를 달성하기 위해 블록체인 기술을
구현합니다.  이용자 각각이 실행하는 게임 앱들이 네트워크에서 서로 연결되며,
게임의 공정한 판정과 기록을 위해 운영되는 서버가 없는 대신,
공정한 판정은 합의 알고리즘을 통해, 기록은 리플리케이션을 통해 이뤄집니다.

이번 스프린트에서 다룰 저장소로는 아래 세 곳이 있습니다.
각자 익숙하거나 선호하는 환경에 따라 다른 저장소에 기여해 주시면 될 것 같습니다.
참고로 세 저장소 모두 Linux, macOS, Windows 세 플랫폼에서 개발 가능합니다.

 -  [Libplanet][libplanet-core]: 네트워킹 및 스토리지, 블록체인 등을 구현하는
    프로젝트의 핵심으로, Unity 등의 게임 엔진과 함께 쓰일 수 있도록 C#으로
    작성되어 있으며 멀티플랫폼입니다.

 -  [Libplanet Explorer (서버)][libplanet-explorer]: Libplanet을 이용해 만든
    게임이 분산 네트워크 위에서 쌓아 올린 블록체인 데이터를 게임 외부에서도
    열람할 수 있도록 GraphQL 프로토콜로 노출하는 C# 앱입니다.

 -  [Libplanet Explorer (웹)][libplanet-explorer-frontend]: 웹 서버가 GraphQL을
    통해 제공하는 데이터를 웹 프론트엔드로 구현한 비교적 최종 사용자 지향의
    웹 앱(클라이언트)입니다.  TypeScript, React, Gatsby, Apollo를 이용해
    작성되어 있습니다.

특히 이 중에서 *Libplanet Explorer (웹)*은 TypeScript로 되어 있어, 블록체인 기술이나
C#을 잘 모르지만, Libplanet에 대해 관심이 있던 참가자 분들도 기여하실 수 있습니다.

[Libplanet]: https://libplanet.io/
[libplanet-core]: https://github.com/planetarium/libplanet
[libplanet-explorer]: https://github.com/planetarium/libplanet-explorer
[libplanet-explorer-frontend]: https://github.com/planetarium/libplanet-explorer-frontend


C# 개발 환경
---------

먼저, C# 프로젝트에  참여하기 위해서는 개발 환경을 설치해야 합니다.
C#은 Python이나 JavaScript 등과 달리 IDE가 없으면 코딩하기 힘든 언어입니다.
Windows라면 최신 버전의 Visual Studio를 설치하면 되겠지만, 여러 플랫폼에서
두루 쓸 수 있는 IDE로 Rider나 VS Code를 추천합니다. 아래 문서들은
Rider 또는 Visual Studio Code를 쓴다는 가정 하에 Libplanet의 개발 환경을
설치하는 방법을 한국어로 안내하고 있습니다.

 -  [Libplanet 개발 환경 설정 (VS Code)][5]
 -  [Libplanet 개발 환경 설정 (Rider)][6]

그 외에, Libplanet 저장소의 *[CONTRIBUTING.md]* 문서는 CLI 도구만을 이용해서 개발하는 아주
기본적인 개발 환경 설정을 안내합니다.  꼭 자신이 이용하는 에디터를 쓰고 싶은 분들은 이쪽을 읽어주시면
되겠습니다.

[5]: https://gist.github.com/dahlia/5333634f62509293cd46c0e4ba65b2f5
[6]: https://gist.github.com/dahlia/08f6e659e2266e941ad026f591c30c9a
[CONTRIBUTING.md]: https://github.com/planetarium/libplanet/blob/master/CONTRIBUTING.md

TypeScript 개발 환경
-------------------

TypeScript 개발 환경은 C# 개발 환경에 비해 간단합니다. Libplanet Explorer (웹) 저장소의 *[README.md]* 문서에
잘 정리되어 있으니, 어렵지 않게 따라하실 수 있을 것입니다.

[README.md]: https://github.com/planetarium/libplanet-explorer-frontend/blob/master/README.md

살펴볼 만한 이슈
----------------

처음 기여하시는 분들을 위한 각 프로젝트 별 초심자용 이슈들을 모아놨습니다.
- [Libplanet][7]
- [Libplanet Explorer (서버)][8]
- [Libplanet Explorer (웹)][9]

프로젝트 구조를 자세히 파악하지 못한 상태에서도 깊게 들어가지 않고 해볼 수 있을 만한 것들입니다.

뿐만 아니라, 좀 더 도전적인 문제를 찾는 분들을 위한 *help wanted* 레이블 또한 준비되어 있습니다.
- [Libplanet][10]
- [Libplanet Explorer (서버)][11]
- [Libplanet Explorer (웹)][12]

[7]: https://github.com/planetarium/libplanet/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22
[8]: https://github.com/planetarium/libplanet-explorer/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22
[9]: https://github.com/planetarium/libplanet-explorer-frontend/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22
[10]: https://github.com/planetarium/libplanet/issues?q=is%3Aissue+is%3Aopen+label%3A%22help+wanted%22
[11]: https://github.com/planetarium/libplanet-explorer/issues?q=is%3Aissue+is%3Aopen+label%3A%22help+wanted%22
[12]: https://github.com/planetarium/libplanet-explorer-frontend/issues?q=is%3Aissue+is%3Aopen+label%3A%22help+wanted%22

고민되거나 망설여진다면
----------------------

어떤 기여를 어떻게 해야 할지 고민이 되는 분들은, 저희 프로젝트에 기여하신 분들의 경험담을 읽어보시고
결정하셔도 좋을 것 같습니다.

- 이승훈 님께서 쓰신 <cite>[Libplanet 처음 기여하기][13]</cite>
- 이수호 님께서 쓰신 <cite>[2019 스프린트 서울 6월 행사를 참여하고 나서...][14]</cite>

[13]: {{< ref "first-contribution.kor.md" >}}
[14]: https://blog.hanaoto.me/sprint_seoul_2019_june/

질문 및 대화방
--------------

궁금한 게 있으시면 [저희 Discord 서버]에 있는 #libplanet-users-kr 채널에
오셔서 물어보셔도 됩니다.  행사 전에 미리 들어오셔서 물어보셔도 좋고, 행사 끝난 뒤라도
좋습니다. 단순히 놀러 오셔도 환영입니다!


[저희 Discord 서버]: https://discord.gg/wUgwkYW

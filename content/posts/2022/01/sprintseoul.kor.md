---
title: Libplanet 팀이 2022년 1월 스프린트서울에도 참여합니다!
date: 2022-01-17
authors: [swen.mun]
---

정말로 오랜만입니다! [스프린트서울][1]에 프로젝트 리더로 참가하는 [Libplanet] 
팀입니다.

장기화 된 코로나로 많은 행사들이 연기되거나 축소되어 많은 분들이 아쉬워하고 계실 것 
같습니다. 그런데 다행히도 올해 1월부터 스프린트서울이 재개된다는 기쁜 소식을 
접했고, 감사하게도 이번에도 프로젝트 리더로 선정되어 여러분을 만나려 합니다. 
지난 번 참여했을 때에는 라이브러리인 Libplanet으로 참가했었는데, 이번에는 함께 
개발한 오픈소스 탈중앙 게임인 [나인 크로니클]쪽도 함께 참가합니다.

[1]: https://sprintseoul.org/
[Libplanet]: https://libplanet.io/
[나인 크로니클]: https://nine-chronicles.com/


프로젝트 소개
-------------

[Libplanet]은 BitTorrent처럼 서버 없이 돌아가는 P2P 멀티플레이 게임을 만들기
위한 네트워킹・스토리지 라이브러리로, 이를 달성하기 위해 블록체인 기술을
구현합니다.  이용자 각각이 실행하는 게임 앱들이 네트워크에서 서로 연결되며,
게임의 공정한 판정과 기록을 위해 운영되는 서버가 없는 대신,
공정한 판정은 합의 알고리즘을 통해, 기록은 리플리케이션을 통해 이뤄집니다.

[나인 크로니클]은 위에서 소개한 Libplanet을 사용한 최초의 P2P MMO 게임으로, 
2020년 10월 메인넷을 출범한 이후 현재까지 약 1년 3개월간 운영하고 있는 커뮤니티 
주도형 탈중앙 게임입니다. 게임 진행에 필요한 모든 게임 로직이 블록체인 위에서 
동작하는 것이 가장 큰 특징으로, 현재 일 평균 3,000명 정도가 플레이하고 있습니다.

이번 스프린트에서 다룰 저장소로는 아래 두 곳으로, 각자 익숙하거나 선호하시는 환경에 
따라 다른 저장소에 기여해 주시면 됩니다. 또한 모든 저장소의 프로젝트는 
Linux, macOS, Windows 세 플랫폼에서 개발 가능합니다.

 -  [Libplanet][libplanet-core]: 네트워킹 및 스토리지, 블록체인 등을 구현하는
    프로젝트의 핵심으로, Unity 등의 게임 엔진과 함께 쓰일 수 있도록 C#으로
    작성되어 있으며 멀티플랫폼입니다.

 -  [나인 크로니클 게임 론처][9c-launcher]: 나인 크로니클의 개인 키와 계정 관리, 
    그리고 가장 중요한 게임 클라이언트의 실행을 담당하는 GUI 애플리케이션입니다. 
    Electron으로 개발되어 있으며 TypeScript와 React, 그리고 GraphQL을 적극적으로 사용하고 있습니다.

[Libplanet]: https://libplanet.io/
[나인 크로니클]: https://nine-chronicles.com/
[libplanet-core]: https://github.com/planetarium/libplanet
[9c-launcher]: https://github.com/planetarium/9c-launcher


C# 개발 환경
---------

먼저, C# 프로젝트에 참여하기 위해서는 개발 환경을 설치해야 합니다.
C#은 Python이나 JavaScript 등과 달리 IDE가 없으면 코딩하기 힘든 언어입니다.
Windows라면 최신 버전의 Visual Studio를 설치하면 되겠지만, 여러 플랫폼에서
두루 쓸 수 있는 IDE로 Rider나 VS Code를 추천합니다. 아래 문서들은
Rider 또는 Visual Studio Code를 쓴다는 가정 하에 Libplanet의 개발 환경을
설치하는 방법을 한국어로 안내하고 있습니다.

 -  [Libplanet 개발 환경 설정 (VS Code)][2]
 -  [Libplanet 개발 환경 설정 (Rider)][3]

그 외에, Libplanet 저장소의 *[CONTRIBUTING.md]* 문서는 CLI 도구만을 이용해서 
개발하는 아주 기본적인 개발 환경 설정을 안내합니다.  꼭 자신이 이용하는 에디터를 
쓰고 싶은 분들은 이쪽을 읽어주시면 되겠습니다.

[2]: https://gist.github.com/dahlia/5333634f62509293cd46c0e4ba65b2f5
[3]: https://gist.github.com/dahlia/08f6e659e2266e941ad026f591c30c9a
[CONTRIBUTING.md]: https://github.com/planetarium/libplanet/blob/main/CONTRIBUTING.md


고민되거나 망설여진다면
----------------------

어떤 기여를 어떻게 해야 할지 고민이 되는 분들은, 저희 프로젝트에 기여하신 분들의 
경험담을 읽어보시고 결정하셔도 좋을 것 같습니다.

- 이승훈 님께서 쓰신 <cite>[Libplanet 처음 기여하기][4]</cite>
- 이수호 님께서 쓰신 <cite>[2019 스프린트 서울 6월 행사를 참여하고 나서...][5]</cite>

[4]: {{< ref "first-contribution.kor.md" >}}
[5]: https://web.archive.org/web/20201028104023/https://blog.hanaoto.me/sprint_seoul_2019_june/

질문 및 대화방
--------------

궁금한 게 있으시면 [저희 Discord 서버]에 오셔서 물어보셔도 됩니다.  행사 전에 
미리 들어오셔서 물어보셔도 좋고, 행사 끝난 뒤라도 좋습니다. 물론 가볍게 놀러 오시는 
것도 환영입니다!

[저희 Discord 서버]: https://discord.gg/YaHPjcrdrw

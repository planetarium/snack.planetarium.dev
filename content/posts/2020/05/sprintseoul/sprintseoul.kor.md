---
title: Libplanet 팀이 스프린트서울에 참가합니다
date: 2020-05-19
authors: [suho.lee]
---

현재 진행되고 있는 [스프린트서울][1]이라는 행사를 아시나요?
오픈 소스에 열정이 있는 분들이 모여서 오픈 소스 프로젝트에 코드나 문서 등을 기여해보는 행사로,
평소에 오픈 소스에 흥미는 있었지만 기여해 볼 계기는 없었던 분들도 이 모임에 오셔서
첫 오픈 소스 기여를 경험할 수 있습니다.

> 스프린트는 오픈 소스 프로젝트의 작성자 또는 기여자와 함께 짧은 시간 동안 함께 문제를 찾고 해결하며,
> 해당 오픈 소스 프로젝트에 대해 보다 깊게 알아가는 행사입니다.

저희 팀은 꾸준히 행사에 참여하고 있으며, 이번 스프린트에도 참여합니다!
저희 팀은 [Libplanet] 프로젝트 리더로 참가하며,
이 행사를 통해 여러분들의 기여를 기대하고 있습니다.

또한 스프린트에 참가하여 저희 저장소에 기여해 주신 분들에 대해 **소정의 상품**도 준비하고 있으니,
많은 참여 부탁드립니다.

[1]: https://sprintseoul.org/
[Libplanet]: https://libplanet.io/


기여하실 수 있는 프로젝트들
------------------------

이번 스프린트에는 Libplanet 말고도 여러 프로젝트가 준비되어 있습니다.

- [Libplanet]
- [Libplanet Explorer]
- [Libplanet Explorer Frontend]

특히 이 중에서 **Libplanet Explorer Frontend** 는 Typesciprt로 되어 있어, 블록체인 기술이나
C#을 잘 모르더라도 기여하실 수 있습니다.

[Libplanet]: https://github.com/planetarium/libplanet
[Libplanet Explorer]: https://github.com/planetarium/libplanet-explorer
[Libplanet Explorer Frontend]: https://github.com/planetarium/libplanet-explorer-frontend

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

Typescript 개발 환경
-------------------

Typescript 개발 환경은 C# 개발 환경에 비해 간단합니다. Libplanet Explorer Frontend 저장소의 *[README.md]*
에 잘 정리되어 있으니, 어렵지 않게 따라하실 수 있을 것입니다.

[README.md]: https://github.com/planetarium/libplanet-explorer-frontend/blob/master/README.md
[Discord 서버]: https://discord.gg/wUgwkYW


살펴볼 만한 이슈
----------------

처음 기여하시는 분들을 위한 각 프로젝트 별 초심자용 이슈들을 모아놨습니다.
- [Libplanet][7]
- [Libplanet Explorer][8]
- [Libplanet Explorer Frontend][9]

프로젝트 구조를 자세히 파악하지 못한 상태에서도 깊게 들어가지 않고 해볼 수 있을 만한 것들입니다.

[7]: https://github.com/planetarium/libplanet/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22
[8]: https://github.com/planetarium/libplanet-explorer/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22
[9]: https://github.com/planetarium/libplanet-explorer-frontend/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22

고민되거나 망설여진다면
----------------------

어떤 기여를 어떻게 해야 할지 고민이 되는 분들은, 저희 프로젝트에 기여하신 분들의 경험담을 읽어보시고
결정하셔도 좋을 것 같습니다.

- 이승훈 님께서 쓰신 <cite>[Libplanet 처음 기여하기][10]</cite>
- 이수호 님께서 쓰신 <cite>[2019 스프린트 서울 6월 행사를 참여하고 나서...][11]</cite>

[10]: {{< ref "first-contribution.kor.md" >}}
[11]: https://blog.hanaoto.me/sprint_seoul_2019_june/

질문 및 대화방
--------------

궁금한 게 있으시면 [저희 Discord 서버]에 있는 #libplanet-users-kr 채널에
오셔서 물어보셔도 됩니다.  행사 전에 미리 들어오셔서 물어보셔도 좋고, 행사 끝난 뒤라도
좋습니다.

[저희 Discord 서버]: https://discord.gg/wUgwkYW

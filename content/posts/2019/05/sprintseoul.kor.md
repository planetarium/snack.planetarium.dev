---
title: Libplanet 팀이 스프린트서울에 참가합니다
date: 2019-05-20
authors: [hong.minhee]
---

오는 6월 29일(토)에 서울 강남에서 모일 [스프린트서울][1]이라는 행사를 아시나요?
오픈 소스에 열정이 있는 분들이 모여서 오픈 소스 프로젝트에 코드나 문서 등을 기여해보는 행사로,
평소에 오픈 소스에 흥미는 있었지만 기여해 볼 계기는 없었던 분들도 이 모임에 오셔서
첫 오픈 소스 기여를 경험할 수 있습니다.

> 스프린트는 오픈 소스 프로젝트의 작성자 또는 기여자와 함께 짧은 시간 동안 함께 문제를 찾고 해결하며,
> 해당 오픈 소스 프로젝트에 대해 보다 깊게 알아가는 행사입니다.

저희 팀은 이미 지난 4월에도 참가한 바 있으며, 6월 29일에도 참가합니다.
저희 팀은 [Libplanet] 프로젝트 리더로 참가하며,
이 행사를 통해 여러분들의 기여를 기대하고 있습니다.

스프린트 참가 신청은 6월 20일까지만 받는다고 하며, [신청 양식] 및 스프린트서울의 상세한 안내는
[공식 홈페이지][1]에서 살펴보실 수 있습니다.

[1]: https://sprintseoul.org/
[Libplanet]: https://libplanet.io/
[신청 양식]: https://forms.gle/DHjbhgpWz9QgzpFo8


Libplanet 프로젝트 소개
-----------------------

Libplanet이 어떤 프로젝트인지 궁금하실 분들을 위해,
<cite>[Libplanet 0.2 릴리스][2]</cite>에서 했던 소개를 인용합니다.

> Libplanet은 분산 <abbr title="Peer-to-Peer">P2P</abbr>로 돌아가는 온라인
> 멀티플레이 게임을 만들 때, 그러한 게임들이 매번 구현해야 하는 P2P 통신이나
> 데이터 동기화 등의 문제를 푸는 공용 라이브러리입니다.
>
> Libplanet은 널리 쓰이는 Unity 엔진과 함께 쓰일 것을 염두에 두고 만들어져,
> 현재 C# 언어로 개발되고 있습니다. 물론 Unity 엔진을 쓰지 않더라도 .NET 또는 Mono
> 플랫폼으로 구현된 게임이라면 쉽게 붙일 수 있도록, [.NET Standard 2.0][3]을 타깃하여
> 이식성을 확보하고 있습니다.
>
> Libplanet의 또 다른 특징은, 프레임워크나 엔진이 아닌 라이브러리라는 점입니다.
> 엔진이나 프레임워크는 게임 프로세스의 진입점(`Main()` 메서드)과 주도권을 가져간 채
> 허용된 부분에 한해서 게임 프로그래머가 스크립팅할 수 있게 하는 데 반해,
> Libplanet은 게임 프로세스를 선점하지 않으며 게임 프로그래머가 명시적으로
> 호출한 곳에서만 비간섭적으로 (unobtrusively) 동작합니다.
> 덕분에 Unity 같은 기성 게임 엔진과도 무리 없이 함께 쓸 수 있습니다.
>
> Libplanet은 [NuGet]에 올라가 있으며, [API 문서][4]도 있습니다.

[2]: {{< ref "libplanet-0.2.kor.md" >}}
[3]: https://github.com/dotnet/standard/blob/master/docs/versions/netstandard2.0.md
[NuGet]: https://www.nuget.org/packages/Libplanet/
[4]: https://docs.libplanet.io/

개발 환경
---------

먼저, 스프린트에 참여하기 위해서는 개발 환경을 설치해야 합니다.  가급적이면 스프린트
시작 전에 **미리 개발 환경을 설치해 와주시면 감사하겠습니다.**  어느 프로젝트나 그렇겠지만,
개발 환경 설치에 시간이 생각보다 많이 들기 때문에, 반나절 가까이 허비하는 경우가 흔합니다.

C#은 Python이나 JavaScript 등과 달리 IDE가 없으면 코딩하기 힘든 언어입니다.
Windows라면 최신 버전의 Visual Studio를 설치하면 되겠지만, 여러 플랫폼에서
두루 쓸 수 있는 IDE로 Rider나 VS Code를 추천합니다. 아래 문서들은
Rider 또는 Visual Studio Code를 쓴다는 가정 하에 Libplanet의 개발 환경을
설치하는 방법을 한국어로 안내하고 있습니다.

 -  [Libplanet 개발 환경 설정 (VS Code)][5]
 -  [Libplanet 개발 환경 설정 (Rider)][6]

그 외에, Libplanet 저장소의 *[CONTRIBUTING.md]* 문서는 CLI 도구만을 이용해서 개발하는 아주
기본적인 개발 환경 설정을 안내합니다.  꼭 자신이 이용하는 에디터를 쓰고 싶은 분들은 이쪽을 읽어주시면
되겠습니다.  단, 그런 경우 Libplanet 커미터들이 당일 행사장에서 도움을 드리기 힘들 수 있기 때문에,
꼭 미리 개발 환경을 잘 설치해서 오시는 게 좋습니다.

[5]: https://gist.github.com/dahlia/5333634f62509293cd46c0e4ba65b2f5
[6]: https://gist.github.com/dahlia/08f6e659e2266e941ad026f591c30c9a
[CONTRIBUTING.md]: https://github.com/planetarium/libplanet/blob/master/CONTRIBUTING.md


살펴볼 만한 이슈
----------------

처음 기여하시는 분들을 위한 [초심자용 이슈][7]들을 모아놨습니다.
프로젝트 구조를 자세히 파악하지 못한 상태에서도 깊게 들어가지 않고 해볼 수 있을 만한 것들입니다.

어떤 기여를 어떻게 해야 할지 고민이 되는 분들은, 이승훈 님께서 쓰신
<cite>[Libplanet 처음 기여하기][8]</cite> 경험담도 도움이 될 것 같습니다.

[7]: https://github.com/planetarium/libplanet/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22
[8]: {{< ref "first-contribution.kor.md" >}}


질문 및 대화방
--------------

궁금한 게 있으시면 [저희 Discord 서버]에 있는 #libplanet-users-kr 채널에
오셔서 물어보셔도 됩니다.  행사 전에 미리 들어오셔서 물어보셔도 좋고, 행사 끝난 뒤라도
좋습니다.

[저희 Discord 서버]: https://discord.gg/wUgwkYW

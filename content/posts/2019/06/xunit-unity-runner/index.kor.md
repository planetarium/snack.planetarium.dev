---
title: Unity 환경에서 단위 테스트 돌리기
date: 2019-06-28
authors: [hong.minhee]

---

안녕하세요. 플라네타리움 개발팀에서 [Libplanet]을 만들고 있는 홍민희입니다.
이 글에서는 게임 엔진으로 널리 쓰이는 Unity 환경에서 단위 테스트를 돌리게
된 경위와 방법을 다루겠습니다.


다양한 환경을 지원하려면
------------------------

Libplanet은 분산 P2P로 돌아가는 온라인 멀티플레이 게임을 만들 때,
그러한 게임들이 매번 구현해야 하는 P2P 통신이나 데이터 동기화 등의
문제를 푸는 공용 라이브러리입니다.

기민한 개선을 이루면서도 [리그레션]이나 코너 케이스에서
일어나기 쉬운 오작동을 최소화하려면 테스트 코드, 그 중에서도 단위 테스트의
도움이 필요합니다.  뿐만 아니라, Libplanet은 라이브러리이므로
이를 이용할 게임이나 앱이 어느 운영체제와 .NET 런타임에서 실행될지
알기 어렵기 때문에, 가능한 다양한 환경에서 모든 테스트를 실행하는 게 좋습니다.

그래서 저희 팀은 Libplanet 저장소에 푸시나 풀 리퀘스트가 생길 때마다
[Azure Pipelines][^1]에서 (Linux, macOS, Windows) ×
(.NET Framework, Mono, .NET Core) 조합[^2]으로 테스트가 돌게
해뒀었습니다.

{{<
figure
  src="before.png"
  width="298"
  caption="매 빌드마다 테스트했던 환경의 조합"
>}}


Unity ≠ Mono
------------

처음에는 Unity가 Mono 런타임을 쓰기 때문에 이 정도로 충분하다고 생각했습니다.
그런데 Unity에서 Libplanet을 써서 게임을 만들다보니 게임에서만 예기치 못한
동작을 보는 일이 몇 번이나 겪게 되었고, 저희 팀은 Mono에서 테스트를 통과하는
것만으로는 Unity에서 잘 돌아간다고 믿기 힘들다는 생각이 점점 커졌습니다.

[실제로 Unity에서 쓰이는 Mono는 업스트림에 많은 패치가 더해진,
꽤 오랜 기간 유지되어 온 다운스트림인 것으로 보입니다.][unity-mono]
게다가 완전히 같은 Mono 런타임에서 테스트한다고 해도,
Unity 플레이어로 인해 생기는 특수한 조건들이 적지 않다는 정황이 자주 보였습니다.
특히, [ZeroMQ]의 C# 구현인 [NetMQ]처럼, 밖으로 드러나는 API의 단순함에
비해 훨씬 복잡한 일들이 안쪽에서 일어나는 라이브러리의 오작동이 잦았습니다.

이러한 모든 것들을 감안했을 때 Unity만을 위한 테스트 환경을 CI에 더해서
지속적으로 잘 돌아가는지 확인할 필요가 있다는 합의가 이뤄졌습니다.

Unity에서 xUnit.net 테스트 돌리기
---------------------------------

Unity에서 제공되는 단위 테스트 기능이 있기 때문에, 처음에는 이를 쓰려고
했습니다.
그런데 Unity에서 제공되는 단위 테스트는 게이머가 실행하는 플레이어 환경이 아닌,
게임 개발자가 사용하는 에디터 환경에서 실행되는 방식이었고,
테스트 프레임워크도 [NUnit]만 지원하는 문제가 있었습니다.
[xUnit.net] 기반으로 만들어져 있는 Libplanet의 테스트 코드를 모두
NUnit 기반으로 바꿀까 하는 생각도 해봤지만 아무래도 분량이 적지 않고,
그렇게 긴 코드를 한 번에 바꾸다 보면 알아채기 힘든 실수도 분명
생길 게 뻔했습니다.

그래서 Unity로 게임 앱이 아닌 테스트 실행기 앱을 만들기로 했습니다.
다행히 xUnit.net은 테스트 작성을 위한 API와 테스트 실행을 위한 API가 잘
나뉘어 있었습니다. 아마도 GUI나 CLI 외에도 각종 IDE에 플러그인 형태로 붙는 등,
다양한 프론트엔드가 있기 때문에 자연스럽게 그런 API를 갖추게 된 것으로 보입니다.
실제로 NuGet에서 "xunit runner"로 검색하면 다양한 환경을 위한 xUnit.net
테스트 실행기가 나옵니다.

다만 한 가지 아쉬운 점은, 달리 API 문서가 있지 않기 때문에 xUnit.net의
소스 코드와 다른 테스트 실행기 소스 코드를 뒤져봐야 했다는 것입니다.[^3]

xUnit.net의 테스트 실행 API는 대강 이렇습니다.  우선 클라이언트 코드가
입력으로 넘긴 어셈블리 (*.dll*) 파일들에서 테스트라고 여겨지는 클래스들과
그 클래스에 속한 테스트 메서드들을 찾습니다.
그리고 나서 그 테스트 메서드 가운데 어떤 테스트를 실행할지는
클라이언트 코드에서 결정할 수 있습니다. 그 다음에는 그 테스트 케이스들을
테스트 실행기가 실행합니다.
테스트의 발견과 실행은 성능을 위해 병렬로 이뤄질 수 있기 때문에
API는 전형적인 [<abbr title="inversion of control">IoC</abbr>][IoC]
패턴을 따릅니다.  [`IMessageSinkWithTypes`][IMessageSinkWithTypes]라는
테스트 발견, 실행 시작, 실패, 성공, 스킵 등의 이벤트를 메시지 형태로 받는
인터페이스를 클라이언트 코드에서 구현하여, 그런 이벤트가 일어났을 때
화면에 로그를 찍거나 해야 합니다. 저희 팀은 테스트를 병렬로 실행하지
않았기 때문에 클라이언트 코드만 더 길어지는 덜 자유로운 API가
답답했습니다. 🙄


Unity로 <abbr title="command-line interface">CLI</abbr> 프로그램 만들기
-----------------------------------------------------------------------

Unity로 테스트 실행기를 만드려고 할 때 가장 고민했던 점은, 처음부터
<abbr title="continuous integration">CI</abbr>에서 실행하기 위한 것이니 만큼
그래픽 화면이 아닌 <abbr title="command-line interface">CLI</abbr>로
조작되고 결과가 보여야 한다는 점이었습니다. 그런데 Unity는 게임 등을 만들기 위한
플랫폼으로, 과연 CLI 앱을 만드는 게 잘 될까 걱정이 앞섰습니다.

찾아보니 다행히 Unity에는 <dfn>헤드리스 모드</dfn>(headless mode)가 있어서,
이 모드에서는 그래픽 화면이 뜨지 않고 [`Debug.Log()`][Debug.Log] 메서드로
찍은 로그도 모두 [표준 출력][stdout]으로 출력된다는 것을 알게 됐습니다.

{{<
figure
  src="unity-build-settings.png"
  width="356"
  caption="헤드리스 모드를 켜는 Unity 빌드 설정의 <q>Server Build</q> 옵션"
>}}

Unity에서 제공되는 `Debug.Log()` 메서드를 쓰지 않더라도, 일반적인 애플리케이션을
만드는 것과 같이 .NET 표준에서 제공하는 [`Console`][Console] 클래스도
정상적으로 작동하는 것을 확인했습니다.

다만 `Main()` 메서드를 정의할 수 있는 것은 아니기 때문에, 명령행 인자는
`Main()` 메서드의 `string[] args` 인자로 받지 못하고, 대신
[`Environment.GetCommandLineArgs()`][GetCommandLineArgs] 메서드로
얻어야 했습니다. 마찬가지로 프로그램의 종료 역시 [`Application.Quit()`][Quit]
메서드를 명시적으로 호출하여 직접 프로세스를 중단시켜야 했습니다.

마지막으로, Unity 플레이어 자체에서 출력되는 메시지들이 있었지만, 이 출력을 막는
방법을 찾지 못했기 때문에 그대로 마무리할 수밖에 없었습니다.[^4]

{{<
figure
  src="noisy-output.png"
  width="739"
  caption="맨 처음과 마지막에 출력되는 Unity 플레이어 자체의 메시지는 결국 없애지 못했다."
>}}


빌드 자동화
-----------

Unity로 CLI 앱을 빌드하고 이를 윈도 뿐만 아니라 Linux나 macOS용으로도
만드는 방법을 문서로 써보니 그 과정이 까다롭고, 또 작업자에 따라 일정하지
않은 결과가 나오기 쉬워 보였습니다.  그래서 저장소에 태그를 만들어서 푸시하면
자동으로 Linux, macOS, Windows용 빌드가 나오도록 만들기로 했습니다.

본격적인 CI를 붙일까 하다가, 단순히 빌드만 나오면 되겠다는 생각에
[GitHub Actions]를 이용해 구성했습니다.

[가와이 요시후미(河合宜文) 씨가 쓴 글][5]을 참고하여, 모든 빌드 과정을 Docker
안쪽에서 진행할 수 있었습니다. 이 과정에서 다른 환경에서 겪어보지 못한 다음과 같은
것들을 겪기도 했습니다.

- Unity는 상용 제품이다보니, 라이선스 활성화 과정이 필요했습니다.

- Unity는 에디터와 플레이어의 경계가 다소 모호합니다. 에디터 환경에서
  실행될 코드도 스크립트로 만들 수 있는데, Unity가 앱을 빌드하게 하는
  스크립트를 그 앱의 일부로 포함시킨 뒤, 이를 실행하는 식으로 앱이
  스스로 빌드되게 만듭니다.

처음에는 세 운영체제를 위한 빌드를 만들기 위해서는 세 운영체제에서 각각
빌드를 해야 하나 생각했지만, 다행히도 Unity는 [크로스 컴파일][6]을
잘 지원하고 있어서, Linux에서 macOS 및 Windows용 빌드도 만들 수 있었습니다.

{{<
figure
  src="github-actions.png"
  width="823"
  caption="GitHub Actions에서 빌드가 되는 모습"
>}}


마무리
------

{{<
figure
  src="after.png"
  width="298"
  caption="Unity 환경에서의 테스트도 더해진 현재의 빌드"
>}}

이렇게 만들어진 Unity용 xUnit.net 테스트 실행기를 Libplanet 프로젝트의
빌드에 적용했고, 현재 잘 동작하고 있습니다. 잘 동작한다는 의미는,
과연 Unity 환경에서만 보이는 상이한 동작을 자주 밟아 테스트가 자주
깨지고 있다는 뜻입니다. 😇 물론, 그러한 버그를 최대한 일찍 발견하고 싶기
때문에 만든 것이므로 기꺼이 받아들이고 있습니다.

이렇게 만들어진 실행기는 코드가 깔끔하게 정리되지는 못했지만,
[GitHub에 오픈 소스로 올렸습니다.][7]
실행 파일은 [릴리스 페이지][8]에서 받을 수 있으니, 써보고 싶으신
분들은 받아서 이용해 보시기 바랍니다!

[Libplanet]: https://libplanet.io/
[리그레션]: https://en.wikipedia.org/wiki/Software_regression
[Azure Pipelines]: https://dev.azure.com/planetarium/libplanet/_build?definitionId=3
[Travis CI]: https://travis-ci.com/
[unity-mono]: https://github.com/Unity-Technologies/mono
[ZeroMQ]: http://zeromq.org/
[NetMQ]: https://github.com/zeromq/netmq
[NUnit]: https://nunit.org/
[xUnit.net]: https://xunit.net/
[xmldoc]: https://docs.microsoft.com/dotnet/csharp/programming-guide/xmldoc/
[IoC]: https://ko.wikipedia.org/wiki/%EC%A0%9C%EC%96%B4_%EB%B0%98%EC%A0%84
[IMessageSinkWithTypes]: https://github.com/xunit/xunit/blob/2.4.1/src/xunit.runner.utility/Messages/IMessageSinkWithTypes.cs
[Debug.Log]: https://docs.unity3d.com/ScriptReference/Debug.Log.html
[stdout]: https://ko.wikipedia.org/wiki/%ED%91%9C%EC%A4%80_%EC%8A%A4%ED%8A%B8%EB%A6%BC#%ED%91%9C%EC%A4%80_%EC%B6%9C%EB%A0%A5_(stdout)
[Console]: https://docs.microsoft.com/dotnet/api/system.console
[GetCommandLineArgs]: https://docs.microsoft.com/dotnet/api/system.environment.getcommandlineargs
[Quit]: https://docs.unity3d.com/ScriptReference/Application.Quit.html
[GitHub Actions]: https://github.com/features/actions
[5]: https://medium.com/@neuecc/using-circle-ci-to-build-test-make-unitypackage-on-unity-9f9fa2b3adfd
[6]: https://ko.wikipedia.org/wiki/%ED%81%AC%EB%A1%9C%EC%8A%A4_%EC%BB%B4%ED%8C%8C%EC%9D%BC%EB%9F%AC
[7]: https://github.com/planetarium/xunit-unity-runner
[8]: https://github.com/planetarium/xunit-unity-runner/releases

[^1]: 2019년 6월 현재 Linux, macOS, Windows를 모두 지원하는 <abbr title="continuous integration">CI</abbr> 서비스로는 [Travis CI]와 Azure Pipelines가 있습니다. 저희 팀은 처음에 Travis CI를 써왔지만 전체적으로 성능이 좋지 않아 이제는 Azure Pipelines를 쓰게 됐습니다.
[^2]: .NET Framework는 윈도만 지원하기 때문에, 실제로는 9개의 환경이 아닌 7개의 환경에서 테스트하게 됩니다.
[^3]: .NET은 오래 전부터 <abbr title="integrated development environment">IDE</abbr>가 보편화되었기 때문에 웹에 API 문서를 올려두지 않고, 그냥 소스 코드에 [XML 문서 주석][xmldoc]만 달아두는 프로젝트가 많습니다. 그렇게 달아 둔 문서는 IDE에서 클래스나 메서드가 자동 완성될 때 툴팁으로 작게 표시됩니다.
[^4]: 혹시 방법을 아시는 분이 있다면 알려주시기 바랍니다. 아니면 아예 풀 리퀘스트를 보내주셔도 좋습니다!

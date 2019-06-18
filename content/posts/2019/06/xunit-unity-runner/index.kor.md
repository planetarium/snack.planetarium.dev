---
title: Unity 환경에서 단위 테스트 돌리기
date: 2019-06-18
authors: [hong.minhee]

---

안녕하세요. 플라네타리움 개발팀에서 [Libplanet]을 만들고 있는 홍민희입니다.

Libplanet은 분산 P2P로 돌아가는 온라인 멀티플레이 게임을 만들 때,
그러한 게임들이 매번 구현해야 하는 P2P 통신이나 데이터 동기화 등의
문제를 푸는 공용 라이브러리입니다.

기민한 개선을 이루면서도 [리그레션]이나 코너 케이스에서
일어나기 쉬운 오작동을 최소화하려면 테스트 코드, 그 중에서도 단위 테스트의
도움이 필요합니다.  뿐만 아니라, Libplanet은 라이브러리이므로
이를 이용할 게임이나 앱이 어느 운영체제와 .NET 런타임에서 실행될
지 알기 어렵기 때문에, 가능한 다양한 환경에서 모든 테스트를 실행하는 게 좋습니다.

그래서 저희 팀은 Libplanet 저장소에 푸시나 풀 리퀘스트가 생길 때마다
[Azure Pipelines][^1]에서 (리눅스, 맥OS, 윈도) × (.NET Framework,
Mono, .NET Core) 조합[^2]으로 테스트가 돌게 해뒀었습니다.

{{< figure src="before.png" width="298" caption="매 빌드마다 테스트했던 환경의 조합">}}

처음에는 Unity가 Mono 런타임을 쓰기 때문에 이 정도로 충분하다고 생각했습니다.
그런데 Unity에서 Libplanet을 써서 게임을 만들다보니 게임에서만 예기치 못한 동작을
보는 일이 몇 번이나 겪게 되었고, 저희 팀은 Mono에서 테스트를 통과하는 것만으로는
Unity에서 잘 돌아간다고 믿기 힘들다는 생각이 점점 커졌습니다.

[실제로 Unity에서 쓰이는 Mono는 업스트림에 많은 패치가 더해진,
꽤 오랜 기간 유지되어 온 다운스트림인 것으로 보입니다.][3]
게다가 완전히 같은 Mono 런타임에서 테스트한다고 해도,
Unity 플레이어로 인해 생기는 특수한 조건들이 적지 않다는 정황이 자주 보였고,
그 모든 것들을 감안했을 때 Unity만을 위한 테스트 환경을 CI에 더해서
지속적으로 잘 돌아가는지 확인할 필요가 있다는 합의가 이뤄졌습니다.

Unity에서 제공되는 단위 테스트 기능이 있기 때문에, 처음에는 이를 쓰려고 했습니다.
그런데 Unity에서 제공되는 단위 테스트는 게이머가 실행하는 플레이어 환경이 아닌,
게임 개발자가 사용하는 에디터 환경에서 실행되는 방식이었고,
테스트 프레임워크도 [NUnit]만 지원하는 문제가 있었습니다.
[xUnit.net] 기반으로 만들어져 있는 Libplanet의 테스트 코드를 모두
NUnit 기반으로 바꿀까 하는 생각도 해봤지만 아무래도 분량이 적지 않고,
그렇게 긴 코드를 한 번에 바꾸다 보면 알아채기 힘든 실수도 분명
생길 게 뻔했습니다.

그래서 Unity로 게임 앱이 아닌 테스트 실행기 앱을 만들기로 했습니다.
다행히 xUnit.net은 테스트 작성을 위한 API와 테스트 실행을 위한 API가
잘 나뉘어 있었습니다. 아마도 GUI나 CLI 외에도 각종 IDE에 플러그인 형태로 붙는 등,
다양한 프론트엔드가 있기 때문에 자연스럽게 그런 API를 갖추게 된 것으로 보입니다.
실제로 NuGet에서 "xunit runner"로 검색하면 다양한 환경을 위한 xUnit.net
테스트 실행기가 나옵니다. 다만 한 가지 아쉬운 점은, 달리 API 문서가 있지 않기 때문에
xUnit.net의 소스 코드와 다른 테스트 실행기 소스 코드를 뒤져봐야 했다는 것입니다.

{{< figure src="after.png" width="298" caption="Unity 환경에서의 테스트도 더해진 현재의 빌드">}}

[Libplanet]: https://libplanet.io/
[리그레션]: https://en.wikipedia.org/wiki/Software_regression
[Azure Pipelines]: https://dev.azure.com/planetarium/libplanet/_build?definitionId=3
[3]: https://github.com/Unity-Technologies/mono
[NUnit]: https://nunit.org/
[xUnit.net]: https://xunit.net/

[^1]: 2019년 6월 현재 리눅스, 맥OS, 윈도를 모두 지원하는 CI 서비스로는 Travis CI와 Azure Pipelines가 있습니다. 저희 팀은 처음에 Travis CI를 써왔지만 전체적으로 성능이 좋지 않아 이제는 Azure Pipelines를 쓰게 됐습니다.
[^2]: .NET Framework는 윈도만 지원하기 때문에, 실제로는 9개의 환경이 아닌 7개의 환경에서 테스트하게 됩니다.

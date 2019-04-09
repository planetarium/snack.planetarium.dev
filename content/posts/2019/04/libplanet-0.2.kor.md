---
title: Libplanet 0.2 릴리스
date: 2019-04-09
authors: [hong.minhee]
---

안녕하세요. 지난주 저희 팀은 [Libplanet]의 두번째 마이너 버전[^1]인 [0.2 버전][2]을 릴리스했습니다.
여러 변화가 있었지만, 이 글에서는 몇 가지 주요 기능 추가 및 API 변경에 대해 다루겠습니다.

[Libplanet]: https://libplanet.io/
[^1]: 저희는 아직 메이저 릴리스를 한 적이 없습니다.
[2]: https://github.com/planetarium/libplanet/releases/tag/0.2.0


Libplanet 소개
--------------

이에 앞서, 이 블로그에 [Libplanet]을 소개한 적이 없으니 간략히 설명을 하고 넘어가겠습니다.

Libplanet은 분산 <abbr title="Peer-to-Peer">P2P</abbr>로 돌아가는 온라인
멀티플레이 게임을 만들 때, 그러한 게임들이 매번 구현해야 하는 P2P 통신이나
데이터 동기화 등의 문제를 푸는 공용 라이브러리입니다.

Libplanet은 널리 쓰이는 Unity 엔진과 함께 쓰일 것을 염두에 두고 만들어져,
현재 C# 언어로 개발되고 있습니다. 물론 Unity 엔진을 쓰지 않더라도 .NET 또는 Mono
플랫폼으로 구현된 게임이라면 쉽게 붙일 수 있도록, [.NET Standard 2.0][3]을 타깃하여
이식성을 확보하고 있습니다.

Libplanet의 또 다른 특징은, 프레임워크나 엔진이 아닌 라이브러리라는 점입니다.
엔진이나 프레임워크는 게임 프로세스의 진입점(`Main()` 메서드)과 주도권을 가져간 채
허용된 부분에 한해서 게임 프로그래머가 스크립팅할 수 있게 하는 데 반해,
Libplanet은 게임 프로세스를 선점하지 않으며 게임 프로그래머가 명시적으로
호출한 곳에서만 비간섭적으로 (unobtrusively) 동작합니다.
덕분에 Unity 같은 기성 게임 엔진과도 무리 없이 함께 쓸 수 있습니다.

Libplanet은 [NuGet]에 올라가 있으며, [API 문서][4]도 있습니다.

[3]: https://github.com/dotnet/standard/blob/master/docs/versions/netstandard2.0.md
[NuGet]: https://www.nuget.org/packages/Libplanet/
[4]: https://docs.libplanet.io/


<abbr title="Network Address Translation">NAT</abbr> 우회
--------------------------------------------------------

[첫 버전][5]부터도 P2P 통신은 됐지만, 피어는 모두 공인 IP를 갖고 있어야 했습니다.
즉, 공유기 뒤에 있는 피어와는 통신이 되지 않았기 때문에, 현실적으로는 쓰임이 제한적이었습니다.
이를 해결하는 것이 급선무였기 때문에 어떻게든 NAT를 우회하는 것이 0.2 로드맵에서 가장 중요했고,
우선은 조금 비효율적이어도 가장 많은 케이스를 커버하고자
<abbr title="Traversal Using Relays around NAT">TURN</abbr> 및
<abbr title="Session Traversal Utilities for NAT">STUN</abbr>이라 불리는
[RFC 5766] 및 [RFC 5389]를 구현했습니다. 이 과정에서 오픈 소스 C# 구현을 찾지 못해
스펙에서 필요한 부분들을 모두 직접 구현하는 수고를 같은 팀의 문성원 님이 해주셨습니다.
이 경험을 풀어서 쓴 〈[NAT를 넘어서 가자][6]〉라는 글도 읽어주시기 바랍니다!

[5]: https://github.com/planetarium/libplanet/releases/tag/0.1.0
[6]: {{< ref "nat_traversal_1.kor.md" >}}
[RFC 5766]: https://tools.ietf.org/html/rfc5766
[RFC 5389]: https://tools.ietf.org/html/rfc5389


좀 더 게임스러운 트랜잭션
-------------------------

[`Transaction<T>`][7]은 네트워크 구성원 사이에 데이터를 동기화하는 단위입니다.
Libplanet은 이전 버전까지는 비슷한 문제를 푸는 [비트코인] 같은 기존 기술을 참고했기 때문에,
모든 트랜잭션에 발신자와 수신자가 있다는 개념을 그대로 받아들였습니다.
비트코인은 송금을 다루므로 재화가 이동하기만 하며 복제되어선 안 됩니다.
따라서 보내는 사람이 있다면 받는 사람이 꼭 있어야 하며,
모든 트랜잭션에 발신자와 수신자가 있다는 개념이 자연스럽습니다.
하지만 게임에서는 캐릭터의 이동처럼 수신자 개념이 없는 행동이나,
광역기처럼 수신자가 둘 이상일 수 있는 행동도 자주 나타납니다.

이러한 상황을 더 자연스럽게 다룰 수 있도록,
이번 버전부터는 `Transaction<T>`의 `Sender`–`Recipient` 개념이 사라지고,
대신 [`Signer`][8]–[`UpdatedAddresses`][9] 개념이 그 자리를 갈음하게 되었습니다.

[7]: https://docs.libplanet.io/0.2.1/api/Libplanet.Tx.Transaction-1.html
[비트코인]: https://bitcoin.org/
[8]: https://docs.libplanet.io/0.2.1/api/Libplanet.Tx.Transaction-1.html#Libplanet_Tx_Transaction_1_Signer
[9]: https://docs.libplanet.io/0.2.1/api/Libplanet.Tx.Transaction-1.html#Libplanet_Tx_Transaction_1_UpdatedAddresses


새로운 상태 접근 API
--------------------

기존에는 모든 [`IAction`][10] 구현은 `Execute()` 메서드 안에서 접근할 계정의 주소 목록을
반드시 `RequestStates()` 메서드를 통해 제출해야 했습니다.
`Execute()` 메서드에서 미리 제출하지 않은 주소의 상태를 읽거나 쓰려고 하면 유효하지 않은
액션으로 취급됐습니다.

하지만 블록체인을 통해 공개 네트워크에서 공유된 상태들은 어차피 누구나 읽을 수 있기 때문에,
읽기의 제한은 큰 의미가 없으며 쓰기의 제한만 있으면 된다는 결론에 이르게 됐습니다.

또한, 기존에는 접근할 계정에 대한 정보가 `RequestStates()` 메서드와 `Execute()` 메서드
양쪽 코드에 중복되므로 버그가 나기 쉬운 구조였고, 조심한다고 하더라도 양쪽을 함께 고쳐야 하는
API도 매우 불편했습니다.

이러한 문제들을 두루 풀고자, 이번 버전부터는 `IAction` 인터페이스의 상태 접근 API가
크게 개선됐습니다. `RequestStates()` 메서드는 아예 사라졌으며,
[`IAction.Execute()`][11]의 인자로 들어온 [`IActionContext`][12] 객체의
[`PreviousStates`][13]가 일종의 "변경 기록" API를 제공하게 되었습니다.
이 변경 기록을 `Execute()` 메서드 안에서 쌓아 나간 뒤,
최종적으로 그 변경 기록을 반환하면 상태가 실제로 갱신됩니다.

또한, 트랜잭션이 만들어질 때 액션이 "리허설 모드"로 실행되는데,
이 리허설을 통해 `Execute()` 메서드가 상태를 갱신하려고 하는 주소의 목록을 얻어서
이 목록도 함께 트랜잭션에 포함되어 서명됩니다.
서명된 트랜잭션을 다른 노드가 받았을 때는, 트랜잭션을 서명한 당사자가 리허설을 통해
구한 주소 목록 이외의 계정 상태를 바꾸는 것이 차단됩니다.

[10]: https://docs.libplanet.io/0.2.1/api/Libplanet.Action.IAction.html
[11]: https://docs.libplanet.io/0.2.1/api/Libplanet.Action.IAction.html#Libplanet_Action_IAction_Execute_Libplanet_Action_IActionContext_
[12]: https://docs.libplanet.io/0.2.1/api/Libplanet.Action.IActionContext.html
[13]: https://docs.libplanet.io/0.2.1/api/Libplanet.Action.IActionContext.html#Libplanet_Action_IActionContext_PreviousStates


액션의 서브타입 다형성 분리
---------------------------

이전 버전까지는 게임마다 `IAction`을 구현한 추상 클래스를 정의하고,
이를 상속하는 여러 구체 클래스를 두는 것이 Libplanet이 상정한 유일한 이용법이었습니다.
그러나 게임에 따라 게임 내 액션의 종류를 `IAction` 수준에서 나누는 것보다,
`IAction`을 단 하나의 클래스로 구현하고 액션에 들어가는 데이터를 통해 동작을 세분화하는 방식이
더 적합한 경우도 있습니다. 또, 액션의 타입에 따라 동적으로 디스패치하는 방식은 내부적으로
[.NET의 리플렉션][14]을 써서 구현했기 때문에 이러한 것이 곤란한 프로젝트도 있을 수 있습니다.

그래서 이번 버전부터는 `Transaction<T>`의 `T`는 `IAction`을 구현할 뿐만 아니라 구체 클래스만을
받아들이게 됐습니다. 추상 클래스나 인터페이스는 `IAction`을 구현했다고 해도 받아들여지지 않으며,
구체 클래스 역시 서브타입의 존재는 완전히 무시되게 됩니다.

대신, 기존처럼 서브타입 다형성을 통해 액션의 동작을 세분화하고 싶다면,
[`PolymorphicAction<T>`][15]를 새로운 액션 데코레이터 구현을 쓰면 됩니다.
예를 들어 기존의 타입이 `Transaction<AbstractAction>`이었다면,
`Transaction<PolymorphicAction<AbstractAction>>` 타입으로 고쳐서 쓰면
대부분의 경우 기존대로 동작하게 됩니다.
물론, `PolymorphicAction<T>` 클래스는 내부적으로 .NET 리플렉션을 씁니다.

[14]: https://docs.microsoft.com/ko-kr/dotnet/framework/reflection-and-codedom/reflection
[15]: https://docs.libplanet.io/0.2.1/api/Libplanet.Action.PolymorphicAction-1.html


그 외
-----

그밖에도 여러 변화가 있었고, 자세한 것은 [전체 변경 내역][2]에서 확인할 수 있습니다.

참고로 *0.2.0* 버전이 릴리스된 뒤 이틀 뒤에 몇 가지 문제를 해결한 [*0.2.1*][15]이 릴리스되어,
현재 최신 버전은 *0.2.1*입니다.

호기심이 생기신 분들은 설치해서 이용해 보시고, 궁금한 점이 있으시다면 저희 팀이 상주해 있는
[디스코드 대화방][16]에 놀러오세요!

[15]: https://github.com/planetarium/libplanet/releases/tag/0.2.1
[16]: https://discord.gg/ue9fgc3

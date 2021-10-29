---
title: Libplanet 0.11–0.19 업데이트 요약
date: 2021-10-29
authors: [hong.minhee]
---

안녕하세요.  오랜만에 소식 전합니다.  [Libplanet][][^1]은 지난 몇 달 동안, 여러
마이너 버전을 릴리스했습니다.  그렇지만 저희의 릴리스 정책과 주기가 바뀜에 따라,
그리고 Libplanet으로 만들어진 첫 게임 〈[나인 크로니클]〉 메인넷의 여러 문제들에
대응하느라 차분히 그간의 업데이트를 정리된 글로 쓸 여유가 없었습니다.
그래서 이번 글에서 그 사이의 변화 중 큰 것들을 중심으로 소개해 볼까 합니다.

[^1]: Libplanet은 분산 P2P로 돌아가는 온라인 멀티플레이어 게임을 만들 때,
      매번 구현해야 하는 P2P 통신이나 데이터 동기화 등의 문제를 푸는
      공용 라이브러리입니다.

[Libplanet]: https://libplanet.io/
[나인 크로니클]: https://nine-chronicles.com/


달라진 릴리스 주기
------------------

이전까지 Libplanet은 릴리스 주기에 뚜렷한 규칙이 없었습니다.  주로 큰 API 변경이
있거나 마지막 릴리스 이후로 시간이 많이 지났을 때 그 동안의 변경을 모아서 새
버전 번호를 부여하는 것에 가까웠습니다.

그러나 지난해 〈[나인 크로니클]〉 메인넷 (이하 <q>메인넷</q>) 출범 이후,
메인넷의 크고 작은 문제들을 해결해 나가기 위해 Libplanet도 그에 발맞춘 잦은
릴리스가 이뤄져야 했습니다.  현재 플라네타리움의 Libplanet 팀과 〈나인 크로니클〉
팀은 긴밀히 협력하며 릴리스 주기를 맞추고 있습니다.  이러한 기조는 한동안 바뀌지
않을 것으로 보입니다.

그러한 방침 아래, 지난 몇 달 동안 릴리스된 Libplanet 버전으로는 올해 3월에 나온
0.11.0부터 금주에 나온 0.19.0까지 총 9번의 마이너 업데이트가 있습니다.

- [0.11.0] (3월 30일)
- [0.12.0] (7월 23일)
- [0.13.0] (7월 28일)
- [0.14.0] (8월 5일)
- [0.15.0] (8월 18일)
- [0.16.0] (8월 25일)
- [0.17.0] (9월 28일)
- [0.18.0] (10월 13일)
- [0.19.0] (10월 27일)

[0.11.0]: https://github.com/planetarium/libplanet/releases/tag/0.11.0
[0.12.0]: https://github.com/planetarium/libplanet/releases/tag/0.12.0
[0.13.0]: https://github.com/planetarium/libplanet/releases/tag/0.13.0
[0.14.0]: https://github.com/planetarium/libplanet/releases/tag/0.14.0
[0.15.0]: https://github.com/planetarium/libplanet/releases/tag/0.15.0
[0.16.0]: https://github.com/planetarium/libplanet/releases/tag/0.16.0
[0.17.0]: https://github.com/planetarium/libplanet/releases/tag/0.17.0
[0.18.0]: https://github.com/planetarium/libplanet/releases/tag/0.18.0
[0.19.0]: https://github.com/planetarium/libplanet/releases/tag/0.19.0


프로토콜 버전
-------------

*[0.11.0] 버전에서 추가됨.*

프로토콜 버전은 블록에 붙는 속성으로, 해당 블록이 어떤 Libplanet 버전을 써서
마이닝됐는지 기록합니다.  프로토콜 버전은 Libplanet을 이용해 만들어진 게임이
Libplanet 버전을 쉽게 업그레이드할 수 있도록 도우며, 한편으로는 Libplanet 쪽에서
기존의 네트워크를 유지하면서도 기능을 추가할 수 있게 합니다.

API 측면에서는 [`Block<T>.ProtocolVersion` 속성][Block<T>.ProtocolVersion]으로
확인할 수 있으며, 32비트 정수형으로 표현됩니다.  표현되는 프로토콜 버전은
Libplanet의 패키지 버전과는 별개의 네트워크 프로토콜의 버전인데, 패키지 버전의
패치 릴리스는 프로토콜 버전이 올라갈 수 없고 반드시 마이너 및 메이저 릴리스할
때만 프로토콜 버전도 함께 증가됩니다.[^2]

[0.19.0] 버전 현재 프로토콜 버전은 2이고, 프로토콜 버전이 도입된 [0.11.0] 버전
미만에서 생성된 블록은 모두 프로토콜 버전 0으로 취급됩니다.

[^2]: 모든 메이저 및 마이너 릴리스가 프로토콜 버전을 증가시키는 것은 아닙니다.

[Block<T>.ProtocolVersion]: https://docs.libplanet.io/0.19.0/api/Libplanet.Blocks.Block-1.html#Libplanet_Blocks_Block_1_ProtocolVersion


네트워크 트랜스포트 레이어
--------------------------

*[0.11.0] 버전에서 추가됨.*

오랫동안 Libplanet은 네트워크 통신에 있어 많은 저수준 처리를 [ZeroMQ]의
.NET 구현인 [NetMQ]에 맡겨 왔습니다.  하지만 모바일이나 웹 등 여러 플랫폼에서도
Libplanet을 쓸 수 있도록, NetMQ에 의존하지 않고도 네트워크 통신이 가능하게
바뀔 필요가 있었습니다.

네트워크 트랜스포트 레이어는 저수준 통신 방식을 다양화하고, 특수한 요구사항이
있을 경우 게임 개발자도 직접 저수준 통신 방식을 정의하여 쓸 수 있도록 추가된
실험적인 추상화 계층입니다.

API 측면에서는 [`ITransport` 인터페이스][ITransport]로 표현되며, 이를 구현한
[`NetMQTransport` 클래스][NetMQTransport]가 기본 제공됩니다.

시범 단계이기에 인터페이스는 현재 여러 마이너 릴리스에 걸쳐 조정되고 있으며,
아직 게임 개발자가 직접 정의한 트랜스포트 구현을 사용할 수는 없습니다.
연내에는 `NetMQTransport`를 대체할 [새로운 TCP 기반 트랜스포트][TcpTransport]
구현과 함께 [`Swarm<T>`][Swarm<T>] 객체가 사용자 정의 트랜스포트를 쓰도록 설정
가능해질 예정입니다.

[ZeroMQ]: https://zeromq.org/
[NetMQ]: https://github.com/zeromq/netmq
[ITransport]: https://docs.libplanet.io/0.19.0/api/Libplanet.Net.Transports.ITransport.html
[NetMQTransport]: https://docs.libplanet.io/0.19.0/api/Libplanet.Net.Transports.NetMQTransport.html
[TcpTransport]: https://github.com/planetarium/libplanet/pull/1523
[Swarm<T>]: https://docs.libplanet.io/0.19.0/api/Libplanet.Net.Swarm-1.html


교체 가능한 작업 증명 해시 알고리즘
-----------------------------------

*[0.12.0] 버전에서 추가됨.*

이전까지 Libplanet은 작업 증명에 [SHA-256] 해시 알고리즘을 써 왔습니다.
그러나 0.12.0 버전부터는 네트워크마다 [`IBlockPolicy<T>.GetHashAlgorithm()`
메서드][IBlockPolicy<T>.GetHashAlgorithm]를 정의하여 해시 알고리즘을 선택할
수 있게 됐습니다.  네트워크마다 다르게 할 수 있을 뿐만 아니라 블록 인덱스에
따라 다른 해시 알고리즘을 쓸 수도 있기 때문에, 네트워크 출범 이후에도 다른 해시
알고리즘으로 쉽게 이행할 수 있습니다.

.NET 런타임에 정의된 [`HashAlgorithm` 추상 클래스][HashAlgorithm]의
서브클래스라면 모두 해시 알고리즘으로 사용할 수 있습니다.  서브클래스는 꼭
.NET 런타임에서 제공하는 것으로 국한되지 않으며, 사용자가 직접 상속 받아
구현하거나 NuGet 등으로 제공되는 서드파티 라이브러리에서 정의한 것도
쓸 수 있습니다.  이를테면 플라네타리움에서 직접 만든 RandomX의 .NET 바인딩
라이브러리인 [RandomXSharp] 역시 `HashAlgorithm`의 서브클래스를 제공합니다.

다음 코드는 1만번째 블록까지는 SHA-256을 쓰고 그 뒤부터는 SHA-512를 쓰도록
블록체인 정책을 설정하는 예입니다.

~~~~ csharp
HashAlgorithmType GetHashAlgorithm(long index) =>
    index <= 10_000
        ? HashAlgorithmType.Of<SHA256>()
        : HashAlgorithmType.Of<SHA512>();
~~~~

[SHA-256]: https://ko.wikipedia.org/wiki/SHA-2
[IBlockPolicy<T>.GetHashAlgorithm]: https://docs.libplanet.io/0.19.0/api/Libplanet.Blockchain.Policies.IBlockPolicy-1.html#Libplanet_Blockchain_Policies_IBlockPolicy_1_GetHashAlgorithm_System_Int64_
[HashAlgorithm]: https://docs.microsoft.com/en-us/dotnet/api/system.security.cryptography.hashalgorithm
[RandomXSharp]: https://github.com/planetarium/RandomXSharp


논블로킹 렌더러
---------------

*[0.14.0] 버전에서 추가됨.*

노드의 로컬 블록체인의 상태가 변화를 이벤트로 수신할 수 있는
[`IRenderer<T>`][IRenderer<T>] 및 [`IActionRenderer<T>`][IActionRenderer<T>]
인터페이스는 별도의 스레드를 만들지 않는 대신 렌더링 로직이 블로킹으로
동작합니다.  이를테면, 렌더링 로직이 `Thread.Sleep(60_000)`을 호출한다면
블록체인의 다음 상태 변화는 60초의 렌더링을 기다린 뒤에 이뤄진다는 것입니다.

0.14.0 버전부터는 시간이 소요되는 렌더링 로직을 별도 스레드에서 논블로킹
방식으로 실행할 수 있게 해주는 [`NonblockRenderer<T>`][NonblockRenderer<T>] 및
[`NonblockActionRenderer<T>`][NonblockActionRenderer<T>] 데코레이터 클래스가
도입됐습니다.  두 클래스는 생성자에서 다른 렌더러를 인자로 받아, 해당 렌더러의
이벤트 핸들러를 별도 스레드에서 호출합니다.  따라서 기존의 렌더러 구현을 한 번
감싸는 것만으로 논블로킹 방식으로 전환할 수 있습니다.

논블로킹 방식이지만 내부적으로는 대기열이 존재하며, 따라서 이벤트의 순서는
보장됩니다.

[IRenderer<T>]: https://docs.libplanet.io/0.19.0/api/Libplanet.Blockchain.Renderers.IRenderer-1.html
[IActionRenderer<T>]: https://docs.libplanet.io/0.19.0/api/Libplanet.Blockchain.Renderers.IActionRenderer-1.html
[NonblockRenderer<T>]: https://docs.libplanet.io/0.19.0/api/Libplanet.Blockchain.Renderers.NonblockRenderer-1.html
[NonblockActionRenderer<T>]: https://docs.libplanet.io/0.19.0/api/Libplanet.Blockchain.Renderers.NonblockActionRenderer-1.html


마이너가 설정 가능한 트랜잭션 선호 함수
---------------------------------------

*[0.17.0] 버전에서 추가됨.*

마이닝할 블록에 포함할 트랜잭션들은 [`IBlockPolicy<T>.ValidateNextBlockTx()`
서술 메서드][IBlockPolicy<T>.ValidateNextBlockTx]를 만족하기만 한다면,
프로토콜에서 정해진 우선순위는 없습니다.[^3]  그렇지만 아직 블록에 포함되지 않는
트랜잭션이 너무 많을 때는 한 블록에 너무 많은 트랜잭션을 다 넣을 수 없기 때문에,
어떤 트랜잭션을 이번 블록에 포함시키고 어떤 트랜잭션을 나중 블록으로 미룰지 줄을
세워야 합니다.

0.17.0 버전부터는 어떤 트랜잭션부터 블록에 넣을지 그 기준을 Libplanet이 임의로
정하는 대신 마이너가 정할 수 있게 됐습니다.  API 측면에서는
[`BlockChain<T>.MineBlock()` 메서드][BlockChain<T>.MineBlock]에
[`IComparer<Transaction<T>>` 타입][IComparer<T>]의 옵션 `txPriority`가
생겼습니다.


[^3]: 물론 같은 서명자의 트랜잭션들 사이에는
      [`Transaction<T>.Nonce`][Transaction<T>.Nonce]를 기준으로 정해지는 순서가
      있습니다.

[IBlockPolicy<T>.ValidateNextBlockTx]: https://docs.libplanet.io/0.19.0/api/Libplanet.Blockchain.Policies.IBlockPolicy-1.html#Libplanet_Blockchain_Policies_IBlockPolicy_1_ValidateNextBlockTx_Libplanet_Blockchain_BlockChain__0__Libplanet_Tx_Transaction__0__
[Transaction<T>.Nonce]: https://docs.libplanet.io/0.19.0/api/Libplanet.Tx.Transaction-1.html#Libplanet_Tx_Transaction_1_Nonce
[BlockChain<T>.MineBlock]: https://docs.libplanet.io/0.19.0/api/Libplanet.Blockchain.BlockChain-1.html#Libplanet_Blockchain_BlockChain_1_MineBlock_Libplanet_Crypto_PrivateKey_DateTimeOffset_System_Boolean_System_Int32_System_Int32_IComparer_Libplanet_Tx_Transaction__0___CancellationToken_
[IComparer<T>]: https://docs.microsoft.com/en-us/dotnet/api/system.collections.generic.icomparer-1


블록 서명
---------

*[0.18.0] 버전에서 추가됨.*

프로토콜 버전 2, Libplanet 버전 0.18.0부터 블록은 마이너의 비밀 키로 서명되며
블록에는 마이너의 주소 뿐만 아니라 공개 키가 포함됩니다.

API 측면에서는, 블록의 서명은 [`Block<T>.Signature` 속성][Block<T>.Signature]에
담기고 마이너의 공개 키는 [`Block<T>.PublicKey` 속성][Block<T>.PublicKey]에
담기게 됩니다.  프로토콜 버전 1 및 0의 블록에서는 두 속성이 모두 `null`로
비어 있습니다.

[Block<T>.Signature]: https://docs.libplanet.io/0.19.0/api/Libplanet.Blocks.Block-1.html#Libplanet_Blocks_Block_1_Signature
[Block<T>.PublicKey]: https://docs.libplanet.io/0.19.0/api/Libplanet.Blocks.Block-1.html#Libplanet_Blocks_Block_1_PublicKey


병렬 프로세스 마이닝
--------------------

*[0.19.0] 버전에서 추가됨.*

Libplanet 0.19.0 버전부터는 블록 마이닝이 자동으로 해당 기기의 프로세서 코어
수에 따라 병렬로 수행됩니다.  마이너가 직접 활용할 프로세스 수를 조절하는
옵션은 추후 버전에서 추가될 예정입니다.


그 외
-----

그 외에도 수많은 기능이 더해졌을 뿐만 아니라, 몇 달 동안의 메인넷 운영에서
발생한 문제를 해결하며 많은 영역에서 크게 안정화 됐습니다.  자세한 내용은
각 버전의 [전체 변경 내역]에서 확인해 주세요.

호기심이 생기신 분들은 설치해서 이용해 보시고, 궁금한 점이 있으시다면 저희 팀이
상주해 있는 [디스코드]에도 놀러오세요!

[전체 변경 내역]: https://github.com/planetarium/libplanet/blob/0.19.0/CHANGES.md
[디스코드]: https://discord.gg/planetarium

---
title: Libplanet 0.8 릴리스
date: 2020-02-04
authors: [hong.minhee]
---

안녕하세요.
저희 팀은 [Libplanet]의 여덟 번째 마이너 버전인 [0.8 버전][0.8.0]을
릴리스했습니다.

Libplanet은 분산 P2P로 돌아가는 온라인 멀티플레이어 게임을 만들 때,
그러한 게임들이 매번 구현해야 하는 P2P 통신이나 데이터 동기화 등의 문제를 푸는
공용 라이브러리입니다.

거의 세 달 만의 새 버전인 만큼, 0.8 버전에서는 저장소 최적화를 비롯한 많은
개선이 있었습니다.
이 글에서는 0.8 버전의 주요 변경 사항들에 대해 다루겠습니다.

[Libplanet]: https://libplanet.io/
[0.8.0]: https://github.com/planetarium/libplanet/releases/tag/0.8.0


제너시스 블록 상정
------------------

`BlockChain<T>`는 이제 특정한 제너시스 블록을 상정하게 되었습니다.
이는 Libplanet으로 만든 여러 게임들이 서로 별개의 네트워크를 구성함에도,
Libplanet이 일종의 메타프로토콜로 동작하기에 엉뚱한 네트워크에 접속 시도를
하는 등의 실수를 방지하기 위해서 입니다.

[`BlockChain<T>()` 생성자][BlockChain{T}()]는 `Block<T>` 객체를 인자로 받으며,
해당 블록이 가장 첫 블록이 됩니다.  만약 `IStore`에 들어있는 제너시스 블록과
`BlockChain<T>()` 생성자가 기대하는 제너시스 블록이 일치하지 않을 경우
[`InvalidGenesisBlockException`][InvalidGenesisBlockException]이 일어나게
됩니다.

현재는 생성자가 제너시스 `Block<T>` 객체를 통째로 받지만,
[다음 버전에는 제너시스 블록 해시만 받고 실제 블록 내용은 네트워크의 다른
노드한테 받을 수도 있게 개선될 예정입니다.][#769]

[BlockChain{T}()]: https://docs.libplanet.io/0.8.0/api/Libplanet.Blockchain.BlockChain-1.html#Libplanet_Blockchain_BlockChain_1__ctor_Libplanet_Blockchain_Policies_IBlockPolicy__0__Libplanet_Store_IStore_Libplanet_Blocks_Block__0__
[InvalidGenesisBlockException]: https://docs.libplanet.io/0.8.0/api/Libplanet.Blocks.InvalidGenesisBlockException.html
[#769]: https://github.com/planetarium/libplanet/pull/769


[`DefaultStore`][DefaultStore] ← `LiteDBStore`
----------------------------------------------

내장 `IStore` 구현이었던 `LiteDBStore`가 사라지고 그 자리를
[`DefaultStore`][DefaultStore]가 대체했습니다.

이름이 바뀐 까닭은 더이상 LiteDB 파일 하나가 아닌,
여러 포맷이 섞인 파일들을 담는 디렉터리에 저장되게 바뀌었기 때문입니다.

또한, 1.0.0 릴리스 전까지 실험을 거듭하여 저장소 최적화를 할 예정으로,
이름에서 구현 세부 사항을 제거하는 의도도 있었습니다.

그 외에도 저장 공간을 줄이기 위한 [`DefaultStore()` 생성자][DefaultStore()]에는
`compress` 옵션이 생겼습니다.  이번 버전에서는 아직 기본적으로 꺼져 있지만,
다음 버전에서는 기본값이 `true`로 바뀔 예정입니다.

[DefaultStore]: https://docs.libplanet.io/master/api/Libplanet.Store.DefaultStore.html
[DefaultStore()]: https://docs.libplanet.io/master/api/Libplanet.Store.DefaultStore.html#Libplanet_Store_DefaultStore__ctor_System_String_System_Boolean_System_Boolean_System_Int32_System_Int32_System_Int32_System_Int32_System_Boolean_System_Boolean_


[`ICryptoBackend`][ICryptoBackend]
----------------------------------

Libplanet은 다양한 플랫폼에서도 쓸 수 있도록,
순수 C#으로 작성된 암호학 라이브러리인 [Bouncy Castle]을 써왔습니다.
그러나 순수 C# 구현은 이식성에서는 큰 장점이 되지만,
성능에서는 오히려 페널티로 작용합니다.

새 버전에서는 이식성과 성능 중 어느 쪽을 취할지 게임 제작자가 고를 수 있도록,
[`ICryptoBackend`][ICryptoBackend]라는 추상화 계층이 추가됐습니다.
기본 구현인 [`DefaultCryptoBackend`][DefaultCryptoBackend]는 여전히
내부적으로 Bouncy Castle에 의존하지만,
게임 제작자는 게임의 타깃 플랫폼에 따라 적절히 `ICryptoBackend` 인터페이스를
구현하여 성능 이점을 누릴 수 있습니다.

예를 들어, Libplanet이 `ICryptoBackend`를 구현한 `MyCryptoBackend` 클래스를
쓰게 하고 싶다면,
아래와 같이 [`CryptoConfig.CryptoBackend` 속성][CryptoConfig.CryptoBackend]를
덮어씌우면 됩니다.

~~~~ csharp
CryptoConfig.CryptoBackend = new MyCryptoBackend();
~~~~

저희 팀에서 만드는 게임인 [나인 크로니클]에서는 비트코인 프로젝트에서 공개한
[secp256k1] C 라이브러리를 호출하는 `ICryptoBackend` 인터페이스를 구현하여
게임 성능을 개선하기도 했습니다.

[Bouncy Castle]: http://www.bouncycastle.org/csharp/
[ICryptoBackend]: https://docs.libplanet.io/0.8.0/api/Libplanet.Crypto.ICryptoBackend.html
[DefaultCryptoBackend]: https://docs.libplanet.io/0.8.0/api/Libplanet.Crypto.DefaultCryptoBackend.html
[CryptoConfig.CryptoBackend]: https://docs.libplanet.io/0.8.0/api/Libplanet.Crypto.CryptoConfig.html#Libplanet_Crypto_CryptoConfig_CryptoBackend
[secp256k1]: https://github.com/bitcoin-core/secp256k1


문서 개선
---------

라이브러리 자체의 변경은 아니지만, [문서 웹사이트][docs]의 디자인에 개선이
있었고, 문성원 님이 작성하신 새로운 [개요][overview] 문서도 추가됐습니다.

[docs]: https://docs.libplanet.io/0.8.0/
[overview]: https://docs.libplanet.io/0.8.0/articles/overview.html


그 외
-----

그 밖에도, 세 달 남짓 Libplanet으로 만들고 있는 게임 [나인 크로니클]의
퍼블릭 테스트를 몇 차례 진행하며 발견한 많은 문제들을 바로잡느라 매우 다양한
변화가 있었습니다.  자세한 것은 [전체 변경 내역][0.8.0]에서 확인할 수 있습니다.

호기심이 생기신 분들은 설치해서 이용해 보시고, 궁금한 점이 있으시다면 저희 팀이
상주해 있는 [디스코드]에 놀러오세요!

[나인 크로니클]: https://nine-chronicles.com/
[디스코드]: https://discord.gg/planetarium

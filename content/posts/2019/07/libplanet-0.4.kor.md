---
title: Libplanet 0.4 릴리스
date: 2019-07-10
authors: [swen.mun]
---

안녕하세요. 저희 팀은 [Libplanet]의 네 번째 마이너 버전인 [0.4 버전][1]을 릴리스했습니다.

Libplanet은 분산 P2P로 돌아가는 온라인 멀티플레이어 게임을 만들 때, 그러한 게임들이 매번 구현해야 하는 P2P 통신이나 데이터 동기화 등의 문제를 푸는 공용 라이브러리입니다.

이 글에서는 0.4 버전의 주요 변경 사항에 대해 다루겠습니다.

[Libplanet]: https://libplanet.io/
[1]: https://github.com/planetarium/libplanet/releases/tag/0.4.0


`LiteDBStore` 추가
------------------

Libplanet은 저장 계층을 간추리기 위해 [`IStore`]라는 인터페이스와 이를 파일 기반으로 구현한 [`FileStore`]를 기본으로 제공합니다. 이 `FileStore`는 작은 규모의 게임에서 사용하기엔 충분했지만, 더 큰 규모의 게임에 적용해보니 다음과 같은 문제가 있었습니다.

- 모든 블록과 그 상태, 트랜잭션 그리고 계정의 주소 등이 각기 별도의 파일로 저장되는 방식이었기 때문에, 파일이 너무 많이 생겼습니다.
- 별도의 캐시나 버퍼가 없어 입출력 성능이 떨어졌습니다.

저희는 이런 문제를 해결하고자 별도의 스토리지 엔진을 사용하는 `IStore` 구현의 필요성을 검토하였고, 그 과정에서 선택한 것이 바로 [LiteDB]입니다. LiteDB는 순수 C#으로 작성되어 있어 .NET 환경에서 이식성이 뛰어나고, 전체 데이터를 단일 파일로 관리할 수 있기 때문에 관리가 쉽습니다.

이렇게 작성된 [`LiteDBStore`]는 `IStore`를 구현하기 때문에, 기존 `FileStore`에서 객체 초기화 방법을 제외하곤 완전히 같은 방법으로 사용할 수 있습니다.

[`IStore`]: https://docs.libplanet.io/0.4.0/api/Libplanet.Store.IStore.html
[`FileStore`]: https://docs.libplanet.io/0.4.0/api/Libplanet.Store.FileStore.html
[LiteDB]: https://www.litedb.org/
[`LiteDBStore`]: https://docs.libplanet.io/0.4.0/api/Libplanet.Store.LiteDBStore.html


간편한 트랜잭션 생성
-------------------

0.3 버전에 추가된 [`Transaction<T>.Nonce`]는 안전한 트랜잭션을 만들기 위한 중요한 장치였지만, 동시에 Libplanet을 사용하는 개발자에게는 골칫거리기도 했습니다. `Transaction<T>`를 만들기 위해서는 반드시 [`BlockChain<T>.GetNonce()`]를 통해 현재 서명하는 계정의 정확한 [논스]를 얻어와서 사용해야 했기 때문이죠. 이는 단순히 번거로운 절차일 뿐만 아니라, 트랜잭션을 언제 만드느냐에 따라 동시성 문제를 일으키기도 했습니다.

하지만 0.4 버전부터는 [`BlockChain<T>.MakeTransaction()`]를 통해 간편하면서 동시성 걱정 없이 트랜잭션을 만들 수 있습니다.

[`Transaction<T>.Nonce`]: https://docs.libplanet.io/0.3.0/api/Libplanet.Tx.Transaction-1.html#Libplanet_Tx_Transaction_1_Nonce
[`BlockChain<T>.GetNonce()`]: https://docs.libplanet.io/0.3.0/api/Libplanet.Blockchain.BlockChain-1.html#Libplanet_Blockchain_BlockChain_1_GetNonce_Libplanet_Address_
[`BlockChain<T>.MakeTransaction()`]: https://docs.libplanet.io/0.4.0/api/Libplanet.Blockchain.BlockChain-1.html#Libplanet_Blockchain_BlockChain_1_MakeTransaction_Libplanet_Crypto_PrivateKey_System_Collections_Generic_IEnumerable__0__System_Collections_Immutable_IImmutableSet_Libplanet_Address__System_Nullable_System_DateTimeOffset__System_Boolean_
[논스]: https://en.wikipedia.org/wiki/Cryptographic_nonce


트랜잭션 전파 자동화
--------------------

이전 버전까지의 Libplanet을 이용한 게임이 트랜잭션을 전파하기 위해선 [`Swarm.BroadcastTxs()`]를 직접 호출해야 했습니다. 그런데 네트워크 장애 등의 이유로 트랜잭션 전파에 실패할 수 있기 때문에, 게임 쪽에서 직접 재시도 로직을 구현해야 했었죠.

(여전히 `.BroadcastTxs()`를 쓸 수도 있지만) 게임은 이제 이를 직접 처리하지 않아도 됩니다. 그 대신에 `Swarm<T>`을 만들 때 자신의 체인을 넣고 그 체인에 (위에서 소개한 `BlockChain<T>.MakeTransaction()`을 사용해서) 트랜잭션을 만들기만 하면 되죠. 나머지는 전파 과정은 `Swarm<T>`가 알아서 수행합니다.

이 과정에서 `Swarm`이 직접 체인을 관리하기 때문에 `BlockChain<T>`처럼 타입 인자(`T`)를 가진 `Swarm<T>`으로 변경되었습니다.


[`Swarm.BroadcastTxs()`]: https://docs.libplanet.io/0.3.0/api/Libplanet.Net.Swarm.html#Libplanet_Net_Swarm_BroadcastTxs__1_System_Collections_Generic_IEnumerable_Libplanet_Tx_Transaction___0___


그 외
----

그 외의 여러 가지 변경 사항은 [전체 변경 내역][1]에서 확인하실 수 있습니다.

이번 변경 사항이나 Libplanet에 대해 궁금한 점이 있으시다면 언제든 저희 팀이 상주해 있는 [디스코드 대화방][2]에 놀러 오세요!

[2]: https://discord.gg/ue9fgc3

---
title: Libplanet 0.5 릴리스
date: 2019-08-22
authors: [dogeon.lee]
---

안녕하세요. 저희 팀은 [Libplanet]의 다섯 번째 마이너 버전인 [0.5 버전][1]을 릴리스했습니다.

Libplanet은 분산 P2P로 돌아가는 온라인 멀티플레이어 게임을 만들 때, 그러한 게임들이 매번 구현해야 하는 P2P 통신이나 데이터 동기화 등의 문제를 푸는 공용 라이브러리입니다.

이 글에서는 0.5 버전의 주요 변경 사항에 대해 다루겠습니다.

[Libplanet]: https://libplanet.io/


블록 액션
-------

체인을 안전하게 유지하기 위해서는 블록들을 채굴할 마이너들이 필요하고, 그러한 마이너들을 모으고 유지하기 위해 보상을 주어야 할 것입니다.
 
기존에는 마이너들에게 보상을 주기 위해선 직접 마이너가 블록에 리워드 액션을 가진 트랜잭션을 추가하게끔 했었지만 [0.5 버전][1] 부터는 `IAction`을 구현한 리워드 액션을 [`BlockPolicy<T>.BlockAction`]을 통해 넘겨줌으로써 블록을 생성한 마이너에게 보상을 주거나 어떠한 액션을 할 수 있습니다.

[`BlockPolicy<T>.BlockAction`]: https://docs.libplanet.io/0.5.0/api/Libplanet.Blockchain.Policies.BlockPolicy-1.html#Libplanet_Blockchain_Policies_BlockPolicy_1_BlockAction


`FileStore` 제거
---------------

Libplanet은 저장 계층을 간추리기 위해 [`IStore`]라는 인터페이스와 이를 파일 기반으로 구현한 [`FileStore`]를 비롯하여 [LiteDB]를 기반으로 구현한 [`LiteDBStore`]를 추가적으로 [0.4] 버전 부터 제공하고 있었습니다. 

- 모든 블록과 그 상태, 트랜잭션 그리고 계정의 주소 등이 각기 별도의 파일로 저장되는 방식이었기 때문에, 파일이 너무 많이 생겼습니다.
- 별도의 캐시나 버퍼가 없어 입출력 성능이 떨어졌습니다. 

LiteDB를 사용하기 시작하면서 FileStore의 사용빈도는 줄어들었고 [`FileStore`]를 지속적으로 관리하기는 어렵다고 판단하여 이번 0.5 버전 부터는 FileStore 구현체를 제공하지 않기로 결정하였습니다.

[0.4]: ../07/libplanet-0.4/
[`IStore`]: https://docs.libplanet.io/0.5.0/api/Libplanet.Store.IStore.html
[`FileStore`]: https://docs.libplanet.io/0.4.0/api/Libplanet.Store.FileStore.html
[LiteDB]: https://www.litedb.org/
[`LiteDBStore`]: https://docs.libplanet.io/0.5.0/api/Libplanet.Store.LiteDBStore.html


프리로드 프로그레스 전달
------------------

본래 프리로드를 위해 [`Swarm<T>.PreloadAsync`] 를 호출하게 되면 기다리는 동안  
내부적으로 얼마나 일이 진행되었는지 같은 정보는 로그를 통해 볼 수 밖에 없었습니다.

아무런 변화 없이 <q>로딩 중</q>과 같은 고정된 메시지를 긴시간 동안 보게 된다면  
게임을 플레이하는 유저 입장에서는 게임을 기다리는 시간이 매우 지루한 시간이 될 것입니다.

하지만 0.5 버전 부터는 첫번째 인자로 `IProgress<PreloadState>` 타입의 인자를 받음으로써  
현재 프리로드 진행상황을 전달받을 수 있도록 되었습니다.

[`PreloadState`]를 상속 받은 [`BlockDownloadState`], [`BlockStateDownloadState`],  
[`StateReferenceDownloadState`], [`ActionExecutionState`] 를 인자로 받은 progress 객체로 report 함으로써  
유저들에게 좀 더 유용한 정보를 제공할 수 있게 되었습니다.

[`Swarm<T>.PreloadAsync`]: https://docs.libplanet.io/0.5.0/api/Libplanet.Net.Swarm-1.html#Libplanet_Net_Swarm_1_PreloadAsync_System_IProgress_Libplanet_Net_PreloadState__System_Collections_Immutable_IImmutableSet_Libplanet_Address__System_Threading_CancellationToken_
[`PreloadState`]: https://docs.libplanet.io/0.5.0/api/Libplanet.Net.PreloadState.html
[`BlockDownloadState`]: https://docs.libplanet.io/0.5.0/api/Libplanet.Net.BlockDownloadState.html
[`BlockStateDownloadState`]: https://docs.libplanet.io/0.5.0/api/Libplanet.Net.BlockStateDownloadState.html
[`StateReferenceDownloadState`]: https://docs.libplanet.io/0.5.0/api/Libplanet.Net.StateReferenceDownloadState.html
[`ActionExecutionState`]: https://docs.libplanet.io/0.5.0/api/Libplanet.Net.ActionExecutionState.html


IBD 속도 개선
-----------

이전까지의 [IBD] 과정은 굉장히 오래 걸리는 작업이었습니다. recentStates나 blockStates 같은 값을 모두 스스로 연산하여 얻었어야 했었기 때문이죠.

하지만 신뢰할 수 있는 노드가 있다면 그 노드로 부터 미리 연산 되어있는 값들을 받아와도 무방할 것입니다. 그리고 연산에 드는 시간 효과적으로 줄일 수 있을 것입니다.

그래서 0.5 버전 부터는 [`Swarm<T>.PreloadAsync`]에 신뢰할 수 있는 노드들을 [`trustedStateValidators`] 인자로 넘겨주어 신뢰할 수 있는 노드들로 부터 이미 연산되어 있는 recentStates 및 blockStates 들을 받아와 저장, 사용합니다.

만약 신뢰할 수 있는 노드들이 없거나 다른 이유로 그 과정에 실패했을 때에는 기존과 같이 직접 연산해서 사용합니다.

[IBD]: https://bitcoin.org/en/glossary/initial-block-download


그 외
----

그 외의 여러 가지 변경 사항은 [전체 변경 내역][1]에서 확인하실 수 있습니다.

이번 변경 사항이나 Libplanet에 대해 궁금한 점이 있으시다면 언제든 저희 팀이 상주해 있는 [디스코드 대화방]에 놀러 오세요!


[1]: https://github.com/planetarium/libplanet/releases/tag/0.5.0
[디스코드 대화방]: https://discord.gg/ue9fgc3

---
title: Libplanet 0.5 릴리스
date: 2019-09-06
authors: [dogeon.lee]
---

안녕하세요. 저희 팀은 [Libplanet]의 다섯 번째 마이너 버전인 [0.5 버전][1]을 릴리스했습니다.

Libplanet은 분산 P2P로 돌아가는 온라인 멀티플레이어 게임을 만들 때, 그러한 게임들이 매번 구현해야 하는 P2P 통신이나 데이터 동기화 등의 문제를 푸는 공용 라이브러리입니다.

0.5 버전에서는 Libplanet과 함께 만들고 있는 게임의 테스트 과정에서 광범위한 성능 및 안정성 개선이 있었습니다. 이 글에서는 그러한 0.5 버전의 주요 변경 사항들에 대해 다루겠습니다.

[Libplanet]: https://libplanet.io/

<abbr title="Initial Block Download">IBD</abbr> 속도 개선
-------------------------------------------------------

이전까지의 [<abbr title="initial block download, 밀린 블록 다운로드">IBD</abbr>][IBD]는 블록이 조금만 많이 쌓여도 굉장히 오래 걸리는 작업이었습니다. 블록들을 다운받은 후 최종 상태를 첫 블록에서부터 스스로 연산하여 얻었어야 했었기 때문이죠.

하지만 신뢰할 수 있는 노드가 있다면 그 노드로부터 미리 연산돼 있는 결과를 받아와 연산에 드는 시간 효과적으로 줄일 수도 있을 것입니다.

그래서 0.5 버전 부터는 [`Swarm<T>.PreloadAsync()`]에 신뢰할 수 있는 노드들을 인자로 넘겨주어 신뢰할 수 있는 노드들로 부터 이미 연산되어 있는 최근 상태 값들을 받아와 저장, 사용할 수도 있게 되었습니다.  

만약 신뢰할 수 있는 노드들이 없거나 다른 이유로 그 과정에 실패했을 때에는 기존과 같이 직접 연산해서 사용합니다.
[IBD]: https://bitcoin.org/en/glossary/initial-block-download
[`Swarm<T>.PreloadAsync()`]: https://docs.libplanet.io/0.5.0/api/Libplanet.Net.Swarm-1.html#Libplanet_Net_Swarm_1_PreloadAsync_System_IProgress_Libplanet_Net_PreloadState__System_Collections_Immutable_IImmutableSet_Libplanet_Address__System_Threading_CancellationToken_


`IRandom.NextDouble()` 제거
------------------------

[`System.Double`의 .NET Standard 공식 문서][official-docs]의 일부를 인용하면 다음과 같은 내용을 볼 수 있습니다.

> 또한, `Double` 값의 산술 연산 및 대입 결과는 `Double` 타입의 정밀도 유실 때문에 플랫폼에 따라 다소 달라질 수 있습니다. 예를 들어, `Double` 값 리터럴을 대입한 결과는 32 비트와 64 비트 버전의 .NET 프레임워크에서 서로 다를 수 있습니다.

위와 같이 Double의 산술 연산 및 대입은 결정적이지 않은 결과를 유발할 수 있습니다. 이 때문에 0.5 버전 부터는 [`IRandom.NextDouble()`]을 제공하지 않기로 결정하였습니다.

이에 관한 자세한 내용은 [이 글][floating-point-determinism]을 참고하시기 바랍니다.

[`IRandom.NextDouble()`]: https://github.com/planetarium/libplanet/pull/419
[official-docs]: https://docs.microsoft.com/en-us/dotnet/api/system.double?view=netstandard-2.0#remarks
[floating-point-determinism]: https://randomascii.wordpress.com/2013/07/16/floating-point-determinism/


블록 액션
-------

체인을 안전하게 유지하기 위해서는 블록들을 채굴할 마이너들이 필요하고, 그러한 마이너들을 모으고 유지하기 위해 보상을 주어야 할 것입니다.
 
기존에는 마이너들에게 보상을 주기 위해선 직접 마이너가 블록에 리워드 액션을 가진 트랜잭션을 스스로 추가해야 했었지만, 이번 버전부터는 매 블록마다 실행되는 [`BlockPolicy<T>.BlockAction`] 속성이 생겨 이 블록 액션을 통해 마이너에게 보상금을 주는 코드를 구현할 수 있습니다.

[`BlockPolicy<T>.BlockAction`]: https://docs.libplanet.io/0.5.0/api/Libplanet.Blockchain.Policies.BlockPolicy-1.html#Libplanet_Blockchain_Policies_BlockPolicy_1_BlockAction


`FileStore` 제거
---------------

Libplanet은 저장 계층을 간추리기 위해 [`IStore`]라는 인터페이스와 이를 파일 기반으로 구현한 [`FileStore`]를 비롯하여 [LiteDB]를 기반으로 구현한 [`LiteDBStore`]를 추가적으로 [0.4] 버전 부터 제공하고 있었습니다.  그러나 `FileStore`는 구현이 내부 구현이 간소하다는 장점에도 불구하고 다음과 같은 한계점도 있었습니다.

- 모든 블록과 트랜잭션 그리고 계정의 매 블록마다의 상태 등이 각기 별도의 파일로 저장되는 방식이었기 때문에, 파일이 너무 많이 생겼습니다.
- 별도의 캐시나 버퍼가 없어서 어떤 물리 저장 장치를 쓰느냐에 따라 입출력 성능이 크게 영향을 받았습니다.

LiteDB를 사용하기 시작하면서 `FileStore`의 사용 빈도는 줄어들었고, 그에 비해 `FileStore`를 지속적으로 관리하기는 어렵다고 판단, 이번 0.5 버전부터는 `FileStore` 구현체를 제공하지 않기로 결정하였습니다.

[0.4]: {{< ref "../07/libplanet-0.4" >}}
[`IStore`]: https://docs.libplanet.io/0.5.0/api/Libplanet.Store.IStore.html
[`FileStore`]: https://docs.libplanet.io/0.4.0/api/Libplanet.Store.FileStore.html
[LiteDB]: https://www.litedb.org/
[`LiteDBStore`]: https://docs.libplanet.io/0.5.0/api/Libplanet.Store.LiteDBStore.html


좀 더 상세한 프리로드 진행 상황 전달
---------------------------

위에서 언급했던 IBD 과정을 수행하기 위해서는 [`Swarm<T>.PreloadAsync()`] 메서드를 호출 할 수 있습니다. 이 메서드의 인자로 `IProgress<BlockDownloadState>`를 전달하면 이를 통해 블록 다운로드 진행 상황을 알 수 있었지만, 블록 다운로드 이후 액션들을 실행하여 (또는 신뢰할 수 있는 노드로부터) 최종 상태를 구하는 작업의 진척 상황은 알려주지 않았습니다.  
이로 인해 블록을 모두 다운로드 받은 이후 로딩 메시지에는 <q>100%</q>라고 보여줌에도 불구하고 여전히 아무런 변화 없이 <q>로딩 중</q>과 같은 고정된 메시지를 얼마간 동안 보게 된다면, 게임을 플레이하는 유저 입장에서는 기다리는 시간이 매우 지루하게 느껴질 것입니다.

하지만 0.5 버전부터는 `IProgress<BlockDownloadState>` 대신 `IProgress<PreloadState>` 타입의 인자를 받음으로써 프리로드 전반의 진행 상황을 세부적으로 전달받을 수 있도록 되었습니다.

[`PreloadState`]를 상속 받은 [`BlockDownloadState`], [`BlockStateDownloadState`],  
[`StateReferenceDownloadState`], [`ActionExecutionState`]를 인자로 받은 `IProgress<PreloadState>` 객체를 통해 알림으로써 이용자에게 더 자세한 정보를 제공할 수 있습니다.

[`Swarm<T>.PreloadAsync()`]: https://docs.libplanet.io/0.5.0/api/Libplanet.Net.Swarm-1.html#Libplanet_Net_Swarm_1_PreloadAsync_System_IProgress_Libplanet_Net_PreloadState__System_Collections_Immutable_IImmutableSet_Libplanet_Address__System_Threading_CancellationToken_
[`RecentStates`]: https://github.com/planetarium/libplanet/blob/master/Libplanet/Net/Messages/RecentStates.cs
[`PreloadState`]: https://docs.libplanet.io/0.5.0/api/Libplanet.Net.PreloadState.html
[`BlockDownloadState`]: https://docs.libplanet.io/0.5.0/api/Libplanet.Net.BlockDownloadState.html
[`BlockStateDownloadState`]: https://docs.libplanet.io/0.5.0/api/Libplanet.Net.BlockStateDownloadState.html
[`StateReferenceDownloadState`]: https://docs.libplanet.io/0.5.0/api/Libplanet.Net.StateReferenceDownloadState.html
[`ActionExecutionState`]: https://docs.libplanet.io/0.5.0/api/Libplanet.Net.ActionExecutionState.html


그 외
----

그 외의 여러 가지 변경 사항은 [전체 변경 내역][1]에서 확인하실 수 있습니다.

이번 변경 사항이나 Libplanet에 대해 궁금한 점이 있으시다면 언제든 저희 팀이 상주해 있는 [디스코드 대화방]에 놀러 오세요!


[1]: https://github.com/planetarium/libplanet/releases/tag/0.5.2
[디스코드 대화방]: https://discord.gg/ue9fgc3

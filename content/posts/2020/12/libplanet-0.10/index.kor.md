---
title: Libplanet 0.10 릴리스
date: 2020-12-04
authors: [suho.lee]
---

안녕하세요.  [Libplanet]의 열 번째 마이너 버전인 [0.10 버전][0.10.0]이
릴리스되었습니다.

Libplanet은 분산 P2P로 돌아가는 온라인 멀티플레이어 게임을 만들 때,
그러한 게임들이 매번 구현해야 하는 P2P 통신이나 데이터 동기화 등의 문제를 푸는
공용 라이브러리입니다.

이번 버전부터 Libplanet은 상태를 관리하기 위해 [Merkle Patricia Trie(MPT)][MPT]를
사용하고, 자산 관리를 위한 별도의 API가 추가되는 등, 여기서 소개하는 내용 이외에도
인터페이스 내외로 많은 변경점이 있었습니다.

이 글에서는 0.10 버전의 주요 변경 사항들에 대해서 다루겠습니다.

[Libplanet]: https://libplanet.io/
[0.10.0]: https://github.com/planetarium/libplanet/releases/tag/0.10.0
[MPT]: https://eth.wiki/en/fundamentals/patricia-tree 

[Block<T>.PreEvaluationHash]
---------------------------

그동안 [`Block<T>`] 는 해당 블록이 가지고 있는 상태에 대한 정보를 따로 들고 있지 않았습니다.
따라서 상태에서 블록을 유도할 수는 있어도, 블록에서 상태의 정합성 등을 검증할 수 있는 방법은
오직 액션을 직접 실행하는 방법 뿐이었습니다. 하지만 이제 [`Block<T>.Hash`] 는 해당 블록에 대한 정보 뿐만 아니라, 
액션을 평가하고 나온 결과의 `Hash` 도 포함되어 유도됩니다. 이전과 같이 액션을 평가하지 않고 블록 정보만을 가진
`Hash` 는 `Block<T>.PreEvaluationHash` 로 저장됩니다.

[`Block<T>`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Blocks.Block-1.html
[Block<T>.PreEvaluationHash]: https://docs.libplanet.io/0.10.2/api/Libplanet.Blocks.Block-1.html#Libplanet_Blocks_Block_1_PreEvaluationHash
[`Block<T>.Hash`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Blocks.Block-1.html#Libplanet_Blocks_Block_1_Hash

[Block<T>.TotalDifficulty]
---------------------------

그동안은 블록체인의 정본(正本, Canonical chain)을 고르는 데 [`Block<T>.Index`]가 사용되었습니다.
하지만 이 방법은 리오그가 발생해도 블록 인덱스가 같은 경우가 자주 발생하여, 장기간 리오그가 일어나지 않다가
한 번에 깊은 리오그가 발생하는 일이 잦았습니다. 따라서 저희는 `Block<T>.TotalDifficulty` 를 정본을 고르는 기준으로
삼게 되었습니다.

[Block<T>.TotalDifficulty]: https://docs.libplanet.io/0.10.2/api/Libplanet.Blocks.Block-1.html#Libplanet_Blocks_Block_1_TotalDifficulty
[`Block<T>.Index`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Blocks.Block-1.html#Libplanet_Blocks_Block_1_Index 

[Merkle Patricia Trie (MPT)]
----------------------------

Merkle Patricia Trie (이하 MPT)는 Ethereum 등지에서 상태를 관리하는 데 사용되는 트리 구조입니다.
기존에는 상태를 저장하는 데 `BlockState` - `StateReference` 방식을 사용했었는데, 이 방식은 예전
상태를 조회할 때 비교적 비효율적인 방식으로 저장되고 있었습니다. 이제는 MPT 방식으로 상태를 저장하여
효율적인 방식으로 상태를 찾을 수 있게 하였습니다. 또한 `planet mpt` 명령어를 이용하여 블록 간 상태를
비교하거나, 특정 블록에서의 상태를 손쉽게 가져올 수 있게 되었습니다. 사용법은 `planet mpt --help` 를
참고해 주십시오.

[Merkle Patricia Trie (MPT)]: https://eth.wiki/en/fundamentals/patricia-tree 

자산을 위한 별도 상태 API
---------------------------

이제까지 Libplanet으로 게임을 만들 때 게임 내 재화는 다른 게임 내 상태와 같은 방식으로 다뤄졌습니다.
이를테면 나인 크로니클 골드는 정수 자료형의 값으로 구현되었습니다. 그러나 그러한 재화는 일반적으로
복제되거나 함부로 소멸되어서는 안 되는데, 사칙연산이 자유롭고 재화 특유의 성질을 내제하고 있지 않은
정수 자료형으로 재화를 구현하다 보면 버그가 끼어들기 쉬웠습니다. 예를 들어, 돈을 이체할 경우에도,
원래 소유자의 잔고는 줄이고 새 소유자의 잔고는 늘려야 하는데, 원래 소유자의 잔고에서 금액을 빼는 것을
빼먹거나 반대로 새 소유자의 잔고에 더하는 것을 빼먹는 버그가 들어갈 수 있었습니다. 혹은 돈을 여러 사람에게
분배할 때도, 나누어 떨어지지 않는 금액이 아무도 모르게 소멸되는 버그도 생기기 쉬웠습니다.
더 큰 수준의 버그도 일어나기 쉬웠는데, 이를테면 프로그래머가 별 신경을 쓰지 않고 게임의 보상으로 플레이어에
잔고에 돈을 더해주는 식의 코드만 짜도, 게임 전체의 경제상으로는 사실상 화폐를 사적으로 주조를 하는 것과 다름 없어집니다.

이러한 실수들을 일찍부터 방지하기 위해, 이번 버전에서는 자산만을 다루기 위한 별도의 상태 API가 생겼습니다.
기존의 [`BlockChain<T>.GetState()`] 메서드나 [`IAccountStateDelta.GetState()`] 메서드와 나란히 [`BlockChain<T>.GetBalance()`]
메서드나 [`IAccountStateDelta.GetBalance()`] 메서드가 생겼고, 자유롭게 덮어 쓸 수 있는 [`IAccountStateDelta.SetState()`] 메서드와
달리 이체를 위한 [`IAccountStateDelta.TransferAsset()`]과 주조를 위한 [`IAccountStateDelta.MintAsset()`]등 용도별 메서드가 생겼습니다.

또, 자산을 값으로 다룰 때도 .NET의 내장 정수 자료형을 쓰는 대신, Libplanet에 새롭게 더해진
[`FungibleAssetValue`] 자료형을 써야 합니다. `FungibleAssetValue`는 기본적으로 [`BigInteger`] 처럼 생겼지만,
몇 몇 부분에서 차이가 있습니다.

1. 나눗셈을 할 때 나머지 값을 암시적으로 버리지 않고, 항상 나머지를 명시적으로 다뤄야 합니다.
따라서 / 연산자를 구현하지 않고 [`DivRem()`] 메서드만 구현합니다.
2. 달러–센트 같이 하부 화폐 단위(minor currency units)를 지원하며, 하부 단위의 자릿수에 한계를 둡니다.
3. 서로 통화끼리는 섞이지 않도록, 각 값의 화폐 단위를 보존합니다.
마지막으로, 위의 3번을 구현하기 위해 화폐 단위를 정의하는 [`Currency`] 자료형이 생겼습니다.
해당 자료형은 화폐 단위의 명칭이나 티커 심볼, 하부 단위의 자릿수 등을 속성으로 갖습니다.

현재 자산 상태 API는 게임 머니 같은 변용성 자산(fungible assets)만 지원하지만, 추후 버전에서는 게임 아이템 같은 대체 불가 자산
[(Non-Fungible Token)][NFT]도 지원할 예정입니다.

[`BlockChain<T>.GetState()`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Blockchain.BlockChain-1.html#Libplanet_Blockchain_BlockChain_1_GetState_Libplanet_Address_System_Nullable_Libplanet_HashDigest_SHA256___Libplanet_Blockchain_StateCompleter__0__
[`IAccountStateDelta.GetState()`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Action.IAccountStateDelta.html#Libplanet_Action_IAccountStateDelta_GetState_Libplanet_Address_
[`BlockChain<T>.GetBalance()`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Blockchain.BlockChain-1.html#Libplanet_Blockchain_BlockChain_1_GetBalance_Libplanet_Address_Libplanet_Assets_Currency_System_Nullable_Libplanet_HashDigest_SHA256___Libplanet_Blockchain_FungibleAssetStateCompleter__0__
[`IAccountStateDelta.GetBalance()`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Action.IAccountStateDelta.html#Libplanet_Action_IAccountStateDelta_GetBalance_Libplanet_Address_Libplanet_Assets_Currency_
[`IAccountStateDelta.SetState()`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Action.IAccountStateDelta.html#Libplanet_Action_IAccountStateDelta_SetState_Libplanet_Address_IValue_
[`IAccountStateDelta.TransferAsset()`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Action.IAccountStateDelta.html#Libplanet_Action_IAccountStateDelta_SetState_Libplanet_Address_IValue_
[`IAccountStateDelta.MintAsset()`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Action.IAccountStateDelta.html#Libplanet_Action_IAccountStateDelta_MintAsset_Libplanet_Address_Libplanet_Assets_FungibleAssetValue_
[`FungibleAssetValue`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Assets.FungibleAssetValue.html
[`BigInteger`]: https://docs.microsoft.com/ko-kr/dotnet/api/system.numerics.biginteger?view=net-5.0
[`DivRem()`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Assets.FungibleAssetValue.html#Libplanet_Assets_FungibleAssetValue_DivRem_Libplanet_Assets_FungibleAssetValue_
[`Currency`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Assets.Currency.html
[NFT]: https://en.wikipedia.org/wiki/Non-fungible_token

새로운 렌더링 API
-------------------
기존에는 액션의 결과를 화면 등에 반영하기 위해 액션 클래스에 [`Render()`]  메서드를
구현해야 했습니다. 그러나 이러한 기존 API는 순수한 로직에 해당하는 액션 클래스에 뷰가 섞이게
만드는 문제가 있었습니다. 예를 들어 같은 블록체인에 대해 3D 게임 엔진을 탑재한 풀 게임 프론트엔드와,
간단한 알림 기능과 게임 내 자산만 보여주는 지갑 프론트엔드를 만드려고 하면, Render() 메서드에는
양쪽에 필요한 모든 코드가 들어가거나, 콜백을 전역 상태로 두고 이를 호출하는 패턴을 따르게 됩니다.
하나의 액션에 다양한 렌더링을 구현할 수 없기 때문입니다.

이를 해결하기 위해 새 버전부터는 [`IAction`] 인터페이스에 `Render()` 및 [`Unrender()`]
메서드가 사라지고, 대신 [`IRenderer<T>`] 및 그 서브타입인 [`IActionRenderer<T>`]
인터페이스가 새롭게 생겼습니다. 프론트엔드는 각자를 위한 IRenderer<T> 또는 IActionRenderer<T> 구현을 갖고,
이를 [`BlockChain<T>`] 객체 생성시에 연결하면 됩니다. 간단한 렌더링만이 필요할 때는 인터페이스를 구현하는
클래스를 직접 짜는 대신, [`AnonymousRenderer<T>`] 클래스를 써보는 것을 추천합니다.[^1]
또한, 새 렌더링 API는 [`IActionRenderer<T>.RenderActionError()`] 메서드를 통해 액션에서 난 예외를 다루거나,
[`IRenderer<T>.RenderBlock()`] 메서드를 통해 블록체인의 높이가 바뀐 것을 감지하거나, [`IRenderer<T>.RenderReorg()`]
메서드를 통해 리오그[^2]가 일어난 것을 감지할 수 있게 되었습니다. 렌더링 코드가 액션과 분리되어 렌더러라는 독립적인 단위가 된 덕에,
데코레이터 패턴을 통한 미들웨어 구조가 가능해졌습니다. 그 예로, 새 버전부터 제공되는 [`LoggedRenderer<T>`] 클래스는
다른 `IRenderer<T>` 구현을 감싸 어떤 렌더링 이벤트가 어떤 시점에 발생했는지를 로그로 남겨줍니다. 디버그할 때는
게임 렌더러를 `LoggedRenderer<T>`로 감싸서 실행하고, 실제 프로덕션에서는 감싸지 않고 게임 렌더러만을 쓰게 하는 식으로 활용 가능합니다.

[`Render()`]: https://docs.libplanet.io/0.9.2/api/Libplanet.Action.IAction.html#Libplanet_Action_IAction_Render_Libplanet_Action_IActionContext_Libplanet_Action_IAccountStateDelta_
[`Unrender()`]: https://docs.libplanet.io/0.9.2/api/Libplanet.Action.IAction.html#Libplanet_Action_IAction_Unrender_Libplanet_Action_IActionContext_Libplanet_Action_IAccountStateDelta_
[`IAction`]: https://docs.libplanet.io/0.9.2/api/Libplanet.Action.IAction.html
[`IRenderer<T>`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Blockchain.Renderers.IRenderer-1.html
[`IActionRenderer<T>`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Blockchain.Renderers.IActionRenderer-1.html
[`BlockChain<T>`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Blockchain.BlockChain-1.html
[`AnonymousRenderer<T>`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Blockchain.Renderers.AnonymousRenderer-1.html
[`IActionRenderer<T>.RenderActionError()`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Blockchain.Renderers.IActionRenderer-1.html#Libplanet_Blockchain_Renderers_IActionRenderer_1_RenderActionError_Libplanet_Action_IAction_Libplanet_Action_IActionContext_Exception_
[`IRenderer<T>.RenderBlock()`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Blockchain.Renderers.IRenderer-1.html#Libplanet_Blockchain_Renderers_IRenderer_1_RenderBlock_Libplanet_Blocks_Block__0__Libplanet_Blocks_Block__0__
[`IRenderer<T>.RenderReorg()`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Blockchain.Renderers.IRenderer-1.html#Libplanet_Blockchain_Renderers_IRenderer_1_RenderReorg_Libplanet_Blocks_Block__0__Libplanet_Blocks_Block__0__Libplanet_Blocks_Block__0__
[`LoggedRenderer<T>`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Blockchain.Renderers.LoggedRenderer-1.html
[^1]: Java와 달리 C#에는 익명 클래스가 없습니다.
[^2]: 리오그에 관해서는 김무훈 님의 지난 스낵 글 [〈탈중앙과 온라인 게임이 교차하다〉]({{< ref "../../10/decentralized-and-online-game-intersect/index.kor.md" >}})를 참고하세요.

지연 렌더러
----------
Libplanet은 현재 종국성(finality)이 없는 작업 증명(PoW) 방식을 쓰고 있어, 최근 블록들은 리오그가 일어나기 쉽습니다.
이 때문에 여러 암호화폐 지갑이나 거래소에서도 트랜잭션의 컨펌 수(number of confirmations) 표시를 흔히 접할 수 있습니다.
컨펌 수가 높을 수록 리오그가 일어날 개연성이 떨어지기 때문입니다. 게임 내 행동의 결과가 리오그로 인해 너무 자주 변동될 경우 너무 혼란스러우므로,
이를 완화하기 위해 지연 렌더러가 추가됐습니다. [`DelayedRenderer<T>`]는 `IRenderer<T>`를 입력으로 받으며 그 스스로도 `IRenderer<T>`를 구현하는 데코레이터로,
이름처럼 렌더링 이벤트를 다소 지연시키는 미들웨어입니다. 블록체인에 새 블록이 쌓여도 바로 관련된 이벤트를 발생시키는 대신, 잠시 기다린 뒤 설정한 컨펌 수를 만족하게 되는 순간 이벤트를 발생시킵니다.
나인 크로니클에서도 지연 렌더러를 쓰고 있으며, 컨펌 수는 플레이어가 설정 가능하게 옵션으로 제공하고 있습니다.[^3]

[`DelayedRenderer<T>`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Blockchain.Renderers.DelayedRenderer-1.html
[^3]: 현재 UI로 설정 가능하지는 않지만, 설정 파일을 직접 고칠 수 있습니다.

[정적 분석기]
------------
Libplanet에서 모든 블록체인 내 상태는 액션을 통해서만 변경될 수 있습니다. 이 액션은 각 노드마다 각자 실행하여 이전 상태로부터 새 상태를 도출하는데,
따라서 블록체인 네트워크의 모든 노드가 일관된 상태를 합의하려면, 액션은 반드시 결정적(deterministic)이어야 합니다.
그러나 아무리 어떠한 요소가 코드를 비결정적으로 만드는지 알고 있다고 하더라도, 복잡한 로직을 결정적으로 짜는 것은 쉽지 않습니다.
알고도 실수할 수 있고, 여러 사람들이 함께 만지다보면 각자 수정한 부분은 결정적으로 보여도 다 합쳐놓고 보니 비결정적으로 되기도 쉽습니다.
이러한 실수를 완화하기 위해, 새 버전부터는 Libplanet 액션 코드의 실수를 정적 분석으로 체크하는 Libplanet.Analyzers 패키지가 도입되었습니다.
이 정적 분석기는 저희가 실제로 나인 크로니클을 개발하면서 반복적으로 만났던 실수들을 토대로 흔한 잠재적 버그들을 미리 경고해 줍니다.
사용법은 아주 쉬운데, NuGet 패키지 의존성으로 추가하기만 하면 빌드할 때 C# 컴파일러 오류와 함께 경고로 출력됩니다.
다만, 아직 초기 버전이기 때문에, 아직 체크의 수가 다양하지 않고, 또 사람이 보기에는 명백하게 바른 코드인데도 잠재적 버그로 경고하는 경우가 여전히 많습니다.
이러한 부분들은 추후 버전에서 점진적으로 개선될 예정입니다.

[정적 분석기]: https://github.com/planetarium/libplanet/tree/main/Libplanet.Analyzershttps://github.com/planetarium/libplanet/tree/main/Libplanet.Analyzers

블록당 바이트 사이즈 및 트랜잭션 수 제한
---------------------------------------
이제까지 Libplanet은 한 블록의 용량이 아무리 크거나 트랜잭션이 아무리 많이 들어가도 이를 제한하지 않았습니다.
그렇지만 이러한 제한이 없을 경우 악의적 공격에 노출되기 쉽고, 아무도 악의적이지 않더라도 너무 많은 트랜잭션을 한 블록에 담으려다 보니
레이턴시가 지나치가 떨어지는 현상이 왕왕 발생했습니다.
이를 완화하기 위해, 새 버전에서는 [`IBlockPolicy<T>`] 인터페이스에서 [`GetMaxBlockBytes()`] 메서드 및 [`MaxTransactionsPerBlock`] 속성을 통해
블럭 하나에 최대 몇 바이트까지 차지할 수 있는지, 그리고 한 블럭에 최대 몇 개의 트랜잭션까지 수용할 수 있는지를 네트워크 단위로 설정 가능하게 됐습니다.
마이너는 블록을 만들 때 설정된 수를 초과하지 않는 선에서 알아서 트랜잭션들을 나눠 담게 되며, 악의적인 노드가 네트워크 설정을 초과하는 블록을
만들어서 전파하더라도 다른 노드들은 이 블록을 무효한 것으로 보게 됩니다.
네트워크나 애플리케이션에 따라 최적 설정이 달라질 수 있으므로, 설정 수치는 개발 단계에서 시범 네트워크를 운영해보며 조정하는 것이
바람직합니다.

[`IBlockPolicy<T>`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Blockchain.Policies.IBlockPolicy-1.html
[`GetMaxBlockBytes()`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Blockchain.Policies.IBlockPolicy-1.html#Libplanet_Blockchain_Policies_IBlockPolicy_1_GetMaxBlockBytes_System_Int64_
[`MaxTransactionsPerBlock`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Blockchain.Policies.IBlockPolicy-1.html#Libplanet_Blockchain_Policies_IBlockPolicy_1_MaxTransactionsPerBlock

그 외
----
그 외에도 여러 성능 개선이나 자잘한 마이너 패치가 있었습니다. [전체 변경 내용] 에서 확인해 주세요.

질문이나 관심이 있으신 분들은 또한 저희 [Discord] 채널에 놀러와 주세요!

[전체 변경 내용]: https://github.com/planetarium/libplanet/releases/tag/0.10.0
[Discord]: https://discord.gg/planetarium

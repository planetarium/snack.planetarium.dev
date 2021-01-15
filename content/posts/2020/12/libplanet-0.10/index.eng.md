---
title: Libplanet 0.10 Released
date: 2020-12-08
authors: [suho.lee]
translators: [kidon.seo]
---

Hello Everyone! We have released the tenth minor version of [Libplanet], [Version 0.10][0.10.0].

Libplanet is a common library that solves game implementation problems such as P2P communication and data synchronization when creating online multiplayer games that run on distributed P2P.

In this version, Libplanet has made many changes both inside and outside the interface, including the use of [<abbr title="Merkle–Patricia Trie">MPT</abbr>][MPT] to manage Libplanet's state and additional APIs for asset management.

This piece addresses key major changes in Version 0.10.

[Libplanet]: https://libplanet.io/
[0.10.0]: https://github.com/planetarium/libplanet/releases/tag/0.10.0
[MPT]: https://eth.wiki/en/fundamentals/patricia-tree 

Result State is Now Included in [`Block<T>.Hash`]
--------------------------------------------------

Until now, [`Block<T>`] did not have any information about the state of the block. And while you could derive the state from the block itself, the only way to verify the consistency of the block's state was to run the action directly. However, `Block<T>.Hash` is now derived not only with information about the block, but also with [`Block<T>.StateRootHash`], which is the hash value of the evaluated actions in the block. As before, the hash value without the evaluated actions is placed in the [`Block<T>.PreEvaluationHash`] property.

[`Block<T>`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Blocks.Block-1.html
[`Block<T>.PreEvaluationHash`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Blocks.Block-1.html#Libplanet_Blocks_Block_1_PreEvaluationHash
[`Block<T>.Hash`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Blocks.Block-1.html#Libplanet_Blocks_Block_1_Hash
[`Block<T>.StateRootHash`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Blocks.Block-1.html#Libplanet_Blocks_Block_1_StateRootHash

[`Block<T>.TotalDifficulty`]
------------------------------

Originally, the block height ([`Block<T>.Index`]) was the only criteria for selecting a canonical chain in the blockchain. However, since it is common for a network to have multiple blocks of the same height at a similar rate, agreements were often only made locally. This was due to the availability of multiple options to choose from when there are blocks with the same height. To fix this issue, the new version includes [`Block<T>.TotalDifficulty`] in the selection criteria to always have one option for the canonical chain. `Block<T>.TotalDifficulty` property is the difficulty level of all blocks from itself to the genesis block. This has also improved security to some level because you can't force your chain as canonical simply by quickly stacking low-difficulty blocks.


[`Block<T>.TotalDifficulty`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Blocks.Block-1.html#Libplanet_Blocks_Block_1_TotalDifficulty
[`Block<T>.Difficulty`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Blocks.Block-1.html#Libplanet_Blocks_Block_1_Difficulty
[`Block<T>.Index`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Blocks.Block-1.html#Libplanet_Blocks_Block_1_Index 

<abbr title="Merkle–Patricia Trie">MPT</abbr>
----------------------------------------------

<abbr title="Merkle–Patricia Trie">MPT</abbr> is a trie data structure used to store states in Ethereum, etc. Previously, the block state stored change in the global state on a block-by-block basis and it was retrieved by querying through an index called the state reference. This took a long time when looking up a state that had not been updated for a while. Now we can check the state much faster through the MPT structure.

And to help with debugging, the newly added `planet mpt` command makes it easy to compare the status between blocks, or import the status from a specific block. Please refer to the `planet mpt --help` option for instructions on how to use it.

Separate State API for Assets
------------------------------

So far, in-game goods have been treated in the same way as in-game states when creating games with Libplanet. For example, NCG (〈Nine Chronicles〉 Gold) is implemented as an integer data type value. Although such goods should never be replicated or destroyed carelessly, implementing them in a data type that is free of proprietary computation and doesn't necessarily hold the characteristics of the goods is prone to bugs.

For instance, when money is transferred, the sender's balance should be reduced and the recipient's balance should be increased. However, bugs that skip updating either the sender's or the recipient's balance could take place. Also, bugs that distribute the money to multiple people and bugs that unintentionally delete remaining amounts after division are possible.

And even more critically, when a programmer carelessly writes a code that just adds money to players' balance as a game reward, this could affect the game economy as a whole and is practically like casting money privately.

To prevent these issues early on, this version has a separate state API for primarily dealing with assets. The [`BlockChain<T>.GetBalance()`] and [`IAccountStateDelta.GetBalance()`] methods are created alongside the existing [`BlockChain<T>.GetState()`] and [`IAccountStateDelta.GetState()`] methods. And in addition to the [`IAccountStateDelta.SetState()`] method which can freely update states, [`IAccountStateDelta.TransferAsset()`] method for transferring assets and [`IAccountStateDelta.MintAsset()`] method for minting assets have been created.

Also, instead of using .NET's built-in integer data type, you need to use the new [`FungibleAssetValue`] data type added to Libplanet. `FungibleAssetValue` basically looks like a [`BigInteger`], but there are some differences.

1. In division, the remaining values are never implicitly discarded and are always treated explicitly.
Therefore, instead of implementing the division operator(`/`), only the [`DivRem()`] method is implemented.
2. It supports minor currency units, such as dollar–cent, and limits the number of digits in the lower unit.
3. It preserves the unit of currency of each value so that different currencies do not mix.
To implement No.3 above, the data type [`Currency`] is created to define the monetary unit. Its property includes the name of the currency unit, ticker symbol, and the number of digits in the lower unit.

Currently, asset state API only supports fungible assets such as game money, but it will also support Non-Fungible Assets([<abbr title="non-fungible token">NFT</abbr>][NFT]) such as game items in the future.

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

New Rendering API
-------------------
Previously, the action class had to implement the [`Render()`] method to reflect the result of the action on the screen. However, this previous API caused the view to mix into the action class that corresponded to pure logic.

For example, if you try to create a full game frontend with a 3D game engine and a wallet frontend that only shows simple notification and in-game assets based on the same blockchain, the `Render()` method either contains all the code required on both sides or follows the call pattern that places the callback in the global state. This is because a single action cannot implement various renderings.

To address this problem, the new version eliminates the `Render()` and [`Unrender()`] methods in the [`IAction`] interface, and instead introduces a new [`IRenderer<T>`] interface and its subtype [`IActionRenderer<T>`]. The frontend has its own implementation of `IRenderer<T>` or `IActionRenderer<T>`, and they can be connected at creation of the [`BlockChain<T>`] object.

When you only need a simple rendering, we recommend that you use the [`AnonymousRenderer<T>`] class instead of creating your own class that implements the interface.[^1]
Also, in the new rendering API, the [`IActionRenderer<T>.RenderActionError()`] method addresses exceptions from actions, the [`IRenderer<T>.RenderBlock()`] method detects the height change in the blockchain, and the [`IRenderer<T>.RenderReorg()`] method detects the occurrence of a reorg[^2]. The separation of the rendering code from the action into an independent unit called renderer allows middleware structure through decorator pattern. For example, the new version's [`LoggedRenderer<T>`] class wraps other `IRenderer<T>` implementations and logs which rendering events occurred at what point. When debugging, you can wrap the game renderer with `LoggedRenderer<T>` and take it out in the actual production.

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
[^1]: Unlike Java, C# doesn't have an anonymous class.
[^2]: For more information on reorg, refer to Muhun Kim's [〈Decentralization Intersects with Online Game]({{< ref "../../10/decentralized-and-online-game-intersect/index.eng.md" >}}).

Delayed Renderer
----------
Since Libplanet currently uses a proof-of-work(PoW) method without finality, recent blocks are prone to reorg. For this reason, many cryptocurrency wallets and exchanges often show transactions' number of confirmations because the higher the number of confirmations, the less likely a reorg occurs. In order to prevent confusion in the game due to frequent reorg in the blockchain, a delayed renderer has been added. [`DelayedRenderer<T>`] is a decorator that receives `IRenderer<T>` as an input and implements `IRenderer<T>` on its own, virtually acting as a middleware that delays rendering events. So instead of immediately generating related events when new blocks are stacked in the blockchain, the delayed renderer waits until it meets the number of confirmations you have set. [Nine Chronicles] also uses a delayed renderer, and the number of confirmations is available as an option for the player to set.[^3]

[`DelayedRenderer<T>`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Blockchain.Renderers.DelayedRenderer-1.html
[Nine Chronicles]: https://nine-chronicles.com/
[^3]: The number of confirmations currently can't be adjusted on the UI, but it can be changed directly in the configuration file.

[Static Analyzer]
------------------
In Libplanet, the state within all blockchain can only be changed through an action. Because actions are executed separately on each node to derive a new state from the previous state and all nodes need to agree on a consistent state, an action must be deterministic. However, despite knowing what makes the code non-deterministic, it's not that simple to make a complex logic deterministic. You can make mistakes knowingly, and especially when multiple people work on the code, each deterministic portion implemented by different people can easily be combined to derive a non-deterministic result.

To address this issue, the new version introduces [Libplanet.Analyzers Package], which checks for errors in the Libplanet action code through static analysis. This static analyzer alerts you in advance to potential bugs that are common, based on repeated mistakes we've made in developing Nine Chronicles. It's very easy to use, just add it as a NuGet package dependency and it will output as a warning along with a C# compiler error when built.

However, since it's still an early version, the number of checks is not diversified, and there are some potential bug warnings even though the code is written correctly. These will gradually be improved in future versions.

[Libplanet.Analyzers Package]: https://www.nuget.org/packages/Libplanet.Analyzers
[Static Analyzer]: https://github.com/planetarium/libplanet/tree/main/Libplanet.Analyzers

Byte Size and Number of Transactions per Block Limited
--------------------------------------------------------
Until now, Libplanet did not limit the block size or the number of transactions a block could take. Without this limitation, however, the network was open to malicious attacks and too many transactions contained in a single block often caused latency issues.

To address this issue, the new version allows the [`GetMaxBlockBytes()`] method and [`MaxTransactionsPerBlock`] properties in the [`IBlockPolicy<T>`] interface to provide network settings that limit the block size and the maximum number of transactions per block. When the miner creates a block, it takes in the number of transactions limited by the network, and even if a malicious node creates and propagates blocks that exceed the network settings, other nodes will see the block as invalid.

Since optimal settings may vary depending on the network or application, it is recommended to adjust the settings by operating a pilot network during the development phase.

[`IBlockPolicy<T>`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Blockchain.Policies.IBlockPolicy-1.html
[`GetMaxBlockBytes()`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Blockchain.Policies.IBlockPolicy-1.html#Libplanet_Blockchain_Policies_IBlockPolicy_1_GetMaxBlockBytes_System_Int64_
[`MaxTransactionsPerBlock`]: https://docs.libplanet.io/0.10.2/api/Libplanet.Blockchain.Policies.IBlockPolicy-1.html#Libplanet_Blockchain_Policies_IBlockPolicy_1_MaxTransactionsPerBlock

Furthermore
-------------
You can learn more about additional changes in our [release notes].

And as always, if you have any questions about the new release or Libplanet in general, please visit our [Discord chatroom][Discord] and let’s chat!

[release notes]: https://github.com/planetarium/libplanet/releases/tag/0.10.0
[Discord]: https://discord.gg/planetarium

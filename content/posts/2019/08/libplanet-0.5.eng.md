---
title: Libplanet 0.5 Released
date: 2019-09-06
authors: [dogeon.lee]
translators: [kidon.seo]
---

Hello all, we’re delighted to announce that the 5th minor version of [Libplanet]—[Version 0.5][0.5.0] along with patch versions, [0.5.1] and [0.5.2], has been released.

Libplanet is a common library that solves game implementation problems such as P2P communication and data synchronization when creating online multiplayer games that run on distributed P2P.

Version 0.5 includes extensive performance and reliability improvements addressed while testing games developed with Libplanet. This post will cover those major changes of Version 0.5.


[Libplanet]: https://libplanet.io/

<abbr title="Initial Block Download">IBD</abbr> Speed Improvement
-------------------------------------------------------

Previously, [<abbr title="initial block download">IBD</abbr>][IBD] used to take a long time to execute, even for a small number of blocks. This was because after downloading the blocks, you had to calculate the final state starting from the first block.

However, if you have a reliable node, it is quite possible to effectively reduce computing time by using precalculated results from that node.

So, from Version 0.5, by handing over trusted nodes as parameters to [`Swarm<T>.PreloadAsync()`], we’re now able to receive, store, and use the most recent state values already computed from those trusted nodes.

If there aren’t any trusted nodes or the process fails for another reason, IBD computes in the same process as previous versions.

[IBD]: https://bitcoin.org/en/glossary/initial-block-download
[`Swarm<T>.PreloadAsync()`]: https://docs.libplanet.io/0.5.0/api/Libplanet.Net.Swarm-1.html#Libplanet_Net_Swarm_1_PreloadAsync_System_IProgress_Libplanet_Net_PreloadState__System_Collections_Immutable_IImmutableSet_Libplanet_Address__System_Threading_CancellationToken_


`IRandom.NextDouble()` Removed
------------------------

Quoting from the [System.Double section of .NET Standard Official Document][official-docs], it states: 

>In addition, the result of arithmetic and assignment operations with `Double` values may differ slightly by platform because of the loss of precision of the `Double` type. For example, the result of assigning a literal `Double` value may differ in the 32-bit and 64-bit versions of the .NET Framework. 

As stated above, arithmetic operations and substitution of Double can cause indeterminant results. Because of this, we’ve decided not to provide [‘IRandom.NextDouble()’] from this version onwards.

Please refer to [this article][floating-point-determinism] for further information.

[`IRandom.NextDouble()`]: https://github.com/planetarium/libplanet/pull/419
[official-docs]: https://docs.microsoft.com/en-us/dotnet/api/system.double?view=netstandard-2.0#remarks
[floating-point-determinism]: https://randomascii.wordpress.com/2013/07/16/floating-point-determinism/


Block Action
-------

In order to keep chains secure, we need miners to mine the blocks, and we need to reward miners to recruit and keep them.

Previously for miners to be rewarded, they had to add a transaction with reward actions to the block each time. But from this version, the new [‘BlockPolicy<T>.BlockAction’] property enables miners to implement a code that rewards them for each block action. 

[`BlockPolicy<T>.BlockAction`]: https://docs.libplanet.io/0.5.0/api/Libplanet.Blockchain.Policies.BlockPolicy-1.html#Libplanet_Blockchain_Policies_BlockPolicy_1_BlockAction


`FileStore` Removed
---------------

Libplanet had been providing an interface called [`IStore`], [`FileStore`][] (a file-based implementation of `IStore`), as well as [`LiteDBStore`][] (implementation based on [LiteDB]) since Version [0.4] to simplify the storage layer. Despite the benefits of its simplistic implementation, however, `FileStore` also had the following limitations:

- There were just too many files created because every block, every transaction, and the status of every account block were stored as separate files.
- With no separate cache or buffer, I/O performance was significantly affected by what physical storage device were used.

As we started using LiteDB, `FileStore` usage rate began to diminish. And so, considering the difficulty of continuously managing ‘FileStore’, we decided not to provide `FileStore` implementation from Version 0.5.

[0.4]: {{< ref "../07/libplanet-0.4" >}}
[`IStore`]: https://docs.libplanet.io/0.5.0/api/Libplanet.Store.IStore.html
[`FileStore`]: https://docs.libplanet.io/0.4.0/api/Libplanet.Store.FileStore.html
[LiteDB]: https://www.litedb.org/
[`LiteDBStore`]: https://docs.libplanet.io/0.5.0/api/Libplanet.Store.LiteDBStore.html


More Detailed Preload Progress
---------------------------

To carry out the IBD mentioned above, you can call the [`Swarm<T>.PreloadAsync()`] method. And previously, sending `IProgress<BlockDownloadState>` to this method’s parameter could tell us about the progress of the block download, but it couldn’t tell us about the specific progress from running actions to the final status after the block download (or from a trusted node).

Therefore, the waiting time of this previous method had to be quite boring for players since the loading message only showed either <q>loading</q> or <q>100%</q> and no specific progress of the block download.

However, from Version 0.5, by receiving the ‘IProgress<PreloadState>’ type parameter instead of ‘IProgress<BlockDownloadState>’, this allows us to get a detailed view of the entire preload progress.

Through `IProgress<PreloadState>` object which receives [`BlockDownloadState`], [`BlockStateDownloadState`], [`StateReferenceDownloadState`] and [`ActionExecutionState`] as parameters inherited from [`PreloadState`], users are provided with more detailed information.

[`Swarm<T>.PreloadAsync()`]: https://docs.libplanet.io/0.5.0/api/Libplanet.Net.Swarm-1.html#Libplanet_Net_Swarm_1_PreloadAsync_System_IProgress_Libplanet_Net_PreloadState__System_Collections_Immutable_IImmutableSet_Libplanet_Address__System_Threading_CancellationToken_
[`RecentStates`]: https://github.com/planetarium/libplanet/blob/master/Libplanet/Net/Messages/RecentStates.cs
[`PreloadState`]: https://docs.libplanet.io/0.5.0/api/Libplanet.Net.PreloadState.html
[`BlockDownloadState`]: https://docs.libplanet.io/0.5.0/api/Libplanet.Net.BlockDownloadState.html
[`BlockStateDownloadState`]: https://docs.libplanet.io/0.5.0/api/Libplanet.Net.BlockStateDownloadState.html
[`StateReferenceDownloadState`]: https://docs.libplanet.io/0.5.0/api/Libplanet.Net.StateReferenceDownloadState.html
[`ActionExecutionState`]: https://docs.libplanet.io/0.5.0/api/Libplanet.Net.ActionExecutionState.html


Furthermore
----

You can learn more about additional changes in our [0.5.0], [0.5.1], [0.5.2] release notes.

And as always, if you have any questions about the new release or Libplanet in general, please visit our [Discord chatroom] and let’s chat!

[0.5.0]: https://github.com/planetarium/libplanet/releases/tag/0.5.0
[0.5.1]: https://github.com/planetarium/libplanet/releases/tag/0.5.1
[0.5.2]: https://github.com/planetarium/libplanet/releases/tag/0.5.2
[Discord Chatroom]: https://discord.gg/ue9fgc3


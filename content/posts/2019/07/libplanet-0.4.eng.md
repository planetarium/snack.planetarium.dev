---
title: Libplanet 0.4 Released
date: 2019-07-10
authors: [swen.mun]
translators: [kidon.seo]
---

Hello everyone, we are happy to announce that the fourth minor version of [Libplanet]—[Version 0.4][1], has been released.

Libplanet is a common library that solves game implementation problems such as P2P communication and data synchronization when creating online multiplayer games that run on distributed P2P.

This post will cover key changes in Version 0.4.

[Libplanet]: https://libplanet.io/
[1]: https://github.com/planetarium/libplanet/releases/tag/0.4.0


`LiteDBStore` Added
-------------------

To simplify the storage layer, Libplanet provides a built-in interface called [`IStore`] and a file-based class called [`FileStore`]. The `FileStore` was enough for a small game, but when we applied it to a larger one, we found the following problems:

- Because all the blocks, their status, transactions, and account addresses, were stored as separate files, there were just too many of them.
- I/O performance was reduced because there were no separate cache or buffers.

To address these issues, we reviewed the need for an `IStore` implementation using a separate storage engine, and in this process we chose [LiteDB]. Written purely in C#, LiteDB is easy to manage because it's highly portable in a .NET environment and it allows you to manage your entire data in a single file.

Since the newly added [`LiteDBStore`] implements `IStore`, besides the object initialization method in the previous `FileStore`, it can be used in exactly the same way.


[`IStore`]: https://docs.libplanet.io/0.4.0/api/Libplanet.Store.IStore.html
[`FileStore`]: https://docs.libplanet.io/0.4.0/api/Libplanet.Store.FileStore.html
[LiteDB]: https://www.litedb.org/
[`LiteDBStore`]: https://docs.libplanet.io/0.4.0/api/Libplanet.Store.LiteDBStore.html


Easy Transaction Creation
-------------------------
[`Transaction<T>.Nonce`] added on Version 0.3 was an important device for creating secure transactions, but at the same time it was a headache for developers who used Libplanet. This was because in order to make a `Transaction<T>`, one had to use [`BlockChain<T>.GetNonce()`] to get the exact [nonce] of the account that’s currently signing and use it. Not only was this process cumbersome, but it also created concurrency problems depending on when transactions were created.

But starting from Version 0.4, [`BlockChain<T>.MakeTransaction()`] makes it simple and easy to create transactions without worrying about concurrency.

[`Transaction<T>.Nonce`]: https://docs.libplanet.io/0.3.0/api/Libplanet.Tx.Transaction-1.html#Libplanet_Tx_Transaction_1_Nonce
[`BlockChain<T>.GetNonce()`]: https://docs.libplanet.io/0.3.0/api/Libplanet.Blockchain.BlockChain-1.html#Libplanet_Blockchain_BlockChain_1_GetNonce_Libplanet_Address_
[`BlockChain<T>.MakeTransaction()`]: https://docs.libplanet.io/0.4.0/api/Libplanet.Blockchain.BlockChain-1.html#Libplanet_Blockchain_BlockChain_1_MakeTransaction_Libplanet_Crypto_PrivateKey_System_Collections_Generic_IEnumerable__0__System_Collections_Immutable_IImmutableSet_Libplanet_Address__System_Nullable_System_DateTimeOffset__System_Boolean_
[nonce]: https://en.wikipedia.org/wiki/Cryptographic_nonce


Transaction Broadcast Automated
-------------------------------
In order for games using previous versions of Libplanet to broadcast transactions, [`Swarm.BroadcastTxs()`] had to be called directly. And because transaction broadcast could fail due to network failure, the retry logic had to be implemented directly from the game side.

(Although `.BroadcastTxs()` is still usable) Now, direct implementation isn’t necessary from games. Instead, they can put their own chains when making `Swarm<T>` and create a transaction (using `BlockChain<T>.MakeTransaction()` as introduced above). The rest will be carried out by `Swarm<T>`. 

In this process, since `Swarm` now directly manages the chain, it has been modified to `Swarm<T>`, indicating that it contains a type parameter(`T`), just like` BlockChain<T>`.



[`Swarm.BroadcastTxs()`]: https://docs.libplanet.io/0.3.0/api/Libplanet.Net.Swarm.html#Libplanet_Net_Swarm_BroadcastTxs__1_System_Collections_Generic_IEnumerable_Libplanet_Tx_Transaction___0___


Furthermore,
------------

You can learn more about additional changes in [our release notes][1].

And as always, if you have any questions about the new release or Libplanet in general, please visit [our Discord chatroom][2] and let’s chat!

[2]: https://discord.gg/ue9fgc3




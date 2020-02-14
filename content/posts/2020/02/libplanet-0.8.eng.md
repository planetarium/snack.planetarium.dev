---
title: Libplanet 0.8 Released
date: 2020-02-05
authors: [chanhyuck.ko, hong.minhee]
translators: [kidon.seo]
---

Hello All.

Our team has released the eighth minor version of [Libplanet], [Version 0.8][0.8.0].

Libplanet is a common library that solves game implementation problems such as P2P communication and data synchronization when creating online multiplayer games that run on distributed P2P.

With the new version updated in nearly three months, there have been many improvements in version 0.8 including storage optimization. This article will cover major changes of Version 0.8.

[Libplanet]: https://libplanet.io/
[0.8.0]: https://github.com/planetarium/libplanet/releases/tag/0.8.0


Genesis Block Anticipation 
--------------------------

`BlockChain<T>` now anticipates a particular genesis block. This is to prevent mistakes such as multiple games attempting to connect to the wrong network. Mistakes like above might occur because although games made from Libplanet form separate networks, Libplanet behaves in a type of metaprotocol.

[`BlockChain<T>()` constructor][BlockChain{T}()] takes the `Block<T>` object as a factor and the block becomes the first block. If genesis block contained in `IStore` and the genesis block expected by the `BlockChain<T>()` constructor do not match, [`InvalidGenesisBlockException`][InvalidGenesisBlockException] will occur.

Currently, the constructor receives the entire `Block<T>` object, but [the next version will have the constructor only receive the genesis block hash and the actual block content to be received from other nodes on the network.][#769]

[BlockChain{T}()]: https://docs.libplanet.io/0.8.0/api/Libplanet.Blockchain.BlockChain-1.html#Libplanet_Blockchain_BlockChain_1__ctor_Libplanet_Blockchain_Policies_IBlockPolicy__0__Libplanet_Store_IStore_Libplanet_Blocks_Block__0__
[InvalidGenesisBlockException]: https://docs.libplanet.io/0.8.0/api/Libplanet.Blocks.InvalidGenesisBlockException.html
[#769]: https://github.com/planetarium/libplanet/pull/769


[`DefaultStore`][DefaultStore] ← `LiteDBStore`
----------------------------------------------

`LiteDBStore`, a built-in `IStore` implementation, has been removed and [`DefaultStore`][DefaultStore] has replaced it.

The reason for this replacement is that while only a single LiteDB file was stored before, more files with multiple formats have been added to be stored within a directory from this version.

Another reason was our intention to remove implementation details from the name, with efforts to optimize the repository until the 1.0.0 release.

In addition, a `compress` option has been created in the [`DefaultStore()` constructor][DefaultStore()] to reduce storage space. Although the option is still turned off by default in this version, the default will be changed to `true` in the next version.

[DefaultStore]: https://docs.libplanet.io/master/api/Libplanet.Store.DefaultStore.html
[DefaultStore()]: https://docs.libplanet.io/master/api/Libplanet.Store.DefaultStore.html#Libplanet_Store_DefaultStore__ctor_System_String_System_Boolean_System_Boolean_System_Int32_System_Int32_System_Int32_System_Int32_System_Boolean_System_Boolean_


[`ICryptoBackend`][ICryptoBackend]
----------------------------------

To be used on a variety of platforms, Libplanet has been using a cryptographic library written in pure C#, [Bouncy Castle]. Although pure C# implementations are a great advantage in portability, they serve as a penalty in performance.

In the new version, an abstraction layer called [`ICryptoBackend`][ICryptoBackend] has been added to allow game developers to choose between portability and performance. While the default implementation, [`DefaultCryptoBackend`][DefaultCryptoBackend], is still internally dependent on Bouncy Castle, game developers can achieve performance benefits by implementing the `ICryptoBackend` interface appropriately, depending on the game’s target platform.

For example, if you want Libplanet to use `MyCryptoBackend` class that implements `ICryptoBackend`, you can overwrite [`CryptoConfig.CryptoBackend` property][CryptoConfig.CryptoBackend] as shown below.

~~~~ csharp
CryptoConfig.CryptoBackend = new MyCryptoBackend();
~~~~

In the case of [Nine Chronicles], a game currently being developed by our team, we have also improved game performance by implementing `ICryptoBackend`  interface that calls [secp256k1] C library unveiled in the Bitcoin project.

[Bouncy Castle]: http://www.bouncycastle.org/csharp/
[ICryptoBackend]: https://docs.libplanet.io/0.8.0/api/Libplanet.Crypto.ICryptoBackend.html
[DefaultCryptoBackend]: https://docs.libplanet.io/0.8.0/api/Libplanet.Crypto.DefaultCryptoBackend.html
[CryptoConfig.CryptoBackend]: https://docs.libplanet.io/0.8.0/api/Libplanet.Crypto.CryptoConfig.html#Libplanet_Crypto_CryptoConfig_CryptoBackend
[secp256k1]: https://github.com/bitcoin-core/secp256k1


Routing Table Improvement
-------------------------

Because Libplanet uses [<abbr title="distributed hash table">DHT</abbr>][DHT] to communicate with other peers, it stores information about the peers associated with itself on the routing table.

Traditionally, this routing table only stored the most recent communication points with that peer. But now, we've also added a communication delay info to give you more information about the network environment.

Developers can use the newly added [`Swarm<T>.CheckAllPeersAsync()` method][Swarm{T}.CheckAllPeersAsync()] to update peers stored on routing tables, and access [`Swarm<T>.Peers` property][Swarm{T}.Peers] from outside Libplanet to identify the peers currently on its routing tables.

[DHT]: {{< ref "../../2019/09/kademlia/" >}}
[Swarm{T}.CheckAllPeersAsync()]: https://docs.libplanet.io/0.8.0/api/Libplanet.Net.Swarm-1.html#Libplanet_Net_Swarm_1_CheckAllPeersAsync_System_Nullable_TimeSpan__CancellationToken_
[Swarm{T}.Peers]: https://docs.libplanet.io/0.8.0/api/Libplanet.Net.Swarm-1.html#Libplanet_Net_Swarm_1_Peers


Changed Block Structure and Serialization 
-----------------------------------------

A block that is a component of the blockchain can be divided into two parts: the transactions and the metadata excluding the transactions. 

As with many blockchain projects, we've defined the part minus the transactions as block headers, and we are now able to compute more efficiently than ever before by using a block header that contains more information compared to only using block hash for computation.

In addition, when serializing blocks and transactions, field keys are shortened and the empty fields are completely excluded, making the serialized expression lighter.

Documentation Improvement
--------------------

Although not a change to the library itself, there have been improvements in the design of the [docs website][docs] and a new [Overview][overview] document written by Swen Mun has been added.

[docs]: https://docs.libplanet.io/0.8.0/
[overview]: https://docs.libplanet.io/0.8.0/articles/overview.html


Furthermore,
------------

In addition, there have been a number of other changes while fixing many problems that we found during our 3 months of [Nine Chronicles] public testing. Details can be found in the [entire change history][0.8.0].

If you're curious, install it and try it. And as always, if you have any questions about the new release or Libplanet in general, please visit our [Discord] chatroom and let’s chat!

[Nine Chronicles]: https://nine-chronicles.com/
[Discord]: https://discord.gg/planetarium

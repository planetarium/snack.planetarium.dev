---
title: Libplanet 0.6 Released
date: 2019-10-04
authors: [chanhyuck.ko]
translators: [kidon.seo]
---

Hello everyone, our team has released the 6th minor version of [Libplanet], [Version 0.6][0.6.0].

Libplanet is a common library that solves game implementation problems such as P2P communication and data synchronization when creating online multiplayer games that run on distributed P2P.

In version 0.6 there are significant changes to Libplanet's network configuration, and many bugs are fixed that had not been found before. In this article we will cover those key changes of Version 0.6.

[Libplanet]: https://libplanet.io/


Kademlia Distributed Hash Table Applied 
---------------------------
In the traditional Libplanet, each peer managed all other peers on the network. Due to the nature of blockchain that transmits every data created, this method manages to work when only a handful of peers are connected to the network, but when the number of peers increase, network communication problem occurs.

To address this issue, Kademlia protocol, one of the distributed hash table techniques, has been applied to manage more peers in a network. If you are curious about the operation of Kademlia distributed hash table, please refer to <cite>[Applying Kademlia Distributed Hash Table to Libplanet]</cite>.

[Applying Kademlia Distributed Hash Table to Libplanet]: {{< ref "../09/kademlia/index.eng.md" >}}


Transaction Transmission Method Changed 
-----------------------------
When a client creates a transaction, it transmits that data to peers on its routing table, which then synchronizes all peers on the blockchain network.

The traditional Libplanet worked by transmitting transaction data at regular intervals, and since each peer had a list of all other peers on a network, the entire network was synchronized with one wave. However, with Kademlia distributed hash table applied, a single wave alone could not guarantee synchronization of the entire network. Because each peer re-transmits data it receives from another peer at an interval until the whole network is synchronized, there’s certainly a possibility that the process will take much longer time than we’d like.

Therefore, from this version, we’ve modified the logic to transmit transaction immediately when transmission begins, preventing long delays in the network synchronization process.


Ensuring Transaction Order within a Block 
---------------------------------
When multiple transactions are included within a block, we must ensure that all clients run the actions in the same order. At the same time, the order of execution must not be predictable until the blocks are mined.

In order to meet the above conditions, this update allows all clients to run actions in the same order by utilizing the block's `Hash` value and the transaction's `Id`.


Asynchronous Block Mining 
---------------
Since Libplanet works based on a [Proof of Work] system, it uses a lot of CPU resources during block mining process. In the previous version, because `Hashcash.Answer()` which looks for `Nonc`e in a block was a synchronous function, the running thread was blocked and it was difficult to abort operation.

From this version, `BlockChain<T>.Mine()` is an asynchronous function, meaning users can abort operation at a desired time by using `CancellationToken`. Also, when blockchain tip changes during mining, `Blockchain <T>.TipChanged` event, which can be subscribed externally, will be called and the mining process will halt when that event occurs.

[Proof of Work]: 
https://en.wikipedia.org/wiki/Proof_of_work


Furthermore 
----

You can learn more about additional changes in our [release notes][0.6.0].

And as always, if you have any questions about the new release or Libplanet in general, please visit our [Discord chatroom] and let’s chat!


[0.6.0]: https://github.com/planetarium/libplanet/releases/tag/0.6.0
[Discord chatroom]: https://discord.gg/ue9fgc3

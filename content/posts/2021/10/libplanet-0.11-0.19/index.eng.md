---
title: What's new in Libplanet 0.11–0.19
date: 2021-10-29
authors: [hong.minhee]
---

Hello.  Long time no see.  [Libplanet][][^1] has released several minor
versions over the past few months.  However, as our release policy and cycle
changed, and as we had responded to deal with diverse problems on the mainnet
of our first game <cite>[Nine Chronicles]</cite>, powered by Libplanet, we'd been
unable to afford to keep up with the updates.  So let's focus on some of
the key changes that have made in between the past releases.

[^1]: Libplanet is a common library that abstracts out the implementation
      details of decentralized multiplayer gaming such as peer-to-peer
      networking and data synchronization.

[Libplanet]: https://libplanet.io/
[Nine Chronicles]: https://nine-chronicles.com/


New Release Cycle
-----------------

Previously, Libplanet had no clear rules for its release cycle.  It was just
simply giving a new version number to a collection of unreleased changes when
there is a big API change or some time has passed since the last release.

However, since the launch of the <cite>Nine Chronicles</cite>' mainnet last
year, Libplanet has had to make frequent releases to fix various problems of
the mainnet.  Currently both teams of Libplanet and <cite>Nine Chronicles</cite>
in Planetarium work closely together to catch up each other's updates.  This
release cycle of Libplanet is likely to continue for a while.

Under that policy, there have been 9 minor releases in the last few months,
from 0.11.0 released in March 2021 to 0.19.0 released this week:

- [0.11.0] (March 30)
- [0.12.0] (July 23)
- [0.13.0] (July 28)
- [0.14.0] (August 5)
- [0.15.0] (August 18)
- [0.16.0] (August 25)
- [0.17.0] (September 28)
- [0.18.0] (October 13)
- [0.19.0] (October 27)

[0.11.0]: https://github.com/planetarium/libplanet/releases/tag/0.11.0
[0.12.0]: https://github.com/planetarium/libplanet/releases/tag/0.12.0
[0.13.0]: https://github.com/planetarium/libplanet/releases/tag/0.13.0
[0.14.0]: https://github.com/planetarium/libplanet/releases/tag/0.14.0
[0.15.0]: https://github.com/planetarium/libplanet/releases/tag/0.15.0
[0.16.0]: https://github.com/planetarium/libplanet/releases/tag/0.16.0
[0.17.0]: https://github.com/planetarium/libplanet/releases/tag/0.17.0
[0.18.0]: https://github.com/planetarium/libplanet/releases/tag/0.18.0
[0.19.0]: https://github.com/planetarium/libplanet/releases/tag/0.19.0


Protocol Versions
-----------------

*Added in version [0.11.0].*

A protocol version is a property of a block that represents in which version of
Libplanet used for mining.  It helps games powered by Libplanet to easily
upgrade the Libplanet version, and on the Libplanet side, it allows us to
add new functionalities without breaking backward compatibility with existing
networks.

API-wise, it is exposed through
the [`Block<T>.ProtocolVersion` property][Block<T>.ProtocolVersion], which is
a 32-bit integer.  Those numbers solely represent a version of the network
protocol, which is distinct from a version of the library package (on NuGet
Gallery).  According to Semantic Versioning, patch releases never increase
the protocol version, but only minor and major release can increase it.[^2]

As of Libplanet [0.19.0], the current protocol version is 2, and any blocks
produced before Libplanet [0.11.0], which introduced protocol versions,
are treated as the protocol version 0.

[^2]: This does not mean that all major and minor releases increase the protocol
      version. In fact, most releases do not increment the protocol version.

[Block<T>.ProtocolVersion]: https://docs.libplanet.io/0.19.0/api/Libplanet.Blocks.Block-1.html#Libplanet_Blocks_Block_1_ProtocolVersion


Network Transport Layer
-----------------------

*Added in version [0.11.0].*

Since its inception, Libplanet has left much of the low-level networking to
[NetMQ], which is a .NET implementation of [ZeroMQ].  However, now it is
necessary to change its networking layer to be possible without relying on NetMQ
so that Libplanet can be used on various platforms such as mobile and Web.

The network transport layer is Libplanet's response to that need.
This abstraction layer was added experimentally to diversify low-level
network transports and to allow game developers to define and use them
if there are special requirements.

API-wise, it is represented as the [`ITransport` interface][ITransport], and
the [`NetMQTransport`][NetMQTransport] which implements it is built-in.

As it is a pilot phase, the interface still has been adjusted through several
minor releases, and game programmers can't yet use their own transport
implementation.  Later in the year, [`Swarm<T>`][Swarm<T>] instances will be
configurable with custom transports besides
the [new TCP-based transport][TcpTransport], which aims to replace
the `NetMQTransport`.

[ZeroMQ]: https://zeromq.org/
[NetMQ]: https://github.com/zeromq/netmq
[ITransport]: https://docs.libplanet.io/0.19.0/api/Libplanet.Net.Transports.ITransport.html
[NetMQTransport]: https://docs.libplanet.io/0.19.0/api/Libplanet.Net.Transports.NetMQTransport.html
[TcpTransport]: https://github.com/planetarium/libplanet/pull/1523
[Swarm<T>]: https://docs.libplanet.io/0.19.0/api/Libplanet.Net.Swarm-1.html


Configurable <abbr title="Proof-Of-Work">PoW</abbr> Hash Algorithm
------------------------------------------------------------------

*Added in version [0.12.0].*

Previously, Libplanet has used [SHA-256] for proof-of-work.  However, since
version [0.12.0], each network can configure its hash algorithm for
<abbr title="proof-of-work">PoW</abbr> by implementing its
[`IBlockPolicy<T>.GetHashAlgorithm()`
method][IBlockPolicy<T>.GetHashAlgorithm].  As it is not only configurable
for each network, but also for block indices, it can be migrated within
a network after its establishment.

You can use any hash algorithm for <abbr title="proof-of-work">PoW</abbr>
as long as it is a subclass of the [`HashAlgorithm`][HashAlgorithm] abstract
class, which is built in the .NET runtime.  It is not necessary to be included
in the .NET runtime, but you can use your custom implementation as well.
For instance, [RandomXSharp], a .NET binding library for RandomX we made,
also provides a subclass of `HashAlgorithm`.

The following code shows an example policy requiring blocks below 10,000th
block to use SHA-256 and above blocks to use SHA-512 within a chain:

~~~~ csharp
HashAlgorithmType GetHashAlgorithm(long index) =>
    index <= 10_000
        ? HashAlgorithmType.Of<SHA256>()
        : HashAlgorithmType.Of<SHA512>();
~~~~

[SHA-256]: https://ko.wikipedia.org/wiki/SHA-2
[IBlockPolicy<T>.GetHashAlgorithm]: https://docs.libplanet.io/0.19.0/api/Libplanet.Blockchain.Policies.IBlockPolicy-1.html#Libplanet_Blockchain_Policies_IBlockPolicy_1_GetHashAlgorithm_System_Int64_
[HashAlgorithm]: https://docs.microsoft.com/en-us/dotnet/api/system.security.cryptography.hashalgorithm
[RandomXSharp]: https://github.com/planetarium/RandomXSharp


Non-blocking Renderers
----------------------

*Added in version [0.14.0].*

[`IRenderer<T>`][IRenderer<T>] and [`IActionRenderer<T>`][IActionRenderer<T>]
interfaces, event listners that wait for state transitions of node's local
chain, flow in a blocking manner as they do not spawn new threads.  Suppose
some rendering logic calls `Thread.Sleep(60_000)`---continued state transition
from it on the chain will be made after waiting for 60 seconds of rending.

Since version 0.14.0, two decorators which execute time-consuming rendering
logic in a separated thread without blocking,
[`NonblockRenderer<T>`][NonblockRenderer<T>] and
[`NonblockActionRenderer<T>`][NonblockActionRenderer<T>] classes,
are introduced.  Both classes take another render through their constructors,
and call its event handlers in a separated thread.  As they are decorators,
the existing renderers can be transformed into a non-blocking style,
by wrapping existing ones with the decorators.

Despite they are non-blocking, they have their own internal queue to guarantee
the order of events.

[IRenderer<T>]: https://docs.libplanet.io/0.19.0/api/Libplanet.Blockchain.Renderers.IRenderer-1.html
[IActionRenderer<T>]: https://docs.libplanet.io/0.19.0/api/Libplanet.Blockchain.Renderers.IActionRenderer-1.html
[NonblockRenderer<T>]: https://docs.libplanet.io/0.19.0/api/Libplanet.Blockchain.Renderers.NonblockRenderer-1.html
[NonblockActionRenderer<T>]: https://docs.libplanet.io/0.19.0/api/Libplanet.Blockchain.Renderers.NonblockActionRenderer-1.html


Configurable Transaction Preference By Miners
---------------------------------------------

*Added in version [0.17.0].*

The protocol does not require miners to have any priority for transactions
to include in a block, if these staisfy
[`IBlockPolicy<T>.ValidateNextBlockTx()` predicate
method][IBlockPolicy<T>.ValidateNextBlockTx] at least.[^3]  However, if there
are too many transactions to be included in a block, a miner may need to
prioritize them so that they are chunked into multiple blocks.

Since version 0.17.0, instead of Libplanet arbitrarily prioritizing them,
miners can configure the priority for transactions to include in a block.
API-wise, [`BlockChain<T>.MineBlock()` method][BlockChain<T>.MineBlock] has the
`txPriority` option which takes an [`IComparer<Transaction<T>>`][IComparer<T>].

[^3]: Of course, there is an order between transactions signed by a signer.
      These are ordered by [`Transaction<T>.Nonce`][Transaction<T>.Nonce].

[IBlockPolicy<T>.ValidateNextBlockTx]: https://docs.libplanet.io/0.19.0/api/Libplanet.Blockchain.Policies.IBlockPolicy-1.html#Libplanet_Blockchain_Policies_IBlockPolicy_1_ValidateNextBlockTx_Libplanet_Blockchain_BlockChain__0__Libplanet_Tx_Transaction__0__
[Transaction<T>.Nonce]: https://docs.libplanet.io/0.19.0/api/Libplanet.Tx.Transaction-1.html#Libplanet_Tx_Transaction_1_Nonce
[BlockChain<T>.MineBlock]: https://docs.libplanet.io/0.19.0/api/Libplanet.Blockchain.BlockChain-1.html#Libplanet_Blockchain_BlockChain_1_MineBlock_Libplanet_Crypto_PrivateKey_DateTimeOffset_System_Boolean_System_Int32_System_Int32_IComparer_Libplanet_Tx_Transaction__0___CancellationToken_
[IComparer<T>]: https://docs.microsoft.com/en-us/dotnet/api/system.collections.generic.icomparer-1


Blocks Signed By Miners
-----------------------

*Added in version [0.18.0].*

Since the protocol version 2, i.e., Libplanet 0.18.0, every block is signed with
the private key of its miner, and it includes the public key besides the addres
of its miner.

API-wise, block signatures are represented as
[`Block<T>.Signature` property][Block<T>.Signature], and miners' public keys
are represented as [`Block<T>.PublicKey` property][Block<T>.PublicKey].
Blocks with the protocol versions 1 and 0 fill both properties with `null`.

[Block<T>.Signature]: https://docs.libplanet.io/0.19.0/api/Libplanet.Blocks.Block-1.html#Libplanet_Blocks_Block_1_Signature
[Block<T>.PublicKey]: https://docs.libplanet.io/0.19.0/api/Libplanet.Blocks.Block-1.html#Libplanet_Blocks_Block_1_PublicKey


Multi-Threaded Mining
---------------------

*Added in version [0.19.0].*

Since Libplanet 0.19.0, each block is mined in parallel, depending on
the number of CPU cores.  The option to configure the number of processes
(workers) will be added in the future.


Many Others
-----------

Besides that, a lot of new features has been added, and it has significantly
stabilized in many areas, solving problems that have arisen during months of
the mainnet ops.  Please check the [entire changelog] of each release
for details.

If you became interested in Libplanet, please give it a try.  As we are always
in [our Discord server], feel free to ask any questions if you have!

[entire changelog]: https://github.com/planetarium/libplanet/blob/0.19.0/CHANGES.md
[our Discord server]: https://discord.gg/planetarium

---
title: Libplanet 0.7 Released
date: 2019-11-11
authors: [seunghun.lee]
translators: [kidon.seo]
---

Hello everyone, our team has released the 7th minor version of [Libplanet], [Version 0.7][0.7.0].

Libplanet is a common library that solves game implementation problems such as P2P communication and data synchronization when creating online multiplayer games that run on distributed P2P.

Major changes in version 0.7 deal with stability and performance related improvements, as well as various usage improvements. In this article we will cover those key changes of Version 0.7.

[Libplanet]: https://libplanet.io/

Type Limitations of Actions and States
------------------------

In previous versions of Libplanet, states and properties of action were expressed in the `object` type and serialized in [.NET's Binary Serialization][Binary Serialization] format when saved. Because this method allows you to serialize .NET objects as they are, there's less burden for both parties that use or develop Libplanet. But ever since we started using this method, we decided to only use it short-term, recognizing the following limitations:

- The specific way serialization and deserialization takes place is implicit. While changes in type implementation affects the format being serialized, it's difficult to determine what specific changes takes place.
- After type values of previously different shapes are serialized, stored in blockchain and then attempted deserialization to the current type, a runtime error may occur or the value may be interpreted as a different meaning than originally intended.
- If a type is defined by the team, you may use techniques such as [VTS], but if the type imported through a package other than an assembly made by the team is accidently mixed and serialized, it will be difficult to respond to serial format changes due to the changed inner expression of that type.
- Serialized results are difficult to interpret on platforms other than .NET, and also, deserialization is difficult if assembly including serialized type is not shared on .NET platform. This makes it difficult for people to see the properties of an action or the states of a particular point in time in an app such as [Libplanet Explorer] or [Libplanet Explorer Frontend].

[VTS]: https://docs.microsoft.com/en-us/dotnet/standard/serialization/version-tolerant-serialization
[Libplanet Explorer Frontend]: https://docs.microsoft.com/en-us/dotnet/standard/serialization/version-tolerant-serialization

So from this version, states and properties of action have been changed to be expressed as [`IValue`][IValue] type of [Bencodex]. Therefore, you must explicitly write a code that converts the types that you define and use inside the game into `IValue` format, as well as a code that interprets what is expressed in the `IValue` format back into the types in the game. It's a little inconvenient, but even when the type of internal expression you're trying to serialize changes, you can easily add processing logic to your serialization or reverse-serialization method, and it's also easier to implement compatibility between different versions.

[Binary Serialization]: https://docs.microsoft.com/en-us/dotnet/standard/serialization/binary-serialization
[Libplanet Explorer]: https://github.com/planetarium/libplanet-explorer
[Bencodex]: https://github.com/planetarium/bencodex.net
[IValue]: https://github.com/planetarium/bencodex.net/blob/0.2.0/Bencodex/Types/IValue.cs


Removed `IReadOnlyList<T>` Implementation from `BlockChain<T>`
--------------------------------------------------------------

Up until the previous version, `BlockChain<T>` class was implementing `IReadOnlyList<T>` interface, which allowed us to use [LINQ] extension methods directly on the `BlockChain<T>` object. The LINQ extension method provides a variety of convenience when handling linear objects, but depending on how you use it, it can significantly alter performance levels. For example, when there are 10,000 blocks in the `BlockChain<T>` object and you want to import the 10,000th block using the `.Last()` method of LINQ, it's easy to think that only the last block is imported directly from the repository. But in reality, from the first block of `BlockChain<T>`, to the last block, each block is loaded on memory and interpreted. This is not a big problem when few blocks are stored, but the more blocks are stored, the more performance issues they may lead to.

Starting with this version, we removed the implementation of `IReadOnlyList<T>` from the `BlockChain<T>` class altogether to prevent problems that might result from misusing LINQ extension methods. Instead, often used computations such as [`BlockChain<T>.Contains()`][BlockChain<T>.Contains] will be directly provided for efficient implementation.

[BlockChain<T>.Contains]: https://docs.libplanet.io/0.7.0/api/Libplanet.Blockchain.BlockChain-1.html#Libplanet_Blockchain_BlockChain_1_Contains_Libplanet_Blocks_Block__0__

[LINQ]: https://docs.microsoft.com/en-us/dotnet/csharp/programming-guide/concepts/linq/


Key Store Implementation to Safely Store Personal Keys
----------------------------------------------

In this version, we have added a Key Store to help you encrypt and secure your private key. Each key file in the Key Store is represented by the [`ProtectedPrivateKey`] [ProtectedPrivateKey] class and can be saved by encrypting the private key with the passphrase you enter. Also, you can save it in JSON format based on [Web3 Secret Storage Definition] of [Ethereum] using the method [`ProtectedPrivateKey.WriteJson()`][ProtectedPrivateKey.WriteJson]. In the future, there will be additional features for integrated management of Key Store directory.

[ProtectedPrivateKey]: https://docs.libplanet.io/0.7.0/api/Libplanet.KeyStore.ProtectedPrivateKey.html
[ProtectedPrivateKey.WriteJson]: https://docs.libplanet.io/0.7.0/api/Libplanet.KeyStore.ProtectedPrivateKey.html#Libplanet_KeyStore_ProtectedPrivateKey_WriteJson_Stream_System_Nullable_Guid___

Currently, Liplanet implements [PBKDF2] and [Scrypt] [key derivation functions], and supports [AES]-128-[CTR] encryption algorithm. The Scrypt implementation has been contributed as [contribution][#654] by [minhoryang]. 🎉

[Ethereum]: https://en.wikipedia.org/wiki/Ethereum
[Web3 Secret Storage Definition]: https://github.com/ethereum/wiki/wiki/Web3-Secret-Storage-Definition
[key derivation functions]: https://en.wikipedia.org/wiki/Key_derivation_function
[PBKDF2]: https://en.wikipedia.org/wiki/PBKDF2
[Scrypt]: https://en.wikipedia.org/wiki/Scrypt
[AES]: https://en.wikipedia.org/wiki/Advanced_Encryption_Standard
[CTR]: https://en.wikipedia.org/wiki/Block_cipher_mode_of_operation#Counter_(CTR)
[minhoryang]: https://github.com/minhoryang
[#654]: https://github.com/planetarium/libplanet/pull/654


Furthermore,
----

This version includes many contributions from the [Hacktoberfest] event. You can learn more about the event in [Looking Back on Hacktoberfest][looking-back-at-hacktoberfest] written by Swen Mun, and all other changes made to this version can be found in [Full Changes] [0.7.0].

And as always, if you have any questions about the new release or Libplanet in general, please visit our [Discord chatroom][Discord] and let’s chat!

[Hacktoberfest]: https://hacktoberfest.digitalocean.com/
[looking-back-at-hacktoberfest]: {{< ref "../11/looking-back-at-hacktoberfest/" >}}
[0.7.0]: https://github.com/planetarium/libplanet/releases/tag/0.7.0
[Discord]: https://discord.gg/planetarium

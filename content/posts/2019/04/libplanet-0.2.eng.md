---
title: Libplanet 0.2 Released
date: 2019-04-09
translated: 2019-04-22
authors: [hong.minhee]
translators: [kidon.seo]
---

Hello, last week our team released the second minor version[^1] of [Libplanet],
[Version 0.2][2].
Although there have been several changes,
this article will cover some key feature additions and API changes.

[Libplanet]: https://libplanet.io/
[^1]: We have not yet released a major version.
[2]: https://github.com/planetarium/libplanet/releases/tag/0.2.0


Introduction to Libplanet
-------------------------

Before getting into our updates, I haven't introduced [Libplanet] on this blog,
so let me briefly explain it to you.

Libplanet is a common library that solves game implementation problems such as
<abbr title="Peer-to-Peer">P2P</abbr> communication and data synchronization
when creating online multiplay games that run on distributed P2P.

Libplanet is now being developed in C# language,
with the aim of being used in conjunction with the popular Unity engine.
Of course, even if you don't use Unity,
Libplanet targets [.NET Standard 2.0][3] so that it's easy to use for
games that are implemented on .NET or Mono.

Another feature of Libplanet is that it is a library,
not an engine or a framework.
Since engines and frameworks control the entry point (`Main()` method) of
a process and dictate its execution flow, game programmers have limited control
and can only program essentially through scripts within sections explictly allowed.
Libplanet does not preempt the game process and operates only when it is
explicitly invoked by the game programmer.
This allows Libplanet to function with game engines like Unity without imposing
additional limitations on the developer.

Libplanet is listed on [NuGet] along with [API docs][4].

[3]: https://github.com/dotnet/standard/blob/master/docs/versions/netstandard2.0.md
[NuGet]: https://www.nuget.org/packages/Libplanet/
[4]: https://docs.libplanet.io/


<abbr title="Network Address Translation">NAT</abbr> Traversal
--------------------------------------------------------------

Although P2P communication was possible from [Libplanet 0.1][5],
all peers had to have a public IP.
In other words, because we couldn't reach peers behind routers,
network communication was actually limited in reality.
Solving this issue was a top priority for us and so
traversing NAT was a major goal in the 0.2 roadmap.
To cover most cases,
we implemented [RFC 5766] and [RFC 5389],
called <abbr title="Traversal Using Relays around NAT">TURN</abbr> and
<abbr title="Session Traversal Utilities for NAT">STUN</abbr>.
Also, there weren't any open source C# implementation to ease the process,
so our team's Swen Mun implemented the necessary parts of
the specification from scratch.
If you're interested in Swen's journey, please also read the article,
<cite>[Moving Beyond NAT][6]</cite>, in which he explains how he solved
this problem.

[5]: https://github.com/planetarium/libplanet/releases/tag/0.1.0
[6]: {{< ref "nat_traversal_1.eng.md" >}}
[RFC 5766]: https://tools.ietf.org/html/rfc5766
[RFC 5389]: https://tools.ietf.org/html/rfc5389


More Game-fitting Transaction
-----------------------------

[`Transaction<T>`][7] is a unit that synchronizes data between network members.
Up to the previous version of Libplanet,
we referred to existing technologies such as [Bitcoin]
that solve similar problems and took on the concept
that all transactions had a sender and a recipient.
In the case of Bitcoin, it deals with monetary transactions so
the notion that there are senders and recipients in
every transaction comes naturally.
In games, however, there are often actions that do not carry a recipient
concept, such as the movement of a character,
or actions that may have more than one recipient, such as wide range skills.

So to make this transaction more game-fitting,
Libplanet from this version on will dismiss the `Sender`–`Recipient` concept of
`Transaction<T>` and instead,
replace it with the [`Signer`][8]–[`UpdatedAddress`][9] concept.

[7]: https://docs.libplanet.io/0.2.1/api/Libplanet.Tx.Transaction-1.html
[Bitcoin]: https://bitcoin.org/
[8]: https://docs.libplanet.io/0.2.1/api/Libplanet.Tx.Transaction-1.html#Libplanet_Tx_Transaction_1_Signer
[9]: https://docs.libplanet.io/0.2.1/api/Libplanet.Tx.Transaction-1.html#Libplanet_Tx_Transaction_1_UpdatedAddresses


New Status Access API
---------------------

Previously, all [`IAction`][10] implementations had to request a set of account
addresses to be accessed within the `Execute()` method through
the `RequestStates()` method.
Ones that attempted to read or write status of addresses that weren't requested
in advance were treated as invalid.

However, we came to the conclusion that, since the status shared
in the public network through blockchain could be read anyway,
the limitation on reading didn't mean much, only the limit on updating.

Additionally, the duplicated information on the accounts to be accessed
in both the `RequestStates()` method and the `Execute()` method was bug-prone.
And even if you were careful, fixing the both methods together was a big hassle.

To solve these problems, the `IAction` interface's status access API
has been greatly improved on this version of Libplanet.
The `RequestStates()` method has disappeared altogether,
and the [`PreviousStates` property][11] of the [`IActionContext`][12] object,
which entered the factor in [`IAction.Execute()` method][13],
now provides a kind of "record of changes" API.
This "record of changes" is stacked inside the `Execute()` method and
when it finally returns the change history, the status is then updated.

Also, when a transaction is created, the action is executed in "rehearsal mode,"
which obtains a set of addresses that the `Execute()` method is
trying to update.
The address set is then included in the transaction with a signature.
This prevents a recipient node from changing the account status of addresses
not included in the address set of the signed transaction.

[10]: https://docs.libplanet.io/0.2.1/api/Libplanet.Action.IAction.html
[11]: https://docs.libplanet.io/0.2.1/api/Libplanet.Action.IActionContext.html#Libplanet_Action_IActionContext_PreviousStates
[12]: https://docs.libplanet.io/0.2.1/api/Libplanet.Action.IActionContext.html
[13]: https://docs.libplanet.io/0.2.1/api/Libplanet.Action.IAction.html#Libplanet_Action_IAction_Execute_Libplanet_Action_IActionContext_


Optional Subtype Polymorphism
-----------------------------

Up to the previous version, the only usage of Libplanet actions was that
each game defines an abstract classs which implements `IAction` and
has multiple concrete classes inheriting it.
But depending on the game, there are cases where it might be better to implement
`IAction` as an only class and select a behavior based on data that goes into
the action than to define multiple types of action at the `IAction` level.
Moreover, some projects might face difficulties because the dynamic dispatcher
for `IAction` types is internally implemented using [.NET reflection][14].

Hence, from this version of Libplanet, `T` in `Transaction<T>` needs not only to
implement `IAction` but also to concrete classes.
Abstraction classes or interfaces aren't acceptable
even if they implement `IAction`,
and the presence of subtypes is completely ignored.

Instead, if you want to select the behavior of an action through
subtype polymorphism, you can use `PolymorphicAction<T>`, a new action class to
decorate another action.
For example, changing `Transaction<AbstractAction>` to
`Transaction<PolymorphicAction<AbstractionAction>>` will work as it has been
in most cases.
Of course, the `PolymorphicAction<T>` class uses .NET reflection under the hood.

[14]: https://docs.microsoft.com/en-us/dotnet/framework/reflection-and-codedom/reflection
[15]: https://docs.libplanet.io/0.2.1/api/Libplanet.Action.PolymorphicAction-1.html


Furthermore,
------------

There have been lots of other changes on Libplanet 0.2.0, so check them out in
our [release notes][2].

FYI, two days after the release of *0.2.0*, a new version with some
troubleshooting issues is now released, with the latest version being
[0.2.1][15] (as of April 9, 2019).

If you're curious, install and have a look around.
And If you have any questions, please join our [Discord chatroom][16]!

[15]: https://github.com/planetarium/libplanet/releases/tag/0.2.1
[16]: https://discord.gg/planetarium

---
title: Decentralization Intersects with Online Game
date: 2020-10-08
authors: [muhun.kim]
translators: [kidon.seo]
---

Hello all! I'm Muhun Kim, an engineering intern at Planetarium for the past two months. I was involved in the beta process prior to the launch of [Nine Chronicles].

In this post, I’d like to introduce a technical example that I thought was unique when combining blockchain and games.

[nine chronicles]: https://nine-chronicles.com

## Decentralization

Online games use servers to operate services, such as multi-play and user data. However, if services go down for a number of reasons, such as when game companies shut down, you will no longer be able to play the games.

If everyone can divide online game services and maintain them, people won’t need to worry about shutting down as long as players keep playing. Decentralization, which fits this concept, means sharing the role of traditional central servers with fellow users. You've probably heard of <abbr title="Peer to peer">P2P</abbr> or distributed technology at least once.

[^1]: Computer that participates in the blockchain network.

## Chain Reorganization

Planetarium utilizes blockchain among many decentralized technologies to preserve data such as game assets, user items, and quests achieved.

Meanwhile, when you store game data in the blockchain, sometimes the information reverts back a few hours. This is a known defect called <dfn>reorganization</dfn> in the blockchain network.[^mirage] In the blockchain community, this is called <dfn>reorg</dfn> for short. I’ll also refer to this concept as reorg.

[^mirage]: Our engineering team calls this a mirage phenomenon because the game data disappears like a dream.

{{<
figure
  src="images/single-chain.png"
  caption="Blocks connected in order are called a chain."
>}}

Before explaining reorg, I’d like to point out that a blockchain network always points to a single chain as its original copy.

Blocks in a blockchain can be created by anyone. However, if nodes create blocks simultaneously, multiple chains with the same beginning but different ends appear. If so, how can we adopt a chain as the original even though there’s no central figure to decide?

{{<
figure
  src="images/orphaned-block.png"
  caption="At similar points in time, the chain with more resources used will be adopted."
>}}

Instead of choosing its own chain, each node chooses the chain that best fits the rule shared by all nodes. The <abbr title="proof-of-work">PoW</abbr> approach used by Nine Chronicles and Libplanet, adopts the chain with more resources invested in among blocks created at a similar time.

{{<
figure
  src="images/orphaned-blocks.png"
  caption=" The blue chain with 5 blocks, is reorg-ed to red blocks. (Deep Reorg)"
>}}

But when another chain that better meets this rule than the adopted chain appears in the network, the network will adopt the new chain which will cause a flip.

Normally, a shallow reorg occurs with one or two blocks, but if the depth of divided blocks is greater than a certain number, a deep reorg occurs. For example:

1. Chains are divided at A and B and broadcasted to other nodes.
2. The number of nodes that either received chain at A or B increases at a similar rate and the length of the chain increases.
3. All nodes have adopted either chain at A or B, and because the chain at A is longer than B, the rate of adoption is higher.
4. All nodes that have adopted chain at B will be reorg-ed to A.

<style>
@media screen and (min-width: 70em) {
  img[src="images/bug-report.png"] {
    width: 60%
  }
}
</style>

{{<
figure
  src="images/bug-report.png"
  caption="A user who owned 10,000 gold yesterday reported having less than 1,000 gold."
>}}

So, as I have said earlier, it's been often mentioned in the Nine Chronicles community that the level and items users originally had ended up reverting back to what they were a few minutes or hours ago due to reorg.[^nonce] Because this occurs on a decentralized network, players unfortunately can't ask a central operator(i.e. game company) to restore it.

[^nonce]: The player's perspective was well explained in the [game review](https://dpsyphle.ninja/2020/08/16/rollbacks-in-decentralized-games.html) written by See-eun Ha, Co-founder of Blockchain Co-living and Co-working Community, Nonce.

## Blockchain Network Reset

Nine Chronicles has reset its blockchain network seven times during the beta period. When the network is reset, all players’ game data becomes reset as well. Here’s the reason why the reset was carried out despite certain risks:

The blockchain network core [Libplanet] stores the state of the game in blocks. Player’s behavior is stored with a data structure called [Action](https://docs.libplanet.io/0.9.5/api/Libplanet.Action.IAction.html).

```json
{
  "stageId": "123",
  "id": "ntPSdIREOUOARaRYJHlGEg==",
  "equipments": ["KTm6cLkrtEWs6k4A821K3Q=="],
  "avatarAddress": "sGo0bo0VwrYA7ubq6yV8ctiU2vc=",
  "foods": [],
  "worldId": "3"
}
```

If a costume element is updated within the game, a new property is added, such as `costumes`, and the hash[^hash] of the block containing this information does not match the protocol that creates the hash of the previous block. And if the protocol changes, previous block data will not be able to be used consecutively.[^expansion] In addition, the protocol changes if the unique values are different, or if the code in [Libplanet] or its SDK is modified that affects the hash.

In these cases, other blockchains usually add protocols to interpret blocks differently after a certain number of blocks. Nine Chronicles may do the same, but we found this method to be unnecessary during the beta period, when changes are frequent, large and small. That's why we decided to reset the chain every time.

Of course, we will be maintaining the chain after the official launch. A number of suggestions have been reviewed, and if there is a chance, we will introduce them on this blog.

[^hash]: A blockchain connects the chain using the hash of the previous block as a meta information, similar to a linked list.
[^expansion]: It is possible that game clients with expanded specifications may not be able to interpret the previous block correctly.

[libplanet]: https://libplanet.io/

## Closing

Planetarium is looking forward to establishing a new type of game culture with "community-run online games." Sometimes we see on the media that an employee of an online game company embezzled game resources, destroying the game's ecosystem. Nine Chronicles can't do that in principle because the rules of the game are transparent to the protocol level.

Despite these advantages, the blockchain protocol used by Libplanet can be felt as an entry barrier. It's similar to the shock I felt when I first saw Git, which distributes the work by line and merges automatically. So we’d love to hear about your experience, thoughts, and concerns playing Nine Chronicles on our [discord channel](https://discord.gg/planetarium) and on GitHub[^github].

This post will be published as a series, and the next issue will introduce Nine Chronicles' handling of reorg and chain resets. Thanks!

[^github]:
    In addition to the Blockchain Core for P2P online games — [Libplanet](https://github.com/planetarium/libplanet),
    Libplanet-based SDK for Nine Chronicles — [Lib9c](https://github.com/planetarium/lib9c), Blockchain Node Service dedicated to Nine Chronicle Clients — [NineChronicles.Standalone](https://github.com/planetarium/ninechronicles.standalone), we will also be releasing the repositories of the launcher and game client for Nine Chronicles.

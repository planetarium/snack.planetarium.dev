---
title: Libplanet 0.3 Released
date: 2019-05-31
authors: [seunghun.lee]
translators: [kidon.seo]
---

Hello everyone, we are happy to announce that the third minor version of [Libplanet]---[Version 0.3][1], has been released.

Libplanet is a common library that solves game implementation problems such as P2P communication and data synchronization when creating online multiplay games that run on distributed P2P.

This post will cover key changes in Version 0.3.

[Libplanet]: https://libplanet.io/
[1]: https://github.com/planetarium/libplanet/releases/tag/0.3.0
[2]: {{< ref "libplanet-0.2.eng.md" >}}


Responsive APIs for Nodes with Different Versions
-------------------------------------------------

In Version 0.2, we added the `appProtocolVersion` parameter on the `Swarm` constructor to designate a protocol version to a node. 
Now from Version 0.3, you can use the `Swarm.DifferentVersionPeerEncountered` event handler to specify the behavior when 
encountering nodes with different versions.

For example, if you receive a message from a higher protocol version, you can configure `Swarm.DifferentVersionPeerEncountered` so that it requires game app upgrades.


Action Rendering API
--------------------

Previously, game apps weren't able to receive a signal (event) indicating completion of an action---specifically, whether or not the execution of an action was reflected in the results of `GetStates()` method. 
Therefore, in order to ensure that an action for a particular address was processed, you had to use methods like [polling][3] to determine if the state of the address changed to a post-action state. 
Not only was this approach complex and cumbersome to implement, but it also had performance issues because the method needed to check the account states multiple times.

To address this issue, an Action Rendering API has been added in this version. 
The [`IAction.Render()`][4] method allows games to receive an event that reflects the outcome of an action in the local states.
Also, if a block containing a processed action becomes invalid due to a change in the majority chain, the [`IAction.Unrender()`][5] method allows you to revert an action that has already been rendered.

[3]: https://en.wikipedia.org/wiki/Polling_(computer_science)
[4]: https://docs.libplanet.io/0.3.0/api/Libplanet.Action.IAction.html#Libplanet_Action_IAction_Render_Libplanet_Action_IActionContext_Libplanet_Action_IAccountStateDelta_
[5]: https://docs.libplanet.io/0.3.0/api/Libplanet.Action.IAction.html#Libplanet_Action_IAction_Unrender_Libplanet_Action_IActionContext_Libplanet_Action_IAccountStateDelta_


Improved Accessibility to Account States
----------------------------------------

In previous versions, we sequentially searched blocks until finding the one with the latest update of the account states.
In this approach, searching for the account states never made required all blocks to be checked starting from the latest address down to the very end. 
Additionally, accounts that had not been updated for a long time while new blocks were continuously added on required you to circle lots of blocks, 
and the longer the chain length, the longer you had to check.

In this version, we have improved search performance by indexing the blocks with the states of each address when saving, 
and directly searching a block when accessing the states.


Improved Performance on Appending Blocks
----------------------------------------

The implementation process that follows when adding blocks to the blockchain has been greatly improved on Version 0.3.

- Redundant validation process when accessing blocks already added to the chain has been removed.
- We've moved on from validating the entire chain when adding a block to just validating that specific block.
- Instead of calculating every time a block hash is required, we now only calculate once when a block is created.
- We've reduced hash calculation time by deriving it from a transaction ID instead of the entire transaction.
- Multiple action evaluating process when adding a block has been reduced to once, minimizing overall block adding time.


Furthermore,
------------

You can learn more about additional changes in [our release notes][1]. 

And as always, if you have any questions about the new release or Libplanet in general, please visit [our Discord chatroom][6] and let’s chat!

[6]: https://discord.gg/planetarium

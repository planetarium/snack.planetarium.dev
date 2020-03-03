---
title: "Game Developer Meets Libplanet 😂"
date: 2020-02-26
authors: [hyun.seungmin]
translators: [kidon.seo]
---

Hello, I'm Hyun Seungmin from Planetarium game dev team. Today, I’ll talk about applying <dfn><abbr title="peer-to-peer">P2P</abbr></dfn> structure to a game using Libplanet instead of the typical <dfn>client–server</dfn> structure. Please note that the contents are entirely based on my experience.

First, let's talk about the *client–server* structure. Most projects I've participated in dealt with client-server structures. In these structures, protocols are constructed for communication purposes, designed to be similar to Web communication. When a client makes a request and hands it over to a server, the server makes a response and returns it to the client. The request mainly consists of a value entered by the user, and the response contains error codes with the protocol's success or failure information and the affected status value (i.e. the <dfn>change</dfn>). Of course, the response doesn't need to include changes that could be predicted by the client (including the amount of gold remaining after purchase in response to a purchase request).

Next, let's look at the *P2P* structure that I'm currently developing. Libplanet constructs the protocol mentioned above in a class (i.e. <dfn>action</dfn>) that implements the `IAction` interface. When a client creates an action and hands it over to a node, the node collects the actions, creates a transaction, collects the transactions, and then creates a block. In this process, a `Render` and an `Unrender` event occur for each action, which allow the client to know whether the action is *successful* or has been *rolled back*.

Although it may seem like a similar structure, on a client–server, the request and response may be separated so the response can contain request information (success or failure, the detailed reason if it fails) as well as the changes. On P2P the other hand, only the request (action) exists and only its information (even render or unrender information requires the node to meet a condition in which it does not stop) can be known. Instead, an interface to access the *before and after status of the action* in each render or unrender stage is provided.

The difference addressed above created a concern for me.

> How can we know the changes?

The issue was that when executing the action of adding an item to the character inventory, I wanted to avoid recreating the entire inventory.
### 1. Compare Before and After Status Values of an Action's Render

The 1st option I thought of was to compare status values before and after the render of an action and extract the changes. However, I was worried that there would be performance issues while deserializing information serialized in blocks, casting them into status values A and B, and then comparing the two at every render·unrender stage. Status values A and B were already large, and there was plenty of room for further growth.

### 2. Include Changes in Each Action

With my 2nd option, I thought that I could accomplish my goals without changing the existing structure and started right away. Despite the feeling that everything was going the way I wanted it to go, I realized that the tests we've done so far were on single nodes, and that there would be problems in a multi-node environment. Here’s why.

All nodes participating in the network process a specific action, and `IAction.PlainValue` property and `IAction.LoadPlainValue()` method ensure that two processing results will be the same even if an action is processed and transmitted from another node. Although it seemed to work on a single node, I realized that in order for it to work on a multi-node, you had to include changes in the property, not somewhere else in the action. And if you actually went through this process (which I did to see what would happen), an `InvalidTxSignatureException`  occurs. This happens when the status value of an action changes. So the exception obviously occurs because the change is empty when you create an action and is filled after the action is rendered. From this process, I realized that the *status value of an action is written so that it wouldn't change*.

Then I thought maybe I could include *predictable changes* when creating an action. Unfortunately, this was easy to hack since the node would simply believe what the client created, so I cleared this idea from my mind in no time. But what if there was a way to verify the *predictable change* within the action? So I asked the engine team, and they responded that the `IRandom` interface provided by the engine is completely objective and therefore, a *predictable change* does not exist. Now that’s good news.


### 3. Include Changes in Target Status Value of Each Action

This method seemed fine, too. I had an expectation that including changes of an action in the target status value would allow us to achieve our goal with a simple expansion without structural modification. The changes of each action piled up in the target status value, and the client would refer to those changess stacked in the target status value at the render stage of a particular action. The change already calculated once didn’t need to be recalculated, and the reference timing of the change was also contextually secure, so client development was smooth. But of course, problems were bound to rise.

> How do we manage life cycles of specific actions’ changes that accumulate in the target status value?

Since change in status value only occurred through an action, a separate action was required to eliminate any changes that were no longer needed. If a target status value is changed to stack changes of Action A, and Action B is used to remove changes that are no longer needed, should those changes be put in the target status value? Yes, there was a logical exception so I've put this plan on hold.

----

Even while writing this piece, Libplanet has become continuously powerful. The `IActionContext` type factor, which is achieved in the execution stage of an action, provides an `IRandom` interface so that the same result can be conclusively obtained across all nodes regardless of the action's status value. While the random object provided by Unity cannot provide the same result across all nodes, the `IRandom` interface can provide one. Do you see how option 2 might once again be possible?

Next time, I'll talk about the `IRandom` interface and how to create a beautiful client environment.

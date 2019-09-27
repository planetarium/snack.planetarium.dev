---
title: Applying Kademlia Distributed Hash Table to Libplanet
date: 2019-09-17
authors: [chanhyuck.ko]
translators: [kidon.seo]
---

Hello, I'm Chanhyuck Ko of Planetarium Dev Team. In this post, I'm going to take some time to briefly explain what [Kademlia] is, one of the [distributed hash table] techniques for efficiently configuring distributed P2P networks, and why it was applied to our project, [Libplanet].

[distributed hash table]: https://en.wikipedia.org/wiki/Distributed_hash_table
[Kademlia]: https://en.wikipedia.org/wiki/Kademlia
[Libplanet]: https://libplanet.io/


What is Kademlia?
---------------------

Distributed Hash Tables (DHT) store and manage data across nodes on a network. When locating data on a network, they play a major role in reducing each node’s load by finding the node that has that data first and then asking for a value.

Various DHT implementations store nodes in their own routing tables in different ways. So how does Kademlia implement a distributed hash table? Let me give you a quick example. Let's go back to 2008 and talk about Kim, a Korean American who lives in Los Angeles. He is visiting Korea to see his friend after a long time, and just got off at Incheon International Airport.

> I’d like to go to my friend's house, but I don't know where it is.

Gee, I think Kim is lost. In 2019, he would have taken out his smartphone and entered the address, but in 2008, he doesn’t have one because it’s not yet popular. Kim takes a closer look at the only information, the address.

> *1-91 Sejong-ro (street), Jongno-gu (district), Seoul (city)*

Without much choice, Kim first heads to Seoul city. And there, he goes up to people and asks them for directions, but not many know where the address is exactly. So, Kim changes his strategy and starts asking how to get to Jongno-gu. There are quite a few people who knows Jongno-gu, and after many twists and turns, Kim arrives at Jongno-gu. Now it's time to ask about Sejong-ro!

Although Kim didn't know the exact location of the address, he gradually narrowed it down and eventually reached his friend's house. Similar to Kim’s example, each peer on a Kademlia network also maintains and searches for peer information.

Peers of a network have virtual addresses. It's not a geographical address like *"1-91 Sejong-ro, Jongno-gu, Seoul"*, but a series of bytes assigned at random or by set rules. As for distance, it’s defined as an [exclusive disjunction] of the address values of two peers, rather than the physical distance between the actual peers.

Instead of containing information from every peer on the network in their routing tables, peers using Kademlia protocol classify them according to the distance defined above and store only a limited number of peers per distance range. Peers with a distance of at least 2<sup>i</sup> and up to 2<sup>i+1</sup> are stored in the i-th row of the routing table. This optional storing of peer information in a routing table allows you to locate peer B by requesting information to a peer that is closest to B that you know, and then repeating this series of request until it leads to B.

[exclusive disjunction]: https://en.wikipedia.org/wiki/Exclusive_or#Computer_science


Reason for Applying Kademlia
----------------------------------

To configure a P2P network that communicates without a server, communication between all peers must be guaranteed. But not all peers have to be directly connected to each other. Take a look at these three peers- A, B and C.

In a traditional Libplanet, we built a network like this. It was a configuration in which all the peers were connected.

{{<
figure
  src="1.png"
  caption="All the peers are connected to each other."
>}}

This is not a big deal when the network is small, but if you have, say 1,000 peers, or 10,000 peers, it's a lot of pressure every time you send that message to the network. 

{{<
figure
  src="2.png"
  caption="Peers overloaded with excessive transmission."
>}}

Using Kademlia, each row of routing tables will consist of peers whose distances are within the same range. When transmitting data, you select and send message to all peers in each row of the routing table, and those peers will do the same for all peers in their own tables. Eventually, every peer on the network will be able to receive the message. In this way, when N peers are on the network, one peer will only send a message log(N) times, preventing the network load from being concentrated on one peer.

{{<
figure
  src="3.png"
  caption="A Network transmitting messages."
>}}


To Conclude 
-------

In order to give users a sense that their actions are processing fast, you need to frequently create blocks of transactions that contain those actions. But the more frequently a block is created, the more network load a miner will receive. To ensure a stable network as its size grows, distributed hash tables had to be applied to Libplanet. In return, we were able to run a test and see that the network load on a single peer was reduced in a harsher setting.

If you have any questions about Kademlia distributed hash table or Libplanet, please visit our [Discord chatroom] and let’s chat!

[1]: https://discord.gg/ue9fgc3

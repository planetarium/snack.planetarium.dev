---
title: "Libplanet PBFT Transitioner Episode 0 - Why did you switch to PBFT?"
date: 2023-04-24
authors: [suho.lee]
ogimage: images/og.eng.jpg
---

Hello. My name is Suho Lee, and I am working as a Libplanet team in the blockchain division at Planetarium. Today, I would like to share the first episode of an article that explains the reasons and process for Libplanet to switch to PBFT. In this blog post, we will discuss the Libplanet blockchain consensus change process, including the reasons for the change, the specific changes made, and the advantages of the new consensus algorithm.

## Introduction

Blockchain technology is revolutionizing the world, and Libplanet is one of the leading blockchains. `Libplanet` is highly scalable and decentralized, built on the .NET platform, and is open-source. The platform is highly efficient and secure, using a unique consensus algorithm that ensures network integrity.

## Let’s talk about Nine Chronicles

As the Libplanet team, we would like to provide an overview of the evolution of block creation in Nine Chronicles since 2020. Initially, we employed the "Proof of Work" method, which involved participants solving problems, with the block of the individual who solved the most difficult problem in the shortest time being selected. However, we encountered two significant issues with this approach:

1. There was no assurance that the individual who solved the most challenging problem would make decisions that benefited the entire community. In some cases, a block with no data was created, and we were compelled to accept it if the problem was more difficult.
2. When a more difficult problem was solved and a block with a higher total difficulty emerged, we had to accept that previous data might change, which was far from ideal.

These challenges negatively impacted the gaming experience, resulting in blocks without data and rollbacks in game progress. Consequently, in 2021, we at Planetarium decided to recognize only the blocks created by ourselves as the official chain to ensure the game could progress effectively.

Nonetheless, we did not want to become the sole authority determining the blocks in Nine Chronicles. Our initial proposal, NCIP-10, was never realized for various reasons. Undeterred, we revised our plan and established NCIP-13. As of 2023, PBFT and any future developments are based on NCIP-13 by default, ensuring a more robust and effective approach to block creation and management.

## Problems with Proof of Work in Blockchain Games

As the Libplanet team, we understand the importance of ensuring network security and efficiency in blockchain games. We know that continuing to use PoW as the consensus algorithm has raised concerns from both internal and external sources due to issues related to finality and chain reorganization.

The lack of finality in PoW can result in transactions not being immediately confirmed on the network, and the possibility of forking means that chain reorganization can occur, causing problems for various services that view the chain. In particular, chain reorganization is another important problem with PoW in small chains. In small chains, it was easy to solve more difficult problems and reorganize the chain as desired, which can have a negative impact on gameplay delays and user experience.

The Libplanet team takes these concerns seriously and is working to transition to a more efficient and secure consensus algorithm, especially Delegated Proof of Stake (DPoS), to provide a better user experience.

By adopting DPoS, we can provide better finality guarantees and avoid chain transition-related issues. DPoS is a consensus algorithm where stakeholders elect delegates to verify transactions on their behalf. This system is more efficient than PoW and avoids the need for miners to solve complex mathematical problems or multiple nodes to verify the same transaction. Instead, stakeholders elect delegates to assume responsibility for verifying transactions.

However, transitioning directly to DPoS is a lot of work. We need to implement fee collection systems and delegation distribution algorithms that were not previously considered in PoW.

Therefore, we have decided to transition to DPoS via Practical Byzantine Fault Tolerance (PBFT).

## Practical Byzantine Fault Tolerance (PBFT)

PBFT is a Byzantine fault-tolerant consensus algorithm that enables the network to reach consensus even when some nodes fail or behave maliciously. Unlike PoW, validators are selected, and the chain progresses through block creation and voting processes among them.

However, PBFT alone cannot achieve a public blockchain. There must be individuals or organizations that can manage these validators, which leads to centralization of the chain.

Therefore, the Delegated Proof of Stake (DPoS) algorithm is the way to select these validators according to the rules and allow individuals or organizations that make more contributions to have more influence on chain consensus, thus avoiding the centralization problem of PBFT.

## Delegated Proof of Stake (DPoS)

The Delegated Proof of Stake (DPoS) consensus algorithm allows users participating in the chain to elect delegates to verify transactions on their behalf, and the delegates receive rewards for doing so, thereby avoiding the centralization problem of PBFT.

By achieving this, the consensus change process of the Libplanet blockchain becomes more democratic, ensuring that the community can participate in the consensus algorithm selection process. This makes the platform more future-oriented by continuously improving it, ensuring that the network continues to evolve.

## Benefits of Changing the Libplanet Blockchain Consensus

There are several benefits to changing the Libplanet blockchain consensus.

First, it guarantees network security and efficiency. By transitioning to a more efficient and secure consensus algorithm, the Libplanet team ensures that the network can handle more transactions and stay secure.

Second, it is democratic. The community can participate in the consensus algorithm selection process, and by adopting DPoS, the network is governed by the people who use it, rather than centralized authorities.

Finally, the consensus change process ensures that the Libplanet blockchain can maintain relevance. By continuously improving the platform, the Libplanet team maintains competitiveness in a changing blockchain environment.
Conclusion

The Libplanet team is working to provide a better blockchain gaming experience for all users. By transitioning to the Delegated Proof of Stake (DPoS) consensus algorithm, we can provide better finality guarantees and avoid chain transition-related issues. DPoS is a more democratic system than PoW or Practical Byzantine Fault Tolerance (PBFT), allowing stakeholders to participate in the verification process. However, there are many considerations when transitioning to DPoS directly, so we have decided to prioritize transitioning to PBFT.
Next Story

We will talk about the considerations we had to make when transitioning from PoW to PBFT.

---
title: Testing P2P Game with Kubernetes
date: 2020-02-20
authors: [swen.mun]
translators: [kidon.seo]
---

Hello, I am Swen Mun, [Libplanet] developer at [Planetarium]. From December 16th last year, we held a 2-week alpha test of [Nine Chronicles], a completely decentralized MMORPG. Today, we're going to share our experience deploying headless games on [Kubernetes].


[Planetarium]: https://planetariumhq.com
[Nine Chronicles]: https://nine-chronicles.com
[Libplanet]: https://libplanet.io
[Kubernetes]: https://kubernetes.io/


What Did We Need?
-----------------

A game developed with Libplanet is considered a blockchain node, and the same goes for Nine Chronicles. That is, every game client can play a role that is in itself similar to a typical game server (data storage, refereeing). To hold a test as close to a game environment in this P2P environment, we needed to run as many of these game clients at the same time.

Although we will be running the games, we’re focused on executing as many game clients at the same time so it's not that important to see the screen of each client. Therefore, we’re OK with running headless without any UI.

Test Conditions 
----------------

- Games under testing (as with software in general) may need to be updated as necessary. It's not a good strategy to go around all running clients and update them one by one.
- While it's easy for an individual developer to run one or two clients, we want to test far more than just a handful.
- Although we will be running the games, we’re focused on executing as many game clients at the same time so it's not that important to see the screen of each client. Therefore, we’re OK with running [headless] without any UI.


[headless]: https://en.wikipedia.org/wiki/Headless_software


Docker
-----------

To meet these conditions, we needed to run and manage multiple processes at the same time, and that led us to use [Docker]. Docker is a popular solution for containerizing and running Linux applications throughout your environment. Although we’re not considering Linux as a major platform for Nine Chronicle’s first launch, developing games with Unity has made it relatively easy to produce a build for Linux, and apart from minor UI bugs (which doesn't matter much for the headless test node), the behavior didn't change much.


[Docker]: https://docker.com


Kubernetes
--------------------

Even though we used a Docker to make a container that easily runs game build, that wasn't the end. Our goal was to easily run/end/update many clients while maintaining test environment. To do this, just using Docker wasn’t enough.

Our first option was the execution environment offered by cloud providers, such as <abbr title="Elastic Container Service">[ECS]</abbr>. These execution environments are designed to efficiently set up complex workflows. But in other words, they're complex to set up and we wouldn’t be using a lot of functionality provided since we’re just using it in a test environment. Also, a test environment dependent on a particular cloud provider would likely to be a burden on future operations.

{{<
figure
  src="comparison.png"
  caption="AWS Container Orchestration Comparison"
>}}

So the alternative we came up with was Kubernetes. Kubernetes is an open-source project that allows us to do what we want similar to services like ECS while being Provider Agnostic. The feature of running and stopping complex containers is called container orchestration, and because we wanted to run multiple containers (games) of the same kind, the setup wasn't that complicated.

[ECS]: https://aws.amazon.com/ecs/?nc1=h_ls


Coming Up
----------

Next time we'll take a look at the specific procedures for setting up the Kubernetes for testing and how to deploy it on the cloud.

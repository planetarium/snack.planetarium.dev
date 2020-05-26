---
title: Team Libplanet is Participating in 2020 Sprint Seoul!
date: 2020-05-19
authors: [suho.lee]
translators: [kidon.seo]
---

Hello all! We are Team [Libplanet], participating in  this year’s [Sprint Seoul][1] as project lead.

We have been consistently participating in Sprint Seoul, and this year’s no different! Although Sprint Seoul has been an event to solve problems together in a short time, this year’s Sprint Seoul is being held throughout May.

Due to this change, we have prepared long issues for people who want to take longer period of time to solve as well as short issues that are great for first time contributors.

Also, we are preparing **small gifts** for those who participate in the sprint and contribute to our repository, so please do participate!


[1]: https://sprintseoul.org/
[Libplanet]: https://libplanet.io/


Project Intro
-------------

[Libplanet] is a networking ・ storage library for creating P2P multiplayer games that run without servers like BitTorrent, and to achieve this, it implements block chain technology. The game apps that each user runs are connected to each other on the network, and instead of having a main server for fair judgment and keeping record of the game, fair judgments are made through consensus algorithms and records are made through replication.

There are three repositories to cover in this Sprint: You can contribute to different repositories depending on your familiarity or preferred environment. For your information, all three repositories can be developed on three platforms: Linux, MacOS, and Windows.

 -   [Libplanet][libplanet-core]: This is the core of our project that implements networking, storage, and blockchain, on a multi-platform, written in C# for use with game engines such as Unity.

 -  [Libplanet Explorer (Server)][libplanet-explorer]: This is a C# app that makes accumulated blockchain data on distributed networks of games created with Libplanet viewable outside the game through the GraphQL protocol.

 -  [Libplanet Explorer (Web)][libplanet-explorer-frontend]: This is a relatively end-user-oriented Web app (client) that implements the web server’s data provided via GraphQL as a Web front end. It is written using TypeScript, React, Gatsby, and Apollo.

Since *Libplanet Explorer (Web)* is written in TypeScript, for those of you who are not familiar with Blockchain technology or C# but are interested in Libplanet, you can definitely contribute.

[Libplanet]: https://libplanet.io/
[libplanet-core]: https://github.com/planetarium/libplanet
[libplanet-explorer]: https://github.com/planetarium/libplanet-explorer
[libplanet-explorer-frontend]: https://github.com/planetarium/libplanet-explorer-frontend


C# Dev Environment
---------

First, we need to set up a development environment to participate in C# projects. Unlike Python or JavaScript, C# is a language that is difficult to code without IDE. For Windows, you can install the latest version of Visual Studio, but we recommend Rider or VS Code as an IDE that can be written across multiple platforms. The documents below guide you in Korean on how to install the development environment of Libplanet assuming that you use Rider or Visual Studio Code (we recommend using Google Translate for English).

 -  [Libplanet Dev Environment Configuration (VS Code)][5]
 -  [Libplanet Dev Environment Configuration (Rider)][6]

In addition, the *[CONTRIBUTING.md]* document in the Libplanet repository guides you through the very basic development environment using CLI tools only. If you really want to use your own editor, please read this.

[5]: https://gist.github.com/dahlia/5333634f62509293cd46c0e4ba65b2f5
[6]: https://gist.github.com/dahlia/08f6e659e2266e941ad026f591c30c9a
[CONTRIBUTING.md]: https://github.com/planetarium/libplanet/blob/master/CONTRIBUTING.md

TypeScript Dev Environment
-------------------

The TypeScript development environment is much simpler than the C# development environment. It's well organized in the *[README.md]* document of the Libplanet Explorer (Web) repository, so you can easily follow it.


[README.md]: https://github.com/planetarium/libplanet-explorer-frontend/blob/master/README.md

Issues Worth Looking At
----------------

For first-time contributors, we’ve organized first-timer issues for each project.
- [Libplanet][7]
- [Libplanet Explorer (Server)][8]
- [Libplanet Explorer (WEb)][9]

These are things that you can do without getting a detailed understanding of the project structure.


We also have a *help wanted* label for those looking for more challenging issues.
- [Libplanet][10]
- [Libplanet Explorer (Server)][11]
- [Libplanet Explorer (Web)][12]

[7]: https://github.com/planetarium/libplanet/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22
[8]: https://github.com/planetarium/libplanet-explorer/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22
[9]: https://github.com/planetarium/libplanet-explorer-frontend/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22
[10]: https://github.com/planetarium/libplanet/issues?q=is%3Aissue+is%3Aopen+label%3A%22help+wanted%22
[11]: https://github.com/planetarium/libplanet-explorer/issues?q=is%3Aissue+is%3Aopen+label%3A%22help+wanted%22
[12]: https://github.com/planetarium/libplanet-explorer-frontend/issues?q=is%3Aissue+is%3Aopen+label%3A%22help+wanted%22

See Yourself a Bit Hesitating?
----------------------

For those of you who are either worried or hesitant about contributing to the project, we recommend reading the experiences of our past contributors and decide.


- <cite>[First Contribution to Libplanet][13]</cite> by Seunghun Lee
- <cite>[After participating in the 2019 Sprint Seoul June event…][14]</cite> by Suho Lee

[13]: {{< ref "first-contribution.eng.md" >}}
[14]: https://blog.hanaoto.me/sprint_seoul_2019_june/

Questions & Conversations
--------------

If you have any questions or concerns, please join the #libplanet-users channel at [our Discord server] and ask away! We’re open for any questions before the event and after the event. If you want to just come and hang out, our doors always open!


[our Discord server]: https://discord.gg/wUgwkYW

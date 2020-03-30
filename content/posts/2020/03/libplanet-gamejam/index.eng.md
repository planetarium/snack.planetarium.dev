---
title: "Libplanet Game Jam"
date: 2020-03-19
authors: [seunggeol.song]
translators: [kidon.seo]
---

Hello, I'm Seunggeol Song, a game client programmer at Planetarium. This time, I'd like to share with you my experience in the in-house [game jam][]
held at Planetarium.

Here at Planetarium, we use our own blockchain game library, [Libplanet][], to create games. Because Libplanet is currently being developed with the assumption that it will be primarily used in [Unity][], we have decided to build an [SDK][] for Unity to enhance usability within the engine. To aid our development process, we held an in-house game Jam of creating small example Unity projects using Libplanet.

Groups of 2 or 3 people were formed and for 2 days before the opening day, we got together to brainstorm potential game projects and eventually came up with 5 dazzling game proposals to apply blockchain technology. I teamed up with [Chanhyuck Ko][] to make a game of [Omok (Five in a Row)]( https://en.wikipedia.org/wiki/Gomoku). To make two players battle, we implemented the concept of a session (i.e. the **room** of the game), using the concept of `Action` and `State` in Libplanet.

{{<
figure
  src="screenshot.png"
  caption=" The Great Looking Omok Game We Created!"
>}}

First, let me introduce some key states and the actions that change them.

`SessionState`: This state saves the session’s information. There is a unique key (room title concept) to distinguish a session from a list in `AgentState`, which is the player information in the session. There is also an address that lets you have access to this state.

`AgentState`: This state saves account information of a player. Here we have the player's information (typically wins and losses) and address.

`PlayerState`: This state saves information about the Go stones used by a player in the game. The coordinates of the stones in the Omok table are stored.

`JoinSession`: This action joins a session with the key a player enters. If there’s no session with the entered key, this action creates a new session with that key. This will change `SessionState`.

`PlaceAction`: This action places a Go stone on the Omok table. This changes the stone information of `PlayerState`.

`ResignAction`: This action surrenders the game. It changes both players' `AgentState`, recording a loss to the loser and a win to the winner.

For more specific internal implementation or code, visit the [Github repository][]!

From the overall experience, I felt that the key to developing blockchain games using Libplanet is ultimately knowing how to deal with these states and actions. Action changes states and we take those states in-game logic to play the game. Before game jam, I didn't have the chance to develop an action myself because I had only recently joined Planetarium. But after implementing the general concept of the session with Chanhyuck Ko, I was able to understand the meaning of action and state and their general usage. It was a great learning experience in many ways.

[game jam]: https://en.wikipedia.org/wiki/Game_jam
[Libplanet]: https://github.com/planetarium/libplanet
[Chanhyuck Ko]: https://github.com/limebell
[Github repository]: https://github.com/planetarium/planet-omok
[Unity]: https://unity.com/
[SDK]: https://en.wikipedia.org/wiki/Software_development_kit


Closing 
-----

If you’re also interested in learning these concepts, I recommend you to take a look at the [Planet Clicker GitHub repository][], which is a clicker game that's easy to use while getting familiar with the action and state structure. And as always, if you have any questions, please visit our [Discord chatroom][] and let’s chat!

[Planet Clicker GitHub repository]: https://github.com/planetarium/planet-clicker
[Discord chatroom]: https://discord.gg/planetarium

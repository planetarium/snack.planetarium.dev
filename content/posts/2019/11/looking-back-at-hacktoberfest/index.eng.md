---
title: Looking Back on Hacktoberfest
date: 2019-11-08
authors: [swen.mun]
translators: [kidon.seo]
---

Hello, today we'd like to present you with some of the contributions [Planetarium] received from participating in [Hacktoberfest] during the month of October.


# Overview

For Hacktoberfest, we prepared a total of 36 issues, and 15 were handled through contributions.

{{<
figure
  src="1.png"
  caption="Contributed Issues"
>}}

After a month of contributions, we learned some interesting facts:

- Half the contributions were focused at the beginning of the month. It appears that our contributors were quite eager from the start of Hacktoberfest. 🏃
- Most issues contributed were for beginners (`label:"good first issue"`).
- Our 3 projects-- [Libplanet], [Libplanet Explorer], and [Libplanet Explorer Frontend]—all received fairly equal contributions.


# Memorable Contributions

- [Auto refresh when block mined][planetarium/libplanet-explorer-frontend#37] contributed by [@MaxStalker] was quite a tough issue, as the number of issue comments indicates. While Libplanet Explorer Frontend requires the GraphQL backend, Libplanet Explorer, the GraphQL backend we prepared kept malfunctioning, causing a long wait for our contributor. 😢 So, we would like to take this opportunity to thank @MaxStalker for completing his contribution by walking us through trouble shooting at our [Discord Chatroom] [2] even after the service had been normalized. 🙇

- We thank [@RozzaysRed] for contributing to issues labeled *hacktobberfest* as well as those that weren’t [3]. If we knew this would’ve happen, we certainly would have put *hacktobberfest* label on way more issues. 😊

- In issue [Rename “maxValue” parameters in IRandom.Next() methods][planetarium/libplanet#555], [@pBouillon] not only made contributions, but also suggested a suitable parameter name (`lowerBound` and `upperBound`). 💬


# Closing

Furthermore, we would like to thank every single one of you for your interest and contribution to our project during Hacktoberfest.

Hacktoberfest is over, but fortunately, we're always open and waiting for you. If you're interested in a problem we're working on or would like to join us, please let us know at our [Discord Chatroom] [2]!


[Planetarium]: https://planetariumhq.com
[Hacktoberfest]: https://hacktoberfest.digitalocean.com/
[Libplanet]: https://github.com/planetarium/libplanet/
[Libplanet Explorer]: https://github.com/planetarium/libplanet-explorer/
[Libplanet Explorer Frontend]: https://github.com/planetarium/libplanet-explorer-frontend/
[planetarium/libplanet-explorer-frontend#37]: https://github.com/planetarium/libplanet-explorer-frontend/issues/37
[planetarium/libplanet#555]: https://github.com/planetarium/libplanet/issues/555
[@MaxStalker]: https://github.com/MaxStalker
[@RozzaysRed]: https://github.com/RozzaysRed
[@pBouillon]: https://github.com/pBouillon
[1]: https://github.com/issues?page=2&q=archived%3Afalse+label%3Ahacktoberfest+org%3Aplanetarium+updated%3A%3C%3D2019-11-01&utf8=%E2%9C%93
[2]: https://discord.gg/planetarium
[3]: https://github.com/issues?q=assignee%3ARozzaysRed+is%3Aclosed

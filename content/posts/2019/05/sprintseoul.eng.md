---
title: Libplanet Team will participate in Sprint Seoul
date: 2019-05-20
authors: [hong.minhee]
translators: [kidon.seo]
---

Did you know [Sprint Seoul][1] will be held in Gangnam this June 29th (Sat)? 
Sprint Seoul is an open source event that gathers people passionate about open source culture and encourages them to contribute codes and/or documents to open source projects. 
Even those who are interested in open source but have not been able to contribute can also come to the event and experience their first open source contribution.

> Sprint invites both authors and contributors of open source projects to get together and find/resolve issues in a short period of time,
> enabling both parties to dive deep into the projects.

Our team has already participated in the event last April, and we’re continuing our participation this coming June. We are participating as the leader of [Libplanet] Project, and we look forward to meeting you all at the event to further develop our project.

Applications for Sprint Seoul will only be accepted until June 20th, and details of the [application form] and the event can be found on the [official website][1].

[1]: https://sprintseoul.org/
[Libplanet]: https://libplanet.io/
[application form]: https://forms.gle/DHjbhgpWz9QgzpFo8


Introducing Project Libplanet 
-----------------------

For those of you who are curious about Libplanet Project, here's an introduction from <cite>[Libplanet 0.2 Released][2]</cite>.

>Libplanet is a common library that solves game implementation problems such as
><abbr title="Peer-to-Peer">P2P</abbr> communication and data synchronization
>when creating online multiplay games that run on distributed P2P.
>
>Libplanet is now being developed in C# language,
>with the aim of being used in conjunction with the popular Unity engine.
>Of course, even if you don't use Unity,
>Libplanet targets [.NET Standard 2.0][3] so that it's easy to use for
>games that are implemented on .NET or Mono.
>
>Another feature of Libplanet is that it is a library,
>not an engine or a framework.
>Since engines and frameworks control the entry point (`Main()` method) of
>a process and dictate its execution flow, game programmers have limited control 
>and can only program essentially through scripts within sections explictly allowed.
>Libplanet does not preempt the game process and operates only when it is
>explicitly invoked by the game programmer.
>This allows Libplanet to function with game engines like Unity without imposing
>additional limitations on the developer.
>
>Libplanet is listed on [NuGet] along with [API docs][4].

[2]: {{< ref "libplanet-0.2.eng.md" >}}
[3]: https://github.com/dotnet/standard/blob/master/docs/versions/netstandard2.0.md
[NuGet]: https://www.nuget.org/packages/Libplanet/
[4]: https://docs.libplanet.io/


Setting Up a Dev Environment 
---------

Before participating in Sprint Seoul, you need to install a development environment. As any project will be, setting up an environment takes much longer than people generally anticipate, which unfortunately wastes valuable time. So if possible, **we’d really appreciate it if you could set up an environment prior to the event.** 

Unlike Python or JavaScript, C# is a language that is difficult to code without an IDE. If you're using Windows, you can install the latest version of Visual Studio, but we recommend Rider or VS Code which can be used across multiple platforms. The following documents provide instructions in Korean on how to install a development environment for Libplanet, assuming that you are using Rider or Visual Studio Code.

- [Setting the Libplanet Development Environment (VS Code)][5]
- [Setting the Libplanet Development Environment (Rider)][6]

In addition, the *[CONTRIBUTING.md]* file in the Libplanet repository guides you through the very basic development environment settings that you develop using only the CLI tool. If you really want to use other editors, please read this file. However, we recommend that you install a well-running environment in advance, since our team may not be able to help you at the day of the event.

[5]: https://gist.github.com/dahlia/5333634f62509293cd46c0e4ba65b2f5
[6]: https://gist.github.com/dahlia/08f6e659e2266e941ad026f591c30c9a
[CONTRIBUTING.md]: https://github.com/planetarium/libplanet/blob/master/CONTRIBUTING.md


Issues Worth Checking Out
----------------

We've put together a collection of [beginner issues][7] for first time contributors. These are issues that you can do without going deep and doesn’t require you to know the entire structure of the project.

If you're worried about what and how to contribute, I think Seunghun's post, <cite>[First Contribution to Libplanet][8]</cite> will certainly help.

[7]: https://github.com/planetarium/libplanet/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22
[8]: {{< ref "first-contribution.eng.md" >}}


Reach Out!
--------------

If you have any questions, please visit [our Discord server] at #libplanet-users-kr channel and ask away! You’re all welcome to come in before or even after the event to chat with us.

[our Discord server]: https://discord.gg/wUgwkYW

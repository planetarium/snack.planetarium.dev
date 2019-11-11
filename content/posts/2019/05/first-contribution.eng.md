---
title: First Contribution to Libplanet
date: 2019-05-07
authors: [seunghun.lee]
translators: [kidon.seo]
---


Hello, I'm Seunghun Lee, member of Planetarium Dev Team. I believe one of the reasons why working at Planetarium is so attractive is that I can work as an open source developer. This piece is about my first contribution to Project [Libplanet][]. For an introduction to Libplanet, please see <cite>[Libplanet 0.2 Released][1]</cite>.

[Libplanet]: https://github.com/planetarium/libplanet
[1]: {{< ref "libplanet-0.2.eng.md" >}}

Why did I contribute to Libplanet?
----------------------------

In January, Planetarium announced its first recruiting notice and revealed a repository for Project Libplanet. Although I thought it was an attractive project by an impressive team, I was hesitant to apply because Libplanet was being developed in C# to work with Unity (my main expertise was Python). After a brief hesitation, however, I made up my mind to participate in Libplanet anyways because it was an open source project. I decided to participate in basic issues at first and see how it went.
 
C# Development Environment 
------------

As mentioned earlier, I used to mainly develop in Python on Mac. I often contributed to Python open source projects that interested me and this was easy because most Python developers also developed on Mac and were familiar with the open source environment. But as I was about to build a C# development environment on Mac, I found myself stuck from the very first step, unsure about what to install. Fortunately, there were projects like [Mono][] and [.NET Core][2] that enabled .NET development on Mac, and editors such as [VS Code][] that also supported plug-ins for C# development. So I was able to set up an environment without much difficulty. Now that Libplanet also provides a [developer guide][3], I think it will be much easier for developers who want to contribute to the project.

[Mono]: https://www.mono-project.com/
[2]: https://en.wikipedia.org/wiki/.NET_Core
[VS Code]: https://code.visualstudio.com/
[3]: https://github.com/planetarium/libplanet/blob/master/CONTRIBUTING.md

What to Contribute?
------------------

Libplanet’s address uses [Ethereum][5]'s address format, which uses a checksum in a combination of upper and lower case letters proposed in [EIP-55][]. For example:

Hexadecimal
:  `0xd1220a0cf47c7b9be7a2e6ba89f429762e7b9adb`

EIP-55 Checksum
:  `0xD1220A0cf47c7B9Be7A2E6BA89F429762e7b9aDb`


When I first contributed to Libplanet, the project used hexadecimal consisting of only lowercase letters for its address format. Therefore, this issue had to be implemented so that the address string representation was expressed in the EIP-55 checksum format used by Ethereum. For more information, see the corresponding [issue][6] and [pull request][7].

Although I had little development experience and background in C#, it was a simple issue that did not require many modules to be fixed, so I was able to make my first contribution rather easily.

[5]: https://www.ethereum.org/
[EIP-55]: https://github.com/ethereum/EIPs/blob/master/EIPS/eip-55.md
[6]: https://github.com/planetarium/libplanet/issues/33
[7]: https://github.com/planetarium/libplanet/pull/43

## What I Learned Through My First Contribution

What I found out from my first contribution was that the C# development environment on Mac was more easy than I had anticipated. The language itself was not difficult because C# was oriented towards a popularized multi-paradigm programming language. While the .NET development environment on Mac was not too difficult to develop, support for various tools on third-party libraries and non-window platforms was still insufficient. However, this is expected to improve gradually thanks to Microsoft's recent open source and multi-platform policies.

I was also able to experience the development culture of Planetarium Team, and it was impressive that all issues were recorded on Github and that members all used English to communicate with the open source community around the world. And since the project was being externally contributed, code reviews were required and management systems like testing and changelogs were being automated and managed through CI.

## Epilogue

Being on Planetarium for about a month since my first contribution, I’m happy to say that I really enjoy working with them.

Planetarium has participated in events such as [Code-Eating Hippo][10] and [Sprint Seoul][11] to promote Libplanet contribution and will continue to actively participate in these events. For those in a similar situation as I was a month ago, there are [beginners' issues][12] for those wanting to contribute for the first time so please check it out.

As always, if you have any questions about the project, please visit our [Discord chat room][13] anytime!

[10]: https://comuka.nonce.community/
[11]: https://sprintseoul.org/
[12]: https://github.com/planetarium/libplanet/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22
[13]: https://discord.gg/planetarium


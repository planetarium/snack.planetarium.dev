---
title: Moving Beyond NAT
date: 2019-04-04
translated: 2019-04-08
authors: [swen.mun]
translators: [kidon.seo]
---

Hello, I'm Swen Mun from the Planetarium Engineering Team.
Today we're going to talk about what's known as [<abbr title="Network Address Translation">NAT</abbr> traversal techniques][1].

[1]: https://en.wikipedia.org/wiki/NAT_traversal


So what's the problem?
----------------------

From game servers to smartphones, every device connected to the Internet has an [IP address].
This enables devices to connect to one another and send/receive messages.

The fundamental problem with IP address is that quantity is limited.
In the case of [IPv4] --- the most widely used protocol, it uses 32-bit addresses which means address space is limited to 2<sup>32</sup> (more than 4 billion) addresses.
(Of course we don't use all of these addresses.)
This seems enough at first glance, but it's far short of operating more than one device per person on the planet.
In fact, since 2011, [IPv4 addresses have all been exhausted][2] and no new addresses have been assigned.

To solve this problem, [IPv6] has been proposed to increase address space to 128-bits, but the supply hasn't been able to meet users' demand.
Thus, many network operators chose to separate the network and have multiple private IPs, and convert those addresses so that they could access the Internet through one authorized IP.
This method is commonly referred to as [NAT] (Network Address Translation) and sometimes refers to a device that handles such process (in general, a [router]).

In the server-client model, accessing the Internet through NAT is not a problem.
If the server has an authorized IP, the client can access it, whether through NAT or not.
However, if you need to connect to a device inside the NAT/firewall, you've got a problem.
Because devices outside NAT cannot access the IP of a private network inside the NAT.
Techniques to address these situations are called [NAT traversal techniques][1].

[IP address]: https://en.wikipedia.org/wiki/IP_address
[IPv4]: https://en.wikipedia.org/wiki/IPv4
[2]: https://en.wikipedia.org/wiki/IPv4_address_exhaustion
[IPv6]: https://en.wikipedia.org/wiki/IPv6
[NAT]: https://en.wikipedia.org/wiki/Network_address_translation
[router]: https://en.wikipedia.org/wiki/Router_(computing)


So which technique do I use?
----------------------------

### <abbr title="Universal_Plug_and_Play">UPnP</abbr> (<abbr title="Internet Gateway Device Protocol">IGDP</abbr>)

Techniques to pass through NAT can largely be divided into two categories --- whether they are supported by NAT or not.
Protocols such as [UPnP] that are proposed to meet the requirements of the modern Internet in which equipment connectivity is valued also addresses NAT passing issues (e.g., [Internet Gateway Device Protocol][IGDP]).
However, this solution can only be applied to equipment that supports UPnP protocol.

[UPnP]: https://en.wikipedia.org/wiki/Universal_Plug_and_Play
[IGDP]: https://en.wikipedia.org/wiki/Internet_Gateway_Device_Protocol


### Relay (<abbr title="Traversal Using Relays around NAT">TURN</abbr>)

The other way around is not getting help from NAT. In other words, this way provides external access while maintaining the private-authorized IP system. How is this possible? At this point, let’s talk about what we can do and can't do.

 -  For device with an authorized IP,

     -  It can process connections from other devices.
     -  It can connect to a device with a different authorized IP.

 -  A device with a private IP,

     -  It is unable to process connection from other devices. 
         -  *To be very precise, it's possible within the same network. But I'll exclude this case to simplify the story. :)*
     -  It can connect to a device that has a different authorized IP.

Let's assume that a server (*S*) with a separate, authorized IP exists outside NAT.
If this server processes the connection instead of the device (let’s call this *A*) behind NAT and forwards (relay) the content to *A*, then we can handle the connection with confidence without relying on NAT's behavior.
This method is referred to as relay technique and is officially called, [<abbr title="Traversal Using Relays around NAT">TURN</abbr>][TURN].

[TURN]: https://en.wikipedia.org/wiki/Traversal_Using_Relays_around_NAT


### Hole Punching

Another way to avoid direct help from NAT is by using a technique called [hole punching] (commonly known as [UDP hole punching] but it is also applicable to TCP).

Hole Punching also assumes a transit server (*S*) similar to [TURN].
However, unlike [TURN], the transit server does not directly relay all communications.
Instead, it only passes on NAT's authorized IP and device *A*'s port information to to device *B*.
In this way when attempting to access *A*, *B* attempts to access NAT's authorized IP and port, not *A*'s private IP.

Although hole punching does not require NAT to implement a specific protocol like UPnP, it does require NAT’s port mapping method.
Specifically, this technique is only applicable to NAT that follows endpoint independent mapping behavior.

[hole punching]: https://en.wikipedia.org/wiki/TCP_hole_punching
[UDP hole punching]: https://en.wikipedia.org/wiki/UDP_hole_punching


Next Story
----------

The NAT traversal techniques we have discussed today have different applicable situations and they all have different pros and cons.
Therefore, people in our field use these methods in combination.
Next time we'll look have a closer look on [TURN], which is the most expensive but the most reliable communication method to move beyond NAT.

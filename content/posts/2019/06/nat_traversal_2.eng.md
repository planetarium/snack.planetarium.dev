---
title: Understanding TURN through an Example
date: 2019-06-18
authors: [swen.mun]
translators: [kidon.seo]
---

Hello, I'm Swen Mun from the Planetarium Dev Team. I introduced you all to [NAT traversal] [in my earlier post][Moving Beyond NAT]. Today, let’s take a deeper look at [TURN].

As the name "Traversal Using Relays around NAT" suggests, TURN refers to the way servers with authorized IP relay peers that want to communicate. It might be difficult to understand this concept simply by listing the functions and sequences, so let me just give you an example of how we actually use TURN in [Libplanet].

## Blockchain & NAT 

Libplanet is a library that makes blockchain technology easy to use in game development. Many blockchain implementations use [P2P]-type networks for communications between distributed [nodes], and so does Libplanet. Unlike other implementations, however, the blockchain application implemented through Libplanet is a game. Typically, these games run on personal computers, on non-stop consoles, and on personal devices such as smartphones, most of which do not have a separate, authorized IP on a NAT-configured network. So, applications running on these devices must pass through NAT for P2P communication.
 
For this reason, Libplanet supports relaying using TURN from 0.2.0. And here's how it works.

## Port Allocation

The first step in relaying over the TURN is a step known as port allocation. Nodes that want to broadcast from outside of NAT send an allocation request (with the appropriate credentials, if necessary) to the TURN server. The request dialogue will be something like this.

> Node: I'd like to receive a relay through an authorized IP and port. Please allocate an appropriate IP and port.

If the request is correct, the TURN server will select and open the appropriate IP and port to receive the connection depending on the settings, and send the following response.


> TURN Server: Port assigned. The address to be relayed in the future is '54.12.1.3:65002'. (Nonce: 'xyz')

This connection that requests port allocation is called *control connection* and it is used for communications between TURN server and the node. One caveat here is the nonce that the TURN server sends with its response. Nonce is unique for each control connection and the acquired nonce must be included in all requests of the control connection. (Or, you may receive a stale nonce error and request it again.)

## Authorization Request and Approval

With the assigned IP and port ('54.12.1.3:65002'), it would be great if other nodes were able to connect directly, but we need to go through one more step—Authorization Request. This is to request the TURN server to enable the allocated port to connect to other IP nodes. Any connections that have not been requested for authorization are blocked, which means that the node you want to relay must have prior IP information of the node you want to connect to. 

But in real life, many users don't know or care about their own public IP, so it's very difficult to communicate this information directly. To resolve this, use cases such as [WebRTC] often figure out the IP information of the node to access at the [signalling] stage. Meanwhile, Libplanet uses the STUN protocol to check if the IP is behind NAT, and if so, it will send the IP to other nodes along with the IP/port that is relayed as public IP. The nodes that receive this information go through the process of requesting permission first via an public IP before they can access the information that has been relayed.

If a node knows the public IP ('10.1.1.1') of another node that it wants to connect to, the authorization request will probably be as follows.

> Node: Requesting Authorization from '10.1.1.1' to '54.12.1.3:65002'.

This access expires after a 300-second lifetime, and to prevent this, the node that requested the authorization must re-request to the TURN server.

## Connection Notification and New Connection Request

After authorization request and approval has been completed, other nodes that have been approved with the allocated IP and port can finally connect. When the nodes make a connection, the TURN server detects it and sends the following message to the control connection.

> TURN Server: A connection attempt was made from '10.1.1.1' to '54.12.1.3:65002'. (Connection ID: '1234')

For the node that requested TURN Server relay to accept this connection, it can create a new connection (not the control connection) and request it to the TURN server. In order to distinguish the external connection request, connection ID should be included in the connection notification message.

> Node: Please transfer data from connection ID: '1234' to this connection from now on.

This new connection is called a *data connection*. Subsequent requests to '54.12.1.3:65002' are passed through this data connection, and responses to the nodes connected to that IP/port are sent to this data connection, goes through the TURN server, and finally to the node.

## Remaining Steps

In order to actually send a response properly, it is necessary to re-relay the data connections created previously and the request-response connection on the Libplanet node. No separate protocol or disclosure standard has been set because this step only needs to be handled well within the node. If the TURN client runs in a separate process from the web server, you can use the [IPC] method and if they run in the same process, inter-thread communication can be used to handle the communication. In our case, Libplanet relays a separate TCP proxy by running it locally.


[NAT traversal]: https://en.wikipedia.org/wiki/NAT_traversal
[Moving Beyond NAT]: {{< ref "nat_traversal_1.eng.md" >}}
[TURN]: https://en.wikipedia.org/wiki/Traversal_Using_Relays_around_NAT
[Libplanet]: https://libplanet.io/
[nodes]: https://en.wikipedia.org/wiki/Node_(networking)
[P2P]: https://en.wikipedia.org/wiki/Peer-to-peer
[IPC]: https://en.wikipedia.org/wiki/Inter-process_communication
[ICE]: https://tools.ietf.org/html/rfc8445
[WebRTC]: https://webrtc.org/
[signalling]: https://developer.mozilla.org/en-US/docs/Web/API/WebRTC_API/Signaling_and_video_calling

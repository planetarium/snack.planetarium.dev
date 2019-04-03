---
title: NAT를 넘어서 가자
date: 2019-04-04
authors: [swen.mun]
---


안녕하세요. 플라네타리움 개발팀 문성원입니다. 오늘은 [NAT 통과 기법]이라고 알려진 방법에 대해서 이야기를 해볼까 합니다.

# 뭐가 문젠가요?

게임 서버에서 스마트폰에 이르기까지 현대 인터넷에 참여하는 모든 단말은 [IP 주소]를 가지고 있습니다. 이는 한 단말이 다른 단말에 연결하여 메시지를 주고받기 위함인데요.

근본적인 문제는 이러한 IP 주소의 수량이 한정되어 있다는 것입니다. 널리 쓰이는 [IPv4]의 경우엔 32비트로 구성되어 단순 계산으론 2<sup>32</sup>개(약 40억개 이상)를 할당할 수 있습니다. (물론 이걸 전부 사용하는 것은 아닙니다.) 얼핏 보면 충분해 보이기도 하지만, 1인당 1개 이상의 기기를 운용하기에는 턱없이 모자라지요. 실제로 2011년 이후로 [IPv4 주소가 모두 소진][IPv4 address exhaustion]되어 신규 주소도 할당이 되지 않는 상태입니다.

이 문제를 해결하기 위해, 주소 공간을 128비트로 크게 늘린 [IPv6]가 제안되었으나, IPv4 주소 고갈에 비해 보급이 더뎠습니다. 해서 많은 네트워크 담당자들은 네트워크를 분리하여 복수의 사설 IP를 두고, 인터넷엔 그러한 주소를 변환하여 하나의 공인 IP로만 접속하게 하는 방식을 택했습니다. 흔히 이야기하는 [NAT(Network Address Translation)][NAT]는 이러한 작업을 이르는 말인 동시에, 경우에 따라선 해당 작업을 처리하는 장치(일반적으론 [라우터)][Router])를 일컫기도 합니다.

서버–클라이언트 모델에서 이런 NAT를 통한 인터넷 접속은 크게 문제가 되지 않습니다. 서버가 공인 IP를 가지고 있다면, 클라이언트는 NAT를 거치건 거치지 않건 접속할 수 있기 때문이죠. 하지만 만약 NAT 안쪽에 있는 단말에 접속해야 한다면 문제가 발생합니다. NAT 안쪽의 사설 네트워크의 IP로는 NAT 바깥의 단말들이 접속할 수 없기 때문이죠. 이러한 상황을 해결하기 위한 기법들을 NAT 통과 기법이라고 합니다.

# 그래서 뭘 써야 하나요?

## UPnP (IGDP)

NAT를 통과하는 기법은 크게 NAT의 도움을 받느냐 그렇지 않느냐로 구분할 수 있습니다. 장비들의 연결성이 중시되는 현대 인터넷의 요구 사항에 맞춰서 제안된 [UPnP]와 같은 프로토콜은, NAT 통과 문제를 해결하는 기능(예: [Internet Gateway Device Protocol][IGDP])을 지원하기도 합니다. 다만, 이는 어디까지나 해당 프로토콜을 지원하는 장비에만 적용할 수 있는 해결책입니다. 어떠한 장비들은 UPnP를 선택적으로 지원하거나, 아예 지원하지 않을 수도 있습니다.

## Relay (TURN)

다른 한 가지 방법은 NAT의 도움을 받지 않는 방법입니다. 다시 이야기하면, 사설 IP ↔ 공인 IP 체계를 유지한 상태에서 외부에서 접속이 가능하게 한다는 것이기도 합니다. 어떻게 할 수 있을까요? 이쯤에서 우리가 할 수 있는 것과 할 수 없는 일을 정리하면 아래와 같습니다.

- 공인 IP를 가진 단말은
    - 다른 단말의 연결을 처리할 수 있습니다.
    - 다른 공인 IP를 가진 단말에 연결할 수 있습니다.
- 사설 IP를 가진 단말은
    - 다른 단말의 연결을 처리할 수 없습니다.
        - *아주 엄밀하게 말하면, 같은 네트워크 안에선 가능합니다. 하지만 이야기를 단순하게 하기 위해 이 경우는 제외하겠습니다. :)*
    - 다른 공인 IP를 가진 단말에 연결할 수 있습니다.

즉 별도의 공인 IP를 가진 서버(S)를 가정하고, 이 서버가 (본래라면 NAT 뒤의 단말이 처리해야 할) 연결을 대신 처리하면서 내용을 NAT 뒤의 단말에 전달(릴레이)해주면 NAT의 동작에 의존하지 않고 확실하게 연결을 처리할 수 있습니다. 이를 릴레이 기법이라고 하며, [TURN]이라는 표준으로 정의되어 있습니다.

## Hole Punching

NAT의 직접적인 도움을 받지 않는 다른 방법 중 한 가지는 [홀 펀칭(Hole Punching)][Hole Punching]이라 불리는 기법입니다. (흔히 [UDP 홀펀칭][UDP Hole Punching]으로 널리 알려졌지만, [TCP에 대해서도 적용할 수 있습니다.][TCP Hole Punching])

홀 펀칭 역시 위의 릴레이와 마찬가지로 중계 서버(S)를 가정합니다. 다만 릴레이와 다른 점은, 중계 서버가 직접 통신을 전부 중계하는 것이 아니라, 접속을 처리할 단말(A)이 속한 NAT의 공인 IP와 포트 정보만 접속을 원하는 단말(B)에 넘겨서, B가 A에 접속할 때 A의 사설 IP가 아닌 NAT의 공인 IP와 포트로 접속을 시도하는 방식입니다.

홀 펀칭은 UPnP처럼 NAT에 특정 프로토콜의 구현을 요구하는 것은 아니지만, NAT의 포트 매핑 방식을 이용하는 기법이기 때문에, 동작 모드에 따라, 보다 정확하게 이야기하자면, 목적지 독립적 매핑(Endpoint Independent Mapping)으로 동작하는 NAT에서만 적용 가능합니다.

# 다음 이야기들

위에서 살펴 본 NAT 통과 기법들은 실현 가능한 상황이나 장단점이 각기 다릅니다. 해서 현업에서는 다양한 방법을 복합적으로 사용합니다.  다음 시간에는 그 중에서 가장 비싸지만 가장 안정적으로 통신을 보장할 수 있는 TURN을 이용한 릴레이 기법에 대해서 더 자세히 살펴보도록 하겠습니다.


[NAT 통과 기법]: https://en.wikipedia.org/wiki/NAT_traversal
[IP 주소]: https://en.wikipedia.org/wiki/IP_address
[IPv4]: https://en.wikipedia.org/wiki/IPv4
[IPv4 address exhaustion]: https://en.wikipedia.org/wiki/IPv4_address_exhaustion
[IPv6]: https://en.wikipedia.org/wiki/IPv6
[NAT]: https://en.wikipedia.org/wiki/Network_address_translation
[Router]: https://en.wikipedia.org/wiki/Router_(computing)
[UPnP]: https://en.wikipedia.org/wiki/Universal_Plug_and_Play
[IGDP]: https://en.wikipedia.org/wiki/Internet_Gateway_Device_Protocol
[TURN]: https://en.wikipedia.org/wiki/Traversal_Using_Relays_around_NAT
[Hole Punching]: https://en.wikipedia.org/wiki/Hole_punching_(networking)
[UDP Hole Punching]: https://en.wikipedia.org/wiki/UDP_hole_punching
[TCP Hole Punching]: https://en.wikipedia.org/wiki/TCP_hole_punching

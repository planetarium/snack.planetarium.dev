---
title: 탈중앙 게임과 AWS re:Invent
date: 2022-01-25
authors: [swen.mun]
ogimage: images/reinvent2021.png
---

안녕하세요. [Libplanet]을 만들고 있는 [플라네타리움]의 문성원입니다.
오늘은 작년 11월 29일부터 12월 3일까지 열린, [AWS re:Invent]에 참석하게 된 계기에 대해서 짤막하게나마 공유토록 하겠습니다.

[Libplanet]: https://libplanet.io/
[플라네타리움]: https://planetariumhq.com/
[AWS re:Invent]: https://reinvent.awsevents.com/

# AWS re:Invent

![](images/reinvent2021.png)

AWS re:Invent는 2012년부터 (코로나 19로 연기된 2019년을 제외하고) 매해 열린 개발자 
행사입니다. 클라우드가 단순히 서비스 운영을 넘어, 소프트웨어 개발에 걸쳐서 막대한 
영향력을 끼치는 현대에 들어서는 가장 큰 개발자 행사라고 해도 과언이 아니죠.

AWS는 re:Invent를 통해서 자사의 비전이나 새로운 제품/기능을 소개하는 것을 넘어서
자사 제품을 사용하여 구축한 모범 사례나 개발 방법론을 공유하기도 합니다.

# 탈중앙 애플리케이션을 만드는 사람들이 왜?

저희가 만드는 Libplanet은 탈중앙 게임을 만들기 위한 블록체인 라이브러리입니다.
저희는 이 Libplanet을 통해서 별도의 중앙 서버 없이도 영원히 플레이 가능한
멀티플레이어 게임이 만들어지는 것을 기대하며, 목표로 하고 있습니다. 실제로 이
Libplanet을 사용해서 만들어진 최초의 MMO 게임인 [나인 크로니클] 역시, 현재는 비록
불완전하지만 이런 탈중앙화 된 게임을 목표로 하여 개발/운영되고 있습니다.

여기까지만 보면 Libplanet과 나인 크로니클을 만드는 저희가 AWS 같은 중앙화 된
<abbr title="Infrastructure as a Service">[IaaS]</abbr>를 쓰는 것, 그리고 그런 
서비스의 제품군을 소개하는 행사에 참석하는 것이 아이러니하게 보일 수 있습니다.

여기에는 크게 2가지 이야기할 거리가 있을 것 같습니다.

## AWS는 단순한 운영 도구 이상입니다.

서두에 말씀드린 것처럼, 현대 소프트웨어 개발에 있어서 AWS와 같은 클라우드 기반 
IaaS들이 가져온 변화는 상상 이상의 것입니다. 많은 개발자가 물리 서버 기반의 
초기 투자 없이도 자신의 서비스를 가볍게 시험해보고, 또 릴리스해 볼 수 있게 
되었습니다. 블록체인 역시 소프트웨어이기 때문에 예외가 아닙니다. 
실제로, AWS나 Azure, GCP 모두 블록체인(주로 이더리움) 노드에 대한 템플릿, 혹은 
관리형 서비스를 제공합니다.

![](images/aws-blockchain-template.png)

이런 템플릿으로 노드를 쉽게 띄워서 돌려볼 수 있게 하므로, 엔지니어가 서비스나 
애플리케이션(저희의 경우 게임)의 공개까지 개발 기간을 단축 시키는 효과를 가져올 뿐 
아니라, 운영 환경에서 얻을 수 있는 정보들을 빠르게 개발팀으로 피드백 시키는 수단으로
활용 할 수 있습니다.

## 결국 운영, 그리고 운영

저희가 만들고 있는 나인 크로니클은 특정 중앙 주체가 도맡아서 운영하는 대신, 분산된 
노드들을 여러 주체가 운영하는 것을 목표로 합니다. 하지만 과연 노드를 어디서 어떻게 
실행해야 할까요?

종래의 중앙화 된 게임 서버들은 [온 프레미스][on-premises](on-premises)라고 불리는 
호스팅 환경에서 실행되어왔습니다. 최근에 와서는 운영 효율 등을 고려하여 클라우드 
IaaS로의 이전을 검토하고, [성공 사례들][1]이 나오고 있지만, 크게 대중화된 방식은 
아닙니다. 주요한 이유 중 하나는, 개인이나 작은 규모의 팀들이 고민하는 
"작은 규모로 먼저 시작할 수 있다"라는 강점이 그리 크게 받아들여지기 어렵기 때문일 
것입니다.

![](images/9c-structure.jpg)

하지만 탈중앙 게임을 지향하는 나인 크로니클과 같은 게임에서, 저희는 노드를 운영하는
사람들이 초기 투자를 많이 하지 않고도 본인들이 원하는 규모에서 
[스케일 아웃][scale-out] 할 수 있는 환경을 제공하는 것은 대단히 중요하다고 
생각합니다. 이는 AWS와 같은 클라우드 IaaS가 제공하는 강점과 정확히 부합하죠.

[나인 크로니클]: https://nine-chronicles.com
[IaaS]: https://en.wikipedia.org/wiki/Infrastructure_as_a_service
[on-premises]: https://en.wikipedia.org/wiki/On-premises_software
[scale-out]: https://en.wikipedia.org/wiki/Scalability#Horizontal_(scale_out)_and_vertical_scaling_(scale_up)
[1]: https://aws.amazon.com/ko/gaming/gaming-customer-references/


# 남은 이야기들

거창하게 여러 가지 이유를 이야기했지만, 아쉽게도 저는 re:Invent 행사장에서 많은 
세션을 듣지는 못했습니다. 하지만 걱정 마세요. 곧 이어서 다른 분들의 re:Invent 
후기를 이곳에 공유토록 하겠습니다. 

또한, 저희와 함께 AWS와 같은 클라우드에 탈중앙 게임 노드를 배포 / 운영하는
도구를 함께 만들 인프라 엔지니어를 [모시고 있습니다.][2] 블록체인이나 C# 경험이
없더라도, AWS와 같은 IaaS를 사용해보신 경험이 있으신 분들이라면 가벼운 마음으로 
많은 지원 부탁드립니다.

[2]: https://recruit.planetariumhq.com/e2ba3fcc-ce76-456a-bea9-0be97622cb48
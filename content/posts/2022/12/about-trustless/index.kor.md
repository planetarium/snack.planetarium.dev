---
title: "신뢰하지 않을 자유"
date: 2022-12-30
authors: [swen.mun]
ogimage: images/og.jpg
---

# 목적

이 글에서는 무신뢰성(Trustless), 그리고 무신뢰성에 기반한 시스템(Trustleses System)에 대해서 소개하고, 무신뢰성이 탈중앙 애플리케이션/네트워크를 만들때 어떤 역할을 한다고 알려져있는지 보편적인 이해에 대해 기술합니다. 또한 이러한 이해를 바탕으로, [나인 크로니클][Nine Chronicles]이나 [Libplanet][]과 같은, [플라네타리움][Planetarium]이 만드는 탈중앙 소프트웨어들에서 어떤 관점으로 수용해야 할지 제 나름의 의견도 남깁니다.

[Nine Chronicles]: https://nine-chronicles.com
[Libplanet]: https://libplanet.io
[Planetarium]: https://planetariumhq.com


# 사이퍼펑크(Cypherpunk)

무신뢰성에 대한 다양한 견해를 언급할 때에, 가장 먼저 설명해야만 하는 개념이 바로 [사이퍼펑크(Cypherpunk)][Cypherpunk]입니다. 브루스 베스키의 단편 소설 제목이자 이후 유사한 SF 소설이나 영화 장르로도 알려진 [사이버펑크(Cyberpunk)][Cyberpunk]와, 암호(Cipher)에서 유래한 이 장난기 어린 단어는, 1992년 [주드 밀론(Jude Milhon)][Jude Milhon]이 처음 쓰기 시작했다고 합니다. 이들의 주된 관심사는 프라이버시(Pricvacy)였는데, 이는 [에릭 휴즈(Eric Huhhes)][Eric Hughes]가 1993년 발표한 [〈사이퍼펑크 선언〉("A Cypherpunk's Manifesto")][A Cypherpunk's Manifesto]에서 엿볼 수 있습니다.

> Privacy is necessary for an open society in the electronic age. Privacy is not secrecy. A private matter is something one doesn't want the whole world to know, but a secret matter is something one doesn't want anybody to know. Privacy is the power to selectively reveal oneself to the world.

> 프라이버시는 전자 시대의 열린 사회를 위해 필수적입니다. 프라이버시는 세상 모든 사람들이 그것에 대해 알게 되는 것을 원하지 않는 것이며, 비밀은 전세계 모든 사람이 몰랐으면 하길 바라는 것이기에 그 둘은 서로 다릅니다. 즉 프라이버시는 자신에 대해 선택적으로 세상에 드러낼 수 있는 힘(권한)입니다.

단순히 "내가 누구인지 밝히고 싶지 않다." 라는 것을 넘어서 신원의 주권에 대한 이야기를 하고 있는 그들로서는, (설령 그것이 쓰기가 더 불편해지더라도) 자신의 주권을 자신의 허락을 받지 않고 공개하는 것에 매우 비판적일 수 밖에 없었습니다. 개인의 정보는 개인이 스스로 지켜야, 그리고 지킬 수 있게 해야 한다는 것이었죠.

> We cannot expect governments, corporations, or other large, faceless organizations to grant us privacy out of their beneficence.

> 우리는 정부, 기업 혹은 큰 익명의 조직들이 우리의 프라이버시를 그들의 선의로 지켜줄 것이라곤 기대할 수 없다. 

그들은 개인이 이러한 조직/단체, 기업 그리고 국가에 저항하는 수단으로서 암호 기술에 주목했습니다. [전자서명(Electronic Signature)][Electronic Signature]을 사용하여, 중앙화된 데이터베이스에 의존하지 않고도 신원 증명을 하길 원했으며, 자금 추적과 검열을 피하려고 독자적인 송금 시스템을 만들었습니다. 그리고 그러한 부산물 중 하나가 그 유명한 [비트코인(Bitcoin)][Bitcoin]이었죠.[^1]

아마도 짐작하셨겠지만, 제가 강조하고 싶은 것은 그들이 암호학 기술들을 활용해 비트코인을 만들었다는 것이 아닙니다. 그들은 자신의 프라이버시를 다른 누군가가 관리하는 것을 극도로 꺼렸고, 그를 피하기 위한 방법이 암호학 기술이었다는 것입니다.

[^1]: 사실 비트코인이 이들의 유일한 부산물인 것은 아닙니다. [미국의 소프트웨어 수출 제재를 피하기 위해 소스 코드를 출력해서 배포한 전설적인 일화][1]로 유명한 암호 프로그램인 [PGP(Pretty Good Privacy)][PGP]는 당대 사이퍼펑크로 유명했던 [필 짐머만(Phil Zimmermann)][Phil Zimmermann]의 저작물이며, 넷스케이프(Netscape)의 공동 설립자였던 [마크 안데르센(Marc Andreessen)][Marc Andreessen]을 포함한 많은 엔지니어가 [Secure Socket Layer(SSL)][SSL]과 관련된 소프트웨어들을 만들기도 했죠.

[Bitcoin]: https://bitcoin.org
[Cypherpunk]: https://en.wikipedia.org/wiki/Cypherpunk
[Cyberpunk]: https://en.wikipedia.org/wiki/Cyberpunk
[Jude Milhon]: https://en.wikipedia.org/wiki/Jude_Milhon
[Eric Hughes]: https://en.wikipedia.org/wiki/Eric_Hughes_(cypherpunk)
[A Cypherpunk's Manifesto]: https://www.activism.net/cypherpunk/manifesto.html
[Electronic Signature]: https://en.wikipedia.org/wiki/Electronic_signature
[PGP]: https://en.wikipedia.org/wiki/Pretty_Good_Privacy
[1]: https://en.wikipedia.org/wiki/Pretty_Good_Privacy#Criminal_investigation
[Phil Zimmermann]: https://en.wikipedia.org/wiki/Phil_Zimmermann
[Marc Andreessen]: https://en.wikipedia.org/wiki/Marc_Andreessen
[SSL]: https://en.wikipedia.org/wiki/Transport_Layer_Security#SSL_1.0,_2.0,_and_3.0


# Web3

(이제는 많은 분들이 아실만한 주제지만) 이런 사이퍼펑크들이 [Web3][]로 대표되는 탈중앙 네트워크/애플리케이션을 만들자는 주장에 항상 긍정적인 것만은 아닙니다. 이들은 현재의 Web3가 주장하거나 지향하는 것이, 이미 너무 타협을 한 나머지 (적어도 본인들이 주장하던 것보다는) 훨씬 더 중앙화 되었다고 비판하죠.[^2]

하지만 이런 비판을 받는 Web3조차도 표현이나 중점을 두는 방향을 변주되었을 지언정, 비슷한 문제의식에 착안한 부분이 있다는 점은 재밌는 지점입니다. 가령 이더리움 재단에서 밝힌[^3] [Web3의 핵심 아이디어][Core ideas of Web3]에는 다음과 같은 언급이 있습니다.

> Web3 is trustless: it operates using incentives and economic mechanisms instead of relying on trusted third-parties.

> Web3는 무신뢰형입니다: 어떤 신뢰하는 제 3자에 의존하는 대신, 인센티브와 경제적 메커니즘을 사용하여 운영합니다.

프라이버시에 대한 언급은 없지만, 여전히 누군가를 믿을 수 없다는 태도는 유지하고 있는 것처럼도 보입니다. 저는 이게 신뢰(Trust)가 특정한 주체에 대한 힘의 근간이 되는 현상을 여전히 견제하고 있기 때문이라고 생각합니다. [개빈 우드(Gavin Wood)][Gavin Wood]가 Web3를 창안하게 된 계기 또한 이러한 문제의식에서 출발했다고 알려져 있습니다.

> The premise of 'Web 3.0' was coined by Ethereum co-founder Gavin Wood shortly after Ethereum launched in 2014. Gavin put into words a solution for a problem that many early crypto adopters felt: the Web required too much trust. That is, most of the Web that people know and use today relies on trusting a handful of private companies to act in the public's best interests.

> Web 3.0의 전제는, 2014년 이더리움이 출시된 직후 공동 설립자인 개빈 우드가 만들었습니다. 개빈은 많은 초기 암호화폐 사용자들이 느꼈던 문제에 대한 해결책을 말했습니다. 웹은 너무 많은 신뢰를 요구하고, 오늘날 사람들이 알고 사용하는 대부분의 웹은 소수의 민간 기업이 공익을 위해 행동할 것을 신뢰하는데 의존합니다.

사이퍼펑크들이 프라이버시를 위해 주장한것은, 단순히 비밀을 간직하고 싶었던 것이 아니라, 어떤 것을 공개할지를 스스로 정해야 한다는 일종의 자기 주권 이야기이었습니다. 그리고 그런 맥락에서 Web3의 오너십 역시 크게 다르지 않을 것입니다. 결국 내가 누구를 믿을지 말지조차, 내가 직접 정할 수 있어야 한다는 것이죠.

[^2]: 개인적으로 자유 소프트웨어 진영과 오픈 소스 소프트웨어 진영의 대립을 보는 것 같기도 해서 흥미로운 부분입니다. 하지만 객관적인 비교가 가능할 만큼 충분한 정보가 없다고 생각하여 다루진 못했습니다.
[^3]: "이더리움 재단의 정의가 전체 Web3를 대표할 만큼 대표성이 있는가." 라는 지적이 있을 수 있으며 동의합니다. 이 글이 작성되는 2022년 10월경 제가 접할 수 있는 자료를 기준으로 판단하였으며 이것과 다르면서 더 보편적으로 알려져 있는 정의가 있으면 본 내용은 수정될 수 있습니다.

[Web3]: https://en.wikipedia.org/wiki/Web3
[Gavin Wood]: https://en.wikipedia.org/wiki/Gavin_Wood
[Core ideas of Web3]: https://ethereum.org/en/web3/#core-ideas


## 합리적 경제인(Homo ecnomicus)

"인센티브와 경제 모델을 누군가의 선의 대신 사용해야 한다."라는 주장은 고전 경제학에서 인용되는 [합리적 경제인(Homo economicus)][Homo economicus]을 연상케도 합니다. 합리적인 경제인 모델은 현대에 들어선 [행동 경제학(Behavioral economics)][Behavioral economics]에 의해 그 현실성이 많이 부정당하고 있는데[^4], 그렇다 보니 Web3의 무신뢰성이라는 것은 전제부터 불가능한 것 아닌가란 의심도 듭니다.

하지만 저는 이 비판을 100% 적용하는 것은 어렵다고 봅니다. 행동 경제학의 합리적인 경제인 비판은, 그것이 잘 성립하지 않기에 그에 수반한 고전 경제학의 가정이나 합리성이 깨질 수 있다는 것인데, 무신뢰성이 필요한 이유는 애초에 합리적인 활동이나 그를 통한 효율을 올리는 것이 아니기 때문입니다. 데이터를 클라우드에 저장하면 더 싸고 더 편할 때도 있는데, 굳이 그걸 내 로컬 하드드라이브에 유지하는 것이 반드시 가격이나 시간 효율 때문만은 아니겠죠.

[^4]: [현상 유지 편향(Status quo bias)][Status quo bias]이나 [전망이론(Prospect theory)][Prospect theory] 등이 흔히 일컬어지는 예시입니다.

[Homo economicus]: https://en.wikipedia.org/wiki/Homo_economicus
[Behavioral economics]: https://en.wikipedia.org/wiki/Behavioral_economics
[Status quo bias]: https://en.wikipedia.org/wiki/Status_quo_bias
[Prospect theory]: https://en.wikipedia.org/wiki/Prospect_theory


# 이념과 효율

효율에 대해서 이야기하기 시작하면 나올 주요 반론(?)중 가장 까다로운 것은 아마 이런 류일 것입니다.

"난 여러분께 제 주권을 돌려달라고 한 적이 없습니다. 제 데이터를 제가 직접 관리하고 싶지도 않구요. 전 그저 서비스를 싸고 쉽고 편하게 쓰고 싶은 것 뿐이에요."

사실 제 생각엔, 세상의 많은 서비스 사용자들이 이렇지 않나 싶기도 합니다. 아무도 못 믿어서 비 수탁형 지갑(Non-Custodial Wallet)에 꼬박꼬박 보관하다가, 실수로 하드를 포맷하거나 컴퓨터가 고장 나 쓰지 못하는 사람은 생각보다 많습니다. 그리고 대부분의 현대적인 서비스들은 점점 소유권과 그에 대한 책임 비용을 사용자에게서 공급자가 가져오는 형태로 진화했기에, "당신의 개인 키가 없어져도 우린 아무 것도 못해드립니다." 라는 이야기가, "우린 너희의 개인 키를 정말로 모른다."라는 진실성보다는, 그저 비겁한 책임 회피만으로 들리는 시대이기도 하죠.

그렇다면 정말로 무신뢰성은 철저히 이념적인 것일 뿐이고, 서비스의 효율에 이바지하는 것이 없을까요? 

## MetaMask의 사례 - 조금 기술적인 이야기

[MetaMask][]는 [이더리움][Ethereum] 네트워크를 사용할 때 많이 사용되는 암호화폐 지갑입니다. 보다 구체적으로는, 사용자는 MetaMask를 통해 자산을 송금하거나, [탈중앙 애플리케이션(Decentralized Application, dApp)][dApp]을 실행할 수 있습니다.

그런데 많은 사용자가 MetaMask를 사용하다 무심결에 사용하는 PC를 초기화해서 난처해지곤 합니다. 이 고지식한 소프트웨어가 계정 정보를 네트워크 어디에도 따로 저장하지 않기 때문인데요. 사실 MetaMask가 저장하는 계정 정보라는 것은 단순히 좀 긴 숫자[^6]인데, MetaMask는 사용자가 입력한 패스워드로 암호화해서 로컬 저장소에 저장할 뿐입니다.

이런 제약들로 인해, MetaMask는 예전 사이퍼펑크들의 강박증을 계승한 듯한 불편한 소프트웨어처럼 보입니다. 하지만 MetaMask, 더 정확히는 MetaMask와 이더리움의 서명 체계가 가지는 아주 독특한 특징이 있는데, 바로 호환성이 엄청나게 뛰어나다는 점입니다. 이더리움과 그 위에서 동작하는 탈중앙 애플리케이션들은, 기본적으로 아무도 믿지 않기에 외부의 계정 체계에 의존하는 것이 아니라 오로지 사용자가 제출한 서명과 데이터를 통해서만 동작합니다. 그로 인해 복잡한 [통합 인증(SSO)][SSO]이나 신원 제공자들과의 협업 없이도, 누구나 같은 서명 체계를 공유하는 네트워크에 호환되는 애플리케이션을 바로 만들 수 있습니다. [^7] 이런 특징 덕에 MetaMask는 그야말로 폭발적인 성장을 이룩할 수 있었습니다.

물론 MetaMask의 이런 성장이 온전히 무신뢰성에 기반한다고 보는 것은 지나친 비약일 수도 있습니다. 소위 DeFi Summer라고 불리는 가상 자산 시장의 호황에 맞춰서 사람들의 관심이 Web3에 몰린 것은 부정할 수 없는 사실이고, MetaMask의 성장에는 지대한 영향을 끼쳤을 것입니다. 하지만 만약 MetaMask를 [ConsenSys][] [^8]가 Google이나 Facebook과 같이 중앙화된 웹서비스처럼, 완전 수탁형 서비스로 제공한다고 했다고 가정해보죠. (이념적인 부분을 차치하더라도) 이렇게 많은 서비스에서 쉽고 빠르게 수용할 수 있었을까요? Web 2.0시대로부터 OAuth가 제안되어 공급자들이 구현하는 것을 기다리는데에만 수년이 걸렸던 걸 돌이켜보면, 이는 어려운 일이라고 생각합니다. 바꾸어 말하자면 이런 확장성이야말로 "Web3스럽다"는 것만으로 치부할 수 없는, 무신뢰성의 가치입니다.


[^6]: 정확히는 [타원 곡선 전자 서명(Elliptic Curve Digital Signature Algorithm)][ECDSA]에 사용되는 숫자로, 자세한 사항은 Bitcoin 위키의 [secp256k1][] 문서를 참고하시면 됩니다. 
[^7]: 네트워크가 호환되지 않는 나인 크로니클이 이더리움과 같은 개인키를 사용할때 같은 주소가 나오는 것 또한 이런 까닭입니다.
[^8]: MetaMask를 개발한 블록체인 기술 기업입니다. [Infura]처럼 이더리움 생태계에 필요한 소프트웨어들을 만드는 것으로 유명합니다.

[MetaMask]: https://metamask.io
[Ethereum]: https://ethereum.org
[dApp]: https://en.wikipedia.org/wiki/Decentralized_application
[SSO]: https://en.wikipedia.org/wiki/Single_sign-on
[ConsenSys]: https://consensys.net
[Infura]: https://infura.io
[ECDSA]: https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm
[secp256k1]: https://en.bitcoin.it/wiki/Secp256k1


## 여전히 안전한 "신뢰" - 조금 철학[^9]적인 이야기

MetaMask의 사례는 무신뢰형 시스템과 소프트웨어가 항상 비효율적인 것만은 아니라는 점을 시사하지만, 항상 더 효율적이라는 이야기는 역시 아닙니다. 그렇기에 모든 소프트웨어를 효율적으로 만들기 위해 무신뢰성을 확보해야 한다는 것 또한 이상한 이야기겠지요. 효율로 확실한 우위를 가지지 못하는 이상, 이런 반론은 여전히 유효합니다.

"코드와 프로토콜을 믿는 것은 사람들을 믿는 것보다 더 위험하다. (혹은 허황되다)"

[P2P 재단][P2P Foundation] 위키에 있는 [무신뢰 시스템(Trustless Systems)][Trustless Systems] 문서에는 이런 톤의 보다 구체적인 주장들을 찾아볼 수 있는데요.

> First, you need to trust the protocol of the cryptocurrency and/or DAO. This isn’t as simple as saying ‘I trust the maths’, for some actual human (or humans) wrote the code and hopefully debugged it, and we are at least trusting them to get it right, no? 

> 우선, 여러분은 암호화폐 혹은 DAO의 프로토콜을 믿어야 합니다. 그런데 이건 "수학을 믿습니다"같이 단순하진 않죠. 실제로는 일부의 사람들이 코드를 작성하고 희망적으로 디버그했으며, 우린 그들이 올바르게 작업했기를 믿는 것이기 때문이죠, 안 그래요?

> Instead of trusting our laws and institutions, we are being asked to trust stakeholders and miners, and programmers, and those who know enough coding to be able to verify the code. We aren’t actually trusting the blockchain technology; we are trusting the people that support the blockchain. 

> 우리의 법률과 기관을 믿는 대신, 우리는 이해 당사자와 채굴자, 그리고 코드를 검증할 정도로 코딩을 할 줄 아는 사람을 신뢰하라는 요청을 받고있는 겁니다. 우린 실제로 블록체인 기술을 신뢰하는 게 아니에요; 우린 그저 블록체인을 지지하는 사람을 신뢰하고 있을 뿐입니다.

저는 무신뢰성에 대한 이런 비판에 대해서 생각할 부분도 있지만, 소프트웨어 엔지니어로서 전적으로 동감하긴 어렵다고 느낍니다.

### 입법, 사법 그리고 행정

어떤 분들은 무신뢰성의 한계에 대해 지적하면서 다음과 같은 대안을 제시하시기도 합니다.

> Perhaps we ought to reconsider the desire to expunge trust, and instead focus on what should be done to strengthen it. One way to support trust is to hold institutions accountable when they betray it. 

> 아마도 우리는 신뢰를 제거하려는 생각을 재고하고, 그것을 강화하기 위해 무엇을 해야 하는지 초점을 맞춰야 할 것입니다. 신뢰를 강화하기 위해 할 수 있는 한 가지 방법은, 기관이 신뢰를 배반했을 때 책임을 지도록 하는 것입니다.

저는 이것이 잘못되었거나 무의미한 일이라고 생각하진 않습니다. 하지만 무신뢰성, 그리고 그것에 기반한 블록체인 기술이 특별히 잘할 수 있는 일이 아니라고 생각됩니다. 왜냐하면, 이런 무신뢰성은 보통 행정에 필요한 권한(e.g., 개인 식별)을 개인에게 환원시키고 프로토콜에 의한 자동화를 강조하는데, 그걸 부정하면 딱히 더 잘할 수 있는 부분이 없기 때문입니다.

어떤 분들은 행정만큼이나, 혹은 그 이상으로 "입법", 그리고 "사법"이 중요하다고 말합니다. 그리고 저도 거기에 동의합니다. 다만 그건 블록체인 소프트웨어가 잘할 수 있는 일도 아니며, 본래의 가정을 무시하고 무리하게 취사선택(cherry-pick)할 때 오히려 비효율적인 부분이 늘어나기 때문에 어울리지 않는다고도 생각합니다. 대표적인 예로는 [탈중앙 자율 조직(Decentralized autonomous organization)][DAO]이 의사 결정 도구로 많이 사용되지만, 정작 투표 과정에서는 이더리움 네트워크를 사용하지 않는 [snapshot][]을 들 수 있겠네요. [^10]

### "찍먹"과 "부먹"

한국에서 탕수육, 특히 배달 탕수육을 먹는데 있어 빠질 수 없는 논쟁거리가 소위 "부먹"(소스를 부어서 먹기)과 "찍먹"(소스를 찍어서 먹기)입니다. 여기에는 얼핏 우스꽝스럽지만, 꽤 진지한 이론적 배경도 있죠. [^11] [^12]

어찌 되었거나, 저는 개인적으론 "찍먹"을 선호합니다. 정확하게는 "찍먹"이나 "부먹"이나 맛에 있어선 별 차이를 못 느낍니다. 하지만 "부먹"이 가지는 치명적인 단점은 경계하는데 바로 "비가역성"입니다. 제가 탕수육을 시켜서 소스를 다 부어버린다면, 이걸 찍어 먹고 싶은 사람은 선택지가 없어집니다.

무신뢰성을 이야기하다 갑자기 탕수육 이야기를 한 것은, 신뢰 관계라는 것도 비슷한 비가역성을 가지고 있다고 생각하기 때문입니다. 누군가를 믿는 걸로 전제된 시스템에선, 누군가를 임의로 믿지 않을 수 없습니다. 하지만 반대는 여전히 가능하죠. [^13]

### 자동화된 행정

"입법"이나 "사법"을 다루기에 현재의 블록체인이 적합하지 않다한들, 혹은 신뢰/무신뢰를 나중에라도 선택을 할 수 있다한들 그것들이 무신뢰성에 기반한 "행정"을 용인해야 할 면죄부가 되진 않습니다. 기여를 하건 못하건, 위험한 건 여전히 위험한 겁니다. 또한 성립할지 어쩔지도 모르는 개념을 굳이 선택할 수 있게 할 이유도 없습니다. 그런데 다시 생각해보면 무신뢰성이, 사람들에게 누군가를 믿지 않을 권리를 주는 것이, 정말로 위험하거나 허황 된 일일까요?

앞서 밝혔듯, 저는 모든 경우에 무신뢰형 시스템이 효율적이거나 윤리적이라고 믿진 않습니다. 현재의 정부, 기업, 또는 중앙화된 구조가 특별히 누군가를 착취하고 박해하려고 발전한 것이 아니라, 이러한 문제를 보다 잘 해결하고자 노력하기 위한 결과라고도 생각합니다. 중앙화된 것이 특별히 구식이거나 비효율적이거나, 청산해야 할 적폐라고 생각하지도 않습니다. 그저 중앙화 되어 있을 뿐이죠. [^14]

탈중앙화라는 관점에서, 무신뢰성에 기반한 "행정"은 무신뢰성 자체보단 행정의 자동화와 "사법"을 간소화(이하 "자동화된 행정")에 더 큰 가치가 있습니다. 이는 사이퍼펑크들과 Web3가 무신뢰성을 통해 소구했던 것이 결국 "주권"이었다는 점을 상기해보면 꽤 자연스러운 흐름입니다.

저는 작금의 블록체인 기술과 그를 통해 사람들이 기대하는 건, 실제 세상의 전제를 아예 뒤집는 수준의 혁신이라 생각합니다. 세상이 진짜 법대로 돌아간다면 경찰이 필요 없겠죠. 그리고 인류는 그런 세상을 지난 수 천년간 경험해 본 적이 없었고, 그런 공백을 메우기 위한 방법이 그 세월 동안 고안되어 왔습니다. 하지만 실체가 없는 소프트웨어를 돈을 주고 사고팔기 시작한 지는 100년이 안 되었고, (메타버스 운운이 호들갑이라 하더라도) 그런 실체 없는, 하지만 사람이 코드로서 제어할 수 있는 가상 세계가 생긴 지는 고작 수 십년에 지나지 않습니다. 이런 상황에서는 기술과 사회에 대한 가정을 그대로 유지하면서, 그것도 저 같은 소프트웨어 엔지니어가 이에 대해 가타부타 논하는 건 그야말로 갓난아이가 공자 앞에서 문자 쓰는 것과 다를 게 없습니다 [^15] 바꾸어 이야기하면, 제가 "자동화된 행정"에 거는 기대는, 실체가 있는 현대 사회에서 인류가 몇 천년간 치고 받으면서 쌓아 올린 다양한 의사 결정 체계[^16]들에 대한 제 나름의 존경과 경의이기도 합니다.


[^9]: 미리 밑밥(?)을 깔아두자면, 저는 학문으로의 철학을 공부하거나 엄밀하게 사고하도록 훈련한 적이 없는 소프트웨어 엔지니어입니다. 때문에 "철학"은 학문을 지칭하기보다 일반어로 이해하여 주시면 감사하겠습니다.
[^10]: 주장을 개진하다 보니 단언적으로 이야기했지만, "무신뢰를 지향하는 시스템에서 이런 의정 활동이 유효한 부분이 전혀 없는가." 저에게도 답이 있는 문제는 아닙니다. 그렇기에 나인 크로니클 DAO에 대해서도 "잘은 모르겠지만, 일단 실험해보자"라는 쪽의 생각에 가깝긴 합니다.
[^11]: 소스를 부어서 먹는 걸 지지하는 분들은, 본래 탕수육이 원래 소스와 볶아서 먹는 요리였음을 주장하는 전통(?)적인 노선과 찍어 먹는 과정에서 생길 수 있는 여러 위생상의 문제를 걱정하는 실리(?)적인 노선이 있습니다.
[^12]: "찍먹"을 주장하시는 분들은 주로 식감이나 소스의 배합 자유도를 중요시한다고 알려져 있습니다.
[^13]: 나인 크로니클의 온보딩포탈이나 플레이어 커뮤니티 등의 사례를 봤을 때, 이것이 실질적으로 가능한 선택인가라는 점은 다소 논쟁적이라고는 봅니다.
[^14]: 그럼 탈중앙화에 "자동화된 행정"이 꼭 필요한 것인가라는 반론이 가능합니다. 그에 대한 생각도 정리해보았는데, 글의 분량 관계상 별도로 내어 적으려고 합니다.
[^15]: 노파심에 계속 적는 거지만, 저는 이게 가치 없다는 주장을 하는 것이 아닙니다. 단지 제가 블록체인 기술로 잘할 수 없는 일이라는 것입니다.
[^16]: 지금으로 충분하지 않다. 라는 착안에서 의견이 다른 분도 계시겠지만... 더 이야기하면 지겨우시겠지만, 그래도 이야기하자면 저는 그 의견에 반대하지 않습니다.

[P2P Foundation]: https://p2pfoundation.net
[Trustless Systems]: https://wiki.p2pfoundation.net/Trustless_Systems
[DAO]: https://en.wikipedia.org/wiki/Decentralized_autonomous_organization
[snapshot]: https://snapshot.org


# 요약

* 무신뢰성은 단순히 선의나 신뢰를 부정해야 한다는 이야기가 아니라, 그럴 수 있는 권리를 개개인에게 부여해야 한다는 주장입니다.
* 사이퍼펑크, Web3 모두 대상의 차이(프라이버시 vs 서비스)는 있지만, 모두 권리에 관한 이야기를 하고 있기에 무신뢰성을 전제로 합니다.
* 무신뢰성은 때때로(혹은 꽤 자주) 효율적이지 못할 수 있지만, 때로는 빠른 확장을 가능케 하기도 합니다.
* 무신뢰성을 전제하는 "자동화된 행정"은, 무언가를 탈중앙화하는 데에 있어 가장 좋은 방법은 아닐 수 있습니다. 하지만 블록체인이란 기술을 가장 잘 활용할 수 있는 방법입니다.


---

(이 글은 제 [개인 Gist](https://gist.github.com/longfin)에 올해 10월 [게시한 글](https://gist.github.com/longfin/019e0067275d134f4302539d2ddbff06)을 옮긴 것입니다.)


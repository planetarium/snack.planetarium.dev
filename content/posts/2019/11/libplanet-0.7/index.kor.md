---
title: Libplanet 0.7 릴리스
date: 2019-11-11
authors: [seunghun.lee]
---

안녕하세요. 저희 팀은 [Libplanet]의 일곱 번째 마이너 버전인 [0.7 버전][0.7.0]을 릴리스했습니다.

Libplanet은 분산 P2P로 돌아가는 온라인 멀티플레이어 게임을 만들 때, 그러한 게임들이 매번 구현해야 하는 P2P 통신이나 데이터 동기화 등의 문제를 푸는 공용 라이브러리입니다.

0.7 버전에서는 Libplanet의 안정성 및 성능 개선과 더불어 다양한 사용성 개선이 있었습니다. 이 글에서는 0.7 버전의 주요 변경 사항들에 대해 다루겠습니다.

[Libplanet]: https://libplanet.io/

액션 및 상태의 타입 제한
------------------------

기존 Libplanet에서 상태 및 액션의 속성은 `object` 타입으로 표현되고 저장할 때는 알아서 [.NET의 바이너리 직렬화][Binary Serialization] 포맷으로 직렬화되었습니다. 이 방식은 .NET 객체를 그대로 직렬화할 수 있으므로 Libplanet을 쓰는 쪽에서도 만드는 쪽에서도 생각할 게 적다는 장점이 있습니다. 하지만 저희 팀은 이 방식을 처음 도입했을 때부터 여러 한계를 인식한 채 한시적으로 사용할 것을 의도했는데, 그 한계는 다음과 같은 것들이 있습니다.

- 직렬화 역직렬화가 구체적으로 이뤄지는 방식이 암시적입니다. 타입의 구현이 달라지면 직렬화되는 포맷에도 영향이 가지만 구체적으로 어떤 변화가 일어나는지 짐작하기 어렵습니다.
- 과거에는 모양이 달랐던 타입의 값이 직렬화되어 블록체인에 저장된 뒤, 현재 타입으로 역직렬화를 시도했을 때 런타임 오류가 나거나 의도한 것과 다른 의미로 해석될 수 있습니다.
- 팀에서 정의한 타입이라면 [VTS] 같은 기법을 도입할 수도 있지만, 실수로 팀에서 만든 어셈블리가 아닌 패키지 등을 통해 가져다 쓴 타입이 섞여서 직렬화된 경우 나중에 해당 타입의 내부 표현이 달라져서 직렬화 형식이 바뀌어도 대응하기가 어렵습니다.
- 직렬화된 결과를 .NET이 아닌 플랫폼에서 해석하기 어려울뿐더러, 같은 .NET 플랫폼이라도 직렬화된 타입을 포함한 어셈블리를 공유하지 않으면 역직렬화는 어렵습니다. 따라서 [Libplanet Explorer]나 [Libplanet Explorer Frontend] 같은 앱에서 액션의 속성이나 특정 시점의 상태를 사람이 보기 쉽게 표시하기 힘듭니다.

[VTS]: https://docs.microsoft.com/en-us/dotnet/standard/serialization/version-tolerant-serialization
[Libplanet Explorer Frontend]: https://docs.microsoft.com/en-us/dotnet/standard/serialization/version-tolerant-serialization

그래서 이번 버전부터는 상태 및 액션의 속성은 [Bencodex]의 [`IValue`][IValue] 타입을 통해서 표현하도록 바뀌었습니다. 따라서 게임 내부에서 정의해서 쓰는 타입들을 `IValue` 형식으로 변환하는 코드, 그리고 `IValue` 형식으로 표현된 것을 다시 게임 내 타입들로 해석하는 코드를 명시적으로 써야 합니다. 조금 귀찮아진 것도 사실이지만, 대신 직렬화하려는 타입의 내부 표현이 바뀌어도 직렬화 혹은 역직렬화 메서드에 해당 변경에 따른 처리 로직을 추가할 수 있게 되었고, 각기 다른 버전 사이의 호환을 좀 더 구현하기 쉽게 되었습니다.

[Binary Serialization]: https://docs.microsoft.com/en-us/dotnet/standard/serialization/binary-serialization
[Libplanet Explorer]: https://github.com/planetarium/libplanet-explorer
[Bencodex]: https://github.com/planetarium/bencodex.net
[IValue]: https://github.com/planetarium/bencodex.net/blob/0.2.0/Bencodex/Types/IValue.cs


`BlockChain<T>`의 `IReadOnlyList<T>` 구현 제거
----------------------------------------------

이전 버전까지 `BlockChain<T>` 클래스는 `IReadOnlyList<T>` 인터페이스를 구현하고 있었고, 그에 따라 `BlockChain<T>` 객체에 직접 [LINQ] 확장 메서드들을 사용할 수 있었습니다. LINQ 확장 메서드는 선형적인 객체를 다룰 때 다양한 편리를 제공하지만, 사용 방법에 따라 상당한 성능상의 차이를 가져올 수 있습니다. 예를 들어 `BlockChain<T>` 객체에 10,000개의 블록이 있을 때 LINQ의 `.Last()` 메서드를 사용하여 10,000 번째 블록을 가져오고자 한다면 마지막 블록만을 저장소에서 바로 가져온다고 생각하기 쉽습니다. 하지만 실제로는 `BlockChain<T>`의 첫 블록부터 마지막 블록까지 조회하며 각 블록에 대해 스토리지에 저장된 내용을 메모리에 올리고 해석하는 작업이 이뤄지게 됩니다. 저장된 블록이 적을 때는 이런 점이 큰 문제가 되지 않지만, 블록이 많아질수록 이런 사용방식이 큰 성능 문제로 이어질 수 있습니다.

이번 버전부터는 `BlockChain<T>` 클래스에서 `IReadOnlyList<T>` 구현을 아예 제거함으로써 LINQ 확장 메서드를 잘못 사용해 생길 수 있는 문제를 방지하도록 했습니다. 대신 [`BlockChain<T>.Contains()`][BlockChain<T>.Contains] 같이 자주 쓰이는 연산은 효율적인 구현을 직접 제공하기로 했습니다.

[BlockChain<T>.Contains]: https://docs.libplanet.io/0.7.0/api/Libplanet.Blockchain.BlockChain-1.html#Libplanet_Blockchain_BlockChain_1_Contains_Libplanet_Blocks_Block__0__

[LINQ]: https://docs.microsoft.com/en-us/dotnet/csharp/programming-guide/concepts/linq/


개인키를 안전하게 저장할 수 있는 키 저장소 구현
-----------------------------------------------

이번 버전에서는 개인키를 암호화하여 안전하게 보호할 수 있도록 키 저장소가 추가되었습니다. 키 저장소 내 각각의 키 파일은 [`ProtectedPrivateKey`][ProtectedPrivateKey] 클래스로 표현되며, 사용자가 입력한 암호(passphrase)로 개인키를 암호화 하여 저장할 수 있습니다. 또한, [`ProtectedPrivateKey.WriteJson()`][ProtectedPrivateKey.WriteJson] 메서드를 이용해 [이더리움][Ethereum]의 [Web3 Secret Storage Definition]에 따라 JSON 형식으로 저장할 수 있습니다. 추후 키 저장소 디렉터리를 통합적으로 관리하는 기능도 추가될 예정입니다.

[ProtectedPrivateKey]: https://docs.libplanet.io/0.7.0/api/Libplanet.KeyStore.ProtectedPrivateKey.html
[ProtectedPrivateKey.WriteJson]: https://docs.libplanet.io/0.7.0/api/Libplanet.KeyStore.ProtectedPrivateKey.html#Libplanet_KeyStore_ProtectedPrivateKey_WriteJson_Stream_System_Nullable_Guid___

현재 [키 유도함수][KDF]는 [PBKDF2]와 [Scrypt]가 구현되어있고, [AES]-128-[CTR] 암호화 알고리즘을 지원하고 있습니다. 이 중 Scrypt 구현은 [minhoryang] 님의 [기여][#654]로 추가되었습니다. 🎉

[Ethereum]: https://en.wikipedia.org/wiki/Ethereum
[Web3 Secret Storage Definition]: https://github.com/ethereum/wiki/wiki/Web3-Secret-Storage-Definition
[KDF]: https://en.wikipedia.org/wiki/Key_derivation_function
[PBKDF2]: https://en.wikipedia.org/wiki/PBKDF2
[Scrypt]: https://en.wikipedia.org/wiki/Scrypt
[AES]: https://ko.wikipedia.org/wiki/%EA%B3%A0%EA%B8%89_%EC%95%94%ED%98%B8%ED%99%94_%ED%91%9C%EC%A4%80
[CTR]: https://ko.wikipedia.org/wiki/%EB%B8%94%EB%A1%9D_%EC%95%94%ED%98%B8_%EC%9A%B4%EC%9A%A9_%EB%B0%A9%EC%8B%9D#%EC%B9%B4%EC%9A%B4%ED%84%B0_(CTR)

[minhoryang]: https://github.com/minhoryang
[#654]: https://github.com/planetarium/libplanet/pull/654


그 외
----

이번 버전에는 [Hacktoberfest] 행사로 많은 분의 기여가 있었습니다. 해당 행사에 관한 내용은 문성원 님이 작성하신 [Hacktoberfest를 돌아보며][looking-back-at-hacktoberfest]에서 자세히 보실 수 있고, 그 외 이번 버전의 모든 변경 사항은 [전체 변경 내용][0.7.0]에서 확인하실 수 있습니다.

이번 변경 사항이나 Libplanet에 대해 궁금한 점이 있으시다면 언제든 저희 팀이 상주해 있는 [디스코드 대화방][Discord]에 방문해 주세요!

[Hacktoberfest]: https://hacktoberfest.digitalocean.com/
[looking-back-at-hacktoberfest]: {{< relref "../looking-back-at-hacktoberfest/index.kor.md" >}}
[0.7.0]: https://github.com/planetarium/libplanet/releases/tag/0.7.0
[Discord]: https://discord.gg/planetarium

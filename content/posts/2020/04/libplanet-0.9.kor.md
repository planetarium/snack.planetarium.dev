---
title: Libplanet 0.9 릴리스
date: 2020-04-28
authors: [hong.minhee]
---

안녕하세요.  [Libplanet]의 아홉 번째 마이너 버전인 [0.9 버전][0.9.0]이
릴리스되었습니다.

Libplanet은 분산 P2P로 돌아가는 온라인 멀티플레이어 게임을 만들 때,
그러한 게임들이 매번 구현해야 하는 P2P 통신이나 데이터 동기화 등의 문제를 푸는
공용 라이브러리입니다.

이번 버전부터 Libplanet은 여러 NuGet 패키지로 배포되는데요.
Libplanet의 외연이 확장되어 일부 의존 라이브러리를 모든 애플리케이션에서
포함하기에는 무거워졌기 때문입니다.

이 글에서는 0.9 버전의 새로운 NuGet 패키지들을 소개하며 주요 변경 사항들에
대해서도 다루겠습니다.

[Libplanet]: https://libplanet.io/
[0.9.0]: https://github.com/planetarium/libplanet/releases/tag/0.9.0


[Libplanet.RocksDBStore]
------------------------

Libplanet.RocksDBStore는 새로 추가된 NuGet 패키지로,
Lipblanet의 [`IStore` 인터페이스][IStore]를 [RocksDB] 백엔드로 구현한
`RocksDBStore` 클래스를 포함합니다.  `RocksDBStore`는 내부 테스트 결과 기존의
[`DefaultStore`][DefaultStore]에 비해 쓰기는 약 10배 읽기는 약 2배 이상
빨라졌으며, 압축 등의 효과 덕에 기존에 비해 15% 이하의 저장 공간만을 차지하게
됐습니다.

위와 같은 장점에도, C++로 작성된 RocksDB 네이티브 바이너리를 애플리케이션과
함께 배포해야 하기 때문에 일부 플랫폼에서는 이용이 곤란할 수 있습니다.
따라서 `RocksDBStore` 클래스는 Libplanet 패키지가 아닌
Libplanet.RocksDBStore라는 별도 NuGet 패키지로 배포하게 되었으며,
Libplanet 패키지에는 여전히 `DefaultStore`가 제공됩니다.   따라서 개발할 때는
설치가 간편한 `DefaultStore`를 쓰고 테스트 및 실제 배포시에만 `RocksDBStore`를
쓰거나, RocksDB 바이너리를 제공하기 어려운 플랫폼에 한해 `DefaultStore`를 쓰는
식의 활용이 가능합니다.

자세한 내용은 이승훈 님이 쓰신 [Libplanet RocksDB 적용기][1]에서 볼 수 있습니다.

[Libplanet.RocksDBStore]: https://www.nuget.org/packages/Libplanet.RocksDBStore/
[IStore]: https://docs.libplanet.io/0.9.0/api/Libplanet.Store.IStore.html
[RocksDB]: https://rocksdb.org/
[DefaultStore]: https://docs.libplanet.io/0.9.0/api/Libplanet.Store.DefaultStore.html
[1]: {{< ref "rocksdb/index.kor.md" >}}


여러 피어로부터 블록 받기
-------------------------

이제까지 [`Swarm<T>` 클래스][Swarm]의 [`PreloadAsync()`][Swarm.PreloadAsync] 및
[`StartAsync()` 메서드][Swarm.StartAsync]는 네트워크에 쌓인 블록을 따라잡기
위해 하나의 피어에게 그간의 모든 블록을 요청하여 받게 되어 있었습니다.
쌓인 블록이 많을 경우 하나의 피어에게만 받다 보니 오래 걸리기 일쑤였고,
운이 안 좋으면 서로 통신이 아주 느린 피어에게 블록을 요청해 받기까지 아주 오래
걸리는 경우도 있었습니다.  블록을 보내주는 쪽에서도 홀로 큰 부담을 져야 하는데,
배포되는 애플리케이션에 기본값으로 설정된 시드 노드의 경우 그 부담이 무시하기
힘들 정도였습니다.

이번 버전부터는 블록을 여러 피어에게 고루 받도록 개선되었으며, 그 가운데
특별히 느린 피어가 끼더라도 전체 블록을 받는 시간이 크게 늦어지는 일도
크게 줄었습니다.

[Swarm]: https://docs.libplanet.io/0.9.0/api/Libplanet.Net.Swarm-1.html
[Swarm.PreloadAsync]: https://docs.libplanet.io/0.9.0/api/Libplanet.Net.Swarm-1.html#Libplanet_Net_Swarm_1_PreloadAsync_System_Nullable_TimeSpan__IProgress_Libplanet_Net_PreloadState__IImmutableSet_Libplanet_Address__EventHandler_Libplanet_Net_PreloadBlockDownloadFailEventArgs__CancellationToken_
[Swarm.StartAsync]: https://docs.libplanet.io/0.9.0/api/Libplanet.Net.Swarm-1.html#Libplanet_Net_Swarm_1_StartAsync_TimeSpan_TimeSpan_CancellationToken_


서명된 앱 프로토콜 버전
-----------------------

지난해, [Libplanet 0.3에는 `Swarm<T>()` 생성자에 `appProtocolVersion` 매개변수가
추가됐습니다.][2]  서로 프로토콜이 호환되는 노드끼리만 통신하고, 호환되지
않는 경우의 처리를 앱에 따라 적절히 처리할 수 있도록 한 것입니다.

저희 팀 역시 이 기능을 활용했고, 더 높은 버전의 노드와 조우할 경우 소프트웨어
업데이트를 유도하는 용도로 썼습니다.  그러나 이렇게 활용하니, 변조된
소프트웨어가 악의적으로 (실제로는 발표된 적 없는) 높은 버전 숫자를 내보이게
하여 다른 노드들이 거짓 소프트웨어 업데이트를 시도하도록 공격하는 데에 쓰일
수 있다는 것을 알게 됐습니다.

이러한 일을 피할 수 있도록, [`System.Int32`][System.Int32]로 표현되던
앱 프로토콜 버전은 이제 서명과 서명자 등 여러 메타데이터를 포함하는
[`AppProtocolVersion` 자료형][AppProtocolVersion]으로
바뀌었습니다. 앱 프로토콜 버전은 서명되어야 하며, 각 노드는 `Swarm<T>()`
생성자의 `trustedAppProtocolVersionSigners` 매개변수로 어떤 서명자의
앱 프로로콜 버전을 신뢰할지 *각자* 정하게 됩니다.

이러한 방식은 각 노드들을 의도하지 않은 (변조된) 소프트웨어 업데이트로부터
보호하는 동시에, 각 노드들이 원한다면 자유롭게 포크된 다른 애플리케이션 로드맵을
선택할 자유도 제공합니다.

[2]: {{< ref "../../2019/05/libplanet-0.3.kor.md" >}}#%EB%B2%84%EC%A0%84%EC%9D%B4-%EB%8B%A4%EB%A5%B8-%EB%85%B8%EB%93%9C%EB%A5%BC-%EB%A7%8C%EB%82%AC%EC%9D%84-%EB%95%8C-%EB%B0%98%EC%9D%91%ED%95%98%EB%8A%94-api
[System.Int32]: https://docs.microsoft.com/en-us/dotnet/api/system.int32
[AppProtocolVersion]: https://docs.libplanet.io/0.9.0/api/Libplanet.Net.AppProtocolVersion.html


키 저장소
---------

지난해, [Libplanet은 0.7 버전에서 `PrivateKey`를 안전하게 저장할 수 있는
`ProtectedPrivateKey` 클래스가 추가됐습니다.][3]  그렇지만
[`ProtectedPrivateKey`][ProtectedPrivateKey]는 하나의 키만 다룰 뿐으로,
여러 키를 다루려면 애플리케이션 측에서 디렉터리를 만들고 파일명을 결정하고
파일에 쓰는 등의 처리를 알아서 구현해야 했습니다.

이번 버전에부터는 키를 물리적으로 보존하고 관리하는 기능인
[`Web3KeyStore`][Web3KeyStore] 클래스가 제공되기 때문에, 더이상 그런 처리를
직접 구현할 필요가 없어졌습니다.  파일 시스템에 [Web3 Secret Storage Definition]
형식으로 키를 보존하는 `Web3KeyStore`와 더불어, 그러한 구체적인 보존 방식(구현
세부사항)을 추상화하는 [`IKeyStore` 인터페이스][IKeyStore] 역시 도입됐습니다.

[3]: {{< ref "../../2019/11/libplanet-0.7/index.kor.md" >}}#%EA%B0%9C%EC%9D%B8%ED%82%A4%EB%A5%BC-%EC%95%88%EC%A0%84%ED%95%98%EA%B2%8C-%EC%A0%80%EC%9E%A5%ED%95%A0-%EC%88%98-%EC%9E%88%EB%8A%94-%ED%82%A4-%EC%A0%80%EC%9E%A5%EC%86%8C-%EA%B5%AC%ED%98%84
[ProtectedPrivateKey]: https://docs.libplanet.io/0.9.0/api/Libplanet.KeyStore.ProtectedPrivateKey.html
[Web3KeyStore]: https://docs.libplanet.io/0.9.0/api/Libplanet.KeyStore.Web3KeyStore.html
[Web3 Secret Storage Definition]: https://github.com/ethereum/wiki/wiki/Web3-Secret-Storage-Definition
[IKeyStore]: https://docs.libplanet.io/0.9.0/api/Libplanet.KeyStore.IKeyStore.html


`planet`: 명령행 도구
---------------------

[`Swarm<T>()` 생성자][Swarm()]는 [지난 버전부터 특정 제너시스 블록을 상정하게
됐고][4], [이번 버전부터는 앱 프로토콜 버전을 서명하게 됐습니다.][5]  이와 같은
값들은 암호학 알고리즘의 결과를 포함하기 때문에, 사람이 임의로 아무 값이나
넣을 수 없습니다.  그렇지만 개발 과정에서는 임의의 값들을 채워봐야 할 일이 많기
때문에, 이 때마다 Libplanet API를 C# 대화형 셸이나 PowerShell 등에서 호출하여
원하는 값을 계산하는 것은 그것대로 여간 번거로운 일이 아니었습니다.

이러한 작업을 좀더 쉽게 할 수 있도록, 이번 버전부터는 `planet`이라는
명령행(<abbr title="command-line interface">CLI</abbr>) 도구를 함께 배포합니다.
`planet` 명령은 여러 서브커맨드를 포함하며, 현재로서는 키 저장소 관리와
앱 프로토콜 버전의 서명 기능을 제공합니다.  이후 임의의 제너시스 블록 생성 등의
기능도 추가될 예정입니다. 자세한 사용법은 `planet --help` 명령을 확인해 주세요.

`planet` 명령은 [Libplanet.Tools]라는 NuGet 패키지로 배포되며, .NET Core SDK가
설치된 시스템에서 아래와 같이 설치할 수 있습니다:

~~~~ bash
dotnet tool install -g Libplanet.Tools
~~~~

.NET Core SDK가 설치되지 않은 환경이라면 [릴리스 페이지][0.9.0]에 첨부된
공식 바이너리를 받아서 설치할 수도 있습니다.  공식 바이너리는 Linux (x64),
macOS (x64), Windows (x64) 세 플랫폼의 버전이 제공되고 있습니다.

[4]: {{< ref "../../2020/02/libplanet-0.8.kor.md" >}}#%EC%A0%9C%EB%84%88%EC%8B%9C%EC%8A%A4-%EB%B8%94%EB%A1%9D-%EC%83%81%EC%A0%95
[5]: #%EC%84%9C%EB%AA%85%EB%90%9C-%EC%95%B1-%ED%94%84%EB%A1%9C%ED%86%A0%EC%BD%9C-%EB%B2%84%EC%A0%84
[Swarm()]: https://docs.libplanet.io/0.9.0/api/Libplanet.Net.Swarm-1.html#Libplanet_Net_Swarm_1__ctor_Libplanet_Blockchain_BlockChain__0__Libplanet_Crypto_PrivateKey_Libplanet_Net_AppProtocolVersion_System_Int32_System_String_System_Nullable_System_Int32__IEnumerable_Libplanet_Net_IceServer__Libplanet_Net_DifferentAppProtocolVersionEncountered_IEnumerable_Libplanet_Crypto_PublicKey__
[Libplanet.Tools]: https://www.nuget.org/packages/Libplanet.Tools/


그 외
-----

그 밖의 여러 변경 사항은 [전체 변경 내용][0.9.0]에서 확인하실 수 있습니다.

호기심이 생기신 분들은 설치해서 이용해 보시고, 궁금한 점이 있으시다면 저희 팀이
상주해 있는 [디스코드]에도 놀러오세요!

[나인 크로니클]: https://nine-chronicles.com/
[디스코드]: https://discord.gg/planetarium

---
title: Libplanet RocksDB 적용기
date: 2020-04-17
authors: [seunghun.lee]
---

안녕하세요. 플라네타리움에서 [Libplanet]을 만들고 있는 이승훈입니다.

Libplanet에서는 [`IStore`]라는 저장계층 추상화 인터페이스와 기본 구현인 [`DefaultStore`]를 제공하고 있고, Libplanet을 이용하여 만들고 있는 게임 [Nine Chronicles]도 이를 쓰고 있었습니다. `DefaultStore`는 Libplanet에 기본으로 포함되어 곧바로 쓸 수 있다는 장점이 있었지만, 성능이나 저장 공간 효율 측면에서 한계가 있었습니다.

이에 따라 저희는 여러 대안 저장 방식을 검토한 끝에 Facebook에서 제작한 [키–값 데이터베이스][Key-Value Database] 라이브러리인 [RocksDB]가 적합하다고 판단했고, 이를 백엔드로 사용하는 `IStore` 구현체인 [`RocksDBStore`]를 만들기로 했습니다. 이번 글에서는 `RocksDBStore`를 만들면서 경험한 일들을 공유하려고 합니다.

[Libplanet]: https://libplanet.io/
[`IStore`]: https://docs.libplanet.io/0.8.0/api/Libplanet.Store.IStore.html
[`DefaultStore`]: https://docs.libplanet.io/0.8.0/api/Libplanet.Store.DefaultStore.html
[RocksDB]: https://rocksdb.org/
[Nine Chronicles]: https://nine-chronicles.com/
[Key-Value Database]: https://ko.wikipedia.org/wiki/%ED%82%A4-%EA%B0%92_%EB%8D%B0%EC%9D%B4%ED%84%B0%EB%B2%A0%EC%9D%B4%EC%8A%A4
[`RocksDBStore`]: https://github.com/planetarium/libplanet/blob/master/Libplanet.RocksDBStore/RocksDBStore.cs

## 의존하는 라이브러리 포함시키기[^1]

RocksDB는 압축이나 메모리 할당을 위해 또다른 라이브러리들에 의존합니다. [Windows 빌드][Windows build]와 다르게 macOS와 Linux의 경우 RocksDB 네이티브 라이브러리를 동적 링크 라이브러리 형태(*.so* 및 *.dylib*)로 사용하기 위해서는 RocksDB가 의존하는 라이브러리들도 시스템에 설치되어 있어야 합니다.

일반적인 서버 앱에서는 시스템에 모든 의존 라이브러리들을 다 설치하는 것이 자연스러운 일입니다. 서버 앱을 구동하는 시스템은 보통 그 서버 앱만을 위해 운영되기 때문입니다. 하지만 저희는 블록체인 노드인 동시에 게이머의 시스템에서 돌아가는 앱을 만들고 있기 때문에 모든 게이머에게 이런 라이브러리들을 따로 설치하라고 요구하는 건 어려웠습니다.

그래서 생각한 것이 게임 클라이언트 내에 RocksDB가 의존하는 라이브러리들도 함께 넣어 배포하는 것이었습니다. 하지만 별도의 수정 없이 가이드대로 RocksDB를 동적 링크 라이브러리 형태로 빌드할 경우, 빌드된 RocksDB 라이브러리에서 게임 클라이언트에 함께 포함된 의존 라이브러리들을 찾지 못하는 문제가 있었습니다.

이 문제를 해결하기 위해 RocksDB 동적 링크 라이브러리 파일의 [rpath]를 수정하는 방식을 사용했습니다. rpath란 <q>run-time search path</q>를 가리키는 말로, 라이브러리 파일이나 실행 파일 내에 하드코딩 되어서 [동적 링킹][] [로더][]가 해당 파일에서 필요한 라이브러리를 찾기 위한 경로입니다. 처음에는 RocksDB 라이브러리를 빌드할때 rpath를 수정하는 방법을 고려했지만 RocksDB의 빌드 스크립트가 생각보다 복잡해 보였기 때문에 빌드가 완료된 라이브러리 파일의 rpath를 수정하기로 했습니다. 다행히 macOS에서는 [`install_name_tool`], Linux에서는 [`patchelf`]라는 툴로 다음과 같이 간단하게 rpath를 현재 RocksDB 라이브러리가 존재하는 디렉터리로 수정할 수 있습니다.

```
# macOS
$ install_name_tool -add-rpath '@loader_path' librocksdb.dylib

# linux
$ patchelf --set-rpath $ORIGIN librocksdb.so
```

rpath 수정에 관한 보다 자세한 내용은 제가 참조한 아래 페이지들을 참조하시면 좋을 것 같습니다.

- [Fun with rpath, otool, and install\_name\_tool](https://medium.com/@donblas/fun-with-rpath-otool-and-install-name-tool-e3e41ae86172)
- [Change Library Search Path For Binary Files in Linux](https://mindonmind.github.io/notes/linux/change_rpath.html)

[Windows Build]: https://github.com/facebook/rocksdb/wiki/Building-on-Windows
[rpath]: https://en.wikipedia.org/wiki/Rpath
[동적 링킹]: https://en.wikipedia.org/wiki/Dynamic_linker
[로더]: https://ko.wikipedia.org/wiki/%EB%A1%9C%EB%8D%94_(%EC%BB%B4%ED%93%A8%ED%8C%85)
[`install_name_tool`]: https://www.unix.com/man-page/osx/1/install_name_tool/
[`patchelf`]: https://github.com/NixOS/patchelf
[^1]: 이 작업을 진행할 당시, Nine Chronicles은 아직 소수의 테스트 플레이어를 대상으로 인스톨러 없이 간소하게 배포할 때였기 때문에, 이런 접근을 하게 되었습니다. 그러나 최근에는 인스톨러를 포함하여 배포하게 되면서 다른 접근도 가능하게 되었습니다. 기회가 된다면 이후 스낵에 다른 접근을 소개하도록 하겠습니다.

## 애플리케이션에서의 데이터베이스 기능 구현

RocksDB는 흔히 사용되는 [관계형 데이터베이스]나 `DefaultStore`에서 사용하고 있는 [LiteDB]등과는 다르게 비교적 단순한 기능만을 지원합니다. 따라서 앞에서 얘기한 데이터베이스에서는 당연하게 지원하는 기능들도 RocksDB를 사용할 때는 애플리케이션에서 직접 구현을 해야 하는 경우가 종종 있습니다.

대표적으로 저장된 데이터 열(rows)의 갯수를 세는 기능이 존재하지 않기 때문에, 데이터를 업데이트할 때마다 개수를 따로 저장해 놓거나 매번 데이터를 순회하면서 세는 등 여러 방식을 이용하여 해당 기능을 직접 구현해야 합니다.

또 다른 예로는 키 검색 기능이 있습니다. RocksDB의 `Seek`은 키의 첫머리(prefix)를 입력으로 받아서 해당하는 키의 위치를 찾아줍니다. 일반적인 데이터베이스의 키 검색 기능처럼 첫머리가 일치하는 키만 검색될 거라고 기대하기 쉽지만, 일반적인 데이터베이스에서의 검색보다는 파일의 오프셋을 이동하는 [`lseek()`][lseek(2)]와 좀 더 유사한 기능을 합니다. 따라서 이 기능을 이용해서 키를 순회할 때는 매 키 마다 해당 키의 첫머리가 내가 찾는 부분 문자열과 일치하는지 검사해야 합니다.

[관계형 데이터베이스]: https://ko.wikipedia.org/wiki/%EA%B4%80%EA%B3%84%ED%98%95_%EB%8D%B0%EC%9D%B4%ED%84%B0%EB%B2%A0%EC%9D%B4%EC%8A%A4
[LiteDB]: https://www.litedb.org/
[lseek(2)]: http://man7.org/linux/man-pages/man2/lseek.2.html

## 문서를 자세히 보지 않으면 하기 쉬운 실수들

RocksDB의 API와 문서화는 기대했던 것에 비해 친절하게 되어있는 편은 아니어서 사용하는 데 약간의 주의가 필요했습니다.

한 예로 RocksDB는 네임스페이스와 같은 역할을 하는 [칼럼 패밀리][](Column Family)가 있습니다. 이 칼럼 패밀리를 데이터베이스에 만들어두면 다음번에 데이터베이스를 사용할 때도 알아서 함께 가져올 것을 기대했지만, 기대와는 달리 데이터베이스를 열 때 `ListColumnFamilies`라는 API를 이용해서 데이터베이스내의 모든 칼럼 패밀리를 명시해주지 않으면 예외가 발생하는 문제가 있었습니다.

또 RocksDB는 문서화에 GitHub의 위키를 이용하는데, 버전별로 문서가 나뉘어있는 등의 정리는 따로 되어 있지 않습니다. 예를 들어 [prefix seek]에 대한 문서를 보면 사용법이 변경에 따라 계속 추가되는데, 최신 사용법은 문서의 마지막에 기록되어 있어서 문서의 첫 부분만 볼 경우 예전 사용법대로 사용하기가 쉽습니다.

[칼럼 패밀리]: https://github.com/facebook/rocksdb/wiki/Column-Families
[prefix seek]: https://github.com/facebook/rocksdb/wiki/Prefix-Seek

## 바인딩 라이브러리의 문제

마지막은 RocksDB의 C# 바인딩 라이브러리인 [rocksdb-sharp]에 관한 내용입니다.

`RocksDBStore`코드중 rocksdb-sharp의 `RocksDBException` 예외를 잡아서 처리하는 코드가 있습니다. 그런데 일부 플랫폼에서는 이 예외를 처리하는 도중 아래와 같은 엉뚱한 예외가 발생하는 경우가 있었습니다.

    ExecutionEngineException: String conversion error: Illegal byte sequence encounterd in the input.

코드를 살펴본 결과 이는 rocksdb-sharp에서 RocksDB에서 발생한 에러메시지를 인코딩할 때 [`Marshal.PtrToStringAnsi()`] 메서드를 사용했기 때문에 발생한 문제였습니다. 저희는 위에서 얘기한 라이브러리 의존성 문제를 해결하기 위해 rocksdb-sharp을 포크해서 사용하고 있었기 때문에 해당 부분에 [`Marshal.PtrToStringUni()`] 메서드를 사용하도록 변경함으로써 어렵지 않게 해당 문제를 해결할 수 있었습니다.

[rocksdb-sharp]: https://github.com/warrenfalk/rocksdb-sharp
[`Marshal.PtrToStringAnsi()`]: https://docs.microsoft.com/en-us/dotnet/api/system.runtime.interopservices.marshal.ptrtostringansi?view=netframework-4.8
[`Marshal.PtrToStringUni()`]: https://docs.microsoft.com/en-us/dotnet/api/system.runtime.interopservices.marshal.ptrtostringuni?view=netframework-4.8

## 마치며

여러 과정을 거치며 RocksDB를 도입하고 저장공간이나 속도 측면에서 향상을 경험할 수 있었습니다. 자세한 구현은 [코드][`RocksDBStore`]를 통해 확인하실 수 있습니다.

RocksDBStore 혹은 Libplanet에 대해 더 궁금한 점이 있으시다면 언제든 저희 팀이 상주해 있는 [디스코드 대화방][Discord]에 놀러 오세요!

[Discord]: https://discord.gg/planetarium

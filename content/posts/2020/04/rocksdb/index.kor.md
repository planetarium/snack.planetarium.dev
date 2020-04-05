---
title: Libplanet RocksDB 적용기
date: 2020-04-05
authors: [seunghun.lee]
---

안녕하세요 플라네타리움에서 [Libplanet]을 만들고 있는 이승훈입니다.

Libplanet 에서는 [`IStore`]라는 저장계층 추상화 인터페이스와 기본 구현인 [`DefaultStore`]를 제공하고 있고, 이는 현재 Libplanet을 이용하여 만들고 있는 [Nine Chronicles]에서 이용되고 있었습니다. `DefaultStore`는 Libplanet에 포함되어 사용하는데 별도의 작업이 필요 없다는 장점이 있었지만, 성능이나 저장공간 효율 측면에서 한계가 있었습니다.

이에 따라 저희는 여러 검토를 거쳐 Facebook에서 제작한 [Key-Value 데이터베이스][Key-Value Database] 라이브러리인 [RocksDB]를 사용하는 것이 적합하다고 판단했고, RocksDB를 백엔드로 사용하는 [`RocksDBStore`]를 만들기로 했습니다. 이번 글에서는 `RocksDBStore`를 만들면서 경험한 일들을 공유하려고 합니다.

[Libplanet]: https://github.com/planetarium/libplanet
[`IStore`]: https://docs.libplanet.io/0.8.0/api/Libplanet.Store.IStore.html
[`DefaultStore`]: https://docs.libplanet.io/0.8.0/api/Libplanet.Store.DefaultStore.html
[RocksDB]: https://rocksdb.org/
[Nine Chronicles]: https://nine-chronicles.com
[Key-Value Database]: https://en.wikipedia.org/wiki/Key-value_database
[`RocksDBStore`]: https://github.com/planetarium/libplanet/tree/master/RocksDBStore

## 공유 라이브러리 포함시키기

RocksDB는 압축이나 메모리 할당을 위해 여러 라이브러리를 사용하고 있습니다. [Windows 빌드][Windows build]와 다르게 macOS와 Linux의 경우 RocksDB를 사용하기 위해서는 이 라이브러리들이 시스템에 설치되어 있어야 합니다.

일반적인 서버에서는 이런 라이브러리들을 시스템에 설치하는 것이 자연스러운 일입니다. 하지만 저희가 만들고 있는 것은 블록체인 노드이기도 하지만 동시에 게임 클라이언트기 때문에 사용자에게 이런 라이브러리들의 설치를 요구하는 건 어려웠습니다.

그래서 생각한 것이 게임 클라이언트에 필요한 라이브러리들을 포함해서 배포하는 것이었습니다. 문제는 RocksDB에 필요한 라이브러리들의 경로가 고정되어있어 해당 라이브러리들을 찾지 못하는 것이었습니다.

이 문제를 해결하기 위해 RocksDB 공유 라이브러리 파일의 [rpath]를 수정하는 방식을 사용했습니다. rpath란 라이브러리 혹은 실행파일이 사용하는 라이브러리를 찾는 경로입니다. 다행히 macOS에서는 [`install_name_tool`], Linux에서는 [`patchelf`]라는 툴로 다음과 같이 간단하게 rpath를 현재 RocksDB 라이브러리가 존재하는 디렉터리로 수정할 수 있습니다.

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
[`install_name_tool`]: https://www.unix.com/man-page/osx/1/install_name_tool/
[`patchelf`]: https://github.com/NixOS/patchelf

## 애플리케이션에서의 데이터베이스 기능 구현

RocksDB는 일반적인 데이터베이스와는 다르게 비교적 단순한 기능만을 지원합니다. 따라서 다른 데이터베이스에는 당연하게 지원하는 기능들도 RocksDB를 사용할 때는 애플리케이션에서 직접 구현을 해야 하는 경우가 종종 있습니다.

대표적으로 저장된 데이터의 개수를 세는 `Count`와 같은 기능이 존재하지 않기 때문에, 데이터를 업데이트할 때마다 데이터의 개수를 저장해 놓거나 데이터를 순회하면서 매번 세는 등 여러 방식을 이용하여 해당 기능을 직접 구현해야 합니다.

또 다른 예로는 키 검색 기능이 있습니다. RocksDB의 `Seek`은 키의 Prefix를 입력으로 받아서 해당하는 키의 위치를 찾아줍니다. 일반적인 데이터베이스의 키 검색 기능처럼 Prefix가 일치하는 키만 검색될 거라고 기대하기 쉽지만, 일반적인 데이터베이스에서의 검색보다는 파일의 오프셋을 이동하는 [lseek]과 좀 더 유사한 기능을 합니다. 따라서 이 기능을 이용해서 키를 순회할 때는 매 키 마다 해당 키의 Prefix가 내가 찾는 Prefix와 일치하는지 검사해야 합니다.

[lseek]: http://man7.org/linux/man-pages/man2/lseek.2.html

## 문서를 자세히 보지 않으면 하기 쉬운 실수들

RocksDB의 API와 문서화는 기대했던 것에 비해 친절하게 되어있는 편은 아니어서 사용하는 데 약간의 주의가 필요했습니다.

한 예로 RocksDB는 네임스페이스와 같은 역할을 하는 [Column Families] 라는 기능을 제공합니다. 이 `ColumnFamily`를 데이터베이스에 만들어두면 다음번에 데이터베이스를 사용할 때도 알아서 함께 가져올 것을 기대했지만, 기대와는 달리 데이터베이스를 열 때 `ListColumnFamilies`라는 API를 이용해서 데이터베이스내의 모든 `ColumnFamily`를 명시해주지 않으면 예외가 발생하는 문제가 있었습니다.

또 RocksDB는 문서화에 GitHub의 위키를 이용하는데, 버전별로 문서가 나뉘어있는 등의 정리는 따로 되어 있지 않습니다. 예를 들어 [`Prefix-Seek`]에 대한 문서를 보면 사용법이 변경에 따라 계속 추가되는데, 최신 사용법은 문서의 마지막에 기록되어 있어서 문서의 첫 부분만 볼 경우 예전 사용법대로 사용하기가 쉽습니다.

[Column Families]: https://github.com/facebook/rocksdb/wiki/Column-Families
[`Prefix-Seek`]: https://github.com/facebook/rocksdb/wiki/Prefix-Seek

## 바인딩 라이브러리의 문제

마지막은 RocksDB의 C#바인딩 라이브러리인 [rocksdb-sharp]에 관한 내용입니다.

`RocksDBStore`코드중 rocksdb-sharp의 `RocksDBException` 예외를 잡아서 처리하는 코드가 있습니다. 그런데 일부 플랫폼에서는 이 예외를 처리하는 도중 아래와 같은 엉뚱한 예외가 발생하는 경우가 있었습니다.

```
ExecutionEngineException: String conversion error: Illegal byte sequence encounted in the input.
```

코드를 살펴본 결과 이는 rocksdb-sharp에서 RocksDB에서 발생한 에러메시지를 인코딩할 때 `Marshal.PtrToStringAnsi()` 메서드를 사용했기 때문에 발생한 문제였습니다. 저희는 위에서 얘기한 공유 라이브러리 문제를 해결하기 위해 rocksdb-sharp을 포크해서 사용하고 있었기 때문에 해당 부분에 `Marshal.PtrToStringUni()` 메서드를 사용하도록 변경함으로써 어렵지 않게 해당 문제를 해결할 수 있었습니다.

[rocksdb-sharp]: https://github.com/warrenfalk/rocksdb-sharp

## 마치며

여러 과정을 거치며 RocksDB를 도입하고 저장공간이나 속도 측면에서 향상을 경험할 수 있었습니다. 자세한 구현은 [코드][`RocksDBStore`]를 통해 확인하실 수 있습니다.

RocksDBStore 혹은 Libplanet에 대해 더 궁금한 점이 있으시다면 언제든 저희 팀이 상주해 있는 [디스코드 대화방][Discord]에 놀러 오세요!

[Discord]: https://discord.gg/planetarium

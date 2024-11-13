---
title: "라이브 게임 에셋 관리 개선기 - 2.메모리 사용 절감"
date: 2024-09-30
authors: [eugene-doobu]
ogimage: images/og.kor.jpg
---

# 인트로
---

[저번 글](../../08/asset-load-1/)에서, 게임이 오래 지속적으로 업데이트되면 컨텐츠가 계속해서 늘어나게 되고, 이를 따로 관리하기 위해 에셋 번들 등의 기법을 통해 에셋을 빌드와 분리해서 관리하기도 한다는 것에 대해 이야기하였다. 이렇게 빌드와 에셋이 분리되더라도 게임을 실행시키기 위해서는 빌드 파일과 온라인에서 별도로 다운받은 에셋들을 동시에 메모리에 올려야 한다. 즉, 게임이 계속 개발되며 리소스가 늘어나게 되면 메모리에 로드해야 하는 에셋들의 수도 늘어난다는 뜻이다.

![또리코네](https://velog.velcdn.com/images/eugene-doobu/post/87876574-6623-4eff-8876-586698d8541b/image.png)

현재 애플 iOS의 최신 기기인 iPhone 16 Pro Max의 경우에도 RAM 용량은 8GB이며, 조금 구버전의 디바이스인 iPhone 12의 경우 RAM 용량은 4GB로, 위 프리코네의 추가 리소스를 한 번에 담을 수 없는 크기이다. 그리고 전 세계 사람들이 플레이하는 게임을 만들기 위해서는 현 시대 최고 스펙의 장비가 아닌 저사양 디바이스를 타겟으로 테스트를 해야 많은 사람들이 안정적으로 플레이할 수 있는 게임이 된다.

이와 같은 논리는 PC 게임에도 동일하게 적용된다. 사람들은 데스크탑 기준으로 보통 16GB 램을 주로 사용하는 것으로 보이며, 신경 좀 쓰면 32GB, 돈 좀 쓰면 64GB의 램을 사용하는 게 일반적일 것이다._(뇌피셜임)_ 하지만 요즘 나오는 PC 게임들의 용량은 점점 커지고 있으며 이제는 100GB 게임의 시대라고 해도 될 정도이다. 아래 리스트는 최근 출시된 고용량의 게임들을 정리해놓은 것이다.

- ARK: Survival Evolved - 275GB
- Call of Duty: Modern Warfare - 250GB
- final fantasy: 15 - 160GB
- Star Wars Jedi: Survivor - 130GB
- The Last of Us Part 1 - 100GB
- Diablo 4 - 90GB

이처럼 게임에는 리소스를 로드하기 위해 큰 메모리가 필요하고, 모든 게임 리소스를 한 번에 RAM에 올릴 수 없다는 것을 알 수 있을 것이다. 그렇다고 게임 리소스를 필요한 순간마다 즉시 로드하고 해제한다면 게임이 뚝뚝 끊길 것이며 이는 유저에게 불쾌한 경험이 될 것이다. 그리고 디바이스의 메모리에는 우리가 만든 게임뿐만 아니라 다양한 프로세스가 올라갈 수 있음을 명심해야 한다.

<center>
	<img src ="https://velog.velcdn.com/images/eugene-doobu/post/c5b8889a-e2bf-41d7-9427-699a82ac4dba/image.png" width="60%"> 
</center>

이러한 이유로 에셋 로드/언로드 타이밍을 지정해 메모리 관리를 하는 것은 게임 개발에서 특히 중요한 부분이고, 이번 글에서는 나인크로니클(9C)에서 메모리 관리를 위해 어떤 작업을 하였는지 작성해보겠다. 또한 현재 타겟 플랫폼에 맞게 사용할 리소스를 최적화하여 게임에 사용되는 리소스를 줄이는 작업도 진행하였는데, 이 부분에 대해서도 같이 다뤄보도록 하겠다.

![고기굽기](https://velog.velcdn.com/images/eugene-doobu/post/d6e0e64a-f04a-4b67-84e5-8bbce5db2744/image.png)

1부. 어드레서블 에셋 도입  
**2부. 메모리 사용 구조 개선 / 리소스 최적화** <- 현재 글  
번외1. 리소스 최적화 기법  
3부. DLC를 통한 패치 시스템


## 개요
---

#### 오브젝트 풀 개요

몇 메가바이트 단위 혹은 그 이상의 크기를 가진 리소스를 메인 스레드를 블록하고 로드하려고 시도하면, 일정한 FPS를 유지해야 하는 게임의 프레임에 큰 영향을 주게 된다. 로드를 비동기로 한다고 하더라도 상황에 따라 프레임에 영향을 주지 않을 뿐, 게임 플레이 자체가 어색해지는 상황이 생길 수 있다. 예를 들어, 총을 발사하려고 공격 키를 눌렀는데 총알 리소스가 로드되기 위해 0.5초 동안 발사가 안 된다고 생각해보자. 유저 경험이 매우 불편할 것이다.

또한 로드된 오브젝트를 사용 직후 바로 파괴한다고 하면, C#의 가비지 컬렉터에 좋지 않은 영향을 줄 수 있다. 특히 총알과 같이 자주 사용되는 오브젝트들은 메모리 파편화를 일으키고 Full GC의 호출을 가속화시킬 것이다. 유니티의 GC는 .NET의 GC보다 효율적이지 못하다. 세대 구분, SOH와 LOH, 메모리 재정렬 같은 개념이 없기 때문에 더욱 예민하게 다루어주어야 한다.

GC는 언제 호출될지 파악할 수 없기 때문에, 이러한 점을 고려하지 않고 개발을 하다 보면 게임이 지속해서, 혹은 중요한 순간에 뚝 끊길 수 있는 위험이 생기게 된다.


![GC](https://velog.velcdn.com/images/eugene-doobu/post/669b11a3-2c58-4121-8012-8ce1d80edc23/image.png)

이러한 문제를 해결하기 위해 **오브젝트 풀링(Object Pooling)** 기법을 활용할 수 있다. 오브젝트 풀링은 자주 사용되는 오브젝트를 미리 생성해 두고, 필요하지 않을 때는 일시적으로 비활성화했다가 다시 필요해지면 재사용하는 방법이다. 이를 통해 메모리 할당과 해제를 최소화하여 가비지 컬렉션의 빈도를 낮추고, 게임의 성능을 향상시킬 수 있다. 예를 들어, 총알 객체를 매번 생성하고 파괴하는 대신, 미리 일정 수의 총알 객체를 생성해 두고 필요할 때 가져와 사용한 후 다시 반환하는 방식이다. 이렇게 하면 메모리 파편화와 GC로 인한 성능 저하를 효과적으로 줄일 수 있다.
<br>

<center>
	<img src ="https://velog.velcdn.com/images/eugene-doobu/post/52bbe188-d36f-40a4-9e05-bab95e0fe1d7/image.png" width="50%"> 
</center>

위 사진에서 곰이 레몬이 필요할 때마다 들고 있는 상황이라고 생각해보자. 기존의 방식이 레몬이 필요할 때마다 씻고 옷을 입고 밖으로 나가서 시장에서 레몬을 구매해 오는 것이었다면, 오브젝트 풀은 레몬을 미리 여러 개 구매해 뒀다가 필요할 때마다 필요한 만큼 들고 있는 것이라고 할 수 있다.

#### 오브젝트 풀 개선

9C에서는 자주 사용될 오브젝트를 오브젝트 풀링을 위해 사용하도록 구현되어 있다. 아래 스크린샷과 같이 다양한 콘텐츠들에 사용될 오브젝트들이 풀에 등록이 되어 있었다.

![UI 풀](https://velog.velcdn.com/images/eugene-doobu/post/58325cf4-70b6-4e4a-bba1-d4e7c9ddec09/image.png)|![스테이지 풀](https://velog.velcdn.com/images/eugene-doobu/post/08db71e2-9239-417a-807c-79b6c01b83d1/image.png)| ![오디오 풀](https://velog.velcdn.com/images/eugene-doobu/post/a808393d-6645-4133-8761-a935ef24ebcd/image.png)
---|---|---|

- 게임에 사용하는 모든 UI 1종씩
- 게임에 사용하는 이펙트 3~5개씩, 필요한 경우 추가 생성
- 모든 사운드 오브젝트 1종씩

이 풀의 문제는 게임 콘텐츠의 모든 오브젝트들의 수명이 영구적이었다는 것이다. 이로 인해 메모리가 계속 쌓이는 상황이었으며, iOS의 경우 특정 디바이스에서 앱이 종료되는 문제가 발생할 정도로 메모리 이슈가 있어 한 번의 응급처치가 들어간 상황이었다.

이후 신규 콘텐츠의 업데이트가 연달아서 예정되어 있던 상황이라, 언제 터질지 모르는 메모리 문제를 빨리 해결해야겠다고 생각했고, 빠른 시간 안에 메모리 사용량을 줄일 방법을 찾기 위해 프로파일링 툴을 통해 현재 게임을 위해 사용하고 있는 메모리를 검사해보았다.

# 에디터 프로파일링

![스크린샷](https://velog.velcdn.com/images/eugene-doobu/post/d190a35a-cb0f-4760-bcad-bafc8372d7ec/image.png)

위 오브젝트 풀에 저장되어 있는 오브젝트들이 얼마만큼의 메모리를 점유하고 있는지 확인하기 위한 테스트를 진행했다. 먼저 비교 대상인 A의 경우 기존 게임에서 스테이지에 돌입 후 메모리 캡처를 한 것이고, B는 현재 사용 중이지 않는 UI(Widget), 이펙트, 사운드를 제거 후 `GC.Collect()`를 강제로 돌린 후 캡처를 한 결과이다.

- (In Used) Native Memory -> 393.5 MB 차이 발생
- Untracked Memory -> 366.5 MB 차이 발생

에디터에서 진행한 프로파일링은 에디터의 UI, 내부적인 시스템으로 인해 많은 노이즈가 끼어있어 정확한 수치를 믿을 수는 없다. 그리고 문제가 되는 모바일 디바이스와 에디터가 구동되고 있는 윈도우의 플랫폼 차이가 존재하기에 더욱 그렇다. 하지만 현재 사용하지 않을 오브젝트만 적당히 제거 한다면 1~200MB 정도의 절감할 수 있을 것이라는 기대를 할 수 있게 되었다.

하지만 여기서 문제가 있다. 기존 모든 리소스를 일단 생성해 두고 사용하던 풀 방식에서, 필요한 오브젝트만 생성하여 사용하는 방식으로 바꾸는 것은 기존 방식에서 큰 변화가 필요했고, 그중에서도 가장 많은 메모리를 차지하는 것으로 추정되는 UI의 구조를 변경하는 것은 현재 게임의 핵심 구조를 뜯어고치는 정도의 대규모 리메이크가 필요한 작업이었다.

심지어 팀원들이 관련하여 콘텐츠 작업을 지속적으로 진행해야 했기에, 특히 관리하기 힘든 게임 에셋의 작업 충돌을 피하기 위해 이와 같은 대규모 개선 작업은 진행하기 어려웠다. 게다가, 라이브 서비스 중인 게임의 경우 업데이트와 패치가 실시간으로 이루어지기 때문에, 대규모 변경은 예상치 못한 버그를 초래할 수 있다는 우려도 있다. 이는 유저들에게 직접적인 영향을 줄 수 있어 더욱 신중한 접근이 필요했다. 현실적으로 단기간에 메모리 사용량을 줄이기 위한 방법을 찾기 위해 어떤 에셋이 얼마만큼 메모리를 사용하는지 분석해 보기로 하였다.

(이 글을 쓰는 지금 시점 UI구조를 바꾼것으로 인한 버그가 발생해서 급하게 고치고 오는 길이다)

![메모리분석](https://velog.velcdn.com/images/eugene-doobu/post/6a8dba62-3d12-4c50-9ad8-79d0320316ec/image.png)

위 A와 B 스냅샷에서 리소스가 사용하는 메모리 사용량의 변화를 체크한 결과이다. 메모리 사용량을 기준으로 내림차순 정렬을 하였더니, 같은 리소스가 A와 B에서 다른 해시 값을 가지며 `new/delete`가 반복되어 표시되는 경향이 있어 어떤 리소스를 얼마만큼 줄였는지에 대해서 파악이 힘들었다.

하지만 어떤 일을 하면 메모리 사용량을 줄일 수 있는지 파악할 수는 있었다. 대부분의 메모리가 `Texture2D`, `AudioClip`을 위해 할당된 것을 확인할 수 있었다. 가장 상위에 위치한 2048x2048 사이즈의 이미지(아틀라스)가 압축되지 않은 사이즈인 32MB 용량으로 존재하는 것을 확인할 수 있고, 이와 비슷한 Texture2D 여러 개 존재하다. AudioClip도 이상할 정도의 메모리를 점유하고 있는 걸 보니 이 둘만 줄여도 많은 양의 메모리가 줄어들 것으로 기대할 수 있었다.

- 압축되지 않은 텍스처들이 많이 존재
- 사운드 옵션이 통일되어 있지 않고, 특정 사운드에서 많은 메모리 사용 중
- 시트 데이터로 보이는 것들 중 많은 메모리를 점유 중인 것이 있음
- 렌더 텍스처들이 먹는 메모리도 컸음
- 특정 콘텐츠에서만 사용하는 리소스들이 항상 많은 크기의 메모리를 점유 중

그 외에도 당장 적용하기 힘들지만 장기적으로 적용할 만한 개선 사항들을 파악할 수 있었다. 일단은 텍스처와 사운드에 대한 용량을 줄이는 것으로 빠르게 효율적인 메모리 사용량 감소 작업을 진행할 것이다.

(스프라이트 아틀라스는 여러 스프라이트 이미지를 하나의 큰 이미지 파일로 결합하는 기술이다. 그래픽 처리 효율성을 향상시키고, 렌더링 속도를 높이며, 메모리 사용을 최적화하는 데 도움을 준다. 이에 대한 자세한 설명과 적용 과정은 별도의 글에서 다뤄보도록 하겠다.)

# iOS 프로파일링

iOS에서 메모리 프로파일링을 하는 이유는 다음과 같다

- PC와 모바일을 동시에 지원할 경우, 메모리 문제는 보통 iOS 디바이스에서 가장 먼저 발생한다
- iOS프로파일러가 쓰기 편하다
- 이전에 에디터에서 프로파일링을 했지만, 그 결과에는 에디터 자체의 데이터가 포함되어 불필요한 노이즈가 발생한다. 이러한 노이즈를 제거하고 정확한 메모리 사용량을 측정하기 위해 특정 디바이스에서 앱을 실행하고 프로파일링하는 것이 좋다.

### 1. 기존 프로젝트에서 성능측정

![iOS 프로파일링](https://velog.velcdn.com/images/eugene-doobu/post/4e20be6b-a335-4eed-8216-54aa733cfafe/image.png)

기존 프로젝트에서 콘텐츠를 진행하면서 메모리 사용량을 측정해보았다. 콘텐츠를 실행할 때 필요한 리소스들이 누적되어 메모리 사용량이 지속적으로 증가하는 것을 확인할 수 있었다.

```
로비 : 1.51GB  
마켓 : 1.56GB  
워크샵-소환 : 1.67GB  
소환영상 시청중 : 1.73GB  
월드보스 전투중 : 1.82GB  
로비 : 1.8GB  
몬스터콜렉션 : 1.83GB  
아레나 전투 로딩 : 1.94GB  
아레나 전투 후 로비 : 1.96GB  
제작강화룬업글분해 후 로비: 2.01GB  
시즌패스 : 2.14GB  
컬랙션 : 2.14GB  
스테이지 329 : 2.2GB  
로비 : 2.17GB  
어드벤처보스 1층 전투 : 2.32GB  
어드벤처보스 돌파 : 2.43GB  
로비 : 2.41GB
```

![gpu](https://velog.velcdn.com/images/eugene-doobu/post/fe239a4d-152c-4969-ada4-b4e537324ca0/image.png)

이렇게 iOS에서 GPU 성능측정과 리소스별 메모리 사용량을 점검할 수 있다. 위 에디터 프로파일링 결과와 비슷하게 압축되지 않은 아틀라스들이 상당히 많은 메모리를 차지하는 것을 확인할 수 있다. 실제 게임이 돌아가는 모바일 디바이스에서도 텍스처 압축만 잘 하면 많은 메모리 여유를 확보할 수 있음을 확신하는 순간이였다.

### 2. 메모리 정리 기능 추가

텍스처 압축에 앞서, '로비로 갈 때마다' 메모리를 수동으로 정리하는 기능을 추가했다. 이전에 9C에서는 대부분의 오브젝트들이 풀에 저장되어 지속적으로 메모리가 쌓이는 형태라고 이야기했지만, 그렇지 않은 콘텐츠들도 존재했다. 기본적으로 전투에서 등장하는 몬스터 스파인 리소스들은 필요할 때 로드하고 전투가 끝나면 파괴하는 구조로 구현되어 있었다.

또한 이전에 iOS에서 메모리 사용량이 많아 앱이 종료되는 이슈가 있었고, 이에 따른 응급처치가 이루어졌는데, 로그인 단계에서 사용하는 오브젝트들을 로비로 들어오는 과정에서 파괴하는 기능이 구현되어 있었다. 하지만 이러한 작업에서도 메모리가 깔끔하게 정리되지 않는 문제가 있었다.

유니티에서는 특정 리소스를 사용하던 오브젝트가 해제되어도 사용하던 리소스를 즉시 해제하지 않고, 씬이 종료될 때 해제하도록 구현되어 있다. 이는 메모리 관리 측면에서 이점이 있을 수 있지만, 우리가 원하는 메모리 최적화에는 걸림돌이 될 수 있다. 예를 들어, 게임 플레이 도중에 필요하지 않게 된 거대한 텍스처나 오디오 클립이 있다면, 해당 오브젝트를 파괴해도 메모리에서 즉시 해제되지 않기 때문에 메모리 사용량이 계속 높게 유지된다.

문제는 9c가 단일 씬 구조로 되어있었기에 로비에 진입하면서 파괴된 오브젝트들에서 사용하던 리소스가 제대로 정리되지 않던 문제가 있었던 것이다. 오브젝트 풀에 쌓이고 있는 오브젝트를 정리하기 전에, 이러한 리소스 청소 과정을 도입해야 겠다고 생각하였고, 해당 기능을 추가하고 메모리 사용량을 다시 측정해보았다. 변경된 코드는 매우 간단하다.

```c#
		// Clear Memory
		Resources.UnloadUnusedAssets();
		GC.Collect();
```

[PR: clear memory on room enter](https://github.com/planetarium/NineChronicles/pull/5319)

이와 같이 코드를 수정하고 나서 다시 메모리를 측정 한 결과이다. 최종 결과 기준 약 200MB 정도의 메모리 사용이 절감되었다.

```
로비: 1.44GB (기존 1.51GB)  
마켓→소환→월드보스전투  
로비: 1.61GB (기존 1.8GB)  
몬콜→아레나 전투  
로비:  1.63GB (기존 1.96GB)
제작강화룬업글분해
로비: 1.72GB (기존 2.01GB)
시즌패스 컬랙션 스테이지329, 330,331(원래 329만 했었는데 실수로 두스테이지 더돔)
로비: 1.92GB(기존 2.17GB 이상)
```

### 3. 오디오/아틀라스 압축 옵션을 적용하고 다시 테스트

다음으로, 아틀라스들이 압축될 수 있도록 설정하고 사운드 옵션을 통일하여 다시 빌드를 진행했다. 이때 사용한 옵션들과 세부 사항은 이 글에서 다루기에는 분량이 많아질 것 같아 별도의 글에서 따로 다뤄보도록 하겠다.

[PR: 아틀라스 셋팅 통일](https://github.com/planetarium/NineChronicles/pull/5318)<br>
[PR: audio controller polishing](https://github.com/planetarium/NineChronicles/pull/5283)

```
로비: 1.13GB(기존 1.44GB) [초기: 1.51GB]
마켓→소환→월드보스전투
로비: 1.3GB(기존 1.61GB) [초기: 1.51GB]
몬콜→아레나 전투
로비:  1.31GB(기존 1.63GB) [초기: 1.96GB]
제작강화룬업글분해
로비: 1.4GB(기존 1.72GB) [초기: 2.01GB]
시즌패스 컬랙션 스테이지329
로비: 1.48GB(기존 1.92GB) [초기: 2.17GB]
```

### 결론

- 사용하지 않는 리소스 정리로 인한 여유 메모리 확보
- 오디오 및 아틀라스 설정을 정리하여 리소스 메모리 사용량 감소

클라이언트 메모리 사용량을 30% 감소(2.1gb → 1.4gb)

# 앱 용량
---

이번 글은 메모리 최적화에 대한 주제를 다루는 글이지만, 관련 작업을 하면서 앱 용량도 효과적으로 줄일 수 있었다.

![8월드](https://velog.velcdn.com/images/eugene-doobu/post/9354bf71-652f-4d8d-a333-a950540ca25f/image.jpg)

### 1. 기존 빌드 결과물 용량

앱 용량 비교는 많은 리소스가 추가되었던 8월드를 기준으로 한다. 실제 앱 용량을 비교하기 전에, 모바일 빌드 CI에서 나온 결과물의 용량을 먼저 확인하여 얼마나 용량이 줄었는지 파악했다. 이 결과물은 실제 앱 용량이 아니라 해당 플랫폼에 업데이트를 준비하기 위한 것으로, 실제 앱 용량은 이보다 더 가볍다.

**안드로이드: 1.2gb**  
**IOS: 2.76gb**

[8월드 리소스 PR](https://github.com/planetarium/NineChronicles/pull/4336)

### 2. 스프라이트 리소스 정리

이번에는 기존 프로젝트에서 사용하는 많은 양의 텍스처가 압축되지 않고 있다는 문제를 발견했다. 또한 하나의 텍스처가 여러 아틀라스에서 중복 포함되는 문제가 있었고, 모든 스파인 아틀라스가 `POT(Power of Two)` 형태가 아니라 특정 디바이스에서 압축이 불가능한 상황이었다.

이를 해결하기 위해 먼저 안드로이드에서의 압축을 위해 스파인 아틀라스 텍스처를 POT 형태로 고정하여 추출하였다. 이후 모든 텍스처에 대해 압축 설정과 아틀라스 정리를 진행했다.

[PR: 스파인 atlas pot](https://github.com/planetarium/NineChronicles/pull/4373)<br>
[PR: 텍스처 패킹](https://github.com/planetarium/NineChronicles/pull/4419)

**안드로이드: 899MB** - 8월드 대비 -301MB  
**IOS: 2.07GB** - 8월드 대비 -690MB

해당 챕터에서 사용한 최적화 기법들에 대한 상세 내용은 추후 별도의 글에서 다뤄보도록 하겠다.

### 실제 앱 용량 비교

빌드 산출물은 위와 같은 결과가 나왔다. 이제 실제 앱 스토어에 등록되어있는 앱의 크기를 통해 유저들이 다운받을 앱 용량이 얼마나 줄었는지 확인해보자.

iOS: `625MB` -> `460MB`  (앱 스토어 커넥트에서  `압축 파일 크기`)  
Android: `648MB` -> `478MB` (구글 플레이 콘솔에서 `원본 파일`)

iOS의 경우 **165mb차이로 26.4%**  
Android의 경우 **170mb차이로 26.2%**

평균 26.3% 정도의 용량을 절감시킬 수 있었다. 이로 인해 앱 다운로드를 통하여 소모될 전력을 절감시켜 지구 온난화의 가속을 둔화시킬 수 있었다.

<center>
	<img src ="https://velog.velcdn.com/images/eugene-doobu/post/9d2c5536-1000-49cd-b07e-208537b63c4a/image.png" width="40%"> 
</center>

# 마무리
---

사실 아직도 최적화 할 일이 많이 남아있다. 

### 오브젝트 풀의 메모리 사용량

처음에 9c의 오브젝트 풀 구조에 대한 문제점을 이야기하였다. 하지만 이를 근본적으로 고치는 작업은 진행하지 못했다. 이를 해결하지 못하면 콘텐츠가 추가됨에 따라 앱 사용 메모리가 지속해서 증가하는 현상이 계속 존재할 것이고, 언젠가는 발목을 크게 잡게 될 가능성이 있다. 

이를 개선하기 위한 첫 삽으로 로그인 씬을 분리하는 작업을 진행해 보았다. 실제 메모리 사용량을 절감하는 데 큰 도움은 안되지만, 앞으로는 콘텐츠 별로 씬을 분리할 수 있고, 모든 오브젝트가 항상 살아있는 것이 아닌 필요한 순간마다 생성해서 풀에 등록해 놓을 수 있도록 적용하는 작업을 시작할 수 있게 되었다.

[PR: 로그인 씬 분리](https://github.com/planetarium/NineChronicles/pull/5452)

### 아틀라스 정리

위에서 스프라이트 리소스 정리를 진행하였지만 모든 아틀라스에 대한 정리를 진행하지 못했다. 여전히 중복해서 아틀라스에 등록되는 텍스처가 존재하고, 아틀라스 구조에 대한 일관성을 확보하지 못했다. 한 화면에 그려질 가능성이 있는 오브젝트들만 패킹하여 렌더링할 수 있도록 아틀라스가 구성이 되어야 할 텐데, 이에 대한 점검도 필요할 것으로 보인다. 이에 대응하기 위한 이슈는 만들어 두었지만, 손을 대고 있지 못하는 상황이다.

[issue: 아틀라스 리소스 정리](https://github.com/planetarium/NineChronicles/issues/4324)

이는 모두 9c에서 사용하는 근본 구조에서 기인한 문제라고도 볼 수 있다. 프로젝트의 초기 단계부터 구조가 설계되고, 그 위에 추가적인 콘텐츠 코드들이 쌓이고 에셋들도 그것에 맞게 쌓아가다 보면 후반에 와서 최적화를 하기에는 곤란해진다. 언젠가 이를 개선할 기회가 생기거나 다시 메모리 문제가 생기기 직전의 상태까지 온다면 버그와 작업 충돌이 생길 수 있음을 각오하고 해당 구조를 뜯어고쳐야 할 순간이 올지도 모르겠다.

이 외에도 몬스터 스파인 에셋 데이터를 저장하는 방식을 바꾸어 로드시간을 단축하기도 하였다. 이와 관련된 내용과 해당 글에서 적용한 최적화 기법에 대한 자세한 내용들은 다음에 작성할 `번외1. 리소스 최적화 기법`글에서 자세히 다뤄보도록 하겠다.

![끝](https://velog.velcdn.com/images/eugene-doobu/post/7ac2a11d-0b69-4e2d-83a3-b4e2dc6c8360/image.png)


[블로그 원본](https://velog.io/@eugene-doobu/%EB%9D%BC%EC%9D%B4%EB%B8%8C-%EA%B2%8C%EC%9E%84-%EC%97%90%EC%85%8B-%EA%B4%80%EB%A6%AC-%EA%B0%9C%EC%84%A0%EA%B8%B0-2.%EB%A9%94%EB%AA%A8%EB%A6%AC-%EC%82%AC%EC%9A%A9-%EC%A0%88%EA%B0%90%EB%82%98%EC%9D%B8%ED%81%AC%EB%A1%9C%EB%8B%88%ED%81%B4)
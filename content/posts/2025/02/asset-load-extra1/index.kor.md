---
title: "라이브 게임 에셋 관리 개선기 - 번외1.리소스 최적화 기법"
date: 2025-02-11
authors: [eugene-doobu]
ogimage: images/og.kor.jpg
---


이번 글은 이전 글에서 이야기한 최적화 기법의 세부 내용을 다루는 글입니다. 이 글을 읽기 전에 이전 글을 읽어보는 걸 추천합니다.


[라이브 게임 에셋 관리 개선기 - 2.메모리 사용 절감
](https://velog.io/@eugene-doobu/%EB%9D%BC%EC%9D%B4%EB%B8%8C-%EA%B2%8C%EC%9E%84-%EC%97%90%EC%85%8B-%EA%B4%80%EB%A6%AC-%EA%B0%9C%EC%84%A0%EA%B8%B0-2.%EB%A9%94%EB%AA%A8%EB%A6%AC-%EC%82%AC%EC%9A%A9-%EC%A0%88%EA%B0%90%EB%82%98%EC%9D%B8%ED%81%AC%EB%A1%9C%EB%8B%88%ED%81%B4)


1부. 어드레서블 에셋 도입 <br>
2부. 메모리 사용 구조 개선 / 리소스 최적화 <- 현재 글  <br>
**번외1. 리소스 최적화 기법** <br>
3부. DLC를 통한 패치 시스템

# 인트로

---
이전 글에서 게임의 용량과 메모리에 대한 내용에 대해 이야기 하고 게임 리소스를 최적화하여 앱스토어에 올라가는 앱의 용량과 게임의 메모리 사용량을 줄이는 작업을 해 보았다. 이번 글에서는 이전 글에서 간단하게 설명만 하고 지나간 리소스 최적화에 사용한 설정에 관한 내용을 정리해 보려고 한다.

이번 번외편에서는 이전에 다룬 텍스처 압축, 텍스처 패킹과 스프라이트 아틀라스, 그리고 오디오 압축 등 주요 리소스 최적화 기법에 대해 간단히 정리해보고자 한다. 단순 나열식에 가까운 글이 될 것 같아 `어떤 방식들이 있구나` 하는 정도로 가볍게 훑어 보는걸 추천한다.

# 0. 다시 한번 나인크로니클

---

![플레이화면](https://velog.velcdn.com/images/eugene-doobu/post/bcf8edab-ac8b-4dc9-b6e3-f837c17a49a4/image.png)

게임 최적화를 하기 이전에 게임이 어떤 특징을 가지고 있는지 알아야 한다. 특히 어떤 디바이스를 사용하느냐에 따라 사용되는 옵션과 전략이 크게 달라질 수 있다. 먼저 [나인크로니클](https://github.com/planetarium/NineChronicles)(9C)은 풀 블록체인 기반의 2D RPG게임이며 **모바일-PC 크로스 플랫폼**을 지원한다. 블록체인 게임이라는 굉장히 특별한 특징이지만, 리소스 최적화와는 크게 연관은 없는 내용이라 `2D`와 `모바일-PC 크로스 플랫폼`이라는 점이 핵심이 된다.

### 2D 게임에서의 최적화

2D 게임의 경우 확실히 3D게임 보다는 최적화 부담이 덜하긴 하지만, 텍스처가 많아지고 이에 대한 관리를 소홀히 하면 큰 문제가 생길 수도 있다. 특히 여러 스프라이트를 겹쳐서 사용하는 경우가 많은데, 이러한 경우 렌더러가 한 픽셀을 여러번 렌더하는 **OverDraw현상이 발생**하여 불필요한 연산이 많아질 수 있다.


![OverDraw](https://velog.velcdn.com/images/eugene-doobu/post/7e3792c4-00c6-4416-8b9a-0dc1d20286a3/image.png)

위 스크린샷은 9c 메인 화면에서 `OverDraw`옵션을 활성화 시킨 모습이다. 화면의 대부분이 흰색으로 보이는데, 이는 씬에서 사용하는 파티클이 중첩되어 렌더링되어 나타난 현상으로 보인다. 좌상단에 있는 퀘스트 UI를 아래 OverDraw를 비활성화 시킨 UI랑 비교해보면, 던전 아이콘(마름모 모양)이 사각형 형태로 오버드로우 되고 있음을 알 수 있다.


![퀘스트 UI](https://velog.velcdn.com/images/eugene-doobu/post/13402bbc-b3a2-4bb7-81fe-83e9d50bfd42/image.png)

> **OverDraw:** 게임 오브젝트를 투명한 “실루엣”으로 렌더링합니다. 투명한 컬러가 중첩되면 한 오브젝트 위에 다른 오브젝트가 그려진 곳을 쉽게 파악할 수 있습니다.

### PC-모바일 게임에서의 최적화

크로스 플랫폼의 경우 일반적으로 PC의 성능이 모바일보다 압도적으로 좋기 때문에, 모바일을 대상으로 최적화한다면 PC 도 자연스럽게 최적화가 될 것으로 생각한다. 따라서 저번 글에서도 오로지 모바일 스토어 상에서의 빌드 용량과 메모리 사용량을 비교를 하였다.

모바일 게임 최적화는 옛날부터 핫한 주제였기에 다양한 글들이 있다. 이에 대한 관심이 있다면 유니티 블로그에 작성된 아래 글을 읽어 보는 것을 추천한다.

[모바일 게임 성능 최적화: 그래픽과 에셋에 관한 전문가 팁](https://unity.com/kr/blog/games/optimize-your-mobile-game-performance-expert-tips-on-graphics-and-assets)

# 1. 스프라이트 아틀라스

---


![Atlas](https://velog.velcdn.com/images/eugene-doobu/post/f74ac31a-012f-412d-ba47-0d6bd81eb2c5/image.png)

스프라이트 아틀라스는 게임에서 사용하는 스프라이트 텍스처들을 위 스크린샷과 같이 하나로 묶어 하나의 텍스처처럼 사용하는 것이다. 게임에서 사용하는 자잘한 텍스처들이 많을수록 최적화를 위해 스프라이트 아틀라스를 적용하는게 좋다.

![Batches](https://velog.velcdn.com/images/eugene-doobu/post/ea15b26a-0ffd-49c5-98a3-0a19a923d42b/image.png)

**1. 드로우콜 줄이기**

CPU가 GPU에게 일을 시키기 위해서는 어떤걸 그려야 한다고 명령을 호출해야 하는데, 이를 `드로우콜(DrawCall)` 이라고 한다. GPU는 연산량이 빠르지만, CPU와 데이터를 주고 받는 시간은 느리기 때문에 GPU를 최대한으로 활용하기 위해서는 이 드로우콜 횟수를 줄여야 한다. 유니티에서는 **동일한 메터리얼을 사용하는 오브젝트들을 묶어 1개의 드로우콜로 묶어서 보내주는** `배칭(Batching)기능`이 있다. 2D Sprite도 배칭이 가능하며 텍스처 아틀라스와 같은 기법을 활용하여 스프라이트들을 하나의 이미지에 모아 GPU로 보내줄 수 있는 것이다. 배치의 수는 유니티의 Statisics에서 쉽게 확인할 수 있다.

**2.텍스처 압축 포멧의 POT(Power of two)**

텍스처 압축 포맷중 압축을 하기 위한 조건이 POT(Power of two)인 경우가 있다. 해당 조건이 있는 포맷의 경우 텍스처 이미지의 사이드가 2의 승수가 아닌 경우 텍스처 압축이 불가능 하다. UI에 사용하는 아이콘들은 이러한 조건을 갖추기 어렵기 때문에, 이러한 텍스처들을 모아 2의 승수의 크기로 아틀라스를 뽑아주면 텍스처 압축이 가능해진다. 텍스처 압축에 대한 내용은 뒤에서 자세하게 다루도록 하겠다.

### 아틀라스 이중압축

![아틀라스 이중 압축](https://velog.velcdn.com/images/eugene-doobu/post/3570d562-9a88-4368-b54e-0e928d66e428/image.png)

(사진 출처: [unity discussions](https://discussions.unity.com/t/do-sprite-atlases-double-compress-sprites/228209))

텍스처 압축은 텍스처의 품질을 변경시키는데, 아틀라스에서 가져오는 텍스처들은 압축이 되어있는지 안되어있는지 체크되지 않는다. 위 스크린샷을 보면, 압축되지 않은(RGBA 32 bit)포맷 으로 설정하고 압축된 텍스처와 압축되지 않은 텍스처를 가져오는 경우 **압축된 텍스처가 품질이 저하된 그대로 아틀라스에 들어오는 것을 확인**할 수 있다. 따라서 스프라이트 아틀라스를 사용하는 경우, 아틀라스에 포함될 텍스처들은 압축이 되지 않도록 잘 분리를 해주어야 좋다.

(텍스처 압축 포맷은 결국 랜덤 액세스가 가능하게 포맷당 정해진 비트를 사용하므로 이중 압축이 되어도 성능적으로 이득을 보는 건 없다)

# 2. 텍스처 압축

---

iOS: `625MB` -> `460MB` (앱 스토어 커넥트에서 `압축 파일 크기`)
Android: `648MB` -> `478MB` (구글 플레이 콘솔에서 `원본 파일`)

[텍스처 패킹에 대한 PR](https://github.com/planetarium/NineChronicles/pull/4419
)

이전 글에서 텍스처 압축을 통해 앱스토어의 용량을 약 26%씩 줄인 결과를 보여주었다. 실제로는 이 작업이 머지되면서 대형 컨텐츠들이 업데이트 되었고, 텍스처 압축 전 빌드 용량은 이 컨텐츠 리소스들이 포함되지 않은 상태였기에 실제로는 26% 이상의 용량이 절약되었을 것이다.

![용량의 차이](https://velog.velcdn.com/images/eugene-doobu/post/86efd201-4480-4df8-b2bb-d83940a3b1b0/image.png)

이처럼 2D 프로젝트에서 텍스처 압축은 엄청난 힘을 보여준다. 이번 챕터에서는 유니티에서 사용할 수 있는 텍스처 압축 옵션들은 어떤 것들이 있고 프로젝트에 어떻게 적용하였는지에 대해 설명해보고자 한다.

### 텍스쳐 파일 포맷

![파일 포멧](https://velog.velcdn.com/images/eugene-doobu/post/247b5455-9714-402f-8ad8-a4dc92764bad/image.png)

_(사진 출처: 유니티 코리아 유튜브)_

흔히 텍스처 포맷이라고 하면 우리가 흔하게 볼 수 있는 `파일 포맷`을 생각해볼 수 있다. 이는 일반적으로 디스크에 파일을 저장할 때 저장 용량을 아끼기 위한 압축 포맷으로 생각하면 된다.

유니티에서는 다양한 파일 포맷을 가져와 별도의 처리 없이 사용할 수 있다. 물론 PSD를 사용하면 프로젝트 자체의 용량이 어마어마 해진다던지, PNG를 사용하면 알파 채널을 컨트롤 하기 힘들어 추가 옵션을 설정해야 한다던지 차이점이 조금씩 존재하지만, 결과적으로 게임 빌드파일에 들어갈 텍스처 어떤 포맷을 사용하든 상관없다.

> **사용 가능 포맷:** BMP, EXR, GIF ,HDR, IFF, JPG, PICT, PNG, PSD, TGA, TIFF...

이러한 텍스처 포맷들은 디스크에 GPU를 위한 형태로 저장되어 있지 않다. 따라서 게임에 텍스처를 효율적으로 사용하기 위해서는 디스크에 저장된 이미지 파일들을 GPU를 위한 텍스처 포맷으로 따로 지정해주어야 한다. 실제 게임에서는 GPU를 위해 변경된 포맷으로 텍스처를 변환 시켜 사용하기 때문에 디스크에 저장되어 있는 포맷이 무엇인지는 상관 없는 것이다.

텍스처 포맷을 지정할 때 현재 사용하는 디바이스에서 지원해주고, 시각적인 효과 대비 이미지 품질이 적게 변하는 포맷으로 잘 조율하여 변경하여야 한다. 텍스처 압축에서 가장 중요한 것은 적절한 압축 포맷을 사용하는 것이다.

#### 왜 GPU에서 못써요?

디스크에 저장되는 파일 포맷들은 보통 저장 용량을 아끼기 위한 압축 포맷인 경우가 많은데, 예를 들어 PNG 파일은 `가변 비율 압축`을 사용하여 자신의 용량을 압축하고 있다. 예를 들어 aaaabbbcccccd라는 원본 데이터가 있을 때, a4b3c5d1과 같은 식으로 디스크에 저장 되게 되는 것이다. GPU에서 텍스처를 사용할 때에는 보통 UV좌표를 이용해서 텍스처의 특정 부분을 `랜덤 엑세스`하여 색상을 가져오게 되는데, `시작 주소+오프셋`방식으로 접근하는 랜덤 액세스 방식은 위처럼 압축되어 있는 데이터에 사용하기가 힘들다. 따라서 GPU에서 랜덤 액세스를 통해 샘플링을 할 수 있도록 포맷을 변경해줘야 한다.

## 텍스처 압축 포맷

대표적인 압축 포맷인 ETC2, ASTC, PVRTC에 대한 정보를 정리해보았다.

### ETC2: 범용성을 앞세운 안드로이드 표준

![ETC2](https://velog.velcdn.com/images/eugene-doobu/post/ab79022c-26e9-41f3-a169-40ae6d8d1cf4/image.png)

(사진 출처: Ericsson AB 2009, ETC2-PACKAGE)

**ETC2**(Ericsson Texture Compression 2)는 OpenGL ES 3.0 이상 버전을 지원하는 대부분의 안드로이드 기기에서 표준처럼 사용되는 압축 포맷이다. `ETC1`의 후속 버전으로, 알파채널을 지원하고 전반적인 압축 후 이미지 퀄리티가 ETC1보다 개선되었다.

### 특징

1. **범용 지원**: 안드로이드 환경 전반에 광범위하게 적용되어 있어 호환성 면에서 유리하다.
2. **알파 지원**: ETC1은 알파 채널을 지원하지 않았지만, ETC2는 RGBA 형태로 알파까지 담을 수 있다.  
3. **고정 비트레이트**: ASTC처럼 가변 비트레이트를 지원하지는 않아, 화질과 크기를 섬세하게 조절하기는 어렵다.

ETC2는 현재 **안드로이드에서 가장 호환성이 좋은 텍스처 포맷**으로 생각하면 된다. 저사양 안드로이드 디바이스들을 타겟으로 삼고 있는 경우 ETC2 포맷을 선택하는 것이 좋다. 뒤에서 소개할 `ASTC` 포맷이 압축 품질, 유연성 면에서 우수하기 때문에 주 타겟으로 삼고있는 디바이스가 저사양 기기가 아니라면 ASTC포맷을 사용하는게 유리하다.

(ASTC 6X6의 경우 ETC2와 비슷한 품질을 보여주지만 용량은 절반 수준이다)


### PVRTC: iOS 위주의 압축

![PVRTC](https://velog.velcdn.com/images/eugene-doobu/post/7a01acc4-5eca-49c4-8a18-8bb234169335/image.png)

(사진 출처: imaginationtech)

### 개요
**PVRTC**(PowerVR Texture Compression)는 iOS 디바이스를 중심으로 많이 사용되는 텍스처 압축 포멧이다. 모든 세대의 iPhone, iPod Touch, iPad에서 사용가능하며, PowerVR GPU를 사용하는 특정 Android 기기에서도 지원된다. **텍스처의 해상도가 2의 지수승 정사각형이어야 한다**는 제약이 있다.

### 특징
1. **블록 크기**: PVRTC는 텍스처가 2의 거듭제곱 해상도를 권장하며, 블록 단위 압축 특성이 있어 이미지가 특정 크기여야 최적 결과를 얻기 쉬움  
2. 블록 경계를 뭉개며 **블러링**을 시켜주며, **블록 경계에서 색이 번지는 현상**이 일어날 수 있다. 도트나 아이콘에는 좋지 않다.

조사하면 할 수록 현재 시점에서 이 포맷을 왜 쓰는지 이해가 가지 않았다. 텍스처의 해상도가 2의 지수승 정사각형이어야 한다는 제약이 너무 크게 느껴졌다. 소형 아이콘은 아틀라스로 묶어서 쓴다고 하더라도 모든 텍스처를 그렇게 쓰기는 힘들다고 생각된다. iOS도 역시 가능하면 **ASTC**를 사용하는게 가장 좋은 방향인 것 같다. 근데 ETC2랑 상황이 다르게 ASTC는 iOS유저라면 거의 확정적으로 사용할 수 있다.

(PVRTC를 사용해야하는 특별한 이유가 있다면 댓글로 알려주세요...)

### ASTC: 다양한 비트레이트로 품질 조절

![ASTC](https://velog.velcdn.com/images/eugene-doobu/post/fd357a41-c2a4-4622-bc64-58a5ee2fbec0/image.png)

(사진 출처: developer.arm.com)


**ASTC**(Adaptive Scalable Texture Compression)는 ARM과 AMD가 공동 개발한 압축 포맷이다. 가변 비트레이트를 지원하며 개발자가 해상도·화질·압축률 간의 트레이드오프를 자유롭게 조정할 수 있다. 또한 위에서 설명한 이전 시대의 포맷들 보다 압축률 대비 텍스처 품질도 뛰어나다.

### 특징
1. **가변 블록 크기**: 4×4부터 12×12 픽셀 블록까지, 비트레이트를 자유롭게 설정 → 원하는 균형점을 찾기 쉬움  
2. **멀티플랫폼 지원 확대**: 최신 안드로이드 기기나 iOS Metal 등에서 점차 지원이 확산.
3. **고품질 유지**: 높은 비트레이트(예: 4×4 블록)로 설정하면 일반 DXT나 ETC2보다 화질이 우수한 압축 결과를 낼 수 있음  
4. 비교적 **최신 기기에서만 지원**한다.

유연한 포맷으로 모델링이라던지 정밀도가 높아야 하는 텍스처는 압축 블럭을 작게 지정(4x4)하고, 이펙트와 같은 휘발성이 높거나 디테일이 높지 않아도 되는 경우 압축 블럭을 크기 지정(12x12)하는 식으로 사용할 수 있다. 어느정도 압축(6x6 정도)을 하더라도 ETC2나 PVRTC와 비슷한 품질이 나오기 때문에 주 타겟 디바이스가 **ASTC를 지원한다면 ASTC를 선택하는걸 추천**한다


## 나인크로니클에서의 텍스처 압축

### 기존상태

![build report](https://velog.velcdn.com/images/eugene-doobu/post/5dca7eb2-279e-4bb1-8847-ce76a4e315f1/image.png)

텍스처 압축 설정 전에 빌드 리포트를 뽑아 리소스의 사이즈를 체크해 본 결과이다. 빌드 리포트의 상위권에 많은 양의 Uncompressed Texture2D 친구들이 있었다. 이것만 압축해도 빌드 용량을 크게 줄일 수 있다. 살펴보니 압축 옵션이 되있는 것들과 안 되 있는 것들이 섞여있던 상태. 우선 되있는 것들의 포맷에 맞춰야 한다는 생각이 들었다.

또한 위의 **이중압축 문제**가 발생하지 않게 아틀라스에 포함될 텍스쳐는 압축을 하지 않아야 한다. 아틀라스에 포함되는 텍스처들과 포함되지 않는 텍스처들이 프로젝트에서 분리가 되어있지 않아 이러한 구분이 까다로웠다. 아틀라스로 관리될 텍스쳐들은 확실히 분리하는게 좋다.

### 시장조사

2024-02-16기준으로 디바이스별 텍스처 압축 포맷 지원에 대한 통계를 찾아보았다.

#### 안드로이드

![Android Texture](https://velog.velcdn.com/images/eugene-doobu/post/53fb8ec7-fcc9-4ec5-8a45-331eeb06356c/image.png)

(+2022.8.8기준 PVRTC 11%)

#### iOS

![iOS Usage](https://velog.velcdn.com/images/eugene-doobu/post/2fa6cd66-a63c-4516-8586-5d5fe96f5084/image.png)

현재 89% 유저가 ios16 이상 기기 사용, **ios13이상 사용시 확정적으로 astc 지원**

(2021년 4월 기준, [약 2%의 유저들만 A7(astc 지원 안하는 기기)칩을 이용](https://forum.unity.com/threads/ios-changed-default-texture-compression-format-from-pvrtc-to-astc.1088845/
)한다고 함)

ios의 경우 아래 포함 상위 기기에서 모두 지원(A8 processor)

- [iPhone 6 & 6 Plus](https://en.wikipedia.org/wiki/IPhone_6)
- [iPod Touch (6th generation)](https://en.wikipedia.org/wiki/IPod_Touch_(6th_generation))
- [iPad Mini 4](https://en.wikipedia.org/wiki/IPad_Mini_4)
- [Apple TV HD](https://en.wikipedia.org/wiki/Apple_TV) (formerly 4th generation)
- [HomePod (1st generation)](https://en.wikipedia.org/wiki/HomePod)

#### 나인크로니클 플레이 유저

회사 내부에서 사용하고 있는 솔루션들의 통계를 통해 게임을 플레이하는 유저들의 국가 통계를 알 수 있었다. 확인 결과 역시 안드로이드는 ETC2로 가는게 안전하다는 판단이 들었다. iOS의 경우 굳이 PVRTC를 사용할 이유를 찾지 못하였다.

## 결론

### 안드로이드 → ETC2

- **일부 색상 손실**
- **95%의 디바이스 지원**
- ETC2가 지원되지 않는 5% 기기는 무압축 32/16bit텍스처 지원
- 기존에도 해당 압축 옵션을 사용한 텍스처들이 꽤 있음

### IOS → ASTC

- **iPhone 5s 타겟으로 최적 지원 안됨** (ios13부터 100%기기 모두 지원)
→ 확인상 거의 모든 텍스처가 ASTC 아니면 압축안함으로 설정되어 있었음. 따라서 디바이스가 ASTC를 지원하지 않아도 사실상 변경사항 거의 없음

따라서, 앞으로

- PVRTC를 사용하지 않음으로 텍스처 이미지를 정사각형으로 뽑을 필요가 없다.
- 텍스처 추출은 안드로이드(ETC2)를 위해 일단 POT으로 뽑아야함

![Spine Pot](https://velog.velcdn.com/images/eugene-doobu/post/c428b723-c5bc-4141-b992-8f0b832bdbfc/image.png)

이 기준에 맞게 프로젝트에서 사용하는 [스파인 리소스들을 정리](https://github.com/planetarium/NineChronicles/pull/4373)하였다.

# 3. 오디오 압축 기법

---

오디오도 설정에 따라 프로젝트의 메모리 사용량이 크게 달라진다.

### 모노와 스테레오

사운드는 모노와 스테레오 사운드로 나뉜다. 스테레오는 2개의 채널을 사용하므로 모노의 2배의 용량을 사용한다고 보면 된다. 사운드의 용량도 가벼운 편이 아니므로 디바이스와 게임 콘텐츠 특성을 고려해 올바른 옵션을 선택하여야 한다.

- **모노**: 하나의 채널을 통해 믹싱되고 재생되는 오디오를 말하며, 이는 하나의 스피커 또는 여러 개의 스피커가 동일한 소리를 동시에 내는 형태입니다.
- **스테레오(Stereo)**: 왼쪽과 오른쪽 두 채널을 사용하여 서로 다른 오디오 신호를 전달하며, 깊이와 차원의 감각을 더해줍니다.
(출처: [KEF: 모노(Mono) vs. 스테레오(Stereo) 사운드: 차이점은 무엇일까요?](https://kr.kef.com/blogs/news/mono-vs-stereo-speakers-sound-differences))

일반적으로 모바일 디바이스의 경우 게임에서 스테레오 사운드를 사용할 일이 거의 없다. 모바일의 경우 대부분 MONO로 설정해주면 된다.

### 로드타입

- **Decompress on load**: 압축을 풀어서 올리는 굉장히 위험한 옵션. 재생속도가 굉장히 빠른 특성이 있다. 사운드의 길이가 짧고 반응속도가 매우 중요한 경우 사용하는게 좋다.
- **Compressed into memory**: 압축된 사운드 사용, 일반적인 효과음을 이 옵션으로 지정하는게 좋다.
- **Streaming**: 보통 사운드 길이가 긴 배경음악, 반응속도가 중요하지 않은 사운드에 적용하는게 좋다.

위 설명대로 대부분의 경우 효과음은 `Compressed into memory`, 배경음악은 `Streaming`을 사용하면 될 것 같다.

### Compression Format

- PCM: 비압축 포맷으로 퀄리티가 중요하며 재생시간이 짧은 오디오 파일에 적합하다.
- Vorbis: 중간길이 정도의 효과음 또는 배경음악에 적합하며 압축률(Quality)를 조절할 수 있다. 대부분의 경우 이 옵션을 선택한다.
- ADPCM: 압축률이 PCM대비 3.5배이기에 메모리는 덜 쓸 수 있지만, CPU자원은 조금 더 사용한다. 노이즈가 발생하기에 노이즈가 크게 상관없는 효과음에 적합하다.

또한 사운드가 Mute되어도 프로세스에 메모리는 존재하는 상태로 남아있는다. 이러한 점을 주의하고 프로파일링을 통해 낭비되고 있는 메모리가 없는지 체크하는게 중요하다.

### 9C에서의 사운드 압축

![오디오](https://velog.velcdn.com/images/eugene-doobu/post/0f339d05-40aa-480a-a248-9d8093f2e7e4/image.png)

메모리 프로파일링 도중.. 뭔가 엄청나 보이는 메모리를 차지하는 AudioClip을 발견하였고, 이를 계기로 프로젝트 오디오 파일들의 압축 옵션을 확인하게 되었었다. 적용 내용은 간단하게 모든 bgm에 대해 동일한 옵션을 적용하였다.

- LoadType: Streaming
- Compression Format: ADPCM
- Sample Rate Setting: Override Sample Rate
- Sample Rate: 22,050

또한 사운드의 디테일을 크게 살릴 필요성이 없다고 판단되어 모든 사운드를 **MONO**형태로 저장하기로 하였다.

이런 간단한 변경을 통해 iOS기준 **백메가 단위의 상당히 많은 메모리를 절약**시킬 수 있었다.

[사운드 옵션 pr](https://github.com/planetarium/NineChronicles/pull/5283)

> **추천 옵션**
**배경음악**: Streaming + Vorbis
**효과음**: Compressed into memory + ADPCM

## 4. 스파인 데이터 개선

이전 글에서 GC에 대한 설명과, 유니티 환경에서 GC가 왜 중요한지에 대해 이야기를 나눈 바 있다. 유니티에서 제공하는 [모바일 디바이스 최적화 책](https://unity.com/blog/games/optimize-your-mobile-game-performance-tips-on-profiling-memory-and-code-architecture-from)서는 메모리와 GC 파트에서 다음과 같은 내용을 강조한다.

**불필요한 힙 할당으로 인해 GC 스파이크가 발생할 수 있다는 점에 유의하세요:**
- 문자열: C#에서 문자열은 값 유형이 아닌 참조 유형입니다. 불필요한 문자열 생성이나 조작을 줄입니다. **JSON 및 XML(혹은 csv)과 같은 문자열 기반 데이터 파일을 구문 분석하지 말고**, 대신 **ScriptableObjects나 MessagePack 또는 Protobuf와 같은 형식으로 데이터를 저장**합니다. 런타임에 문자열을 빌드해야 하는 경우 StringBuilder 클래스 사용
...

![스파인 프로파일링](https://velog.velcdn.com/images/eugene-doobu/post/24a170b7-b77e-4137-a59b-eacd149d5396/image.png)

기존 9C 프로젝트는 JSON 기반 데이터 파일을 런타임에 파싱하여 스파인 애니메이션을 수행하고 있었다. 에디터 프로파일링 결과, JSON 데이터 파싱 과정에서 상당한 GC Alloc이 발생하고, 이에 따른 처리 시간이 소요되는 것을 확인할 수 있었다.

### 스파인 데이터 포맷 변경

스파인 데이터 포맷을 JSON에서 바이너리 형태로 변경했다. 기존 스파인 데이터(JSON 포맷)는 아래와 같이 설정값을 직관적으로 확인하고 수정하기 쉽다는 장점이 있었다.

```js
{
    "skeleton": {
        "hash": "pk8bvriq1EUyoeKgE79GQivbfyg",
        "spine": "3.8.99",
        "x": -384.15,
        "y": -105.72,
        "width": 674,
        "height": 450,
        "images": "./images/",
        "audio": "C:/Users/user/Desktop/animation/Cut_Scene"
    },
    "bones": [{
        "name": "root",
        "x": 1.47
    }, {
        "name": "cutscene_01",
        "parent": "root",
        "rotation": 50.7,
        "x": 291.32,
        "y": -106.04
    }],
    "slots": [{
      ...
    }],
    "skins": [{
        "name": "default",
        "attachments": {
            "cutscene": {
                "cutscene_01": {
                    "x": -40.95,
                    "y": 405.78,
                    "rotation": -50.7,
                    "width": 674,
                    "height": 450
                }
            }
        }
    }],
    "animations": {
      ...
    }
}
```

이러한 특성 때문에 스파인 리소스를 처음 임포트하고 확인해보는 과정에서는 json형태로 데이터를 저장하는게 유리할 수 있다. 그러나 인게임에서는 이러한 장점이 필요 없고, 오히려 로드시 성능에 악영향을 미친다는 단점만 남는다. 실제 환경에서의 성능을 위해 binary형태로 데이터를 저장하는 방식으로 설정을 변경하였다.

### 스파인 버전 업

기존에 사용하던 스파인 3.8 버전을 4.1 버전으로 업그레이드했다.
특히 대규모 프로젝트 환경에서 성능이 크게 개선되었다고 한다.

추가로 버전 관리를 용이하게 하기 위해 스파인을 Git 패키지 형태로 프로젝트에 임포트하도록 수정했다.

[스파인 4-0-00 체인지로그](https://ko.esotericsoftware.com/spine-changelog#v4-0-00-beta)<br>
[스파인 업그레이드PR](https://github.com/planetarium/NineChronicles/pull/4119)

### 스파인 성능비교

![스파인 변경 전 이미지](https://velog.velcdn.com/images/eugene-doobu/post/67b123f0-3347-41ef-b54a-757e38c943c9/image.png)

변경 전 스파인 프로파일링

---

![스파인 변경 후 이미지](https://velog.velcdn.com/images/eugene-doobu/post/75bb8871-4d37-4cba-923c-a468076ed0ff/image.png)

변경 후 스파인 프로파일링

---

같은 스테이지에서 몬스터 생성 과정을 비교한 결과, `2.5MB / 162.94ms`에서 `0.7MB / 27.06ms`로 성능이 개선된 것을 확인할 수 있었다.


## 마치며

내용을 정리하면서 텍스처 압축에 대해 다시 한 번 정리할 수 있었고, 내가 이런 일을 했었구나도 정리해볼 수 있었다. 관련 자료를 검색하면서 좋은 블로그들도 몇 개 찾았다. 아래 참고에 봤던 블로그들을 모아놨으니 해당 주제에 관심이 있다면 하나씩 같이 보는걸 추천한다.

![잘자요](https://velog.velcdn.com/images/eugene-doobu/post/0415a8b3-1cd9-4a3a-8f92-f947b720b0a7/image.png)

 
 ---
 
 ### 참고 
 
 [나무위키-텍스처 압출 포맷](https://namu.wiki/w/%ED%85%8D%EC%8A%A4%EC%B2%98%20%EC%95%95%EC%B6%95%20%ED%8F%AC%EB%A7%B7)<br>
 [[유니티 TIPS] 알쓸유잡 | 효율적인 텍스처 압축 이해하기& 꿀팁](https://www.youtube.com/watch?v=BeEjoTa9sSo)<br>
 [아틀라스 리소스 폴더 주의](https://mentum.tistory.com/585)<br>
 [아틀라스 이중압축](https://mentum.tistory.com/586)<br>
 ["유니티에서는"어째서 PNG보다는 TGA가 더 쓸모있는 파일 포맷인가?](https://chulin28ho.tistory.com/362)<br>
 [텍스처 압축과 ASTC](https://hotfoxy.tistory.com/116)


[블로그 원본](https://velog.io/@eugene-doobu/%EB%9D%BC%EC%9D%B4%EB%B8%8C-%EA%B2%8C%EC%9E%84-%EC%97%90%EC%85%8B-%EA%B4%80%EB%A6%AC-%EA%B0%9C%EC%84%A0%EA%B8%B0-%EB%B2%88%EC%99%B81.%EB%A6%AC%EC%86%8C%EC%8A%A4-%EC%B5%9C%EC%A0%81%ED%99%94-%EA%B8%B0%EB%B2%95)
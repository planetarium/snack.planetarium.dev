---
title: 태국에서만 2562년으로 가는 소프트웨어?
date: 2020-02-25
authors: [hong.minhee, swen.mun]
---
## 미래에서 온 손님

작년 12월에 저희는 마침내 첫 번째 알파테스트를 진행했고, 감사하게도 세계 각지에서 많은 분이 참여해 주셨습니다. 이는 팀에게 있어 굉장한 기회인 동시에 도전이기도 했습니다. 당연하게 크고 작은 문제가 있었는데요. 그중 저희를 난처하게 만들었던 문제 중 하나는 IBD였습니다.

<abbr title="initial block download">IBD</abbr>란 게임을 켰을 때 네트워크의 다른 피어들로부터 그동안 쌓인 블록들을 내려받아 최신 상태로 동기화하는 단계인데요. 아무래도 세계 각지에서 참여하시다 보니 네트워크 지연 등의 문제로 인해 시간이 오래 걸리거나 이상 종료되는 경우가 종종 있었습니다.

그런데 그중에서도 특이한 증상을 보고한 사용자가 있었습니다. 당시 저희가 겪던 다른 문제들과 다르게 가장 첫 번째 블록을 내려받고 나서 이후 블록을 받을 수 없다는 것이었습니다.

{{<
figure
  src="1.png"
  caption="사용자로부터 받은 스크린숏"
>}}

저희는 이 사용자가 보내 준 스크린숏을 확인하고 한 가지 이상한 점을 깨달았습니다. 날짜가 2019년이 아닌 2562년으로 적혀있던 것이었는데요. 그래서 저희는 한가지 가설을 세웠습니다. 모종의 이유로 파일 시스템이 고장이 나 있어서 블록 헤더의 해시가 잘못 계산되고 있다는 것이죠.

이를 검증하기 위해 저희는 양해를 구하고 원격 데스크톱을 통해 문제가 발생한 시스템을 직접 조사하기로 했습니다.


## 날짜가 잘못되지 않았다

다행히 해당 문제를 겪고 있던 사용자는 접속을 흔쾌히 허락해주셨습니다. 스크린숏으로 확인한 것처럼 여전히 날짜는 2562년이었습니다. 일단 가장 먼저 시간을 맞추기 위해 제어판을 열었습니다. 대부분의 현대적인 운영체제가 그렇듯이 Windows도 네트워크를 통해 시간을 동기화하는 기능이 있습니다. 그러나 이렇게 시간을 다시 동기화해도 제어판과 시스템의 날짜는 2562년으로 변함없었고 마지막 동기화 시각도 연도만이 다를 뿐 날짜, 시간이 모두 제가 사용하고 있는 시스템과 다르지 않았습니다.

그런데 문제를 조금 살펴보기로 하고 제어판 이곳저곳을 확인 하던 중 제 눈길을 끄는 화면이 있었습니다.

{{<
figure
  src="2.png"
  caption="그레고리안력으로는 2019년이라고 표시되어 있다."
>}}

저희 개발팀에서 태국어를 읽을 수 있는 사람은 없었지만, "Date in Gregorian"을 보니 "2562년"은 "2019년"의 다른 표현이라는 것을 알아차렸습니다. 그래서 시험 삼아 포맷을 바꾸니 예상대로 2019년 12월 16일이 표시되었고, 혹시나 하는 마음에 게임을 실행해보니 IBD 단계에서 문제없이 잘 실행이 되었습니다. 


## 불력

재현 방법과 실마리를 찾았으니 사용자께는 일단 잠시 지역 설정을 미국으로 해주실 것을 제안드렸고, 감사하게도 그 사용자분은 그 제안을 승낙하셨습니다.

문제를 재현하기 위해 저희는 로컬 개발 환경에서 운영체제의 지역 설정을 태국으로 변경한 뒤 Libplanet의 단위 테스트를 돌려봤습니다. 아니나 다를까, 몇몇 테스트가 실패하는 것을 확인할 수 있었습니다. 그 가운데 가장 치명적인 문제는 내용상으로는 같은 블록의 해시가 달라지는 현상이었습니다. 살펴보니 해시의 입력을 만드는 과정에 [`Block<T>.Timestamp` 필드를 직렬화][1]한 결과가 기대와 달랐습니다. `DateTimeOffset.ToString()` 메서드의 동작이 운영체제의 로캘에 영향을 받는 것입니다.

동남아시아에서 불교는 구미의 기독교와 같은 위치입니다. 그래서 역법에서도 예수 그리스도의 탄신을 기원(epoch)으로 삼는 [그레고리력] 대신, 석가모니의 입멸을 기원으로 삼는 [불력][](佛曆)이 일반적으로 쓰인다고 합니다. 태국도 예외는 아니어서, 전통적으로는 음력인 불력을 양력으로 수정한 [타이 태양력]을 쓰고 있습니다. 석가모니 입멸은 기원전 543년으로, 서기 2019년은 타이 태양력으로 2562년이 됩니다.

이와 같이, 세계에는 문화권에 따라 다양한 역법을 쓰고 있으므로, 사용자 인터페이스를 표시할 때 각 문화권에 알맞는 날짜 형식으로 표시되어야 합니다. 사실 `DateTimeOffset.ToString()` 메서드는 이를 위해 [`IFormatProvider`][IFormatProvider] 객체도 파라미터로 받는 오버로드를 갖고 있습니다. `IFormatProvider` 인터페이스를 구현하는 클래스 중에서 가장 많이 쓰이는 것이 [`CultureInfo`][CultureInfo]입니다. 이름에서 알 수 있듯, `CultureInfo`는 유닉스 계열에서 로캘(locale)이라고 부르는 것과 같은 개념입니다. 아래와 같이, `DateTimeOffset.ToString()` 메서드는 파라미터로 어떤 로캘을 설정하느냐에 따라 결과물이 달라집니다.

```csharp
> using System.Globalization;
> var now = DateTimeOffset.Now;
> now.ToString("yyyy-MM-ddTHH:mm:ss.ffffffZ", new CultureInfo("ko-KR"))
"2020-02-13T17:37:16.436163Z"
> now.ToString("yyyy-MM-ddTHH:mm:ss.ffffffZ", new CultureInfo("th-TH"))
"2563-02-13T17:37:16.436163Z"
```

하지만 아무 로캘도 설정하지 않고 해당 파라미터를 생략하면 적당히 그 코드가 실행되는 환경의 로캘을 따라가게 됩니다. 아래 코드는 제가 운영체제의 지역 설정을 한국으로 해뒀을 때의 결과입니다.

```csharp
> now.ToString("yyyy-MM-ddTHH:mm:ss.ffffffZ")
"2020-02-13T17:37:16.436163Z"
```

[문서에 따르면, 해당 파라미터가 생략된 오버로드][2]는 [`CultureInfo.CurrentCulture`][CultureInfo.CurrentCulture]를 따른다고 합니다. `CultureInfo.CurrentCulture` 속성은 이름에서도 알 수 있듯 실행 환경의 로캘을 가르킵니다. 따라서, 실행 환경의 로캘과 무관하게 언제나 결정적인 동작을 원한다면 명시적으로 [`CultureInfo.InvariantCulture`][CultureInfo.InvariantCulture]를 지정해야 합니다.

메서드가 비결정적으로 동작할 수 있음에도 불구하고 해당 파라미터를 생략하면 실행 환경의 로캘을 따르도록 API를 설계한 것은, 아마 저러한 서식(formatting) 연산이 대개 사용자 인터페이스를 그리는 데에 쓰이고, 그렇기 때문에 국제화에 큰 신경을 쓰지 않고 코딩을 해도 자연스럽게 문화권에 알맞은 서식으로 보이도록 하려는 의도일 것입니다. 하지만 저희가 해당 메서드를 쓴 것은 사용자 인터페이스가 아니라, 결정적이어야 하는 암호학적 해시의 입력인 것이 불찰이었습니다.

원인을 알았으니 [`DateTimeOffset.ToString()` 메서드와 마찬가지로 `CultureInfo`나 `IFormatProvider` 파라미터가 생략된 메서드를 찾아서, 명시적으로 `CultureInfo.InvariantCulture`를 지정하도록 패치][libplanet#734]하는 것으로 급한 문제는 일단락됐습니다.

CI에서도 아랍어나 프랑스어, 히브리어 로캘 등에서도 단위 테스트를 실행하도록 보강하기도 했습니다. 유럽에는 소수점 표시를 점(`.`)이 아니라 쉼표(`,`)로 하는 나라도 많고, 중동에는 오른쪽에서 왼쪽으로 글을 쓰기도 하므로, 저희에게 다소 생소하게 느껴지는 언어권을 일부러 고른 것입니다.

또, 앞으로 비슷한 실수는 얼마든지 일어날 수 있기 때문에, 실행 환경의 로캘에 따라 동작이 달라지는 코드를 찾아주는 [정적 분석도 도입][libplanet#737]하였습니다.

[1]: https://github.com/planetarium/libplanet/blob/82aaba0c37591ebf51207038e8c5c122272ce98b/Libplanet/Blocks/Block.cs#L488
[2]: https://docs.microsoft.com/en-us/dotnet/api/system.datetimeoffset.tostring?view=netstandard-2.0#System_DateTimeOffset_ToString
[그레고리력]: https://ko.wikipedia.org/wiki/%EA%B7%B8%EB%A0%88%EA%B3%A0%EB%A6%AC%EB%A0%A5
[불력]: https://en.wikipedia.org/wiki/Buddhist_calendar
[타이 태양력]: https://en.wikipedia.org/wiki/Thai_solar_calendar
[IFormatProvider]: https://docs.microsoft.com/en-us/dotnet/api/system.iformatprovider?view=netstandard-2.0
[CultureInfo]: https://docs.microsoft.com/en-us/dotnet/api/system.globalization.cultureinfo?view=netstandard-2.0
[CultureInfo.CurrentCulture]: https://docs.microsoft.com/en-us/dotnet/api/system.globalization.cultureinfo.currentculture?view=netstandard-2.0
[CultureInfo.InvariantCulture]: https://docs.microsoft.com/en-us/dotnet/api/system.globalization.cultureinfo.invariantculture?view=netstandard-2.0
[libplanet#734]: https://github.com/planetarium/libplanet/pull/734
[libplanet#737]: https://github.com/planetarium/libplanet/pull/737


## 마치며

앞서 언급한 것처럼 암호학적 해시를 계산하는 함수에 서식 같은 비결정적인 동작이 예상되는 API를 사용하는 것은 장기적으로 좋은 결정은 아닙니다. 일반적으로 문자열은 이러한 서식이 많이 적용되기 때문에 자료형 차원에서 피하는 것이 안전합니다.

하지만 아쉽게도 이 저희는 이 문제를 테스트 중간에 발견하였고, 해시 방식을 바꾸는 것은 이전 데이터의 호환성을 깨는 결정이었기 때문에 아직 대대적인 수정은 하지 못했습니다. 하지만 Libplanet 릴리스 1.0 전에는 이러한 부분을 수정할 예정입니다.

---
title: Software from Year 2562 Emerges in Thailand?
date: 2020-02-25
authors: [hong.minhee, swen.mun]
translators: [kidon.seo]
---
## Guest from the Future

Last December, we finally conducted our first alpha test, and thankfully, many people from all over the world participated. It was both a great opportunity and a challenge for the team. Of course, there were big and small problems. Among them, one problem that took us by surprise was IBD.

<abbr title="initial block download">IBD</abbr> is a stage that occurs when you turn on a game, download blocks from other peers in the network and sync them to the latest state. Since we had participants from all over the world, IBD often took a long time or even ended abnormally due to network delays.

One of our participants reported a very unusual symptom. Unlike other problems we had at that time, the participant successfully downloaded the first block but couldn’t download the rest afterward.

{{<
figure
  src="1.png"
  caption="Screenshot of Our Participant"
>}}

We checked the screenshot our user sent us and realized one strange thing. The date was 2562 instead of 2019. So we came up with a hypothesis. For some reason, the file system was broken and the hash of the block header was being miscalculated.

To verify this, we asked for permission to investigate the problem directly through remote desktop.


## The Date Was Not Wrong

Fortunately, the user experiencing this problem kindly accepted our request for remote access. And once we were able to access the desktop, we saw that the date was still in 2562 as it appeared in the screenshot. First, we opened the Control Panel to sync time. Like most modern operating systems, Windows has the ability to synchronize time over the network. But when we resynchronized time, the control panel and the system's year didn't change and remained in 2562. Notably, apart from the year, date and time were no different from the system on our side.

We decided to explore the problem a little bit more, and while checking out the control panel, one detail caught our attention.

{{<
figure
  src="2.png"
  caption="Year Displayed as 2019 in Gregorian calendar"
>}}

No one in our development team could read Thai, but looking at "Date in Gregorian”, we noticed that "2562" was a different expression of "2019." So we changed the format, and as expected, December 16th, 2019 was displayed. And when we launched the game for testing, it went smoothly at the IBD stage.

## Buddhist Calendar

Now that we had found a clue and a way to reproduce the issue, we suggested our user to set up the region in the US for the time being, and thankfully, our user agreed to our proposal.

To reproduce this problem on our side, we changed the regional setting of our OS to Thailand in the local development environment and then ran the unit test of Libplanet. Sure enough, we were able to see some of them fail. The most crucial problem was that the hash of the same block was changing. As we looked closer, the result of [serializing `Block<T>.Timestamp` field][1] in the process of creating a hash input was different than expected. The behavior of the `DateTimeOffset.ToString()` method was affected by the locale of the operating system.

In Indochina Peninsula, Buddhism takes the same place as Christianity in Europe. So, instead of the [Gregorian calendar], which uses the birth of Jesus Christ as an epoch, countries in Indochina Peninsula had used the [Buddhist calendar] which takes Buddha’s attainment of parinirvana (nirvana after death) as an epoch. Although countries like Cambodia and Laos eventually took on the Gregorian calendar, Thailand still uses the [Thai solar calendar], which is a solar modification of the traditional Buddhist lunar calendar. Buddha’s parinirvana was in 543 BC, and so the year 2019 A.D. becomes 2562 under the Thai solar calendar.

As such, the world uses various calendars depending on the cultural region. So when displaying user interface, time should be displayed in the appropriate date format for each region. In fact, `DateTimeOffset.ToString()` method has an overload that also receives [`IFormatProvider`][IFormatProvider] objects as parameters for this purpose. [`CultureInfo`][CultureInfo] is the most common class to implement the `IFormatProvider` interface. As the name suggests, `CultureInfo` is the same concept that the Unix family calls locale. As shown below, the result of `DateTimeOffset.ToString()` method depends on which locale you set up as the parameter.

```csharp
> using System.Globalization;
> var now = DateTimeOffset.Now;
> now.ToString("yyyy-MM-ddTHH:mm:ss.ffffffZ", new CultureInfo("ko-KR"))
"2020-02-13T17:37:16.436163Z"
> now.ToString("yyyy-MM-ddTHH:mm:ss.ffffffZ", new CultureInfo("th-TH"))
"2563-02-13T17:37:16.436163Z"
```

However, if you omit the parameter without setting any locale, the method will follow the locale of the environment in which the code is executed. The code below is the result of setting up the operating system region in Korea.

```csharp
> now.ToString("yyyy-MM-ddTHH:mm:ss.ffffffZ")
"2020-02-13T17:37:16.436163Z"
```

[According to the docs, the overload with the omitted parameter][2] follows [`CultureInfo.CurrentCulture`][CultureInfo.CurrentCulture]. As you can infer from its name, the `CultureInfo.CurrentCulture` property points to the locale of the execution environment. Therefore, you must explicitly specify [`CultureInfo.InvariantCulture`][CultureInfo.InvariantCulture] if you want a deterministic action at all times regardless of the locale of your execution environment.

Even though the method may be non-deterministic, the API designed to follow the locale of the execution environment is probably intended because such formatting operations are usually used for user interface, and coding can naturally look appropriate to the cultural community without much concern about internationalization. But the reason why we used this method was not for user interface, but for the cryptographic hash input that had to be deterministic— this turned out to be a mistake.

Now that we know the cause, we have solved the urgent problem by [finding a method that has the `CultureInfo` or `IFormatProvider` parameters omitted, and patching it to explicitly designate `CultureInfo.InvariantCulture`, just like the method `DateTimeOffset.ToString`()][libplanet#734].

CI has also been reinforced with unit testing in Arabic, French, Hebrew locale and so on. Since there are a lot of countries in Europe that use comma (`,`) instead of period (`.`) in decimal places, and countries in the Middle East that writes from right to left, we deliberately chose language regions that were somewhat unfamiliar to us.

In addition, because similar mistakes can happen in the future, we have [introduced static analysis][libplanet#737] that finds codes whose behavior depends on the locale of the execution environment.

[1]: https://github.com/planetarium/libplanet/blob/82aaba0c37591ebf51207038e8c5c122272ce98b/Libplanet/Blocks/Block.cs#L488
[2]: https://docs.microsoft.com/en-us/dotnet/api/system.datetimeoffset.tostring?view=netstandard-2.0#System_DateTimeOffset_ToString
[Gregorian calendar]: https://en.wikipedia.org/wiki/Gregorian_calendar
[Buddhist calendar]: https://en.wikipedia.org/wiki/Buddhist_calendar
[Thai solar calendar]: https://en.wikipedia.org/wiki/Thai_solar_calendar
[IFormatProvider]: https://docs.microsoft.com/en-us/dotnet/api/system.iformatprovider?view=netstandard-2.0
[CultureInfo]: https://docs.microsoft.com/en-us/dotnet/api/system.globalization.cultureinfo?view=netstandard-2.0
[CultureInfo.CurrentCulture]: https://docs.microsoft.com/en-us/dotnet/api/system.globalization.cultureinfo.currentculture?view=netstandard-2.0
[CultureInfo.InvariantCulture]: https://docs.microsoft.com/en-us/dotnet/api/system.globalization.cultureinfo.invariantculture?view=netstandard-2.0
[libplanet#734]: https://github.com/planetarium/libplanet/pull/734
[libplanet#737]: https://github.com/planetarium/libplanet/pull/737


## Closing

As mentioned earlier, using APIs with non-determinant behaviors such as formatting in functions that calculate cryptographic hash is not a good decision in the long run. Typically, because strings are heavily formatted, it's safe to avoid them from data level perspective.

But unfortunately, we found this problem in the middle of the test, and we haven't made any major modifications yet because changing the hash method was a decision that would break the compatibility of previous data. However, these parts will be modified before releasing Libplanet 1.0.

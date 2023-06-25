---
layout: post
title: "UK Timezone Differences in Linux"
date: '2017-02-26 12:00:00 +0000'
tags:
- .NET
- .NET Core
- Development
- Linux
categories:
- Development
description: Beware your buggy Unix Epoch logic!
---

Whilst porting a C# application over to .NET Core I came across a buggy line of
code that only caused a problem when the application was ran in Linux:

```csharp
new DateTime(1970, 1, 1).ToUniversalTime()
```

The code was being used in a calculation for the Unix Epoch and should have used
`DateTimeKind.Utc` in the `DateTime` constructor to specify the date as UTC.
It was omitted, but since this code ran on machines set to the UK locale, this
was not a problem.

In Windows, the value of this expression was **01/01/1970 00:00:00**.

This makes sense. In the UK we have daylight savings time (British Summer Time)
but this obviously runs in the summer.

However, on Ubuntu 16.04, the expression outputted **31/12/1969 23:00:00**.

Curious, I thought. Why was Linux adjusting this time back an hour, as if it was
in daylight saving? After some experimenting, I found the date range that triggered
this behaviour was during 19th February 1968 to 31st October 1971. [It turns out](https://en.wikipedia.org/wiki/British_Summer_Time)
that during this period the UK was experimenting with implementing daylight saving time across the entire year
(British Standard Time).

So Linux is quite correct. The 1st January 1970 was indeed
in daylight saving in the UK.

Windows does not seem to respect this historical anomaly, thus resulting in
this buggy code working correctly when ran in Windows but failing in Linux.

Bugs happen, and things like this can slip through the net. Fortunately, discrepancy
was detected by a failing test in Linux. However, I hate to think
what sort of havoc this sort of thing could play in an application where date/time logic is
not sufficiently tested across timezones and now - with .NET Core - operating systems.

Timezones will continue to confound and confuse programmers, and will likely do so for a long time.

*Here's the [StackOverflow](http://stackoverflow.com/q/41892805/2323497) question I posed concerning this curiosity.*

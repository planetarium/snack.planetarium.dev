---
title: "Serilog를 통해 애플리케이션 데이터를 수집하고 분석하자"
date: 2023-03-03
authors: [suho.lee]
ogimage: images/og.png
---

# 들어가며
분산 네트워크나 마이크로서비스 아키텍처 상에서는 각 어플리케이션 간의 로그를 수집하고, 어플리케이션 간의 로그를 짝 맞춰야 할 일이 종종 있습니다. 
이 글에서는 Serilog 와 S3를 이용하여 로그를 수집하고, 이를 Athena나 다른 로그 서치 엔진에 응용할 수 있는 방법을 안내하고자 합니다.

# 구조화 된 로그(Structured Log)
프로그래밍 경험이 좀 되신 분들이라면 [구조화 된 로그](https://cloud.google.com/logging/docs/structured-logging?hl=ko)에 대해 들어보셨을 것입니다.
구조화 된 로그는, 어떤 로그의 내용이 어떤 의미를 가지는지를 명확하게 표현하는 것을 말합니다.
예를 들어, 다음과 같은 로그가 있다고 가정해봅시다.

```
2023-03-03 12:00:00.0000000 [INFO] [User] [suho.lee] [Login] [Success]
```
이 로그를 보면, 2021년 3월 3일 12시에 suho.lee라는 사용자가 로그인에 성공했다는 것을 알 수 있습니다.
하지만, 이 로그는 어떤 로그인인지, 어떤 서비스에서 로그인을 시도했는지, 로그인에 성공했는지 실패했는지 등의 정보를 알 수 없습니다.
이러한 로그는, 로그를 분석하거나, 로그를 수집하여 다른 시스템에 전달할 때, 어떤 로그인지, 어떤 서비스에서 로그인을 시도했는지 등의 정보를 알 수 없기 때문에, 의미가 없습니다.

때문에 로그를 구조화 된 로그로 작성하는 것이 중요합니다.
구조화 된 로그의 예시는 다음과 같습니다.

```json
{
  "timestamp": "2023-03-03 12:00:00.0000000",
  "level": "INFO",
  "service": "User",
  "user": "suho.lee",
  "action": "Login",
  "result": "Success"
}
```

Serilog는 이런 형태의 구조화 된 로그를 쉽게 작성할 수 있도록 도와주는 라이브러리입니다.

# Serilog
다른 언어와 마찬가지로, C#에서도 로그를 작성하는 라이브러리가 많이 있습니다.
Serilog는 이 중 하나입니다.
Serilog는 다음과 같은 특징을 가지고 있습니다.

- Sink를 통해 다양한 로그 저장소에 로그를 저장할 수 있습니다.
- 한 가지 로그에 대해 여러 표현법을 지원합니다.
- 로그를 작성하는 코드에 영향을 주지 않고, 로그를 수집하는 코드를 변경할 수 있습니다.

# Serilog를 이용한 로그 작성
Serilog를 이용하여 로그를 작성하는 방법은 다음과 같습니다.

1. Serilog 패키지를 설치합니다.
```
dotnet add package Serilog
```
2. Serilog를 초기화합니다.
```csharp
var logger = new LoggerConfiguration()
    .WriteTo.Console()
    .CreateLogger();
```
3. 로그를 작성합니다.
```csharp
logger.Information("Hello, Serilog!");
```
4. 로그를 수집합니다.
```
2023-03-03 12:00:00.0000000 [INF] Hello, Serilog!
```
이렇게 Serilog를 이용하여 로그를 작성할 수 있습니다.

또한 이렇게 작성 된 로그를 구조화 된 로그로 작성할 수 있습니다.
1. 로그를 구조화 된 로그로 변경합니다.
```csharp
logger.Information("Hello, {name}!", "Serilog");
```
2. 로그를 수집합니다.
```
2023-03-03 12:00:00.0000000 [INF] Hello, Serilog!
```
3. 로그를 구조화 된 표현법으로 변경하면 다음과 같습니다.
```json
{
  "timestamp": "2023-03-03 12:00:00.0000000",
  "level": "INFO",
  "messageTemplate": "Hello, {name}!",
  "properties": {
    "name": "Serilog"
  }
}
```

또한 Deconstruct를 이용하여 데이터를 펼쳐 볼 수 있습니다.
다음과 같은 좌표를 나타내는 클래스가 있다고 가정해봅시다.
```csharp
public class Coordinate
{
    public double Latitude { get; set; }
    public double Longitude { get; set; }
}
```
이 클래스를 다음과 같이 로그에 작성할 수 있습니다.
```csharp
var coordinate = new Coordinate { Latitude = 37.566535, Longitude = 126.9779692 };
logger.Information("Hello, {@coordinate}!", coordinate);
```

이렇게 작성된 로그를 수집하면 다음과 같이 나옵니다.
```
2023-03-03 12:00:00.0000000 [INF] Hello, { Latitude: 37.566535, Longitude: 126.9779692 }!
```
구조화 된 표현법으론 다음과 같이 나옵니다.
```json
{
  "timestamp": "2023-03-03 12:00:00.0000000",
  "level": "INFO",
  "messageTemplate": "Hello, {@coordinate}!",
  "properties": {
    "coordinate": {
      "Latitude": 37.566535,
      "Longitude": 126.9779692
    }
  }
}
```

# Serilog를 이용한 로그 수집(Serilog.Sinks)
Serilog는 다양한 로그 저장소에 로그를 저장할 수 있도록 다양한 [Sink](https://github.com/serilog/serilog/wiki/Provided-Sinks)를 제공합니다.
이 글에서는 [Serilog.Sinks.AmazonS3](https://github.com/serilog-contrib/Serilog.Sinks.AmazonS3)를 사용하여 S3에 로그를 저장해 보겠습니다.

1. Serilog.Sinks.AmazonS3 패키지를 설치합니다.
```
dotnet add package Serilog.Sinks.AmazonS3
```
2. Serilog를 appsettings.json을 이용해 초기화합니다.
```json
{
  "Serilog": {
    "MinimumLevel": "Information",
    "WriteTo": [
      {
        "Name": "AmazonS3",
        "Args": {
          "Path": "log.json",
          "BucketName": "bucket-name",
          "RollingInterval": "Day",
          "ServiceUrl": "https://s3.ap-northeast-2.amazonaws.com"
        }
      }
    ]
  }
}
```

권한 등 잘 설정이 되었다면 지정한 버킷에 로그가 저장됩니다.

# Amazon Glue를 이용한 로그 크롤링
Amazon S3에 저장된 로그를 Amazon Athena를 이용하여 분석할 수 있습니다.
하지만 Amazon Athena는 JSON 형식의 로그를 분석하기에는 한계가 있습니다.
그래서 Amazon Athena를 이용하여 로그를 분석하기 위해서는 로그를 Amazon Glue를 이용하여 크롤링해야 합니다.

Glue를 이용하여 데이터 카탈로그에 크롤링을 하는 방법은 다음 글을 참고하시면 됩니다.
https://docs.aws.amazon.com/ko_kr/athena/latest/ug/data-sources-glue.html

# Amazon Athena를 이용한 로그 분석
Amazon Athena는 여러 빅데이터 분석 툴과 마찬가지로 SQL을 이용하여 데이터를 분석할 수 있습니다.
다음과 같이 Amazon Athena를 이용하여 로그를 분석할 수 있습니다.

```sql
SELECT
  timestamp,
  level,
  messageTemplate,
  properties.coordinate.Latitude,
  properties.coordinate.Longitude
FROM
  "database-name"."table-name"
WHERE
  timestamp BETWEEN '2023-03-03 00:00:00' AND '2023-03-03 23:59:59'
```

이를 이용하여 여러 분산 네트워크 상의 노드들의 로그를 분석할 수 있습니다.
예시로, 두 노드 간에 통신이 이루어지는 시간을 분석해 보겠습니다.
table1은 노드1의 로그를, table2는 노드2의 로그를 나타냅니다.
```sql
SELECT
  table1.timestamp AS node1_timestamp,
  table1.level AS node1_level,
  table1.messageTemplate AS node1_messageTemplate,
  table1.properties.coordinate.Latitude AS node1_latitude,
  table1.properties.coordinate.Longitude AS node1_longitude,
  table2.timestamp AS node2_timestamp,
  table2.level AS node2_level,
  table2.messageTemplate AS node2_messageTemplate,
  table2.properties.coordinate.Latitude AS node2_latitude,
  table2.properties.coordinate.Longitude AS node2_longitude
FROM
  "database-name"."table1"
JOIN
  "database-name"."table2"
ON
  table1.properties.coordinate.Latitude = table2.properties.coordinate.Latitude
  AND table1.properties.coordinate.Longitude = table2.properties.coordinate.Longitude
WHERE
  table1.timestamp BETWEEN '2023-03-03 00:00:00' AND '2023-03-03 23:59:59'
  AND table2.timestamp BETWEEN '2023-03-03 00:00:00' AND '2023-03-03 23:59:59'
```

이런 식으로 로그를 분석하면 두 노드 사이의 통신 시간을 알 수 있습니다.

# 마치며
이 글에서는 Serilog를 이용하여 로그를 수집하고 Amazon Athena를 이용하여 로그를 분석하는 방법을 소개했습니다.
오늘 소개한 방법을 응용하면 다양한 분산 네트워크 상의 노드들의 로그를 분석할 수 있을 것으로 기대합니다.
또한 이 글에서는 성능이나 여러 가지 제약 사항들을 고려하지 않았습니다.
이 글에서 소개한 방법을 실제로 사용할 때는 성능과 여러 제약 사항들을 고려해야 합니다.

---

(이 글은 [.NET Conf 2023 x Seoul](https://www.dotnetconf.kr/2023)에 올해 2월 [발표한 내용](https://www.dotnetconf.kr/f2ea6fa1-f802-4dba-be87-539d32d3584b)을 각색한 것입니다.)


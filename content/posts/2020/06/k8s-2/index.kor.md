---
title: (진짜로) 쿠버네티스로 P2P 게임 테스트하기
date: 2020-06-19
authors: [swen.mun]
---

안녕하세요, [플라네타리움]에서 [Libplanet]을 개발하고 있는 문성원입니다. [쿠버네티스로 P2P 게임 테스트하기][1]를 올린 뒤로 한참 뒤에서야 본격적인 내용을 소개드리게 된 점 양해 부탁드립니다. 저희가 왜 [쿠버네티스][](Kubernetes)를 사용해서 게임을 테스트하게 되었는지, 그 경위에 대해 궁금하신 분은 잠깐 시간을 내서 이전 글을 다시 읽어보시면 좋을 것 같네요.

준비 되셨나요. 그럼, 시작하겠습니다.


[플라네타리움]: https://planetariumhq.com
[나인 크로니클]: https://nine-chronicles.com
[Libplanet]: https://libplanet.io
[쿠버네티스]: https://kubernetes.io/


파드, 레플리카셋, 디플로이먼트
--------------------------

쿠버네티스는 기본적인 실행 단위로 [파드][Pod](Pod)를 제공합니다. 실행 중인 [도커][Docker](Docker) 컨테이너와 비슷한 무언가라고 이해하셔도 당장은 무방합니다. 다중 컨테이너로 파드를 구성할 수도 있지만, 대부분의 경우 파드는 단일 컨테이너로 구성합니다. 저희도 그렇구요.

어쨌거나 이러한 파드는 단독으로 실행이 가능하게끔 구성할 수 있습니다. 하지만 웹서버와 같이 항상 실행되고 있는 것을 고려한다면, 충분하진 않습니다. 파드의 실행은 보장해주지만, 재시작등에는 관여하지 않기 때문이죠. 이럴때 필요한 것이 [레플리카셋][ReplicaSet](ReplicaSet)입니다. 레플리카셋은 실행되고 있어야 하는 파드의 수량을 선언적으로 정의하며, 쿠버네티스는 이 수량을 맞추는 것을 보장합니다.

하지만 이런 레플리카셋을 직접 구성하기보다는, [디플로이먼트][Deployment](Deployment)와 같은 상위 개념의 리소스를 정의하는 것이 일반적이라고합니다. 디플로이먼트는 레플리카셋을 포함하는 최상위 개념으로, 버저닝과 스케일 업등을 지원합니다.

```

                     +------Deployment-------+
                     |                       |
                     |  +---ReplicaSet----+  |
               +-----+--+                 +--+-----+
               |     |  +----+-------+----+  |     |
               |     +-------+-------+-------+     |
               |             |       |             | 
               |             |       |             |
  +------------+----+   +----+-------+----+   +----+------------+
  |         +--v--+ |   | +--v--+ +--v--+ |   | +--v--+         |
  |         |     | |   | |     | |     | |   | |     |         |
  |         | pod | |   | | pod | | pod | |   | | pod |         |
  |         |     | |   | |     | |     | |   | |     |         |
  |         +-----+ |   | +-----+ +-----+ |   | +-----+         |
  +------Node-------+   +------Node-------+   +------Node-------+

```

이때 저희는 디플로이먼트에 대한 명세(yaml)만을 작성하면 되고, 레플리카셋과 파드는 쿠버네티스가 자동으로 생성합니다. 다음은 저희가 알파 테스트에서 사용했던 정보로 구성한 디플로이먼트입니다.

```yaml
apiVersion: v1
items:
- apiVersion: extensions/v1beta1
  kind: Deployment
  metadata:
    labels:
      app: client
    name: client
  spec:
    progressDeadlineSeconds: 600
    replicas: 0
    revisionHistoryLimit: 2
    selector:
      matchLabels:
        app: client
    strategy:
      rollingUpdate:
        maxSurge: 25%
        maxUnavailable: 25%
      type: RollingUpdate
    template:
      metadata:
        creationTimestamp: null
        labels:
          app: client
      spec:
        containers:
        - args:
          - NineChronicles.Standalone.Executable.dll
          - run
          - --app-protocol-version=1/3d20e54Ba9f85b931B3308F143df7f65c472a9d8/MEUCIQCRhlIsn.o2AQ5LT+Kpms0QrJyiDDKOO4i8KeZrF0xX5AIgH2BLVBpfZ2zUQJXKcmo3144raoRXa68OrJrQ2hl7HOc=/ZHUxMjpkb3dubG9hZFVybHNkdTc6V2luZG93c3UwOnU1Om1hY09TdTA6ZXU5OnRpbWVzdGFtcHUzMzoyMDIwLTAzLTE5VDE0OjEzOjQ3Ljc0NDQ2MTArMDA6MDBl
          - --trusted-app-protocol-version-signer=04433a3b9b5065d49bccfab308891ad264685008aa36b1cfd83f7dea1f2a491e178767ac146189a6d416640a35ef39285cd58a23e2d6837bc0f2c34e48b1ae840a
          - --genesis-block-path=https://9c-test.s3.ap-northeast-2.amazonaws.com/genesis-block-9c-alpha-2020-3
          - --store-path=/data/miner
          - --store-type=rocksdb
          - --ice-server=turn://turn3.planetarium.dev:3478
          - --peer
          - 027bd36895d68681290e570692ad3736750ceaab37be402442ffb203967f98f7b6,9c-alpha-2020-3-seed-1.planetarium.dev,31234
          - 02f164e3139e53eef2c17e52d99d343b8cbdb09eeed88af46c352b1c8be6329d71,9c-alpha-2020-3-seed-2.planetarium.dev,31234
          - 0247e289aa332260b99dfd50e578f779df9e6702d67e50848bb68f3e0737d9b9a5,9c-alpha-2020-3-seed-3.planetarium.dev,31234
          command:
          - dotnet
          image: 319679068466.dkr.ecr.ap-northeast-2.amazonaws.com/nekoyume-unity:standalone-git-cd3db0c3e27b435312d3ca9307e9abdee925ab2f
          imagePullPolicy: IfNotPresent
          name: client
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
        dnsPolicy: ClusterFirst
        imagePullSecrets:
        - name: acr-regcred
        nodeSelector:
          beta.kubernetes.io/os: linux
        restartPolicy: Always
        schedulerName: default-scheduler
        securityContext: {}
        terminationGracePeriodSeconds: 30
```

[Pod]: https://kubernetes.io/ko/docs/concepts/workloads/pods/pod-overview/
[ReplicaSet]: https://kubernetes.io/ko/docs/concepts/workloads/controllers/replicaset/
[Deployment]: https://kubernetes.io/ko/docs/concepts/workloads/controllers/deployment/
[Docker]: https://docker.com


서비스
-----

이렇게 만들어진 파드는 기본적으로는 쿠버네티스 밖 세계로는 전혀 노출되지 않습니다. 단순히 파드 안에서 결과를 외부에 전송하는게 전부라면 이걸로도 충분하겠지만, 저희가 만드는 나인 크로니클은 P2P RPG 게임으로, 시드(Seed) 역할을 할 노드는 외부에서 접근이 가능해야 했습니다. (여담이지만, 다른 노드들이 왜 접속이 안되도 괜찮은지는 [이 글][2]을 보시면 아실 수 있습니다.)

이를 해결하기 위해선 


다음 이야기
----------

혹시 이미 쿠버네티스에 익숙하신 분이라면 위의 저희 구성에 "뭔가 이상한데?"와 같은 위화감을 느끼신 분도 계실 겁니다. 실제로 위의 예시 설정 중 어떤 것은 쿠버네티스에 대한 이해가 부족하던 시절에 작성된 것으로, 현재 더이상 사용되지 않으며 다른 구성으로 교체하였습니다. 다음 시간엔 저희가 구체적으로 어떤 실수를 했으며, 그로 인해 어떤 설정을 고쳐야 했는지에 대해 이야기해보죠.

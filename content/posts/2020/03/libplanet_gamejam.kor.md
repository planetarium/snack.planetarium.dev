---
title: "Libplanet_gamejam"
date: 2020-03-19
authors: [seunggeol.song]
---

안녕하세요, 플라네타리움의 게임 클라이언트 프로그래머인 송승걸입니다. 이번 시간에는 플라네타리움에서 열렸던 사내 [게임잼](https://en.wikipedia.org/wiki/Game_jam)에 대해 제가 느꼈던 점을 나눠보고자 합니다.

플라네타리움에선 저희가 자체 제작한 블록체인 게임 라이브러리인 [Libplanet](https://github.com/planeta   rium/libplanet)(이하 `립플래닛`)을 사용해 게임을 만들고 있습니다. 립플래닛은 현재 주로 [Unity](https://en.wikipedia.org/wiki/Unity_(game_engine))에서 사용하는 것을 상정하고 개발 중이기 때문에, 엔진 내에서의 사용성을 위해 Unity용 [SDK](https://en.wikipedia.org/wiki/Software_development_kit)를 제작하기로 했습니다. 이를 위해 Unity에서 립플래닛을 사용하는 조그마한 예시 프로젝트를 만들어 작업에 도움을 받기 위해 플라네타리움 사내 게임잼을 개최했습니다.

2~3명이 한 조를 이뤄 게임 개발을 할 것을 상정하고 개최일까지 2일의 시간을 두고 게임 기획안을 생각해봤고, 그 동안 블록체인 기술을 적용해볼 멋진 게임 기획안이 5개나 제시되었습니다. 저는 [고찬혁](https://github.com/limebell)님과 한 조가 되어 오목 게임을 만들기로 했습니다. 2명의 플레이어가 대국하게 하려고 세션 개념, 즉 여러분들이 익히 알고 계신 게임의 `방` 개념을 립플래닛의 `Action`(액션)과 `State`(상태)개념을 사용해 구현했습니다.

{{<
figure
  src="screenshot.png"
  width="500"
  caption="저희가 만든 오목 게임의 멋진 모습입니다!"
>}}

우선 대표적인 `State`들과 이를 변경시키는 액션들을 소개해 드리겠습니다.

- `SessionState` : 세션의 정보를 저장합니다. 세션 안의 플레이어 정보인 `AgentState`의 리스트와 세션을 구분할 수 있는 고유한 `Key`(방 제목 개념)가 존재하고, 당연하게도 이 `State`를 접근할 수 있도록 하는 `Address`(주소)도 있습니다.

- `AgentState` : 플레이어의 계정 정보를 저장합니다. 이곳엔 플레이어의 정보(대표적으로 전적)과 `Address`가 있습니다.

- `PlayerState` : 플레이어가 게임 내에서 사용하는 돌들의 정보를 저장합니다. 오목판 내의 돌의 좌표 정보가 저장됩니다.

- `JoinSession` : 사용자가 입력한 `Key`를 가진 세션에 참가하는 `Action`입니다. 입력한 `Key`를 가진 세션이 없다면 그 `Key`를 가진 세션을 만듭니다. 이를 통해 `SessionState`를 변화시킵니다.

- `PlaceAction` : 바둑돌을 오목판 위에 올려두는 `Action`입니다. 이를 통해 `PlayerState`의 돌 정보를 변화시킵니다.

- `ResignAction` : 플레이어가 항복하는 `Action`입니다. 두 플레이어의 `AgentState`를 모두 변화시키는데, 항복한 플레이어에 패배 기록을 함과 동시에 승리한 플레이어에게 승리 기록을 합니다.

자세한 내부 구현이나, 코드를 보고 싶으시다면 [Github 저장소](https://github.com/planetarium/planet-omok)를 둘러보세요!

결국, 립플래닛을 사용한 블록체인 게임 개발의 관건은 결국 `State`와 액션을 어떻게 다루는지에 달려있다고 생각합니다. 액션은 `State`를 변화시키고, 게임 로직에서 `State`를 사용해 게임이 동작하는 것이죠. 게임잼 전엔 플라네타리움과 함께 한 지 얼마 되지 않아 액션을 직접 만들어 보지 못했지만, 이번 기회에 일반화된 세션 개념을 고찬혁님과 함께 구현해보니 `State`와 `Action`의 의미와 일반적인 사용법에 익숙해져 여러모로 좋은 시간이었습니다.

마치며
---

게임잼이니만큼 간단한 예제로써 사용하기 적합한 게임으로 클리커 게임인 Planet Clicker의 [Github 저장소](https://github.com/planetarium/planet-clicker)를 둘러보시면서 간단한 `Action`과 `State` 구조를 둘러보시는 건 어떠신가요? 더 자세한 용법이나 질문이 있으시다면 언제든 플라네타리움 팀원이 상주한 [디스코드 서버](https://discord.gg/planetarium)로 놀러 와주세요!

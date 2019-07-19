---
title: Experiencing Unity Test Runner
date: 2019-07-12
authors: [yang.chunung]
translators: [kidon.seo]
---

Hello, I'm Yang Chunung, game developer at Planetarium. Today I'm here to talk about my experience using the [Unity Test Runner][unity-tests-runner].


Before I Start
--------------

I am currently developing blockchain games using [Libplanet] and Unity. After joining the team and learning that we’d be developing games with Unity, I had this rather unfounded confidence thinking, “I’ve had plenty of GUI programming experience, so how hard could it be?” (note: I had no prior experience with Unity).

Obviously, my lacking Unity experience led me to give up testing when I first started the project, but as time went on, the need for testing grew and that’s when I found the Unity Test Runner.

The Unity Test Runner is a built-in test tool provided by Unity. After creating a [NUnit]-based test, you can run the test in Unity Editor by building a testing environment[^1] in both Play Mode and Edit Mode.


Assembly Definition Files
--------------------------------------------------

After making a test script using the documents, I ran into a problem. While other libraries were recognized without any issue, the test script couldn’t recognize the namespace of the actual game code that I wanted to test. The reason was that unlike *Assembly-CSharp.dll*, which is automatically recognized in Unity editor, the game project script couldn’t be recognized within the test script. 

{{<
figure
  src="tests-asmdef.png"
  caption="Adding Dependencies on <em>Tests.asmdef</em> "
>}}

Creating an assembly definition file that defines a project script and then adding dependencies to the assembly definition file[^2] defined for testing will solve the problem.

Please refer to the [relevant documentation](https://docs.unity3d.com/2018.3/Documentation/Manual/ScriptCompilationAssemblyDefinitionFiles.html) for more information. 


Platform Settings for Assembly Definition Files
-------------------------------------------------------------

Even after creating the assembly definition file, the third-party library that works well in the editor broke down when building due to recognition failure. 
This problem was caused by the assembly definition file trying to include the extended editor features sometimes provided in libraries within the build. 

{{<
figure
  src="unity-platform.png"
  caption="Check only Editor"
>}}

The solution is quite simple: create a separate editor definition file inside that library’s *Editor* folder and change the *Include Platforms* setting to only *Editor*.


Running the Test
----------------------

When ready, create the test and run it in the editor. Results can be viewed directly from the Test Runner window. 

{{<
figure
  src="test-result.png"
  caption="Test Results"
>}}

Although there are still more codes in the current project that have not been tested, since the Unity Test Runner has been applied, we've been writing tests together for bug fixes and new add-ons, which has saved us a lot of time in checking production and logic-- something we used to check by running the game every time.
For other projects that also use Unity, I confidently recommend that you apply the Unity Test Runner to increase productivity and enhance overall project experience. Thank you!


[Libplanet]: https://github.com/planetarium/libplanet.net
[unity-tests-runner]: https://docs.unity3d.com/Manual/testing-editortestsrunner.html
[NUnit]: https://nunit.org/

[^1]: Unity player built for that platform can automatically build and run Play Mode Testing on its own.
[^2]: If you didn’t do a separate setting when creating the test runner in the editor, it will be created as *Assets/Tests/Test.asmdef*.


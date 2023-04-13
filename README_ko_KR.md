# Vcpkg: 개요

[中文总览](README_zh_CN.md)
[Español](README_es.md)
[English](README.md)
[Français](README_fr.md)

Vcpkg는 Windows, Linux 및 MacOS에서 C 및 C++ 라이브러리를 관리하는 데 도움을 주는 라이브러리입니다.
이 도구와 생태계는 지속적으로 진화하고 있으며, 저희는 기여를 언제나 환영합니다!

이전에 vcpkg를 사용한 적이 없거나 vcpkg를 사용하는 방법을 알고 싶을 경우,
아래의 [시작하기](#시작하기) 단락을 확인하면 vcpkg 사용을 시작하는 방법이 설명되어 있습니다.

Vcpkg를 설치하였다면, `vcpkg help` 명령어로 사용 가능한 명령어에 대한 간단한 설명을 볼 수 있습니다.
`vcpkg help [command]` 명령어로는 각 명령어별 도움말을 볼 수 있습니다.

* GitHub: port는 [https://github.com/microsoft/vcpkg](https://github.com/microsoft/vcpkg)에, 관련 프로그램은 [https://github.com/microsoft/vcpkg-tool](https://github.com/microsoft/vcpkg-tool)에 있습니다.
* Slack: [https://cppalliance.org/slack/](https://cppalliance.org/slack/), #vcpkg 채널
* Discord: [\#include \<C++\>](https://www.includecpp.org), #🌏vcpkg 채널
* 도움말: [Documentation](docs/README.md)

# 목차

- [Vcpkg: 개요](#vcpkg-개요)
- [목차](#목차)
- [시작하기](#시작하기)
  - [빠르게 시작하기: Windows](#빠르게-시작하기-windows)
  - [빠르게 시작하기: Unix](#빠르게-시작하기-unix)
  - [Linux 개발자 도구 설치하기](#linux-개발자-도구-설치하기)
  - [macOS 개발자 도구 설치하기](#macos-개발자-도구-설치하기)
  - [CMake와 함께 vcpkg 사용](#cmake와-함께-vcpkg-사용)
    - [Visual Studio Code와 CMake Tools](#visual-studio-code와-cmake-tools)
    - [Vcpkg와 Visual Studio CMake 프로젝트](#vcpkg와-visual-studio-cmake-프로젝트)
    - [Vcpkg와 CLion](#vcpkg와-clion)
    - [서브모듈로 vcpkg 사용하기](#서브모듈로-vcpkg-사용하기)
- [탭 완성/자동 완성](#탭-완성자동-완성)
- [예시](#예시)
- [기여하기](#기여하기)
- [라이선스](#라이선스)
- [보안](#보안)
- [데이터 수집](#데이터-수집)

# 시작하기

먼저, 사용하는 운영체제에 따라
[윈도우](#빠르게-시작하기-windows) 또는 [macOS와 Linux](#빠르게-시작하기-unix)
빠르게 시작하기 가이드를 따라가세요.

더 자세한 정보는 [패키지 설치 및 사용][getting-started:using-a-package]에 있습니다.
만약 필요한 라이브러리가 vcpkg 카탈로그에 없는 경우,
[GitHub 저장소에서 이슈를 열 ​​수 있습니다][contributing:submit-issue].
Vcpkg 팀과 커뮤니티가 이슈를 확인하면, 해당하는 port를 추가할 수 있습니다.

Vcpkg의 설치가 완료되었다면,
셸에 [탭 완성](#탭-완성자동-완성)을 추가할 수 있습니다.

마지막으로, vcpkg의 미래에 관심이 있다면,
[manifest][getting-started:manifest-spec] 가이드를 확인하세요!
이것은 실험적인 기능이며 버그가 있을 가능성이 높습니다.
시도해보고 문제가 있다면 [이슈를 열어주세요][contributing:submit-issue]!

## 빠르게 시작하기: Windows

필요조건:
- Windows 7 이상
- [Git][getting-started:git]
- [Visual Studio][getting-started:visual-studio] 영어 언어팩이 설치된 2015 Update 3 버전 이상

첫번째로, vcpkg 자체를 다운로드하고 부트스트랩합니다. Vcpkg는 어디에나 설치할 수 있지만,
일반적으로 CMake 프로젝트는 vcpkg를 submodule로 사용하는 것을,
Visual Studio 프로젝트는 시스템에 설치하는 것을 추천합니다.
시스템 설치는 `C:\src\vcpkg` 나 `C:\dev\vcpkg` 등의 위치에 하는 것을 권장하는데,
그렇지 않으면 일부 포트 빌드 시스템에서 경로 문제가 발생할 수도 있기 때문입니다.

```cmd
> git clone https://github.com/microsoft/vcpkg
> .\vcpkg\bootstrap-vcpkg.bat
```

당신의 프로젝트에 라이브러리를 설치하려면 다음 명령을 실행하세요.

```cmd
> .\vcpkg\vcpkg install [packages to install]
```

참고로, 위 명령은 x86 라이브러리를 설치하는 것이 기본 설정입니다. 만약 x64 버전을
설치하고 싶다면, 다음 명령을 실행하세요.

```cmd
> .\vcpkg\vcpkg install [package name]:x64-windows
```

또는 이렇게도 가능합니다.

```cmd
> .\vcpkg\vcpkg install [packages to install] --triplet=x64-windows
```

다음과 같이 `search` 하위 명령어를 사용하여 필요한 라이브러리를 검색할 수도 있습니다.

```cmd
> .\vcpkg\vcpkg search [search term]
```

Visual Studio에서 vcpkg를 사용하려면
다음 명령을 실행해야 합니다(관리자 권한이 필요할 수도 있습니다).

```cmd
> .\vcpkg\vcpkg integrate install
```

이제 CMake를 사용하지 않는 프로젝트도 만들 수 (또는 기존 프로젝트를 열 수) 있습니다.
설치한 모든 라이브러리는 추가 설정 없이도 프로젝트에서 즉시 `# include` 및 사용할 수 있습니다.

Visual Studio에서 CMake를 사용하는 경우,
[여기를 보세요](#vcpkg와-visual-studio-cmake-프로젝트).

IDE 외부에서 CMake와 함께 vcpkg를 사용하려면,
다음과 같이 툴체인 파일을 사용할 수 있습니다.

```cmd
> cmake -B [build directory] -S . "-DCMAKE_TOOLCHAIN_FILE=[path to vcpkg]/scripts/buildsystems/vcpkg.cmake"
> cmake --build [build directory]
```

CMake에서 라이브러리를 사용하려면 여전히 `find_package` 등이 필요합니다.
CMake를 IDE와 사용하는 방법을 포함한
자세한 정보는 [CMake 섹션](#cmake와-함께-vcpkg-사용)을 확인하세요.

Visual Studio Code를 포함한 다른 툴의 경우
[통합 가이드][getting-started:integration]를 확인하세요.

## 빠르게 시작하기: Unix

Linux에서의 필요조건:
- [Git][getting-started:git]
- [g++][getting-started:linux-gcc] >= 6

macOS에서의 필요조건:
- [Apple Developer Tools][getting-started:macos-dev-tools]

우선, vcpkg 자체를 다운로드하고 설치해야 합니다. 어디에나 설치할 수 있지만,
일반적으로 CMake 프로젝트의 하위 모듈로 vcpkg를 사용하는 것이 좋습니다.

```sh
$ git clone https://github.com/microsoft/vcpkg
$ ./vcpkg/bootstrap-vcpkg.sh
```

프로젝트에 라이브러리를 설치하려면 다음 명령을 실행하세요.

```sh
$ ./vcpkg/vcpkg install [packages to install]
```

다음과 같이 `search` 하위 명령어를 사용하여 필요한 라이브러리를 검색할 수도 있습니다.

```sh
$ ./vcpkg/vcpkg search [search term]
```

CMake와 함께 vcpkg를 사용하려면 툴체인 파일을 이용해 보세요.

```sh
$ cmake -B [build directory] -S . "-DCMAKE_TOOLCHAIN_FILE=[path to vcpkg]/scripts/buildsystems/vcpkg.cmake"
$ cmake --build [build directory]
```

CMake에서 라이브러리를 사용하려면 여전히 `find_package` 등이 필요합니다.
CMake와 VSCode를 위한 CMake Tools를 vcpkg와 함께 사용하는 최선의 방법을 포함한
자세한 정보는 [CMake 섹션](#cmake와-함께-vcpkg-사용)을 확인하세요.

다른 툴에 대해서는 [통합 가이드][getting-started:integration]를 확인하세요.

## Linux 개발자 도구 설치하기

Linux의 배포판별로 설치해야 하는 개발자 소프트웨어가 다릅니다.

- Debian, Ubuntu, popOS 및 기타 Debian 기반 배포판

```sh
$ sudo apt-get update
$ sudo apt-get install build-essential tar curl zip unzip
```

- CentOS

```sh
$ sudo yum install centos-release-scl
$ sudo yum install devtoolset-7
$ scl enable devtoolset-7 bash
```

다른 배포판의 경우, g++ 6 이상의 버전을 설치하여야 합니다.
특정 배포판에 대한 안내를 추가하고 싶은 경우,
[PR을 열어주세요][contributing:submit-pr]!

## macOS 개발자 도구 설치하기

macOS에서는 터미널에서 다음 명령어를 실행하기만 하면 됩니다.

```sh
$ xcode-select --install
```

그런 다음 나타나는 창의 안내에 따르세요.

설치가 끝나면 [빠른 시작 가이드](#빠르게-시작하기-unix)를 참고하여 vcpkg를 설치하세요.

## CMake와 함께 vcpkg 사용

CMake와 함께 vcpkg를 사용하는 경우, 다음 내용이 도움이 될 것입니다!

### Visual Studio Code와 CMake Tools

Workspace `settings.json` 파일에 다음을 추가하면
CMake Tools는 자동으로 vcpkg의 라이브러리를 사용할 것입니다.

```json
{
  "cmake.configureSettings": {
    "CMAKE_TOOLCHAIN_FILE": "[vcpkg root]/scripts/buildsystems/vcpkg.cmake"
  }
}
```

### Vcpkg와 Visual Studio CMake 프로젝트

CMake 설정 편집기를 열고 `CMake toolchain file`에서
vcpkg 툴체인 파일에 경로를 추가합니다.

```
[vcpkg root]/scripts/buildsystems/vcpkg.cmake
```

### Vcpkg와 CLion

Toolchains settings을 엽니다.
(File > Settings on Windows and Linux, CLion > Preferences on macOS),
그리고 CMake 세팅을 엽니다 (Build, Execution, Deployment > CMake).
마지막으로 `CMake options`에서 다음 줄을 추가합니다.

```
-DCMAKE_TOOLCHAIN_FILE=[vcpkg root]/scripts/buildsystems/vcpkg.cmake
```

각 프로필에 이것을 추가해야합니다.

### 서브모듈로 vcpkg 사용하기

프로젝트의 서브모듈로 vcpkg를 사용하는 경우,
cmake 실행 시 `CMAKE_TOOLCHAIN_FILE`을 전달하는 대신,
첫 번째 `project()` 호출 전에 CMakeLists.txt에 다음을 추가하는 방법도 있습니다.

```cmake
set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/vcpkg/scripts/buildsystems/vcpkg.cmake"
  CACHE STRING "Vcpkg toolchain file")
```

이렇게 하면 설정-빌드 단계가 약간 더 쉬워집니다.
또한, 여전히 `CMAKE_TOOLCHAIN_FILE`을 직접 전달하면
vcpkg를 사용하지 않을 수 있습니다.

[getting-started:using-a-package]: docs/examples/installing-and-using-packages.md
[getting-started:integration]: docs/users/buildsystems/integration.md
[getting-started:git]: https://git-scm.com/downloads
[getting-started:cmake-tools]: https://marketplace.visualstudio.com/items?itemName=ms-vscode.cmake-tools
[getting-started:linux-gcc]: #installing-linux-developer-tools
[getting-started:macos-dev-tools]: #installing-macos-developer-tools
[getting-started:macos-brew]: #installing-gcc-on-macos
[getting-started:macos-gcc]: #installing-gcc-on-macos
[getting-started:visual-studio]: https://visualstudio.microsoft.com/
[getting-started:manifest-spec]: docs/specifications/manifests.md

# 탭 완성/자동 완성

`vcpkg`는 powershell과 bash 모두에서 명령, 패키지 이름 및 옵션의 자동 완성을 지원합니다.
선택한 셸에서 탭 완성을 활성화하려면 다음 두 명령어 중 하나를 실행합니다.

```pwsh
> .\vcpkg integrate powershell
```

```sh
$ ./vcpkg integrate bash # or zsh
```

그 다음 콘솔을 재시작하세요.

# 예시

[패키지 설치 및 사용](docs/examples/installing-and-using-packages.md),
[zip 파일에서 새 패키지 추가](docs/examples/packaging-zipfiles.md),
[GitHub 저장소에서 새 패키지 추가](docs/examples/packaging-github-repos.md)에
대한 구체적인 예시는 [문서](docs/README.md)를 참고하세요.

문서는 이제 웹사이트 https://vcpkg.io/ 에서도 온라인으로 확인 가능합니다. 모든 피드백에 진심으로 감사드립니다!
https://github.com/vcpkg/vcpkg.github.io/issues 에서 이슈를 제출할 수 있습니다.

[4분짜리 데모 영상도 준비되어 있습니다](https://www.youtube.com/watch?v=y41WFKbQFTw).

# 기여하기

Vcpkg는 오픈소스 프로젝트입니다, 따라서 여러분의 기여를 통해 만들어집니다.
기여할 수 있는 몇 가지 방법은 다음과 같습니다.

* Vcpkg 또는 vcpkg에 포함된 패키지의 [이슈 제출][contributing:submit-issue]
* [수정 사항 및 새 패키지 제출][contributing:submit-pr]

자세한 내용은 [기여 가이드](CONTRIBUTING.md)를 참고하세요.

이 프로젝트는 [Microsoft Open Source Code of Conduct][contributing:coc]을 채택했습니다.
더 많은 정보를 얻고 싶다면 [Code of Conduct FAQ][contributing:coc-faq] 문서를 참고하세요.
추가 질문이나 의견은 이메일 [opencode@microsoft.com](mailto:opencode@microsoft.com)로 보내주세요.

[contributing:submit-issue]: https://github.com/microsoft/vcpkg/issues/new/choose
[contributing:submit-pr]: https://github.com/microsoft/vcpkg/pulls
[contributing:coc]: https://opensource.microsoft.com/codeofconduct/
[contributing:coc-faq]: https://opensource.microsoft.com/codeofconduct/

# 라이선스

이 저장소의 코드는 [MIT 라이선스](LICENSE.txt)에 따라 사용이 허가됩니다. Port로 제공되는
라이브러리는 각 라이브러리의 원저자가 설정한 라이선스에 따라 제공됩니다. 가능한 경우, vcpkg는
`installed/<triplet>/share/<port>/copyright`에 관련된 라이선스를 저장합니다.

# 보안

Vcpk가 제공하는 대부분의 port는 각각의 라이브러리를 빌드할 때
원 개발자들이 권장하는 빌드 시스템을 이용하고,
소스 코드와 빌드 도구를 각각의 공식 배포처로부터 다운로드합니다.
방화벽 뒤에서 사용하는 경우, 어떤 port를 설치하느냐에 따라 필요한 접근 권한이 달라질 수 있습니다.
만약 "air gapped" 환경에서 설치해야만 한다면, "air gapped"가 아닌 환경에서 
[asset 캐시](docs/users/assetcaching.md)를 다운로드하고, 
이후에 "air gapped" 환경에서 공유하는 것을 고려해 보십시오.

# 데이터 수집

vcpkg는 사용자 경험을 개선하는 데 도움이 되도록 사용 데이터를 수집합니다.
Microsoft는 이 정보를 익명으로 수집합니다.
다음을 통해 원격 정보 제공을 비활성화할 수 있습니다.
- -disableMetrics 옵션을 포함하여 bootstrap-vcpkg 스크립트 실행
- 명령줄에서 vcpkg에 --disable-metrics 전달
- VCPKG_DISABLE_METRICS 환경 변수 설정

[https://learn.microsoft.com/vcpkg/about/privacy](https://learn.microsoft.com/vcpkg/about/privacy)에서 vcpkg 데이터 수집에 대해 자세히 알아보세요.

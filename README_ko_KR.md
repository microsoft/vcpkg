# Vcpkg: 개요

Vcpkg는 Windows, Linux 및 MacOS에서 C 및 C++ 라이브러리를 관리하는 데 도움이 됩니다.
이 툴과 생태계는 지속적으로 진화하고 있으며 항상 기여해 주셔서 감사합니다!

이전에 vcpkg를 사용한 적이 없거나 vcpkg를 사용하는 방법을 알고 싶을 경우,
vcpkg 사용을 시작하는 방법은 [시작하기](#시작하기) 섹션을 확인하세요.

사용 가능한 명령어에 대한 간단한 설명을 보려면 vcpkg를 설치 한 후 `vcpkg help` 또는 `vcpkg help [command]` 명령어로 명령어 별 도움말을 볼 수 있습니다.

* Github: [https://github.com/microsoft/vcpkg](https://github.com/microsoft/vcpkg)
* Slack: [https://cppalliance.org/slack/](https://cppalliance.org/slack/), #vcpkg 채널
* Discord: [\#include \<C++\>](https://www.includecpp.org), #🌏vcpkg 채널
* Docs: [Documentation](docs/README.md)

[![Build Status](https://dev.azure.com/vcpkg/public/_apis/build/status/microsoft.vcpkg.ci?branchName=master)](https://dev.azure.com/vcpkg/public/_build/latest?definitionId=29&branchName=master)

# 목차

- [Vcpkg: 개요 둘러보기](#vcpkg-개요)
- [목차](#목차)
- [시작하기](#시작하기)
  - [빠르게 시작하기: 원도우](#빠르게-시작하기-원도우)
  - [빠르게 시작하기: 유닉스](#빠르게-시작하기-유닉스)
  - [리눅스 개발자 도구 설치하기](#리눅스-개발자-도구-설치하기)
  - [macOS 개발자 도구 설치하기](#macos-개발자-도구-설치하기)
    - [10.15버전 이전 macOS에 GCC 설치하기](#1015버전-이전-macos에-gcc-설치하기)
  - [CMake와 함께 vcpkg 사용](#cmake와-함께-vcpkg-사용)
    - [Visual Studio Code와 CMake Tools](#visual-studio-code와-cmake-tools)
    - [Visual Studio CMake 프로젝트와 Vcpkg](#visual-studio-cmake-프로젝트와-vcpkg)
    - [Vcpkg와 CLion](#vcpkg와-clion)
    - [서브모듈로서의 Vcpkg](#서브모듈로서의-vcpkg)
- [탭 완성/자동 완성](#탭-완성/자동-완성)
- [예제](#예제)
- [기여](#기여)
- [라이선스](#라이선스)
- [데이터 수집](#데이터-수집)

# 시작하기

먼저, 사용하는 운영체제에 따라 빠르게 시작하기 문서를 따라가세요.
[윈도우](#빠르게-시작하기-윈도우) 또는 [macOS 그리고 Linux](#빠르게-시작하기-유닉스).

더 많은 정보를 얻고 싶다면, [패키지 설치 및 사용][getting-started:using-a-package] 문서를 참고하세요.
만약 필요한 라이브러리가 vcpkg 카탈로그에 없는 경우, vcpkg 팀이나 커뮤니티가 볼 수 있는
[GitHub 저장소에서 이슈를 열 ​​수 있습니다][contributing:submit-issue]
또한 잠재적으로 vcpkg에 포트가 추가될 것 입니다.

vcpkg를 설치하고 작동 한 후, 
셸에 [탭 완성/자동 완성](#탭-완성/자동-완성)을 추가 할 수 있습니다.

마지막으로, vcpkg의 미래에 관심이 있다면,
[manifest][getting-started:manifest-spec] 가이드를 확인하세요!
이것은 실험적인 기능이며 버그가 있을 수도 있습니다.
시도해보고 문제가 있다면 [이슈을 여세요][contributing:submit-issue]!

## 빠르게 시작하기: 윈도우

필요조건:
- Windows 7 이상
- [Git][getting-started:git]
- [Visual Studio][getting-started:visual-studio] 영어 언어팩이 설치된 2015 Update 3 버전 이상
 
첫번째로, vcpkg 자체를 다운로드하고 부트스트랩합니다; 어디에나 설치할 수 있습니다,
하지만 일반적으로 CMake 프로젝트의 하위 모듈로 vcpkg를 사용하는 것이 좋습니다.
Visual Studio 프로젝트를 위해 전역적으로 설치합니다.
설치 위치는 `C:\src\vcpkg` 나 `C:\dev\vcpkg`를 사용할것을 권장합니다. 
그렇지 않으면 일부 포트 빌드 시스템에서 경로 문제가 발생할 수도 있습니다.

```cmd
> git clone https://github.com/microsoft/vcpkg
> .\vcpkg\bootstrap-vcpkg.bat
```

당신의 프로젝트에 라이브러리를 설치, 실행 시키려면 다음과 같이 작성하세요:

```cmd
> .\vcpkg\vcpkg install [packages to install]
```

다음과 같이 `search` 하위 명령어를 사용하여 필요한 라이브러리를 검색 할 수도 있습니다.

```cmd
> .\vcpkg\vcpkg search [search term]
```

Visual Studio에서 vcpkg를 사용하려면
다음 명령을 실행합니다 (관리자 권한이 필요할 수도 있습니다):

```cmd
> .\vcpkg\vcpkg integrate install
```


그런 다음, 이제 CMake가 아닌 새 프로젝트를 만들 수 있습니다. (또는 기존 프로젝트를 열 수 있습니다)
설치된 모든 라이브러리는 즉시 `# include` 될 준비가 되어 추가 구성없이 프로젝트에서 사용할 수 있습니다.

Visual Studio에서 CMake를 사용하는 경우,
[여기를 보세요](#visual-studio-code와-cmake-tools).

IDE 외부에서 CMake와 함께 vcpkg를 사용하려면,
툴체인 파일을 사용할 수 있습니다:

```cmd
> cmake -B [build directory] -S . -DCMAKE_TOOLCH
AIN_FILE=[path to vcpkg]/scripts/buildsystems/vcpkg.cmake
> cmake --build [build directory]
```

CMake와 라이브러리를 사용하려면 `find_package` 등이 필요합니다.
IDE에서 CMake 사용에 대한 자세한 내용은 [CMake 섹션](#cmake와-함께-vcpkg-사용)을 확인하세요.


Visual Studio Code를 포함한 다른 툴의 경우
[통합 가이드][getting-started:integration]을 확인하세요.

## 빠르게 시작하기: 유닉스

Linux에서의 필요조건:
- [Git][getting-started:git]
- [g++][getting-started:linux-gcc] >= 6

macOS에서의 필요조건:
- [Apple Developer Tools][getting-started:macos-dev-tools]
- macOS 10.14이나 아래 버전에서는 다음 도구들도 필요합니다:
  - [Homebrew][getting-started:macos-brew]
  - [g++][getting-started:macos-gcc] >= 6 from Homebrew

첫번째로, vcpkg 자체를 다운로드하고 부트스트랩합니다; 어디에나 설치할 수 있습니다,
하지만 일반적으로 CMake 프로젝트의 하위 모듈로 vcpkg를 사용하는 것이 좋습니다.

```sh
$ git clone https://github.com/microsoft/vcpkg
$ ./vcpkg/bootstrap-vcpkg.sh
```

당신의 프로젝트에 라이브러리를 설치, 실행 시키려면 다음과 같이 작성하세요:

```sh
$ ./vcpkg/vcpkg install [packages to install]
```

다음과 같이 `search` 하위 명령어를 사용하여 필요한 라이브러리를 검색 할 수도 있습니다.

```sh
$ ./vcpkg/vcpkg search [search term]
```

CMake에서 vcpkg를 사용하려면 툴체인 파일을 사용할 수 있습니다
```sh
$ cmake -B [build directory] -S . -DCMAKE_TOOLCHAIN_FILE=[path to vcpkg]/scripts/buildsystems/vcpkg.cmake
$ cmake --build [build directory]
```

CMake와 라이브러리를 사용하려면 `find_package` 등이 필요합니다.
CMake 및 CMake Tools for VSCode에서 vcpkg를 가장 잘 사용하는 방법에 대한 자세한 내용은 
[CMake 섹션](#cmake와-함께-vcpkg-사용)을 확인하세요.

다른 툴에 대해서는 [통합 가이드][getting-started:integration]을 확인하세요.
## 리눅스 개발자 도구 설치하기

리눅스의 다양한 배포판에는 다양한 패키지가 있습니다.
설치 필요:

-Debian, Ubuntu, popOS 및 기타 Debian 기반 배포판:

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

다른 배포판의 경우 g++ 6 이상의 버전을 설치해야합니다.
특정 배포판에 대한 지침을 추가하려면
[PR을 열어주세요][contributing:submit-pr]!

## macOS 개발자 도구 설치하기

macOS 10.15에서는 터미널에서 다음 명령어를 실행하시면 됩니다.

```sh
$ xcode-select --install
```

그런 다음 나타나는 창에 나타나는 메시지를 따르세요.

macOS 10.14 및 이전 버전에서는 homebrew에서 g++도 설치해야합니다.
다음 섹션의 지침을 따르세요.

### 10.15버전 이전 macOS에 GCC 설치하기

이번 섹션은 10.15 이전의 macOS 버전을 사용하는 경우에만 필요합니다.
homebrew를 설치하는 것은 매우 쉽습니다. 자세한 내용은 <brew.sh>를 확인하세요.
가장 간단하게 다음 명령어을 실행합니다.

```sh
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

그런 다음 최신 버전의 gcc를 설치하시려면 다음 명령어를 실행하십시오.

```sh
$ brew install gcc
```

그런다음 [빠른 시작 가이드](#빠르게-시작하기-유닉스)와 함께 vcpkg를 부트스트랩 할 수 있습니다.

## CMake와 함께 vcpkg 사용

CMake와 함께 vcpkg를 사용하는 경우, 다음과 같이 따라해 보세요

### Visual Studio Code와 CMake Tools

작업 공간 `settings.json` 파일에 다음을 추가하면
CMake 도구는 라이브러리에 자동으로 vcpkg를 사용합니다.

```json
{
  "cmake.configureSettings": {
    "CMAKE_TOOLCHAIN_FILE": "[vcpkg root]/scripts/buildsystems/vcpkg.cmake"
  }
}
```

### Visual Studio CMake 프로젝트와 Vcpkg

CMake 설정 편집기를 열고 'CMake toolchain file'에서
vcpkg 툴체인 파일에 경로를 추가합니다.

```
[vcpkg root]/scripts/buildsystems/vcpkg.cmake
```

### Vcpkg와 CLion

Toolchains settings을 엽니다.
(File > Settings on Windows and Linux, CLion > Preferences on macOS),
그리고 Cmake 세팅을 엽니다 (Build, Execution, Deployment > CMake).
마지막으로 `CMake options`에서 다음 줄을 추가합니다.

```
-DCMAKE_TOOLCHAIN_FILE=[vcpkg root]/scripts/buildsystems/vcpkg.cmake
```

각 프로필에 이것을 추가해야합니다.

### 서브모듈로서의 Vcpkg

프로젝트의 하위 모듈로 vcpkg를 사용하는 경우
cmake 호출에`CMAKE_TOOLCHAIN_FILE`을 전달하는 대신 첫 번째 `project ()` 호출 전에 CMakeLists.txt에 다음을 추가 할 수 있습니다.

```cmake
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/vcpkg/scripts/buildsystems/vcpkg.cmake
  CACHE STRING "Vcpkg toolchain file")
```

이렇게 하면 `CMAKE_TOOLCHAIN_FILE`을 직접 전달하여 구성-빌드 단계가 약간 더 쉬워지지만 
사람들이 vcpkg를 사용하지 못하게 됩니다.

[getting-started:using-a-package]: docs/examples/installing-and-using-packages.md
[getting-started:integration]: docs/users/integration.md
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
선택한 셸에서 탭 완성을 활성화하려면 다음 명령어를 실행합니다.

```pwsh
> .\vcpkg integrate powershell
```

혹은

```sh
$ ./vcpkg integrate bash
```

사용하는 셸에 따라 콘솔을 다시 시작세요.

# 예제

구체적인 연습은 [문서](docs/README.md)를 참고하세요,
including [패키지 설치 및 사용](docs/examples/installing-and-using-packages.md),
[zip 파일에서 새 패키지 추가](docs/examples/packaging-zipfiles.md),
및 [GitHub 저장소에서 새 패키지 추가](docs/examples/packaging-github-repos.md).

이제 ReadTheDocs에서 온라인으로 문서를 사용할 수도 있습니다: <https://vcpkg.readthedocs.io/>!

[4분짜리 데모 영상을 보세요](https://www.youtube.com/watch?v=y41WFKbQFTw).

# 기여

Vcpkg는 오픈소스 프로젝트입니다, 따라서 여러분의 기여로 만들어 졌습니다. 
기여할 수 있는 몇 가지 방법은 다음과 같습니다:

* vcpkg 또는 기존 패키지의 [문제 제출][contributing:submit-issue] 
* [Submit Fixes and New Packages][contributing:submit-pr]

자세한 내용은 [컨트리뷰팅 가이드](CONTRIBUTING.md)를 참고하세요.

이 프로젝트는 [Microsoft Open Source Code of Conduct][contributing:coc]을 채택했습니다.
더 많은 정보를 얻고 싶다면 [Code of Conduct FAQ][contributing:coc-faq] 문서를 참고하거나 추가 질문 또는 의견은 이메일 [opencode@microsoft.com](mailto:opencode@microsoft.com)로 보내주세요.

[contributing:submit-issue]: https://github.com/microsoft/vcpkg/issues/new/choose
[contributing:submit-pr]: https://github.com/microsoft/vcpkg/pulls
[contributing:coc]: https://opensource.microsoft.com/codeofconduct/
[contributing:coc-faq]: https://opensource.microsoft.com/codeofconduct/

# 라이선스

이 저장소의 코드는 [MIT 라이선스](LICENSE.txt)에 따라 라이선스가 부여됩니다.

# 데이터 수집

vcpkg는 사용자 경험을 개선하는 데 도움이 되도록 사용 데이터를 수집합니다.
Microsoft는 이 정보를 익명으로 수집합니다.
bootstrap-vcpkg 스크립트를 -disableMetrics를 추가해 다시 실행하여 원격 분석을 옵트아웃 할 수 있습니다.
커맨드 라인에서 --disable-metrics를 vcpkg에 전달합니다.
또는 VCPKG_DISABLE_METRICS 환경 변수를 설정합니다.

docs/about/privacy.md 에 vcpkg 데이터 수집에 대해 자세히 알아보세요.

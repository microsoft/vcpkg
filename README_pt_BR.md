# Vcpkg
[中文总览](README_zh_CN.md)
[Español](README_es.md)
[한국어](README_ko_KR.md)
[Français](README_fr.md)
[English](README.md)

Vcpkg ajuda você a manusear bibliotecas de C e C++ no Windows, Linux e MacOS. Esta ferramenta e o ecossistema (que a envolve) estão em constante evolução, e nos sempre agradecemos pelas contribuições!

Se você nunca usou o vcpkg anteriormente, ou se você está tentando descobrir como usar o vcpkg, verifique a nossa seção [Primeiros passos](#primeiros-passos) para saber como começar a usar o vcpkg.

Para uma breve descrição dos comandos disponiveis, uma vez que você tenha instalado o vcpkg, você pode rodar os comandos `vcpkg help`, or `vcpkg help [command]` para ajuda de um comando especifico.

* GitHub: portas em [https://github.com/microsoft/vcpkg](https://github.com/microsoft/vcpkg), programa em [https://github.com/microsoft/vcpkg-tool](https://github.com/microsoft/vcpkg-tool)
* Slack: [https://cppalliance.org/slack/](https://cppalliance.org/slack/), no canal #vcpkg
* Discord: [\#include \<C++\>](https://www.includecpp.org), no canal #🌏vcpkg
* Documentos: [Documentation](docs/README.md)

# Sumário

- [Vcpkg: Visão Geral](#vcpkg)
- [Sumário](#sumário)
- [Primeiros Passos](#primeiros-passos)
  - [Inicio rapido: Windows](#guia-de-inicio-rapido-windows)
  - [Inicio rapido: Unix](#guia-rapido-de-inicio-unix)
  - [Instalando o Linux Developer Tools](#instalando-o-linux-developer-tools)
  - [Instalando o macOS Developer Tools](#instalando-macos-developer-tools)
  - [Usando vcpkg com CMake](#usando-vcpkg-com-cmake)
    - [Visual Studio Code com CMake Tools](#visual-studio-code-com-cmake-tools)
    - [Vcpkg com Visual Studio Projetos CMake](#vcpkg-com-visual-studio-projetos-cmake)
    - [Vcpkg com CLion](#vcpkg-com-clion)
    - [Vcpkg como um Submodulo](#vcpkg-como-um-submodulo)
    - [Vcpkg via FetchContent](#vcpkg-via-fetchcontent)
- [Tab-Completion/Auto-Completion](#tab-completionauto-completion)
- [Examples](#examples)
- [Contributing](#contributing)
- [License](#license)
- [Security](#security)
- [Telemetry](#telemetry)

# Primeiros Passos

Primeiramente, siga o guia rapido de inicio para
[Windows](#guia-de-inicio-rapido-windows), ou [macOS e Linux](#guia-rapido-de-inicio-unix),
dependendo de qual que você usa.

Para mais informações, consulte [Instalação e utilização de pacotes][getting-started:using-a-package].
Se a biblioteca que você precisa não está presente no catálogo do vcpkg,
você pode [abrir uma issue no repositório do github][contributing:submit-issue]
onde a equipe e a comunidade do vcpkg possa ver,
e potencialmente fazer o aport para o vcpkg.

Após você tenha o vcpkg instalado e funcionando,
você pode adicionar o [tab completion](#tab-completionauto-completion) para o seu shell.

Finalmente, se você está interessado no futuro do vcpkg,
confira o Guia [manifest!][getting-started:manifest-spec]
Isto é uma feature que está em fase experimental e provavelmente terá bugs,
então tente usar a feature e [abra todas as issues possiveis][contributing:submit-issue]!

## Guia de inicio rapido: Windows

Pre-Requisitos:
- Windows 7 ou mais novo
- [Git][getting-started:git]
- [Visual Studio][getting-started:visual-studio] 2015 Update 3 ou mais recente com o idioma padrão em Inglês.

Primeiramente, baixe e compile  o vcpkg em si; ele pode ser instalado em qualquer pasta,
porém geralmente nos recomendamos usar o vcpkg como um submodulo para projetos em CMake,
e instalando globalmente para projetos em Visual Studio.
Nos recomendamos instalar em lugares como `C:\src\vcpkg` ou `C:\dev\vcpkg`,
uma vez que, de uma outra modo você pode encontrar problemas ao rodar no path para algumas portas na construção de sistemas.

```cmd
> git clone https://github.com/microsoft/vcpkg
> .\vcpkg\bootstrap-vcpkg.bat
```

Para instalar as bibliotecas para seu projeto, execute o seguinte comando:

```cmd
> .\vcpkg\vcpkg install [packages to install]
```

Nota: Esse comando irá instalar por padrão as bibliotecas x86. Para instalar as bibliotecas x64, execute:

```cmd
> .\vcpkg\vcpkg install [package name]:x64-windows
```

Ou

```cmd
> .\vcpkg\vcpkg install [packages to install] --triplet=x64-windows
```

Voçê também pode procurar por bibliotecas que você precisa com o subcomando `search`:

```cmd
> .\vcpkg\vcpkg search [search term]
```

Siga a sequência para usaar o vcpkg com o Visual Studio,
execute os comandos a seguir (Pode requisitar privilégios de administrador):

```cmd
> .\vcpkg\vcpkg integrate install
```

Após isso, voçê agora pode criar um novo projeto CMake (ou obrir um projeto já existente).
Com todas as bibliotecas instaladas já podem ser immediatamente usadas em seu projeto com o codigo `#include`
sem configuração adicional.

Se voçê está usando o CMake com o Visual Studio,
clique [aqui](#vcpkg-com-visual-studio-projetos-cmake).

Na sequência, para usar o vcpkg com CMake fora de uma IDE,
você precisa o utilizar o toolchain file:

```cmd
> cmake -B [build directory] -S . "-DCMAKE_TOOLCHAIN_FILE=[path to vcpkg]/scripts/buildsystems/vcpkg.cmake"
> cmake --build [build directory]
```

Com o CMake, você ainda precisará utilizar o `find_package` para ter o prazer de usar as bibliotecas.
Confira a [sessão CMake](#usando-vcpkg-com-cmake) para mais informações,
incluindo o uso do CMake com uma IDE.

Para qualquer outra ferramenta, incluindo o Visual Studio COde,
confira o [guia de integração][getting-started:integration].

## Guia rapido de Inicio: Unix

Pré-Requisitos para Linux:
- [Git][getting-started:git]
- [g++][getting-started:linux-gcc] >= 6

Pré-Requisitos para MacOS:
- [Apple Developer Tools](#instalando-macos-developer-tools)

Primeiramente, baixe e compile o proprio vcpkg; ele pode ser instalado em qualquer pasta,
mas geralmente recomendamos usar o  vcpkg como um sobmodulo para projetos em CMake.

```sh
$ git clone https://github.com/microsoft/vcpkg
$ ./vcpkg/bootstrap-vcpkg.sh
```

Para instalar as bibliotecas para seu projeto, execute o seguinte comando:

```sh
$ ./vcpkg/vcpkg install [packages to install]
```

Voçê também pode procurar por bibliotecas que você precisa com o subcomando `search`:

```sh
$ ./vcpkg/vcpkg search [search term]
```

Na sequência para usar o vcpkg com o CMake, voçê pode usar o toolchain file:

```sh
$ cmake -B [build directory] -S . "-DCMAKE_TOOLCHAIN_FILE=[path to vcpkg]/scripts/buildsystems/vcpkg.cmake"
$ cmake --build [build directory]
```

Com o CMake, você ainda precisará utilizar o `find_package` para ter o prazer de usar as bibliotecas.
Confira a [sessão CMake](#usando-vcpkg-com-cmake) para mais informações, sobre como usar da melhor forma o vcpkg com o CMake e o CMake tools para o VSCode.

Para qualquer outra ferramente, confira o [Guia de integração][getting-started:integration].

## Instalando o Linux Developer Tools

Para as diferentes distribuições Linux, há diferentes pacotes que você precisará instalar:

- Debian, Ubuntu, popOS, e outras distros baseadas no Debian:

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

Para qualuquer outra distribuição, tenha certeza que você instalou ou tenha instalado o g++ 6 ou mais novo.
Se voçê deseja adicionar instruções osbre uma distribuição específica,
[Por Favor abra um Pull Request][contributing:submit-pr]!

## Instalando macOS Developer Tools

No MacOS, a unica coisa que voçê deve fazer é executar o comando asseguir no terminal do sistema:
```sh
$ xcode-select --install
```

A seguir siga as instruções juntos com as janelas que aperecerão.

Voçê será capaz de compilar o vcpkg seguindo o [Guia rapido](#guia-rapido-de-inicio-unix)

## Usando vcpkg com CMake

### Visual Studio Code com CMake Tools

Adicionado os comandos a seguir no seu workspace `settings.json` fará que
o CMake Tools use automaticamente o vcpkg para as bibliotecas:

```json
{
  "cmake.configureSettings": {
    "CMAKE_TOOLCHAIN_FILE": "[vcpkg root]/scripts/buildsystems/vcpkg.cmake"
  }
}
```

### Vcpkg com Visual Studio Projetos CMake

Abra o editor de configurações do CMake, e abaixo de `CMake toolchain file`,
adicione o path para o vcpkg toolchain file:

```
[vcpkg root]/scripts/buildsystems/vcpkg.cmake
```

### Vcpkg com CLion

Abra as configurações do Toolchains
(Arquivos > Configurações do Windows e Linux, CLion > Preferencias no MacOS),
e va até o CMake settings (Build, Execution, Deployment > CMake).
Finalmente, em `CMake options`, adicione a seguinte linha:

```
-DCMAKE_TOOLCHAIN_FILE=[vcpkg root]/scripts/buildsystems/vcpkg.cmake
```

Voçê precisar adicionar essa linha para cada usuário (profile).

### Vcpkg como um Submodulo

When using vcpkg as a submodule of your project,
you can add the following to your CMakeLists.txt before the first `project()` call,
instead of passing `CMAKE_TOOLCHAIN_FILE` to the cmake invocation.

```cmake
set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/vcpkg/scripts/buildsystems/vcpkg.cmake"
  CACHE STRING "Vcpkg toolchain file")
```

This will still allow people to not use vcpkg,
by passing the `CMAKE_TOOLCHAIN_FILE` directly,
but it will make the configure-build step slightly easier.

### Vcpkg via FetchContent

You can also grab vcpkg with CMake's built-in [FetchContent](https://cmake.org/cmake/help/v3.24/module/FetchContent.html) module.

Don't worry about the bootstrap scripts, since `vcpkg.cmake` will run them for you!

```
cmake_minimum_required(VERSION 3.14)

include(FetchContent)
FetchContent_Declare(vcpkg
    GIT_REPOSITORY https://github.com/microsoft/vcpkg/
    GIT_TAG 2022.09.27
)
FetchContent_MakeAvailable(vcpkg)

# NOTE: This must be defined before the first project call
set(CMAKE_TOOLCHAIN_FILE "${vcpkg_SOURCE_DIR}/scripts/buildsystems/vcpkg.cmake" CACHE FILEPATH "")

project(FOOBAR LANGUAGES "CXX")
``` 

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

# Tab-Completion/Auto-Completion

`vcpkg` supports auto-completion of commands, package names,
and options in both powershell and bash.
To enable tab-completion in the shell of your choice, run:

```pwsh
> .\vcpkg integrate powershell
```

or

```sh
$ ./vcpkg integrate bash # or zsh
```

depending on the shell you use, then restart your console.

# Examples

See the [documentation](docs/README.md) for specific walkthroughs,
including [installing and using a package](docs/examples/installing-and-using-packages.md),
[adding a new package from a zipfile](docs/examples/packaging-zipfiles.md),
and [adding a new package from a GitHub repo](docs/examples/packaging-github-repos.md).

Our docs are now also available online at our website https://vcpkg.io/. We really appreciate any and all feedback! You can submit an issue in https://github.com/vcpkg/vcpkg.github.io/issues.

See a 4 minute [video demo](https://www.youtube.com/watch?v=y41WFKbQFTw).

# Contributing

Vcpkg is an open source project, and is thus built with your contributions.
Here are some ways you can contribute:

* [Submit Issues][contributing:submit-issue] in vcpkg or existing packages
* [Submit Fixes and New Packages][contributing:submit-pr]

Please refer to our [Contributing Guide](CONTRIBUTING.md) for more details.

This project has adopted the [Microsoft Open Source Code of Conduct][contributing:coc].
For more information see the [Code of Conduct FAQ][contributing:coc-faq]
or email [opencode@microsoft.com](mailto:opencode@microsoft.com)
with any additional questions or comments.

[contributing:submit-issue]: https://github.com/microsoft/vcpkg/issues/new/choose
[contributing:submit-pr]: https://github.com/microsoft/vcpkg/pulls
[contributing:coc]: https://opensource.microsoft.com/codeofconduct/
[contributing:coc-faq]: https://opensource.microsoft.com/codeofconduct/

# License

The code in this repository is licensed under the [MIT License](LICENSE.txt). The libraries
provided by ports are licensed under the terms of their original authors. Where available, vcpkg
places the associated license(s) in the location `installed/<triplet>/share/<port>/copyright`.

# Security

Most ports in vcpkg build the libraries in question using the original build system preferred
by the original developers of those libraries, and download source code and build tools from their
official distribution locations. For use behind a firewall, the specific access needed will depend
on which ports are being installed. If you must install in in an "air gapped" environment, consider
installing once in a non-"air gapped" environment, populating an
[asset cache](docs/users/assetcaching.md) shared with the otherwise "air gapped" environment.

# Telemetry

vcpkg collects usage data in order to help us improve your experience.
The data collected by Microsoft is anonymous.
You can opt-out of telemetry by
- running the bootstrap-vcpkg script with -disableMetrics
- passing --disable-metrics to vcpkg on the command line
- setting the VCPKG_DISABLE_METRICS environment variable

Read more about vcpkg telemetry at docs/about/privacy.md

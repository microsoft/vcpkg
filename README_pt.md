# Vcpkg: visão geral

[中文总览](README_zh_CN.md) |
[Español](README_es.md) |
[한국어](README_ko_KR.md) |
[Français](README_fr.md) |
[English](README.md)

Vcpkg ajuda você a gerenciar bibliotecas C e C++ no Windows, Linux e MacOS.
Esta ferramenta e ecossistema estão em constante evolução e sempre agradecemos as contribuições!

Se você nunca usou o vcpkg antes, ou se está tentando descobrir como usar o vcpkg,
confira nossa seção [Primeiros passos](#getting-started) para saber como começar a usar o vcpkg.

Para obter uma breve descrição dos comandos disponíveis, depois de instalar o vcpkg,
você pode executar `vcpkg help`, ou `vcpkg help [command]` para obter ajuda específica do comando.

* GitHub: pacote completo em [https://github.com/microsoft/vcpkg](https://github.com/microsoft/vcpkg), programa em [https://github.com/microsoft/vcpkg-tool](https://github.com/microsoft/vcpkg-tool)
* Slack: [https://cppalliance.org/slack/](https://cppalliance.org/slack/), the #vcpkg channel
* Discord: [\#include \<C++\>](https://www.includecpp.org), the #🌏vcpkg channel
* Documentos: [Documentation](https://learn.microsoft.com/vcpkg)

# Índice

* [Vcpkg: visão geral](#vcpkg-visão-geral)
* [Índice](#Índice)
* [Primeiros passos](#primeiros-passos)
  * [Início rápido: Windows](#início-rápido-windows)
  * [Início rápido: Unix](#início-rápido-unix)
  * [Instalando ferramentas de desenvolvedor do Linux](#Instalando-ferramentas-de-desenvolvedor-do-Linux)
  * [Instalando ferramentas de desenvolvedor do macOS](#instalando-ferramentas-de-desenvolvedor-do-macos)
  * [Usando vcpkg com CMake](#usando-vcpkg-com-cmake)
    * [Visual Studio Code com CMake Tools](#visual-studio-code-com-ferramentas-cmake)
    * [Vcpkg com Projectos Visual Studio CMake](#vcpkg-com-projectos-visual-studio-cmake)
    * [Vcpkg com CLion](#vcpkg-com-clion)
    * [Vcpkg como um submódulo](#vcpkg-como-um-submódulo)
* [Tab-Completion/Auto-Completion](#tab-completionauto-completion)
* [Exemplos](#exemplos)
* [Contribuindo](#contribuindo)
* [Licença](#licença)
* [Segurança](#segurança)
* [Telemetria](#telemetria)

# Primeiros passos

Primeiro, siga o guia de início rápido para
[Windows](#início-rápido-windows) ou [macOS e Linux](#início-rápido-unix),
dependendo do que você está usando.

Para obter mais informações, consulte [Instalando e usando pacotes] [primeiros passos: usando um pacote].
Se uma biblioteca que você precisa não estiver presente no catálogo vcpkg,
você pode [abrir um problema no repositório do GitHub][contributing:submit-issue]
onde a equipe e a comunidade do vcpkg possam vê-lo,
e potencialmente adicionar a porta ao vcpkg.

Depois de ter vcpkg instalado e funcionando,
você pode querer adicionar [tab-completion](#tab-completionauto-completion) ao seu shell.

Finalmente, se você estiver interessado no futuro do vcpkg,
confira o guia [manifesto][introdução: especificação do manifesto]!
Este é um recurso experimental e provavelmente terá bugs,
então experimente e [abra todos os problemas][contribuir: enviando-problema]!

## Início rápido: Windows

Pré-requisitos:
- Windows 7 ou mais recente
- [Git][primeiros passos:git]
- [Visual Studio] [primeiros passos: visual-studio] 2015 Update 3 ou superior com o pacote de idioma inglês

Primeiro, baixe e inicialize o próprio vcpkg; pode ser instalado em qualquer lugar,
mas geralmente recomendamos usar vcpkg como um submódulo para projetos CMake,
e instalá-lo globalmente para projetos do Visual Studio.
Recomendamos algum lugar como `C:\src\vcpkg` ou `C:\dev\vcpkg`,
caso contrário, você pode ter problemas de caminho para alguns sistemas de compilação de portas.

```cmd
> git clone https://github.com/microsoft/vcpkg
> .\vcpkg\bootstrap-vcpkg.bat
```

Para instalar bibliotecas para os seus projectos, execute:

```cmd
> .\vcpkg\vcpkg install [nome do pacote por instalar]
```

Nota: este comando irá instalar bibliotecas x86 por padrão. Para instalar x64, execute:

```cmd
> .\vcpkg\vcpkg install [nome do pacote por instalar]:x64-windows
```

Ou

```cmd
> .\vcpkg\vcpkg install [nome do pacote por instalar] --triplet=x64-windows
```

Voce pode também procurar pela biblioteca que precisa com o subcomando `search`:

```cmd
> .\vcpkg\vcpkg search [termo de procura]
```

Para usar o vcpkg com o Visual Studio,
execute o seguinte comando (pode exigir autorização do administrador):

```cmd
> .\vcpkg\vcpkg integrate install
```

Depois disso, agora você pode criar um novo projeto sem CMake (ou abrir um já existente).
Todas as bibliotecas instaladas estarão imediatamente prontas para serem `#include`'d e usadas
em seu projeto sem configuração adicional.

Se você estiver usando o CMake com o Visual Studio,
continue [aqui](#vcpkg-com-projectos-visual-studio-cmake).

Para usar vcpkg com CMake fora de um IDE,
você pode usar o arquivo toolchain:

```cmd
> cmake -B [diretorio de trabalho] -S . "-DCMAKE_TOOLCHAIN_FILE=[localizacao do vcpkg]/scripts/buildsystems/vcpkg.cmake"
> cmake --build [diretorio de trabalho]
```

Com o CMake, você ainda precisará de `find_package` (localizar os pacotes) e similares para usar as bibliotecas.
Confira a [secção CMake](#usando-vcpkg-com-cmake) para mais informações,
incluindo o uso do CMake com um IDE.

Para quaisquer outras ferramentas, incluindo o Visual Studio Code,
confira o [guia de integração][primeiros passos: integração].

## Início rápido: Unix

Pré-requisitos para Linux:
- [Git][primeiros passos:git]
- [g++][primeiros passos:linux-gcc] >= 6

Pré-requisitos para macOS:
- [Apple Developer Tools][primeiros passos: macos-dev-tools]

Primeiro, baixe e inicialize o próprio vcpkg; pode ser instalado em qualquer lugar,
mas geralmente recomendamos o uso de vcpkg como um submódulo para projetos CMake.

```sh
$ git clone https://github.com/microsoft/vcpkg
$ ./vcpkg/bootstrap-vcpkg.sh
```

Para instalar as bibliotecas do seu projecto, execute:

```sh
$ ./vcpkg/vcpkg install [pacote por instalar]
```

Voce pode também procurar pela biblioteca que precisa com o subcomando `search`:

```sh
$ ./vcpkg/vcpkg search [termo de pesquisa]
```

Para usar vcpkg com CMake, você pode usar o arquivo toolchain:

```sh
$ cmake -B [diretorio de trabalho] -S . "-DCMAKE_TOOLCHAIN_FILE=[localizacao do vcpkg]/scripts/buildsystems/vcpkg.cmake"
$ cmake --build [diretorio de trabalho]
```

Com o CMake, você ainda precisará `find_package` e similares para usar as bibliotecas.
Confira a [seção CMake](#using-vcpkg-with-cmake)
para obter mais informações sobre a melhor forma de usar vcpkg com CMake,
e ferramentas CMake para VSCode.

Para quaisquer outras ferramentas, confira o [guia de integração][primeiros passos:integração].

## Instalando ferramentas de desenvolvedor do Linux

Nas diferentes distros do Linux, existem diferentes pacotes que você
precisa instalar:

- Debian, Ubuntu, popOS e outras distribuições baseadas em Debian:

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

Para quaisquer outras distribuições, certifique-se de instalar o g++ 6 ou superior.
Se você deseja adicionar instruções para sua distro específica, [abra um PR][contribuindo:enviar-pr]!

## Instalação das ferramentas de desenvolvedor do macOS

No macOS, a única coisa que você precisa fazer é executar o seguinte no seu terminal:

```sh
$ xcode-select --install
```

Em seguida, siga as instruções nas janelas que aparecerem.

Você poderá inicializar o vcpkg junto com o [guia de início rápido](#quick-start-unix)

## Usando vcpkg com CMake

### Visual Studio Code com ferramentas CMake

Adicionar o seguinte ao seu espaço de trabalho `settings.json` fará CMake Tools usar automaticamente `vcpkg` para bibliotecas:

```json
{
  "cmake.configureSettings": {
    "CMAKE_TOOLCHAIN_FILE": "[vcpkg root]/scripts/buildsystems/vcpkg.cmake"
  }
}
```

### Vcpkg com Projetos CMake do Visual Studio

Abra o CMake Settings Editor e, em `CMake toolchain file`, adicione o caminho ao arquivo de cadeia de ferramentas vcpkg:

```
[vcpkg root]/scripts/buildsystems/vcpkg.cmake
```

### Vcpkg com CLion

Abra as configurações das cadeias de ferramentas
(Arquivo > Configurações no Windows e Linux, CLion > Preferências no macOS), e vá para as configurações do CMake (Build, Execution, Deployment > CMake). Finalmente, em `CMake options`, adicione a seguinte linha:

```
-DCMAKE_TOOLCHAIN_FILE=[vcpkg root]/scripts/buildsystems/vcpkg.cmake
```

Você deve adicionar esta linha a cada perfil.

### Vcpkg como um submódulo

Ao usar o vcpkg como um submódulo do seu projeto,
você pode adicionar o seguinte ao seu CMakeLists.txt antes da primeira chamada `project()`, em vez de passar `CMAKE_TOOLCHAIN_FILE` para a invocação do cmake.

```cmake
set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/vcpkg/scripts/buildsystems/vcpkg.cmake"
  CACHE STRING "Vcpkg toolchain file")
```

Isso ainda permitirá que as pessoas não usem o vcpkg, passando o `CMAKE_TOOLCHAIN_FILE` diretamente, mas tornará a etapa de configuração-construção um pouco mais fácil.

[getting-started:using-a-package]: https://learn.microsoft.com/vcpkg/examples/installing-and-using-packages
[getting-started:integration]: https://learn.microsoft.com/en-us/vcpkg/users/buildsystems/msbuild-integration
[getting-started:git]: https://git-scm.com/downloads
[getting-started:cmake-tools]: https://marketplace.visualstudio.com/items?itemName=ms-vscode.cmake-tools
[getting-started:linux-gcc]: #installing-linux-developer-tools
[getting-started:macos-dev-tools]: #installing-macos-developer-tools
[getting-started:macos-brew]: #installing-gcc-on-macos
[getting-started:macos-gcc]: #installing-gcc-on-macos
[getting-started:visual-studio]: https://visualstudio.microsoft.com/
[getting-started:manifest-spec]: https://learn.microsoft.com/en-us/vcpkg/users/manifests

# Tab-Completion/Auto-Completion

`vcpkg` suporta preenchimento automático de comandos, nomes de pacotes, e opções em powershell e bash. Para habilitar o preenchimento de tabulação no shell de sua escolha, execute:

```pwsh
> .\vcpkg integrate powershell
```

Ou:

```sh
$ ./vcpkg integrate bash # or zsh
```

dependendo do shell que você usa, reinicie o console.

# Exemplos

Consulte a [documentação](https://learn.microsoft.com/vcpkg) para orientações específicas,
incluindo [instalando e usando um pacote](https://learn.microsoft.com/vcpkg/examples/installing-and-using-packages),
[adicionando um novo pacote de um arquivo zip](https://learn.microsoft.com/vcpkg/examples/packaging-zipfiles),
e [adicionando um novo pacote de um repositório GitHub](https://learn.microsoft.com/vcpkg/examples/packaging-github-repos).

Nossos documentos agora também estão disponíveis online em nosso site <https://vcpkg.io/>. Nós realmente apreciamos todo e qualquer feedback! Você pode enviar um problema em <https://github.com/vcpkg/vcpkg.github.io/issues>.

Veja um [vídeo de demonstração](https://www.youtube.com/watch?v=y41WFKbQFTw) de 4 minutos.

# Contribuindo

Vcpkg é um projeto de código aberto e, portanto, é construído com suas contribuições.
Aqui estão algumas maneiras pelas quais você pode contribuir:

* [Enviar problemas][contributing:submit-issue] em vcpkg ou pacotes existentes
* [Enviar correções e novos pacotes][contributing:submit-pr]

Consulte nosso [Guia de contribuição](CONTRIBUTING.md) para obter mais detalhes.

Este projeto adotou o [Código de Conduta de Código Aberto da Microsoft][contributing:coc].
Para obter mais informações, consulte as [Perguntas frequentes sobre o Código de Conduta][contributing:coc-faq]
ou e-mail [opencode@microsoft.com](mailto:opencode@microsoft.com)
com quaisquer perguntas ou comentários adicionais.

[contribuindo:submit-issue]: https://github.com/microsoft/vcpkg/issues/new/choose
[contribuindo:submit-pr]: https://github.com/microsoft/vcpkg/pulls
[contribuindo:coc]: https://opensource.microsoft.com/codeofconduct/
[contribuindo:coc-faq]: https://opensource.microsoft.com/codeofconduct/

# Segurança

A maioria das portas no vcpkg compila as bibliotecas em questão usando o sistema de compilação original preferido
pelos desenvolvedores originais dessas bibliotecas e baixar o código-fonte e criar ferramentas de seus
locais de distribuição oficiais. Para uso atrás de um firewall, o acesso específico necessário dependerá
em quais portas estão sendo instaladas. Se você precisar instalar em um ambiente "air gap", considere
instalando uma vez em um ambiente sem "air gap", preenchendo um
[cache de ativos](https://learn.microsoft.com/vcpkg/users/assetcaching) compartilhado com o ambiente "air gapped".

# Telemetria

vcpkg coleta dados de uso para nos ajudar a melhorar sua experiência.
Os dados coletados pela Microsoft são anônimos.
Você pode cancelar a telemetria por
- executando o script bootstrap-vcpkg com -disableMetrics
- passando --disable-metrics para vcpkg na linha de comando
- definir a variável de ambiente VCPKG_DISABLE_METRICS

Leia mais sobre a telemetria vcpkg em [https://learn.microsoft.com/vcpkg/about/privacy](https://learn.microsoft.com/vcpkg/about/privacy).

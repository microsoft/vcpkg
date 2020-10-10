# Vcpkg: Vue d'ensemble

[中文总览](README_zh_CN.md)
[Español](README_es.md)

Vcpkg vous aides à gérer vos bibliothèques C et C++ sur Windows, Linux et MacOS.
L'outil et l'écosystème est en évolution constante, et nous apprécions vos contributions!

Si vous n'avez jamais utilisé vcpkg, ou si vous essayer d'utiliser vcpkg, regardez notre [introduction](#introduction) pour comprendre comment l'utiliser.

Pour une description des commandes disponibles, quand vous avez installé vcpkg, vous pouvez lancer `vcpkg help` ou `vcpkg help [commande]` pour de l'aide spécifique à une commande.


* Github: [https://github.com/microsoft/vcpkg](https://github.com/microsoft/vcpkg)
* Slack: [https://cppalliance.org/slack/](https://cppalliance.org/slack/), the #vcpkg channel
* Discord: [\#include \<C++\>](https://www.includecpp.org), le canal #🌏vcpkg
* Docs: [Documentation](docs/index.md)

[![Build Status](https://dev.azure.com/vcpkg/public/_apis/build/status/microsoft.vcpkg.ci?branchName=master)](https://dev.azure.com/vcpkg/public/_build/latest?definitionId=29&branchName=master)

# Sommaire

- [Vcpkg: Vue d'ensemble](#vcpkg-vue-d'ensemble)
- [Sommaire](#Sommaire)
- [Introduction](#introduction)
  - [Introduction Windows](#Introduction:-Windows)
  - [Introduction Unix](#Introduction-aux-Systèmes-Unix)
  - [Installer les pré requis pour linux](#installation-des-pré-requis-linux)
  - [Installer les pré requis pour macOS](#installation-des-pré-requis-macos) 
    - [Installer GCC pour macOS avant 10.15](#installer-gcc-pour-macos-avant-10.15)
    - [Utiliser vcpkg avec CMake](#utiliser-vcpkg-avec-cmake) 
      - [Visual Studio Code avec CMake Tools](#visual-studio-code-avec-cmake-tools)
      - [Vcpkg avec Visual Studio pour un projet CMake](#vcpkg-avec-visual-studio-un-projet-cmake)
      - [Vcpkg avec CLion](#vcpkg-avec-clion)
      - [Vcpkg en tant que sous module](#vcpkg-en-tant-que-sous-module)
    - [Tab-Completion/Auto-Completion](#tab-completionauto-completion)
    - [Exemples](#exemples)
    - [Contribuer](#contribuer)
    - [Licence](#licence)
    - [Télémétrie](#Télémétrie)
    
# Introduction

Premièrement, suivez le guide d'introduction [Windows](#Introduction:-Windows), où [macOS et Linux](#Unix), en fonction de vos besoins.

Pour plus d'information, regardez [utiliser des paquets][getting-started:utiliser-un-paquet].  
Si la bibliothèque dont vous avez besoin n'est pas présente dans la liste, vous pouvez [ouvrir une issue sur le repo github](contribuer:faire-une-issue) où l'équipe de vcpkg et la communauté peut le voir, et possiblmeent ajouter le port de vcpkg.
 
Après avoir installé et lancé vcpkg you pourriez voilà ajouter [l'auto completion](auto-completion) à votre shell.

Si vous êtes intéressé sur le future de vcpkg, regardez le guide du [manifeste][getting-started:manifest-spec]
C'est une fonctionnalité experimentale et possiblement bugé.
donc essayez d'[ouvrir des issues](contribuer:envoyer-une-issue)

# Introduction: Windows
Pré-requis:
  - Windows 7 ou plus
  - [Git][getting-started:git]
  + [Visual Studio][getting-started:visualstudio]  2015 mise à jour 3 où plus récente avec le pack de langue Anglais

  Premièrement, téléchargez et lancer le fichier bootstrap-vcpkg; il peut être installé n'importe où mais il est recommandé d'utiliser vcpkg pour des projets CMake, Nous recommendont ces chemins `C:\src\vcpkg` ou `C:\dev\vcpkg`, sinon vous pouriez avoir des problèmes de chemin pour certaines compilations.


```cmd
> git clone https://github.com/microsoft/vcpkg
> .\vcpkg\bootstrap-vcpkg.bat
```

Pour installer des bibliothèques pour votre projet, lancez:

```cmd
> .\vcpkg\vcpkg install [packages to install]
```

vous pouvez aussi chercher la bibliotèque dont vous avez besoin avec l'argument `search`:

```cmd
> .\vcpkg\vcpkg search [search term]
```


Pour utiliser vcpkg avec Visual Studio
lancez cette commande en administrateur

```cmd
> .\vcpkg\vcpkg integrate install
```

Après ça, vous pourrez l'utiliser dans des projets sans utiliser CMake

toutes les biblothèques installés sont directement prête à être `#include` et utilisé sans aucune configuration particulières.

Si ou utilisez CMake avec Visual Studio continuez [ici](#vcpkg-avec-cmake-et-visual-studio)

Pour utiliser vcpkg en dehors d'un IDE, vous pouvez utiliser le fichier de toolchain

```cmd
> cmake -B [build directory] -S . -DCMAKE_TOOLCHAIN_FILE=[path to vcpkg]/scripts/buildsystems/vcpkg.cmake
> cmake --build [build directory]
```

avec CMake, vous devrez utiliser `find_package` et `target_libraries` pour compiler.

regardez la [section CMake](#utiliser-vcpkg-avec-cmake) pour plus d'information ansi qu'utiliser CMake avec un IDE

Pour les autres éditeurs y compris Visual Studio Code regardez le [guide](getting-started:integration)


## Introduction aux Systèmes Unix

pré-requis pour Linux:
- [Git][getting-started:git]
- [g++][getting-started:linux-gcc] >= 6

pré-requis pour macOS:
- [outils de développeemnts apple][getting-started:macos-dev-tools]
- Pour macOS 10.14 et en dessous, vous aurez besoin de:
  - [Homebrew][getting-started:macos-brew]
  - [g++][getting-started:macos-gcc] >= 6

Premièrement clonez et lancer le bootstrap vcpkg; ça peut être installé n'importe ou mais il est recommandé de l'utiliser comme un sous module pour CMake

```sh
$ git clone https://github.com/microsoft/vcpkg
$ ./vcpkg/bootstrap-vcpkg.sh
```

Pour installer des bibliothèques pour votre projet, lancez:

```sh
$ ./vcpkg/vcpkg install [packages to install]
```

vous pouvez aussi chercher la bibliotèque dont vous avez besoin avec l'argument `search`:


```sh
$ ./vcpkg/vcpkg search [search term]
```

Pour utiliser vcpkg en dehors d'un IDE, vous pouvez utiliser le fichier de toolchain

```cmd
> cmake -B [build directory] -S . -DCMAKE_TOOLCHAIN_FILE=[path to vcpkg]/scripts/buildsystems/vcpkg.cmake
> cmake --build [build directory]
```

avec CMake, vous devrez utiliser `find_package` et `target_libraries` pour compiler.

regardez la [section CMake](#utiliser-vcpkg-avec-cmake) pour plus d'information ansi qu'utiliser CMake avec un IDE

Pour les autres éditeurs y compris Visual Studio Code regardez le [guide][getting-started:integration].

## Installation des pré requis linux

Pour les différentes distros linux, les noms des paquets sont différents vous aurez besoin de ces paquets pour l'installation:

- Debian, Ubuntu, popOS, et les autres bases debian:

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

Pour les autres distributions, installez au minimum g++ 6.
Si vous voulez ajouter des intrustructions spécifiques pour votre distro, [faites du PR][contribuer:faire-une-pr]!

## Installation des pré requis macOS

Pour macOS 1.15, la seule chose dont vous avez besoin est lancer cette commande:

```sh
$ xcode-select --install
```

En suite suivez les instructions qui vont s'afficher

Pour macOS 10.14 et les versions précédentes, vous aurez besoin d'installer g++ avec homebrew.
Svuiez les instructions dans la section suivante.

### Installer GCC pour macOS en desosus de 10.15

cette partie est seulement nécessaire if vous avez une version de macOS en dessous de 10.15.

Installer homebrew devrait être très simple pour plus d'informations allez sur  <brew.sh>, mais la seule commande dont vous avez besoin est:

```sh
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

Ensuite, installer gcc avec cette commande:

```sh
$ brew install gcc
```

Ensuite suivez l'[introduction Unix](#Introduction-aux-Systèmes-Unix)

## Utiliser vcpkg avec CMake

Si vous utilisez avec cmake la suite pourrait vous aider

## Visual Studio Code avec CMake tools

```json
{
  "cmake.configureSettings": {
    "CMAKE_TOOLCHAIN_FILE": "[vcpkg root]/scripts/buildsystems/vcpkg.cmake"
  }
}
```
### vcpkg avec visual studio un projet cmake

ouvrez les paramètres CMake, et ajouter le chemin ci-dessous à `CMake toolchain file`

```
[vcpkg root]/scripts/buildsystems/vcpkg.cmake
```

### Vcpkg avec CLion

ouvrez les paramètres de Toolchains 
(File > Settings on windows et linux, CLion > Preference pour macOS ensuite allez dans CMake ).
Dans Cmake options, ajouter la ligne suivante:


```
-DCMAKE_TOOLCHAIN_FILE=[vcpkg root]/scripts/buildsystems/vcpkg.cmake
```

Vous devrez le refaire pour chaque projet


### Vcpkg en tant que sous module

quand vous utilisez vcpkg comme un sous module de votre projet, vous pouvez l'ajouter au CMakeLists.txt avant le premier appel de `project()`, au lieu d'utiliser `CMAKE_TOOLCHAIN_FILE` dans les paramètres d'appel de cmake

```cmake
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/vcpkg/scripts/buildsystems/vcpkg.cmake
  CACHE STRING "Vcpkg toolchain file")
```

Cela n'empêche pas d'utiliser `CMAKE_TOOLCHAIN_FILE` directement par la commande cmake mais ça permet de simplifier la configuration.

[getting-started:utiliser-un-paquet]: docs/examples/installing-and-using-packages.md
[getting-started:integration]: docs/users/integration.md
[getting-started:git]: https://git-scm.com/downloads
[getting-started:cmake-tools]: https://marketplace.visualstudio.com/items?itemName=ms-vscode.cmake-tools
[getting-started:linux-gcc]: #installing-linux-developer-tools
[getting-started:macos-dev-tools]: #installing-macos-developer-tools
[getting-started:macos-brew]: #installing-gcc-on-macos
[getting-started:macos-gcc]: #installing-gcc-on-macos
[getting-started:visual-studio]: https://visualstudio.microsoft.com/
[getting-started:manifest-spec]: docs/specifications/manifests.md

# Tab-Completion/Auto-Completion

`vcpkg` supporte l'auto-completion des commandes, nom de paquets, et options dans powershell et bash.
pour activer la tab-completion dans le shell de votre choix:

```pwsh
> .\vcpkg integrate powershell
```

ou

```sh
$ ./vcpkg integrate bash
```

suivant le shell qui est utiliser, redémarrer la console

# Exemples

regarde la [documentation](doc/index.md) pour des instructions plus spécifiques ainsi que [l'installation et l'utilisation des paquets](docs/examples/installing-and-using-packages.md)
[ajouter un paquet depuis un fichier zip](docs/examples/packaging-zipfiles.md),
et [ajouter un nouveau paquet depuis un repo GitHub](docs/examples/packaging-github-repos.md).

La documentation est aussi disponible en ligne sur ReadTheDocs: <https://vcpkg.readthedocs.io/>!

regarde une démo de 4 minutes en anglais [video demo](https://www.youtube.com/watch?v=y41WFKbQFTw).

# Contribuer

Vcpkg est un projet opensource, et évolue avec vos contributions


* [créer Issues][contributing:submit-issue] in vcpkg or existing packages
* [proposer des fix et des nouveaux paquets  que vous faites][contributing:submit-pr]


s'il vous plait referez-vous au [ guide de contribution](CONTRIBUTING.md) pour plus de détails.


This project has adopted the [Microsoft Open Source Code of Conduct][contribuer:coc].
[contributing:submit-issue]: https://github.com/microsoft/vcpkg/issues/new/choose
[contributing:submit-pr]: https://github.com/microsoft/vcpkg/pulls
[contributing:coc]: https://opensource.microsoft.com/codeofconduct/
[contributing:coc-faq]: https://opensource.microsoft.com/codeofconduct/

# Licence
  Le code du repository est sous licence [MIT](LICENSE.txt)

# Télémétrie

vcpkg collecte des données pour nous aider à améliorer votre experience. Les données collecté par Microsoft sont anonymes.
vous pouvez désactiver la télémétrie en relançant le bootstrap-vcpkg avec l'argument `-disableMetrics`, passer l'argument `--disable-metrics` à chaque execution de vcpkg, ou en créant une variable d'environnement nommé `VCPKG_DISABLE_METRICS`;

Vous trouverez plus d'informations à propos de la télémétrie dans vcpkg sur cette [page](docs/about/privacy.md)
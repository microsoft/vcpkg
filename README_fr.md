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
    - [Utiliser vcpkg avec CMake](#utiliser+vcpkg-avec-cmake) 
      - [Visual Studio Code avec CMake Tools](#visual-studio-code-avec-cmake-tools)
      - [Vcpkg avec Visual Studio pour un projet CMake](#vcpkg-avec-visual-studio-un-projet-cmake)
      - [Vcpkg avec CLion](#vcpkg-avec-clion)
      - [Vcpkg en tant que sous module](Vcpkg en-tant-que-sous-module)
    - [Tab-Completion/Auto-Completion](#tab-completionauto-completion)
    - [Exemples](#exemples)
    - [Contribuer](#contribuer)
    - [Licence](#licence)
    - [Télémétrie](#Télémétrie)
    
# Introduction

Premièrement, suivez le guide d'introduction [Windows](#Introduction:-Windows), où [macOS et Linux](#Unix), en fonction de vos besoins.

Pour plus d'information, regardez [Installer et utiliser des paquets](installer-et-utiliser-des-paquets).  
Si la bibliothèque dont vous avez besoin n'est pas présente dans la liste, vous pouvez [ouvrir une issue sur le repo github](contribuer:faire-une-issue) où l'équipe de vcpkg et la communauté peut le voir, et possiblmeent ajouter le port de vcpkg.
 
Après avoir installé et lancé vcpkg you pourriez voilà ajouter [l'auto completion](auto-completion) à votre shell.

Si vous êtes intéressé sur le future de vcpkg, regardez le guide du [manifeste](introduction:spec-manifeste) 
C'est une fonctionnalité experimentale et possiblement bugé.
donc essayez d'[ouvrir des issues](contribuer:envoyer-une-issue)

# Introduction: Windows
Pré-requis:
  - Windows 7 ou plus
  - [Git](introduction-:-git)
  + [Visual Studio](introduction-:-visual-studio)  2015 mise à jour 3 où plus récente avec le pack de langue Anglais

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

If ou utilisez CMake avec Visual Studio continuez [ici](#vcpkg-avec-cmake-et-visual-studio)

Pour utiliser vcpkg en dehors d'un IDE, vous pouvez utiliser le fichier de toolchain

```cmd
> cmake -B [build directory] -S . -DCMAKE_TOOLCHAIN_FILE=[path to vcpkg]/scripts/buildsystems/vcpkg.cmake
> cmake --build [build directory]
```

avec CMake, vous devrez utiliser `find_package` et `target_libraries` pour compiler.

regardez la [section CMake](#utiliser-vcpkg-avec-cmake) pour plus d'information ansi qu'utiliser CMake avec un IDE

Pour les autres éditeurs y compris Visual Studio Code regardez le [guide](#introduction:integration)


## Introduction aux Systèmes Unix

pré-requis pour Linux:
- [Git][introduction-à-git:git]
- [g++][introduction-à-gcc:linux-gcc] >= 6

pré-requis pour macOS:
- [Apple avec XCode][introduction:-macOS]
- Pour macOS 10.14 et en dessous, vous aurez besoin de:
  - [Homebrew][macOS-avec-brew]
  - [g++][macOS-avec-gcc] >= 6

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

Pour les autres éditeurs y compris Visual Studio Code regardez le [guide](#introduction:integration).

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


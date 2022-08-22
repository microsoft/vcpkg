# Vcpkg: Vue d'ensemble

[中文总览](README_zh_CN.md)
[Español](README_es.md)

Vcpkg vous aide à gérer vos bibliothèques C et C++ sur Windows, Linux et MacOS.
L'outil et l'écosystème sont en évolution constante, et nous apprécions vos contributions!

Si vous n'avez jamais utilisé vcpkg, ou si vous essayez d'utiliser vcpkg, lisez notre [introduction](#introduction) pour comprendre comment l'utiliser.

Pour une description des commandes disponibles, quand vous avez installé vcpkg, vous pouvez lancer `vcpkg help` ou `vcpkg help [commande]` pour de l'aide spécifique à une commande.


* Github: [https://github.com/microsoft/vcpkg](https://github.com/microsoft/vcpkg)
* Slack: [https://cppalliance.org/slack/](https://cppalliance.org/slack/), the #vcpkg channel
* Discord: [\#include \<C++\>](https://www.includecpp.org), le canal #🌏vcpkg
* Docs: [Documentation](docs/README.md)

[![Build Status](https://dev.azure.com/vcpkg/public/_apis/build/status/microsoft.vcpkg.ci?branchName=master)](https://dev.azure.com/vcpkg/public/_build/latest?definitionId=29&branchName=master)

# Sommaire

- [Vcpkg: Vue d'ensemble](#vcpkg-vue-d'ensemble)
- [Sommaire](#Sommaire)
- [Introduction](#introduction)
  - [Introduction Windows](#Introduction:-Windows)
  - [Introduction Unix](#Introduction-aux-Systèmes-Unix)
  - [Installer les prérequis pour linux](#installation-des-prérequis-linux)
  - [Installer les prérequis pour macOS](#installation-des-prérequis-macos) 
    - [Installer GCC pour macOS avant 10.15](#installer-gcc-pour-macos-avant-10.15)
    - [Utiliser vcpkg avec CMake](#utiliser-vcpkg-avec-cmake) 
      - [Visual Studio Code avec CMake Tools](#visual-studio-code-avec-cmake-tools)
      - [Vcpkg avec Visual Studio pour un projet CMake](#vcpkg-avec-visual-studio-un-projet-cmake)
      - [Vcpkg avec CLion](#vcpkg-avec-clion)
      - [Vcpkg en tant que sous module](#vcpkg-en-tant-que-sous-module)
    - [Tab-Completion/Auto-Completion](#tab-complétionauto-complétion)
    - [Exemples](#exemples)
    - [Contribuer](#contribuer)
    - [Licence](#licence)
    - [Télémétrie](#Télémétrie)
    
# Introduction

Premièrement, suivez le guide d'introduction [Windows](#Introduction:-Windows), ou [macOS et Linux](#Unix), en fonction de vos besoins.

Pour plus d'information, regardez [utiliser des paquets][getting-started:utiliser-un-paquet].  
Si la bibliothèque dont vous avez besoin n'est pas présente dans la liste, vous pouvez [ouvrir une issue sur le repo github](contribuer:faire-une-issue) où l'équipe de vcpkg et la communauté peuvent le voir, et possiblement ajouter le port de vcpkg.
 
Après avoir installé et lancé vcpkg vous pourriez vouloir ajouter [l'auto-complétion](auto-completion) à votre shell.

Si vous êtes intéressé par le futur de vcpkg, regardez le guide du [manifeste][getting-started:manifest-spec] !
C'est une fonctionnalité expérimentale et possiblement boguée, donc essayez d'[ouvrir des issues](contribuer:envoyer-une-issue) !

# Introduction: Windows
Prérequis :
  - Windows 7 ou plus
  - [Git][getting-started:git]
  + [Visual Studio][getting-started:visualstudio] 2015 mise à jour 3 où plus récente avec le pack de langue Anglais

Premièrement, téléchargez et lancer le fichier bootstrap-vcpkg; il peut être installé n'importe où mais il est recommandé d'utiliser vcpkg pour des projets CMake. Nous recommandons ces chemins `C:\src\vcpkg` ou `C:\dev\vcpkg`, sinon vous pourriez avoir des problèmes de chemin pour certaines compilations.


```cmd
> git clone https://github.com/microsoft/vcpkg
> .\vcpkg\bootstrap-vcpkg.bat
```

Pour installer des bibliothèques pour votre projet, lancez:

```cmd
> .\vcpkg\vcpkg install [paquets à installer]
```

Vous pouvez aussi chercher la bibliothèque dont vous avez besoin avec l'argument `search`:

```cmd
> .\vcpkg\vcpkg search [terme de recherche]
```


Pour utiliser vcpkg avec Visual Studio, lancez cette commande (pourrait nécessiter d'être lancée avec les droits administrateur)

```cmd
> .\vcpkg\vcpkg integrate install
```

Ensuite, vous pouvez créer un nouveau projet n'utilisant pas CMake (ou en ouvrir un préexistant). 
Toutes les bibliothèques installées sont directement prêtes à être `#include` et utilisées sans davantage de configuration.

Si vous utilisez CMake avec Visual Studio continuez [ici](#vcpkg-avec-cmake-et-visual-studio).

Afin d'utiliser vcpkg en dehors d'un IDE, vous pouvez utiliser le fichier de toolchain :

```cmd
> cmake -B [dossier de build] -S . "-DCMAKE_TOOLCHAIN_FILE=[chemin vers vcpkg]/scripts/buildsystems/vcpkg.cmake"
> cmake --build [dossier de build]
```

Avec CMake, vous devrez utiliser `find_package` notamment, et autres, pour compiler.

Regardez la [section CMake](#utiliser-vcpkg-avec-cmake) pour plus d'information, notamment utiliser CMake avec un IDE.

Pour les autres éditeurs, y compris Visual Studio Code regardez le [guide d'intégration](getting-started:integration).


## Introduction aux Systèmes Unix

Prérequis pour Linux :
- [Git][getting-started:git]
- [g++][getting-started:linux-gcc] >= 6

Prérequis pour macOS:
- [Outils de développement Apple][getting-started:macos-dev-tools]
- Pour macOS 10.14 et en dessous, vous aurez besoin de:
  - [Homebrew][getting-started:macos-brew]
  - [g++][getting-started:macos-gcc] >= 6

Premièrement, clonez et lancez le bootstrap vcpkg; il peut être installé n'importe où mais il est recommandé de l'utiliser comme un sous-module pour projets CMake.

```sh
$ git clone https://github.com/microsoft/vcpkg
$ ./vcpkg/bootstrap-vcpkg.sh
```

Pour installer des bibliothèques pour votre projet, lancez :

```sh
$ ./vcpkg/vcpkg install [paquets à installer]
```

Vous pouvez aussi chercher la bibliothèque dont vous avez besoin avec l'argument `search` :


```sh
$ ./vcpkg/vcpkg search [terme de recherche]
```

Pour utiliser vcpkg en dehors d'un IDE, vous pouvez utiliser le fichier de toolchain :

```cmd
> cmake -B [dossier de build] -S . "-DCMAKE_TOOLCHAIN_FILE=[chemin vers vcpkg]/scripts/buildsystems/vcpkg.cmake"
> cmake --build [dossier de build]
```

Avec CMake, vous devrez utiliser `find_package` notamment, et autres, pour compiler.

Lisez la [section CMake](#utiliser-vcpkg-avec-cmake) pour plus d'information, notamment utiliser CMake avec un IDE.

Pour les autres éditeurs, y compris Visual Studio Code lisez le [guide d'intégration][getting-started:integration].

## Installation des prérequis linux

Pour les différentes distros Linux, il y a différents paquets que vous aurez besoin d'installer :

- Debian, Ubuntu, popOS, et les autres distros basées sur Debian :

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
Si vous voulez ajouter des instructions spécifiques pour votre distro, [ouvrez une PR svp][contribuer:faire-une-pr] !

## Installation des prérequis macOS

Pour macOS 10.15, la seule chose dont vous avez besoin est de lancer cette commande :

```sh
$ xcode-select --install
```

Ensuite suivez les instructions qui s'afficheront dans la fenêtre.

Pour macOS 10.14 et les versions précédentes, vous aurez besoin d'installer g++ avec homebrew; suivez les instructions dans la section suivante.

### Installer GCC pour macOS antérieur à 10.15

Cette partie est seulement nécessaire si vous avez une version de macOS antérieure à 10.15.

Installer homebrew devrait être très simple; pour plus d'informations allez sur <brew.sh>, mais le plus simple est de lancer la commande suivante :

```sh
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

Ensuite, afin d'obtenir une version à jour de gcc, lancez la commande suivante :

```sh
$ brew install gcc
```

Ensuite suivez l'[introduction Unix](#Introduction-aux-Systèmes-Unix)

## Utiliser vcpkg avec CMake

Si vous utilisez vcpkg avec CMake, la suite pourrait vous aider !

## Visual Studio Code avec CMake tools

```json
{
  "cmake.configureSettings": {
    "CMAKE_TOOLCHAIN_FILE": "[vcpkg root]/scripts/buildsystems/vcpkg.cmake"
  }
}
```
### Vcpkg avec des projets CMake Visual Studio

Ouvrez les paramètres CMake, et ajoutez le chemin ci-dessous à `CMake toolchain file` :

```
[vcpkg root]/scripts/buildsystems/vcpkg.cmake
```

### Vcpkg avec CLion

Ouvrez les paramètres de Toolchains (File > Settings sur Windows et Linux, CLion > Preference pour macOS) et allez dans les paramètres CMake (Build, Execution, Deployment > CMake).
Finalement, dans `CMake options`, ajoutez la ligne suivante :

```
-DCMAKE_TOOLCHAIN_FILE=[vcpkg root]/scripts/buildsystems/vcpkg.cmake
```

Malheureusement, vous devrez le refaire pour chaque projet.


### Vcpkg en tant que sous-module

Quand vous utilisez vcpkg comme un sous-module de votre projet, vous pouvez l'ajouter à votre CMakeLists.txt avant le premier appel de `project()`, au lieu d'utiliser `CMAKE_TOOLCHAIN_FILE` dans les paramètres d'appel de cmake.

```cmake
set(CMAKE_TOOLCHAIN_FILE "${CMAKE_CURRENT_SOURCE_DIR}/vcpkg/scripts/buildsystems/vcpkg.cmake"
  CACHE STRING "Vcpkg toolchain file")
```

Cela permettra toujours aux gens de ne pas utiliser vcpkg, en passant directement le CMAKE_TOOLCHAIN_FILE, mais cela rendra l'étape de configuration-construction légèrement plus facile.

[getting-started:utiliser-un-paquet]: docs/examples/installing-and-using-packages.md
[getting-started:integration]: docs/users/buildsystems/integration.md
[getting-started:git]: https://git-scm.com/downloads
[getting-started:cmake-tools]: https://marketplace.visualstudio.com/items?itemName=ms-vscode.cmake-tools
[getting-started:linux-gcc]: #installing-linux-developer-tools
[getting-started:macos-dev-tools]: #installing-macos-developer-tools
[getting-started:macos-brew]: #installing-gcc-on-macos
[getting-started:macos-gcc]: #installing-gcc-on-macos
[getting-started:visual-studio]: https://visualstudio.microsoft.com/
[getting-started:manifest-spec]: docs/specifications/manifests.md

# Tab-complétion/Auto-complétion

`vcpkg` supporte l'auto-complétion des commandes, nom de paquets, et options dans powershell et bash.
Pour activer la tab-complétion dans le shell de votre choix :

```pwsh
> .\vcpkg integrate powershell
```

ou

```sh
$ ./vcpkg integrate bash
```

selon le shell que vous utilisez, puis redémarrez la console.

# Exemples

Lisez la [documentation](doc/README.md) pour des instructions plus spécifiques ainsi que [l'installation et l'utilisation des paquets](docs/examples/installing-and-using-packages.md),
[ajouter un nouveau paquet depuis un fichier zip](docs/examples/packaging-zipfiles.md),
et [ajouter un nouveau paquet depuis un dépôt GitHub](docs/examples/packaging-github-repos.md).

La documentation est aussi disponible en ligne sur ReadTheDocs : <https://vcpkg.readthedocs.io/> !

Regardez une [démo vidéo]((https://www.youtube.com/watch?v=y41WFKbQFTw) de 4 minutes en anglais.

# Contribuer

Vcpkg est un projet open source, et évolue ainsi avec vos contributions. 
Voici quelques moyens pour vous d'y contribuer :
* [Soumettre des Issues][contributing:submit-issue] sur vcpkg ou des paquets existants
* [Proposer des corrections et de nouveaux paquets][contributing:submit-pr]


Veuillez vous référer au [guide de contribution](CONTRIBUTING.md) pour plus de détails.


Ce projet a adopté le [Code de Conduite Open Source de Microsoft][contribuer:coc].
[contributing:submit-issue]: https://github.com/microsoft/vcpkg/issues/new/choose
[contributing:submit-pr]: https://github.com/microsoft/vcpkg/pulls
[contributing:coc]: https://opensource.microsoft.com/codeofconduct/
[contributing:coc-faq]: https://opensource.microsoft.com/codeofconduct/

# Licence
Le code sur ce dépôt est distribué sous [licence MIT](LICENSE.txt).

# Télémétrie

vcpkg collecte des données pour nous aider à améliorer votre expérience.
Les données collectées par Microsoft sont anonymes.
Vous pouvez désactiver la télémétrie en relançant le bootstrap-vcpkg avec l'argument `-disableMetrics`, passer l'argument `--disable-metrics` à chaque exécution de vcpkg, ou en créant une variable d'environnement nommée `VCPKG_DISABLE_METRICS`.

Vous trouverez plus d'informations à propos de la télémétrie dans vcpkg sur cette [page](docs/about/privacy.md).

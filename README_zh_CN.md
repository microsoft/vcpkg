# Vcpkg: 总览

[English Overview](README.md)

Vcpkg 可帮助您在 Windows、 Linux 和 MacOS 上管理 C 和 C++ 库。
这个工具和生态链正在不断发展，我们一直期待您的贡献！

若您从未使用过vcpkg或希望了解如何使用vcpkg，请查阅[快速开始](#入门)章节。

如需获取有关可用命令的简短描述，请在编译vcpkg后执行 `vcpkg help` 或执行 `vcpkg help [command]` 来获取具体的帮助信息。

* Github: [https://github.com/microsoft/vcpkg](https://github.com/microsoft/vcpkg)
* Slack: [https://cppalliance.org/slack/](https://cppalliance.org/slack/)， #vcpkg 频道
* Discord: [\#include \<C++\>](https://www.includecpp.org)， #🌏vcpkg 频道
* 文档: [Documentation](docs/index.md)

[![当前生成状态](https://dev.azure.com/vcpkg/public/_apis/build/status/microsoft.vcpkg.ci?branchName=master)](https://dev.azure.com/vcpkg/public/_build/latest?definitionId=29&branchName=master)

# 目录

- [Vcpkg: 总览](#vcpkg-总览)
- [目录](#目录)
- [入门](#入门)
  - [快速开始: Windows](#快速开始-windows)
  - [快速开始: Unix](#快速开始-unix)
  - [安装 Linux Developer Tools](#安装-linux-developer-tools)
  - [安装 macOS Developer Tools](#安装-macos-developer-tools)
    - [在 macOS 10.15 之前版本中安装 GCC](#在-macos-1015-之前版本中安装-gcc)
  - [在 CMake 中使用 vcpkg](#在-cmake-中使用-vcpkg)
    - [Visual Studio Code 中的 CMake Tools](#visual-studio-code-中的-cmake-tools)
    - [Visual Studio CMake 工程中使用 vcpkg](#visual-studio-cmake-工程中使用-vcpkg)
    - [CLion 中使用 vcpkg](#clion-中使用-vcpkg)
    - [将 vcpkg 作为一个子模块](#将-vcpkg-作为一个子模块)
  - [快速开始: 清单](#快速开始-清单)
- [Tab补全/自动补全](#tab补全自动补全)
  - [示例](#示例)
  - [贡献者](#贡献者)
- [License](#license)
- [数据收集](#数据收集)

# 入门

首先，请阅读以下任一方面的快速入门指南：
[Windows](#快速开始-windows) 或 [macOS和Linux](#快速开始-unix)，
这取决于您使用的是什么平台。

有关更多信息，请参见 [安装和使用软件包][getting-started:using-a-package]。
如果vcpkg目录中没有您需要的库，
您可以 [在GitHub上打开问题][contributing:submit-issue]。
vcpkg团队和贡献者可以看到它的地方，
并可能将这个库添加到vcpkg。

安装并运行vcpkg后，
您可能希望将 [TAB补全](#tab补全自动补全) 添加到您的Shell中。

最后，如果您对vcpkg的未来感兴趣，请查看 [清单](#快速开始-清单)！
这是一项实验性功能，可能会出现错误。
因此，请尝试一下并[打开所有问题][contributing:submit-issue]!

## 快速开始: Windows

需求:
- Windows 7 或更新的版本
- [Git][getting-started:git]
- [Visual Studio 2015 Update 3][getting-started:visual-studio] 或更新的版本（包含英文语言包）

首先，请下载vcpkg并执行 bootstrap.bat 脚本。
它可以安装在任何地方，但是通常我们建议您使用 vcpkg 作为 CMake 项目的子模块，并将其全局安装到 Visual Studio 项目中。
我们建议您使用例如 `C:\src\vcpkg` 或 `C:\dev\vcpkg` 的安装目录，否则您可能遇到某些库构建系统的路径问题。

```cmd
> git clone https://github.com/microsoft/vcpkg
> .\vcpkg\bootstrap-vcpkg.bat
```

使用以下命令安装您的项目所需要的库：

```cmd
> .\vcpkg\vcpkg install [packages to install]
```

您也可以使用 `search` 子命令来查找vcpkg中集成的库:

```cmd
> .\vcpkg\vcpkg search [search term]
```

若您希望在 Visual Studio 中使用vcpkg，请运行以下命令 (首次启动需要管理员权限)

```cmd
> .\vcpkg\vcpkg integrate install
```

在此之后，您可以创建一个非cmake项目 (或打开已有的项目)。
在您的项目中，所有已安装的库均可立即使用 `#include` 包含您需使用的库的头文件并无需添加额外配置。

若您在 Visual Studio 中使用cmake工程，请查阅[这里](#visual-studio-cmake-工程中使用-vcpkg)。

为了在IDE以外在cmake中使用vcpkg，您需要使用以下工具链文件:

```cmd
> cmake -B [build directory] -S . -DCMAKE_TOOLCHAIN_FILE=[path to vcpkg]/scripts/buildsystems/vcpkg.cmake
> cmake --build [build directory]
```

在cmake中，您仍需通过 `find_package` 来使用第三方库。
请查阅 [CMake 章节](#在-cmake-中使用-vcpkg) 获取更多信息，其中包含了在IDE中使用cmake的内容。

对于其他工具 (包括Visual Studio Code)，请查阅 [集成指南][getting-started:integration]。

## 快速开始: Unix

Linux平台的使用需求:
- [Git][getting-started:git]
- [g++][getting-started:linux-gcc] >= 6

macOS平台的使用需求:
- [Apple Developer Tools][getting-started:macos-dev-tools]
- macOS 10.14 或更低版本中，您也需要:
  - [Homebrew][getting-started:macos-brew]
  - Homebrew 中 [g++][getting-started:macos-gcc] >= 6

首先，请下载vcpkg并执行 bootstrap.sh 脚本。
我们建议您将vcpkg作为cmake项目的子模块使用。

```sh
$ git clone https://github.com/microsoft/vcpkg
$ ./vcpkg/bootstrap-vcpkg.sh
```

使用以下命令安装任意包：

```sh
$ ./vcpkg/vcpkg install [packages to install]
```

您也可以使用 `search` 子命令来查找vcpkg中已集成的库:

```sh
$ ./vcpkg/vcpkg search [search term]
```

为了在cmake中使用vcpkg，您需要使用以下工具链文件:

```sh
$ cmake -B [build directory] -S . -DCMAKE_TOOLCHAIN_FILE=[path to vcpkg]/scripts/buildsystems/vcpkg.cmake
$ cmake --build [build directory]
```

在cmake中，您仍需通过 `find_package` 来使用第三方库。
为了您更好的在cmake或 VSCode CMake Tools 中使用vcpkg，
请查阅 [CMake 章节](#在-cmake-中使用-vcpkg) 获取更多信息，
其中包含了在IDE中使用cmake的内容。

对于其他工具，请查阅 [集成指南][getting-started:integration]。

## 安装 Linux Developer Tools

在Linux的不同发行版中，您需要安装不同的工具包:

- Debian，Ubuntu，popOS或其他基于 Debian 的发行版:

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

对于其他的发行版，请确保已安装 g++ 6 或更新的版本。
若您希望添加特定发行版的说明，[请提交一个 PR][contributing:submit-pr]!

## 安装 macOS Developer Tools

在 macOS 10.15 中，唯一需要做的是在终端中运行以下命令:

```sh
$ xcode-select --install
```

然后按照出现的窗口中的提示进行操作。

在 macOS 10.14 及先前版本中，您也需要使用 homebrew 安装 g++。
请遵循以下部分中的说明：

### 在 macOS 10.15 之前版本中安装 GCC

此条只在您的macOS版本低于 10.15 时是必须的。
安装homebrew应当很轻松，请查阅 <brew.sh> 以获取更多信息。
为了更简便，请使用以下命令:

```sh
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
```

然后，为了获取最新版本的gcc，请运行以下命令：

```sh
$ brew install gcc
```

此时，您就可以使用 bootstrap.sh 编译vcpkg了。 请参阅 [快速开始](#快速开始-unix)

## 在 CMake 中使用 vcpkg

若您希望在CMake中使用vcpkg，以下内容可能帮助您：

### Visual Studio Code 中的 CMake Tools

将以下内容添加到您的工作区的 `settings.json` 中将使CMake Tools自动使用vcpkg中的第三方库:

```json
{
  "cmake.configureSettings": {
    "CMAKE_TOOLCHAIN_FILE": "[vcpkg root]/scripts/buildsystems/vcpkg.cmake"
  }
}
```

### Visual Studio CMake 工程中使用 vcpkg

打开CMake设置选项，将 vcpkg toolchain 文件路径在 `CMake toolchain file` 中：

```
[vcpkg root]/scripts/buildsystems/vcpkg.cmake
```

### CLion 中使用 vcpkg

打开 Toolchains 设置
(File > Settings on Windows and Linux, CLion > Preferences on macOS)，
并打开 CMake 设置 (Build, Execution, Deployment > CMake)。
最后在 `CMake options` 中添加以下行:

```
-DCMAKE_TOOLCHAIN_FILE=[vcpkg root]/scripts/buildsystems/vcpkg.cmake
```

遗憾的是，您必须手动将此选项加入每个项目配置文件中。

### 将 vcpkg 作为一个子模块

当您希望将vcpkg作为一个子模块加入到您的工程中时，
您可以在第一个 `project()` 调用之前将以下内容添加到 CMakeLists.txt 中，
而无需将 `CMAKE_TOOLCHAIN_FILE` 传递给cmake调用。

```cmake
set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/vcpkg/scripts/buildsystems/vcpkg.cmake
  CACHE STRING "Vcpkg toolchain file")
```

使用此种方式可无需设置 `CMAKE_TOOLCHAIN_FILE` 即可使用vcpkg，且更容易完成配置工作。

## 快速开始: 清单

如果您期待vcpkg在未来会更好，我们真的很感激😄。
但是，首先要警告：vcpkg中的清单支持仍处于beta中！
通常，vcpkg可以正常工作，但您很可能会在使用时遇到至少一个或两个错误。
另外，我们可能会在稳定之前更改vcpkg的各个功能，请提前知悉。
如果您遇到任何错误，请[提交一个issue][contributing:submit-issue]！

首先，在 [Windows](#快速开始-windows) 或 [Unix](#快速开始-unix) 正常安装vcpkg。
您可能希望将vcpkg安装在常用的位置，由于安装的目录位于本地，并且可以从同一vcpkg目录中同时运行多个vcpkg命令。

然后，您必须通过将 `manifests` 添加到以逗号分隔的 `--feature-flags` 选项中来打开 `manifests` vcpkg功能标记，
或将其添加到以逗号分隔的 `VCPKG_FEATURE_FLAGS` 环境变量中。

您也可能希望添加vcpkg路径至环境变量 `PATH` 中。
这时，我们要做的就是创建清单。
创建一个名为 `vcpkg.json` 的文件，然后添加以下内容：

```json
{
  "name": "<name of your project>",
  "version-string": "<version of your project>",
  "dependencies": [
    "abseil",
    "boost"
  ]
}
```

您所安装的库将生成在 `vcpkg_installed` 文件夹中，并与您的 `vcpkg.json` 所在的文件夹相同。
如果您可以使用常规的 CMake toolchain 或 Visual Studio / MSBuild 集成，
它将自动安装依赖项，您需要将MSBuild的 `VcpkgManifestEnabled` 设置为 `On`。
如果您希望不使用 CMake 或 MSBuild 来安装依赖项，您可以使用命令 `vcpkg install --feature-flags = manifests` 。

请查阅 [清单][getting-started:manifest-spec] 获取更多信息。

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

# Tab补全/自动补全

`vcpkg` 支持命令，包名称，以及 Powershell 和 Bash 中的选项。
若您需要在指定的 shell 中启用Tab补全功能，请依据您使用的shell运行：

```pwsh
> .\vcpkg integrate powershell
```

或

```sh
$ ./vcpkg integrate bash
```

然后重新启动控制台。

## 示例

请查看 [文档](docs/index.md) 获取具体示例，
其包含 [安装并使用包](docs/examples/installing-and-using-packages.md)，
[使用压缩文件添加包](docs/examples/packaging-zipfiles.md)
和 [从GitHub源中添加一个包](docs/examples/packaging-github-repos.md)。

我们的文档现在也可以从 [ReadTheDocs](https://vcpkg.readthedocs.io/) 在线获取。

观看4分钟 [demo视频](https://www.youtube.com/watch?v=y41WFKbQFTw)。

## 贡献者

Vcpkg是一个开源项目，并通过您的贡献不断发展。
下面是一些您可以贡献的方式:

* [提交一个关于vcpkg或已支持包的新issue][contributing:submit-issue]
* [提交修复PR和创建新包][contributing:submit-pr]

请参阅我们的 [贡献准则](CONTRIBUTING.md) 了解更多详细信息。

该项目采用了 [Microsoft开源行为准则][contributing:coc]。
获取更多信息请查看 [行为准则FAQ][contributing:coc-faq] 或联系 [opencode@microsoft.com](mailto:opencode@microsoft.com)提出其他问题或意见。

[contributing:submit-issue]: https://github.com/microsoft/vcpkg/issues/new/choose
[contributing:submit-pr]: https://github.com/microsoft/vcpkg/pulls
[contributing:coc]: https://opensource.microsoft.com/codeofconduct/
[contributing:coc-faq]: https://opensource.microsoft.com/codeofconduct/

# License

在此存储库中使用的代码均遵循 [MIT License](LICENSE.txt)。

# 数据收集

vcpkg会收集使用情况数据，以帮助我们改善您的体验。
Microsoft收集的数据是匿名的。
您也可以通过使用 `-disableMetrics` 、在命令行上将`--disable-metrics`传递给vcpkg，或通过设置环境变量 `VCPKG_DISABLE_METRICS` 并重新运行 bootstrap-vcpkg 脚本来选择禁用数据收集。
请在 [privacy.md](docs/about/privacy.md) 中了解有关 vcpkg 数据收集的更多信息。

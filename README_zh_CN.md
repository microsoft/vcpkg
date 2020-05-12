# Vcpkg

## 概要
Vcpkg 可帮助您在 Windows、Linux 和 MacOS 上管理 C 和 C++ 库。这个工具和生态系统正在不断发展，您的参与对它的成功至关重要！

如需获取有关可用命令的简短描述， 请执行 `vcpkg help`。

## 快速开始
需求:
- Windows 10、8.1、7、Linux、或 MacOS
- Visual Studio 2015 Update 3 或更新的版本 (Windows 中)
- Git
- *可选:* CMake 3.12.4

如何开始:
```
> git clone https://github.com/Microsoft/vcpkg.git
> cd vcpkg

PS> .\bootstrap-vcpkg.bat
Linux:~/$ ./bootstrap-vcpkg.sh
```

然后，[集成](docs/users/integration.md)至本机环境中，执行 (注意: 首次启动需要管理员权限)
```
PS> .\vcpkg integrate install
Linux:~/$ ./vcpkg integrate install
```

使用以下命令安装任意包
```
PS> .\vcpkg install sdl2 curl
Linux:~/$ ./vcpkg install sdl2 curl
```

与CMake一起使用已安装库的最佳方法是通过工具链文件 `scripts\buildsystems\vcpkg.cmake`。要使用此文件，您只需将 `-DCMAKE_TOOLCHAIN_FILE=[vcpkg root]\scripts\buildsystems\vcpkg.cmake` 作为参数添加到CMake命令行中。

在Visual Studio中，您可以创建一个新项目(或打开一个已有项目)。所有已安装的库都可以使用 `#include` 在您的项目中使用，而无需进行其他配置。

若需获取更多信息，请查看[使用一个包](docs/examples/installing-and-using-packages.md)具体示例。 若您需要使用的库不在vcpkg中，请[在GitHub上创建一个issue](https://github.com/microsoft/vcpkg/issues) ，开发团队和贡献者会看到它，并有可能为此库创建端口文件。

有关 macOS 和 Linux 支持的其他说明，请参见[官方公告](https://blogs.msdn.microsoft.com/vcblog/2018/04/24/announcing-a-single-c-library-manager-for-linux-macos-and-windows-vcpkg/)。

## Tab补全/自动补全
`vcpkg`支持在 Powershell 和 bash 中自动补全命令、程序包名称、选项等。如需启用自动补全功能，请使用以下命令:
```
PS> .\vcpkg integrate powershell
Linux:~/$ ./vcpkg integrate bash
```
并重启您的控制台。


## 示例
请查看[文档](docs/index.md)获取具体示例，其包含[安装并使用包](docs/examples/installing-and-using-packages.md)，[使用压缩文件添加包](docs/examples/packaging-zipfiles.md)，和[从GitHub源中添加一个包](docs/examples/packaging-github-repos.md)。

我们的文档现在也可以从[ReadTheDocs](https://vcpkg.readthedocs.io/)在线获取。

观看4分钟[demo视频](https://www.youtube.com/watch?v=y41WFKbQFTw)。

## 贡献者
Vcpkg通过您的贡献不断发展。下面是一些您可以贡献的方式:

* 创建一个关于vcpkg或已支持包的[新issue](https://github.com/Microsoft/vcpkg/issues)
* [创建修复PR和创建新包](https://github.com/Microsoft/vcpkg/pulls)

请参阅我们的[贡献准则](CONTRIBUTING.md)了解更多详细信息。

该项目采用了[Microsoft开源行为准则](https://opensource.microsoft.com/codeofconduct/)。获取更多信息请查看 [行为准则FAQ](https://opensource.microsoft.com/codeofconduct/faq/)或联系[opencode@microsoft.com](mailto:opencode@microsoft.com)提出其他问题或意见。

## License

使用的代码 License 为[MIT License](LICENSE.txt)。

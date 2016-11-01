# Vcpkg

## Overview
Vcpkg helps you get C and C++ libraries on Windows. This tool and ecosystem are currently in a preview state; your involvement is vital to its success.

For short description of available commands, run `vcpkg help`.

## Quick Start
If there is no `vcpkg.exe` (such as after a `git clone`), run
```
C:\src\vcpkg> powershell -exec bypass scripts\bootstrap.ps1
```
Then, to hook up user-wide integration, run (note: requires admin on first use)
```
C:\src\vcpkg> .\vcpkg integrate install
```
Install any packages with
```
C:\src\vcpkg> .\vcpkg install sdl2 curl
```
Finally, create a New Project (or open an existing one) in Visual Studio 2015. You can now `#include` and use any of the installed libraries.

## Examples
See the [`docs\EXAMPLES.md`](docs/EXAMPLES.md) document for specific walkthroughs, including using a package and adding a new package.

See a 4 mm [demo in video](https://www.youtube.com/watch?v=y41WFKbQFTw).

## Contributing
Vcpkg is built with your contributions. Here are some ways you can contribute:

* [Submit Issues](https://github.com/Microsoft/vcpkg/issues) in vcpkg or existing packages
* [Submit Fixes and New Packages](https://github.com/Microsoft/vcpkg/pulls)

Please refer to our [Contribution guidelines](CONTRIBUTING.md) for more details.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/). For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## License

Code licensed under the [MIT License](LICENSE.txt).

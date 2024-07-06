<!-- 
This document is a copy of the README file on the Microsoft/vcpkg-docs repository.

To make changes modify this file instead:
https://github.com/microsoft/vcpkg-docs/blob/main/vcpkg/readme/vcpkg-README.md
-->

[🌐 Read in a different language](https://learn.microsoft.com/locale/?target=https%3A%2F%2Flearn.microsoft.com%2Fvcpkg%2F)

# vcpkg overview

vcpkg is a free and open-source C/C++ package manager maintained by Microsoft
and the C++ community. 

Initially launched in 2016 as a tool for assisting developers in migrating their
projects to newer versions of Visual Studio, vcpkg has evolved into a
cross-platform tool used by developers on Windows, macOS, and Linux. vcpkg has a
large collection of open-source libraries and enterprise-ready features designed to
facilitate your development process with support for any build and project
systems. vcpkg is a C++ tool at heart and is written in C++ with scripts in
CMake. It is designed from the ground up to address the unique pain points C/C++
developers experience.

This tool and ecosystem are constantly evolving, and we always appreciate
contributions! Learn how to start contributing with our [packaging
tutorial](https://learn.microsoft.com/vcpkg/get_started/get-started-adding-to-registry) and [maintainer
guide](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide).

# Get started

First, follow one of our quick start guides.

Whether you're using CMake, MSBuild, or any other build system, vcpkg has you covered:

* [vcpkg with CMake](https://learn.microsoft.com/vcpkg/get_started/get-started)
* [vcpkg with MSBuild](https://learn.microsoft.com/vcpkg/get_started/get-started-msbuild)
* [vcpkg with other build systems](https://learn.microsoft.com/vcpkg/users/buildsystems/manual-integration)

You can also use any editor:

* [vcpkg with Visual Studio](https://learn.microsoft.com/vcpkg/get_started/get-started-vs)
* [vcpkg with Visual Sudio Code](https://learn.microsoft.com/vcpkg/get_started/get-started-vscode)
* [vcpkg with
  CLion](<https://www.jetbrains.com/help/clion/package-management.html>)

If a library you need is not present in the vcpkg registry, [open an issue on
the GitHub repository][contributing:submit-issue] or [contribute the package
yourself](https://learn.microsoft.com/vcpkg/get_started/get-started-adding-to-registry).

After you've gotten vcpkg installed and working, you may wish to [add
tab completion to your terminal](https://learn.microsoft.com/vcpkg/commands/integrate#vcpkg-autocompletion).

# Use vcpkg

Create a [manifest for your project's dependencies](https://learn.microsoft.com/vcpkg/consume/manifest-mode):

```Console
vcpkg new --application
vcpkg add port fmt
```

Or [install packages through the command line](https://learn.microsoft.com/vcpkg/consume/classic-mode):

```Console
vcpkg install fmt
```

Then use one of our available integrations for
[CMake](https://learn.microsoft.com/vcpkg/concepts/build-system-integration#cmake-integration),
[MSBuild](https://learn.microsoft.com/vcpkg/concepts/build-system-integration#msbuild-integration) or 
[other build
systems](https://learn.microsoft.com/vcpkg/concepts/build-system-integration#manual-integration).

For a short description of all available commands, run `vcpkg help`.
Run `vcpkg help [topic]` for details on a specific topic.

# Key features

vcpkg offers powerful features for your package management needs:

* [easily integrate with your build system](https://learn.microsoft.com/vcpkg/concepts/build-system-integration)
* [control the versions of your dependencies](https://learn.microsoft.com/vcpkg/users/versioning)
* [package and publish your own packages](https://learn.microsoft.com/vcpkg/concepts/registries)
* [reuse your binary artifacts](https://learn.microsoft.com/vcpkg/users/binarycaching)
* [enable offline scenarios with asset caching](https://learn.microsoft.com/vcpkg/concepts/asset-caching)

# Contribute

vcpkg is an open source project, and is thus built with your contributions. Here
are some ways you can contribute:

* [Submit issues][contributing:submit-issue] in vcpkg or existing packages
* [Submit fixes and new packages][contributing:submit-pr]

Please refer to our [mantainer guide](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide) and
[packaging tutorial](https://learn.microsoft.com/vcpkg/get_started/get-started-packaging) for more details.

This project has adopted the [Microsoft Open Source Code of
Conduct][contributing:coc]. For more information see the [Code of Conduct
FAQ][contributing:coc-faq] or email
[opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional
questions or comments.
 
[contributing:submit-issue]: https://github.com/microsoft/vcpkg/issues/new/choose
[contributing:submit-pr]: https://github.com/microsoft/vcpkg/pulls
[contributing:coc]: https://opensource.microsoft.com/codeofconduct/
[contributing:coc-faq]: https://opensource.microsoft.com/codeofconduct/
  
# Resources

* Ports: [Microsoft/vcpkg](<https://github.com/microsoft/vcpkg>)
* Source code: [Microsoft/vcpkg-tool](<https://github.com/microsoft/vcpkg-tool>)
* Docs: [Microsoft Learn | vcpkg](https://learn.microsoft.com/vcpkg)
* Website: [vcpkg.io](<https://vcpkg.io>)
* Email: [vcpkg@microsoft.com](<mailto:vcpkg@microsoft.com>)
* Discord: [\#include \<C++\>'s Discord server](<https://www.includecpp.org>), in the #🌏vcpkg channel
* Slack: [C++ Alliance's Slack server](<https://cppalliance.org/slack/>), in the #vcpkg channel

# License

The code in this repository is licensed under the MIT License. The libraries
provided by ports are licensed under the terms of their original authors. Where
available, vcpkg places the associated license(s) in the location
[`installed/<triplet>/share/<port>/copyright`](https://learn.microsoft.com/vcpkg/contributing/maintainer-guide#install-copyright-file).

# Security

Most ports in vcpkg build the libraries in question using the original build
system preferred by the original developers of those libraries, and download
source code and build tools from their official distribution locations. For use
behind a firewall, the specific access needed will depend on which ports are
being installed. If you must install it in an "air gapped" environment, consider
instaling once in a non-"air gapped" environment, populating an [asset
cache](https://learn.microsoft.com/vcpkg/users/assetcaching) shared with the otherwise "air gapped"
environment.

# Telemetry

vcpkg collects usage data in order to help us improve your experience. The data
collected by Microsoft is anonymous. You can opt-out of telemetry by:

- running the bootstrap-vcpkg script with `-disableMetrics`
- passing `--disable-metrics` to vcpkg on the command line
- setting the `VCPKG_DISABLE_METRICS` environment variable

Read more about vcpkg telemetry at [https://learn.microsoft.com/vcpkg/about/privacy](https://learn.microsoft.com/vcpkg/about/privacy).

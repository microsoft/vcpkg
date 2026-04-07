# Contribution Guidelines

Vcpkg is a community driven effort to build a productive and robust ecosystem of native libraries - your contributions are invaluable!

## Issues

The easiest way to contribute is by reporting issues with either `vcpkg.exe` or an existing package on [GitHub](https://github.com/Microsoft/vcpkg). When reporting an issue with `vcpkg.exe`, make sure to clearly state:
- The machine setup: "I'm using Windows 10 Anniversary Update. My machine is using the fr-fr locale. I successfully ran 'install boost'." 
- The steps to reproduce: "I run 'vcpkg list'"
- The outcome you expected: "I expected to see 'boost:x86-windows'"
- The actual outcome: "I get no output at all" or "I get a crash dialog"

When reporting an issue with a package, make sure to clearly state:
- The machine setup (as above)
- What package and version you're building: "opencv 3.1.0"
- Any relevant error logs from the build process.

## Pull Requests

We are happy to accept pull requests for fixes, features, new packages, and updates to existing packages. In order to avoid wasting your time, we highly encourage opening an issue to discuss whether the PR you're thinking about making will be acceptable. This is doubly true for features and new packages.

### New package Guidelines

We're glad you're interested in submitting a new package! Here are some guidelines to help you author an excellent portfile:
- Avoid functional patches. Patches should be considered a last resort to implement compatibility when there's no other way. 
- When patches can't be avoided, do not modify the default behavior. The ideal lifecycle of a patch is to get merged upstream and no longer be needed. Try to keep this goal in mind when deciding how to patch something.
- Prefer to use the `vcpkg_xyz` functions over raw `execute_command` calls. This makes long term maintenance easier when new features (such as custom compiler flags or generators) are added.

## Legal

You will need to complete a Contributor License Agreement (CLA) before your pull request can be accepted. This agreement testifies that you are granting us permission to use the source code you are submitting, and that this work is being submitted under appropriate license that we can use it.

You can complete the CLA by going through the steps at https://cla.microsoft.com. Once we have received the signed CLA, we'll review the request. You will only need to do this once.

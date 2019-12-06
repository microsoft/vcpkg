Vcpkg PR Checklist
=====================
Revision: 0

## Overview
This document provides an annotated checklist which vcpkg team members use to apply the "reviewed" label on incoming pull requests. If a pull request violates any of these points, we may ask contributors to make necessary changes before we can merge the changeset.

Feel free to create an issue or pull request if you feel that this checklist can be improved. Please increment the revision number when modifying the checklist content.

## Checklist
You can link any of these checklist items in a GitHub comment by copying the link address attached to each item code.

<details id=c000001>
<summary><a href=#c000001>c000001</a>: No deprecated helper functions are used</summary>

See our [Maintainer Guidelines and Policies](maintainer-guide.md#Avoid-deprecated-helper-functions) for more information.

</details>

<details id=c000002>
<summary><a href=#c000002>c000002</a>: Control Version field is updated</summary>

See our [Maintainer Guidelines and Policies](maintainer-guide.md#versioning) for more information.

</details>

<details id=c000003>
<summary><a href=#c000003>c000003</a>: New ports contain a Description field written in English</summary>

A description only one or a few sentences long is helpful. Consider using the library's official description from their `README.md` or similar if possible. Automatic translations are acceptable and we are happy to clean up translations to English for our contributors.

See our [CONTROL file documentation](https://github.com/grdowns/vcpkg/blob/pr-checklist/docs/maintainers/control-files.md#description) for more information
    
</details>

<details id=c000004>
    <summary><a href=#c000004>c000004</a>: No unnecessary comments are present in the changeset</summary>

See our [Maintainer Guidelines and Policies](maintainer-guide.md#Avoid-excessive-comments-in-portfiles) for more information.

</details>

<details id=c000005>
<summary><a href=#c000005>c000005</a>: Downloaded archives are versioned if available

</details>

<details id=c000006>
<summary><a href=#c000006>c000006</a>: New ports pass CI checks for triplets that the library officially supports

</details>

<details id=c000007>
<summary><a href=#c000007>c000007</a>: Patches fix issues that are vcpkg-specific only</summary>

If possible, patches to the library source code should be upstreamed to the library's official repository. Opening up a pull request on the library's repository will help to improve the library for everyone, not just vcpkg users.

</details>

<details id=c000008>
<summary><a href=#c000008>c000008</a>: New ports download source code from the official source if available</summary>

</details>

<details id=c000009>
<summary><a href=#c000009>c000009</a>: Port system dependencies are communicated with a message during installation</summary>

Example:
```cmake
message(STATUS "${PORT} has system dependencies on")
```

</details>

<details id=c000010>
<summary><a href=#c000010>c000010</a>: Ports and port features are named correctly</summary>

For user accessibility, we prefer names of ports and port features to be intuitive and close to their counterparts in official sources and other package managers. If you are unsure about the naming of a port or port feature, we recommend checking repology.org, packages.ubuntu.com, or searching for additional information using a search engine. We can also help our contributors with this, so feel free to ask for naming suggestions if you are unsure.

</details>

<details id=c000011>
<summary><a href=#c000011>c000011</a>: Library targets are exported when appropriate</summary>

To provide users with a seamless build system integration, please be sure to export and provide a means of finding the library targets intended to be used downstream. Targets not meant to be exported should be be marked private and not exported.

</details>

<details id=c000012>
<summary><a href=#c000012>c000012</a>: Ports do not use applications which modify the user's system</summary>
    
Examples of these applications are `sudo`, `apt`, `brew`, or `pip`. Please use an alternative to these types of programs wherever possible.
    
</details>

<details id=c000013>
<summary><a href=#c000013>c000013</a>: Ports with system dependencies include an information message during installation</summary>

Example:
```cmake
message(
"${PORT} currently requires the following libraries from the system package manager:
    autoconf libtool
These can be installed on Ubuntu systems via sudo apt install autoconf libtool"
)
```

</details>

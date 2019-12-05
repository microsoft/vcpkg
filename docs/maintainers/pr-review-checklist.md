Vcpkg PR Checklist
=====================
Revision: 0

## Overview
This document provides an annotated checklist which vcpkg team members use to apply the "reviewed" label on incoming pull requests. If a pull request violates any of these points, we may ask contributors to make necessary changes before we can merge the changeset.

## Usage

You can link any of these items in a GitHub comment with the following:
```markdown
<!-- Using item c000001 as an example -->
Can you please correct this? See [c000001](docs/maintainers/pr-review-checklist#c000001)
```
Rendered output:

Can you please correct this? See [c000001](docs/maintainers/pr-review-checklist#c000001)

## Checklist


- <details name=c000001>
    <summary>c000001: No deprecated helper functions are used</summary>

    See [Maintainer Guidelines and Policies](maintainer-guide.md#Avoid-deprecated-helper-functions)
</details>


- <details id=c000002>
    <summary>c000002: Control Version field is updated</summary>

    See [Maintainer Guidelines and Policies](maintainer-guide.md#Avoid-deprecated-helper-functions#versioning)

</details>

- <a id=c000003></a>New ports contain a Description field written in English

- <details>
    <summary>No unnecessary comments are present in the changeset</summary>

    See [Maintainer Guidelines and Policies](maintainer-guide.md#Avoid-deprecated-helper-functions#Avoid-excessive-comments-in-portfiles)

</details>

- Downloaded archives are versioned if available

- New ports pass CI checks for triplets that the library officially supports

- <details>
    <summary>Patches fix issues that are vcpkg-specific only</summary>

    If possible, patches to the library source code should be upstreamed to the library's official repository. Opening up a pull request on the library's repository will help to improve the library for everyone, not just vcpkg users.

</details>

- <details>
    <summary>New ports download source code from the official source if available</summary>

</details>

- <details>
    <summary>Port system dependencies are communicated with a message during installation</summary>

    Example:
    ```cmake
    message(STATUS "${PORT} has system dependencies on")

    ```

</details>
Check if a package/all features are named correctly, go to Debian package manager, for example. If there is a naming question, escalate to engineer 

Check repology.org, packages.ubuntu.com, perform a Google search, etc 

If unsure, ping a Redmond team member and ask for their opinion 

Suggested Response - “Should the name of this <port or feature> be named <name>? <Resource> shows that this is the usual name. Can you rename this <port or feature>? 

PR exports library targets 

PR adds “find_package(<port>) but casing is incorrect. E.g. find_package(zlib) is wrong because zlib needs to be capitalized	 

PR adds a use of “sudo”, “apt,” “brew”, or “pip” 

Suggested Response - “We do not allow ports to use applications which modify the user’s system. Is it possible to use an alternative to <application>? 

PR uses a system dependency not available in vcpkg 

Suggested Response - “Can you please add a system dependency message to the top of the portfile.cmake? <System dependency message> 

[foo](#c000003)
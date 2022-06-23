# Creating Registries

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/maintainers/registries.md).**

There are two parts to using registries; this documents the creation side of
the relationship. In order to learn more about using registries that others
have created, please read [this documentation](../users/registries.md).
## Table of Contents

- [Creating Registries](#creating-registries)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
    - [Git Registries](#git-registries)
      - [Adding a New Version](#adding-a-new-version)
    - [Filesystem Registries](#filesystem-registries)
      - [Adding a New Version](#adding-a-new-version-1)
    - [Builtin Registries](#builtin-registries)

## Overview

Registries are collections of ports and their versions. There are two major
choices of implementation for registries, if you want to create your own -
git registries, and filesystem registries.

Git registries are simple git repositories, and can be shared publicly or
privately via normal mechanisms for git repositories. The vcpkg repository at
<https://github.com/microsoft/vcpkg>, for example, is a git registry.

Filesystem registries are designed as more of a testing ground. Given that they
literally live on your filesystem, the only way to share them is via shared
directories. However, filesystem registries can be useful as a way to represent
registries held in non-git version control systems, assuming one has some way
to get the registry onto the disk.

Note that we expect the set of registry types to grow over time; if you would
like support for registries built in your favorite public version control
system, don't hesitate to open a PR.

The basic structure of a registry is:

- The set of versions that are considered "latest" at certain times in history,
  known as the "baseline".
- The set of all the versions of all the ports, and where to find each of
  these in the registry.

### Git Registries

As you're following along with this documentation, it may be helpful to have
a working example to refer to. We've written one and put it here:
<https://github.com/northwindtraders/vcpkg-registry>.

All git registries must have a `versions/baseline.json` file. This file
contains the set of "latest versions" at a certain commit. It is laid out as
a top-level object containing only the `"default"` field. This field should
contain an object mapping port names to the version which is currently the
latest.

Here's an example of a valid baseline.json:

```json
{
  "default": {
    "kitten": {
      "baseline": "2.6.2",
      "port-version": 0
    },
    "port-b": {
      "baseline": "19.00",
      "port-version": 2
    }
  }
}
```

The `versions` directory contains all the information about which versions of
which packages are contained in the registry, along with where those versions
are stored. The rest of the registry just acts as a backing store, as far as
vcpkg is concerned: only things inside the `versions` directory will be used
to direct how your registry is seen by vcpkg.

Each port in a registry should exist in the versions directory as
`<first letter of port>-/<name of port>.json`; in other words, the
information about the `kitten` port would be located in
`versions/k-/kitten.json`. This should be a top-level object with only a
single field: `"versions"`. This field should contain an array of version 
objects:

- The version of the port in question; should be exactly the same as the
  `vcpkg.json` file, including the version fields and `"port-version"`.
- The `"git-tree"` field, which is a git tree; in other words, what you get
  when you write `git rev-parse COMMIT-ID:path/to/port`.

Note that the version fields for ports with `CONTROL` files, is 
`"version-string"`; we do not recommend using `CONTROL` files in new
registries, however.

_WARNING_: One very important part of registries is that versions should
_never_ be changed. Updating to a later ref should never remove or change an
existing version. It must always be safe to update a registry.

Here's an example of a valid version database for a `kitten` port with one 
version:

```json
{
  "versions": [
    {
      "version": "2.6.2",
      "port-version": 0,
      "git-tree": "67d60699c271b7716279fdea5a5c6543929eb90e"
    }
  ]
}
```

In general, it's not important where you place port directories. However, the
idiom in vcpkg is to follow what the built in vcpkg registry does: your 
`kitten` port should be placed in `ports/kitten`.

_WARNING_: One other thing to keep in mind is that when you update a registry,
all previous versions should also be accessible. Since your user will set their
baseline to a commit ID, that commit ID must always exist, and be accessible
from your HEAD commit, which is what is actually fetched. This means that your
HEAD commit should be a child of all previous HEAD commits.

### Builtin Registries

Builtin registries are treated as special [Git registries](#git-registries). Instead of fetching from a remote url, builtin registries consult the `$VCPKG_ROOT/.git` directory of the vcpkg clone. They use the currently checked out `$VCPKG_ROOT/versions` directory as the source for versioning information.

#### Adding a New Version

There is some git trickery involved in creating a new version of a port. The
first thing to do is make some changes, update the `"port-version"` and regular
version field as you need to, and then test with `overlay-ports`:
`vcpkg install kitten --overlay-ports=ports/kitten`.

Once you've finished your testing, you'll need to make sure that the directory
as it is is under git's purview. You'll do this by creating a temporary commit:

```pwsh
> git add ports/kitten
> git commit -m 'temporary commit'
```

Then, get the git tree ID of the directory:

```pwsh
> git rev-parse HEAD:ports/kitten
73ad3c823ef701c37421b450a34271d6beaf7b07
```

Then, you can add this version to the versions database. At the top of your
`versions/k-/kitten.json`, you can add (assuming you're adding version
`2.6.3#0`):

```json
{
  "versions": [
    {
      "version": "2.6.3",
      "port-version": 0,
      "git-tree": "73ad3c823ef701c37421b450a34271d6beaf7b07"
    },
    {
      "version": "2.6.2",
      "port-version": 0,
      "git-tree": "67d60699c271b7716279fdea5a5c6543929eb90e"
    }
  ]
}
```

then, you'll want to modify your `versions/baseline.json` with your new version 
as well:

```json
{
  "default": {
    "kitten": {
      "baseline": "2.6.3",
      "port-version": 0
    },
    "port-b": {
      "baseline": "19.00",
      "port-version": 2
    }
  }
}
```

and amend your current commit:

```pwsh
> git commit --amend
```

then share away!

### Filesystem Registries

As you're following along with this documentation, it may be helpful to have
a working example to refer to. We've written one and put it here:
<https://github.com/vcpkg/example-filesystem-registry>.

All filesystem registries must have a `versions/baseline.json` file. This file
contains the set of "latest versions" for a certain version of the registry.
It is laid out as a top-level object containing a map from version name to
"baseline objects", which map port names to the version which is considered
"latest" for that version of the registry.

Filesystem registries need to decide on a versioning scheme. Unlike git 
registries, which have the implicit versioning scheme of refs, filesystem
registries can't rely on the version control system here. One possible option
is to do a daily release, and have your "versions" be dates.

_WARNING_: A baseline must not be modified once published. If you want to change or update versions, you need to create a new baseline in the `baseline.json` file.

Here's an example of a valid `baseline.json`, for a registry that has decided
upon dates for their versions:

```json
{
  "2021-04-16": {
    "kitten": {
      "baseline": "2.6.2",
      "port-version": 0
    },
    "port-b": {
      "baseline": "19.00",
      "port-version": 2
    }
  },
  "2021-04-15": {
    "kitten": {
      "baseline": "2.6.2",
      "port-version": 0
    },
    "port-b": {
      "baseline": "19.00",
      "port-version": 1
    }
  }
}
```

The `versions` directory contains all the information about which versions of
which packages are contained in the registry, along with where those versions
are stored. The rest of the registry just acts as a backing store, as far as
vcpkg is concerned: only things inside the `versions` directory will be used
to direct how your registry is seen by vcpkg.

Each port in a registry should exist in the versions directory as
`<first letter of port>-/<name of port>.json`; in other words, the
information about the `kitten` port would be located in
`versions/k-/kitten.json`. This should be a top-level object with only a
single field: `"versions"`. This field should contain an array of version 
objects:

- The version of the port in question; should be exactly the same as the
  `vcpkg.json` file, including the version fields and `"port-version"`.
- The `"path"` field: a relative directory, rooted at the base of the registry
  (in other words, the directory where `versions` is located), to the port 
  directory. It should look something like `"$/path/to/port/dir`"

Note that the version fields for ports with `CONTROL` files, is 
`"version-string"`; we do not recommend using `CONTROL` files in new
registries, however.

In general, it's not important where you place port directories. However, the
idiom in vcpkg is to follow somewhat closely to what the built in vcpkg
registry does: your `kitten` port at version `x.y.z` should be placed in
`ports/kitten/x.y.z`, with port versions appended as you see fit (although
since `#` is not a good character to use for file names, perhaps use `_`).

_WARNING_: One very important part of registries is that versions should
_never_ be changed. One should never remove or change an existing version.
Your changes to your registry shouldn't change behavior to downstream users.

Here's an example of a valid version database for a `kitten` port with one 
version:

```json
{
  "versions": [
    {
      "version": "2.6.2",
      "port-version": 0,
      "path": "$/ports/kitten/2.6.2_0"
    }
  ]
}
```

#### Adding a New Version

Unlike git registries, adding a new version to a filesystem registry mostly
involves a lot of copying. The first thing to do is to copy the latest
version of your port into a new version directory, update the version and
`"port-version"` fields as you need to, and then test with `overlay-ports`:
`vcpkg install kitten --overlay-ports=ports/kitten/new-version`.

Once you've finished your testing, you can add this new version to the top of
your `versions/k-/kitten.json`:

```json
{
  "versions": [
    {
      "version": "2.6.3",
      "port-version": 0,
      "path": "$/ports/kitten/2.6.3_0"
    },
    {
      "version": "2.6.2",
      "port-version": 0,
      "path": "$/ports/kitten/2.6.2_0"
    }
  ]
}
```

then, you'll want to modify your `versions/baseline.json` with your new version 
as well (remember not to modify existing baselines):

```json
{
  "2021-04-17": {
    "kitten": {
      "baseline": "2.6.3",
      "port-version": 0
    },
    "port-b": {
      "baseline": "19.00",
      "port-version": 2
    }
  },
  "2021-04-16": {
    "kitten": {
      "baseline": "2.6.2",
      "port-version": 0
    },
    "port-b": {
      "baseline": "19.00",
      "port-version": 2
    }
  },
  "2021-04-15": {
    "kitten": {
      "baseline": "2.6.2",
      "port-version": 0
    },
    "port-b": {
      "baseline": "19.00",
      "port-version": 1
    }
  }
}
```

and you're done!

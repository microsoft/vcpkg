# Package Federation: Custom Registries

**Note: this is the feature as it was initially specified and does not necessarily reflect the current behavior.**

**Up-to-date documentation is available at [Registries](../users/registries.md).**

As it is now, vcpkg has over 1400 ports in the default registry (the `/ports` directory).
For the majority of users, this repository of packages is enough. However, many enterprises
need to more closely control their dependencies for one reason or another, and this document
lays out a method which we will build into vcpkg for exactly that reason.

## Background

A registry is simply a set of packages. In fact, there is already a registry in vcpkg: the default one.
Package federation, implemented via custom registries, allows one to add new packages,
edit existing packages, and have as much or as little control as one likes over the dependencies that one uses.
It gives the control over dependencies that an enterprise requires.

### How Does the Current Default Registry Work?

Of course, the existing vcpkg tool does have packages in the official,
default registry. The way we describe these packages is in the ports tree –
at the base of the vcpkg install directory, there is a directory named ports,
which contains on the order of 1300 directories, one for each package. Then,
in each package directory, there are at least two files: a CONTROL or
vcpkg.json file, which contains the name, version, description, and features
of the package; and a portfile.cmake file which contains the information on
how to download and build the package. There may be other files in this
registry, like patches or usage instructions, but only those two files are
needed.

### Existing vcpkg Registry-like Features

There are some existing features in vcpkg that act somewhat like a custom
registry. The most obvious feature that we have is overlay ports – this
feature allows you to specify any number of directories as "overlays", which
either contain a package definition directly, or which contain some number of
package directories; these overlays will be used instead of the ports tree
for packages that exist in both places, and are specified exclusively on the
command line. Additionally, unfortunately, if one installs a package from
overlay ports that does not exist in the ports tree, one must pass these
overlays to every vcpkg installation command.

There is also the less obvious "feature" which works by virtue of the ports
tree being user-editable: one can always edit the ports tree on their own
machine, and can even fork vcpkg and publish their own ports tree.
Unfortunately, this then means that any updates to the source tree require
merges, as opposed to being able to fast-forward to the newest sources.

### Why Registries?

There are many reasons to want custom registries; however, the most important reasons are:

* Legal requirements – a company like Microsoft or Google
  needs the ability to strictly control the code that goes into their products,
  making certain that they are following the licenses strictly.
  * There have been examples in the past where a library which is licensed under certain terms contains code
    which is not legally allowed to be licensed under those terms (see [this example][legal-example],
    where a person tried to merge Microsoft-owned, Apache-licensed code into the GPL-licensed libstdc++).
* Technical requirements – a company may wish to run their own tests on the packages they ship,
  such as [fuzzing].
* Other requirements – an organization may wish to strictly control its dependencies for a myriad of other reasons.
* Newer versions – vcpkg may not necessarily always be up to date for all libraries in our registry,
  and an organization may require a newer version than we ship;
  they can very easily update this package and have the version that they want.
* Port modifications – vcpkg has somewhat strict policies on port modifications,
  and an organization may wish to make different modifications than we do.
  It may allow that organization to make certain that the package works on triplets
  that our team does not test as extensively.
* Testing – just like port modifications, if a team wants to do specific testing on triplets they care about,
  they can do so via their custom registry.

Then, there is the question of why vcpkg needs a new solution for custom registries,
beyond the existing overlay ports feature. There are two big reasons –
the first is to allow a project to define the registries that they use for their dependencies,
and the second is the clear advantage in the user experience of the vcpkg tool.
If a project requires specific packages to come from specific registries,
they can do so without worrying that a user accidentally misses the overlay ports part of a command.
Additionally, beyond a feature which makes overlay ports easier to use,
custom registries allow for more complex and useful infrastructure around registries.
In the initial custom registry implementation, we will allow overlay ports style paths,
as well as git repositories, which means that people can run and use custom registries
without writing their own infrastructure around getting people that registry.

It is the intention of vcpkg to be the most user-friendly package manager for C++,
and this allows us to fulfill on that intention even further.
As opposed to having to write `--overlay-ports=path/to/overlay` for every command one runs,
or adding an environment variable `VCPKG_OVERLAY_PORTS`,
one can simply write vcpkg install and the registries will be taken care of for you.
As opposed to having to use git submodules, or custom registry code for every project,
one can write and run the infrastructure in one place,
and every project that uses that registry requires only a few lines of JSON.

[legal-example]: https://gcc.gnu.org/legacy-ml/libstdc++/2019-09/msg00054.html
[fuzzing]: https://en.wikipedia.org/wiki/Fuzzing

## Specification

We will be adding a new file that vcpkg understands - `vcpkg-configuration.json`.
The way that vcpkg will find this file is different depending on what mode vcpkg is in:
in classic mode, vcpkg finds this file alongside the vcpkg binary, in the root directory.
In manifest mode, vcpkg finds this file alongside the manifest. For the initial implementation,
this is all vcpkg will look for; however, in the future, vcpkg will walk the tree and include
configuration all along the way: this allows for overriding defaults.
The specific algorithm for applying this is not yet defined, since currently only one
`vcpkg-configuration.json` is allowed.

The only thing allowed in a `vcpkg-configuration.json` is a `<configuration>` object.

A `<configuration>` is an object:
* Optionally, `"default-registry"`: A `<registry-implementation>` or `null`
* Optionally, `"registries"`: An array of `<registry>`s

Since this is the first RFC that adds anything to this field,
as of now the only properties that can live in that object will be
these.

A `<registry-implementation>` is an object matching one of the following:
* `<registry-implementation.builtin>`:
  * `"kind"`: The string `"builtin"`
* `<registry-implementation.directory>`:
  * `"kind"`: The string `"directory"`
  * `"path"`: A path
* `<registry-implementation.git>`:
  * `"kind"`: The string `"git"`
  * `"repository"`: A URI
  * Optionally, `"path"`: An absolute path into the git repository
  * Optionally, `"ref"`: A git reference

A `<registry>` is a `<registry-implementation>` object, plus the following properties:
* Optionally, `"scopes"`: An array of `<package-name>`s
* Optionally, `"packages"`: An array of `<package-name>`s

The `"packages"` and `"scopes"` fields of distinct registries must be disjoint,
and each `<registry>` must have at least one of the `"scopes"` and `"packages"` property,
since otherwise there's no point.

As an example, a package which uses a different default registry, and a different registry for boost,
might look like the following:

```json
{
  "default-registry": {
    "kind": "directory",
    "path": "vcpkg-ports"
  },
  "registries": [
    {
      "kind": "git",
      "repository": "https://github.com/boostorg/vcpkg-ports",
      "ref": "v1.73.0",
      "scopes": [ "boost" ]
    },
    {
      "kind": "builtin",
      "packages": [ "cppitertools" ]
    }
  ]
}
```

This will install `fmt` from `<directory-of-vcpkg.json>/vcpkg-ports`,
`cppitertools` from the registry that ships with vcpkg,
and any `boost` dependencies from `https://github.com/boostorg/vcpkg-ports`.
Notably, this does not replace behavior up the tree -- only the `vcpkg-configuration.json`s
for the current invocation do anything.

### Behavior

When a vcpkg command requires the installation of dependencies,
it will generate the initial list of dependencies from the package,
and then run the following algorithm on each dependency:

1. Figure out which registry the package should come from by doing the following:
    1. If there is a registry in the registry set which contains the dependency name in the `"packages"` array,
      then use that registry.
    2. For every scope, in order from most specific to least,
      if there is a registry in the registry set which contains that scope in the `"scopes"` array,
      then use that registry.
      (For example, for `"cat.meow.cute"`, check first for `"cat.meow.cute"`, then `"cat.meow"`, then `"cat"`).
    3. If the default registry is not `null`, use that registry.
    4. Else, error.
2. Then, add that package's dependencies to the list of packages to find, and repeat for the next dependency.

vcpkg will also rerun this algorithm whenever an install is run with different configuration.

### How Registries are Laid Out

There are three kinds of registries, but they only differ in how the registry gets onto one's filesystem.
Once the registry is there, package lookup runs the same, with each kind having it's own way of defining its
own root.

In order to find a port `meow` in a registry with root `R`, vcpkg first sees if `R/meow` exists;
if it does, then the port root is `R/meow`. Otherwise, see if `R/m-` exists; if it does,
then the port root is `R/m-/meow`. (note: this algorithm may be extended further in the future).

For example, given the following port root:

```
R/
  abseil/...
  b-/
    boost/...
    boost-build/...
    banana/...
  banana/...
```

The port root for `abseil` is `R/abseil`; the port root for `boost` is `R/b-/boost`;
the port root for `banana` is `R/banana` (although this duplication is not recommended).

The reason we are making this change to allow more levels in the ports tree is that ~1300
ports are hard to look through in a tree view, and this allows us to see only the ports we're
interested in. Additionally, no port name may end in a `-`, so this means that these port subdirectories
will never intersect with actual ports. Additionally, since we use only ASCII for port names,
we don't have to worry about graphemes vs. code units vs. code points -- in ASCII, they are equivalent.

Let's now look at how different registry kinds work:

#### `<registry.builtin>`

For a `<registry.builtin>`, there is no configuration required.
The registry root is simply `<vcpkg-root>/ports`.

#### `<registry.directory>`

For a `<registry.directory>`, it is again fairly simple.
Given `$path` the value of the `"path"` property, the registry root is either:

* If `$path` is absolute, then the registry root is `$path`.
* If `$path` is drive-relative (only important on Windows), the registry root is
  `(drive of vcpkg.json)/$path`
* If `$path` is relative, the registry root is `(directory of vcpkg.json)/$path`

Note that the path to vcpkg.json is _not_ canonicalized; it is used exactly as it is seen by vcpkg.

#### `<registry.git>`

This registry is the most complex. We would like to cache existing registries,
but we don't want to ignore new updates to the registry.
It is the opinion of the author that we want to find more updates than not,
so we will update the registry whenever the `vcpkg.json` or `vcpkg-configuration.json`
is modified. We will do so by keeping a sha512 of the `vcpkg.json` and `vcpkg-configuration.json`
inside the `vcpkg-installed` directory.

We will download the specific ref of the repository to a central location (and update as needed),
and the root will be either: `<path to repository>`, if the `"path"` property is not defined,
or else `<path to repository>/<path property>` if it is defined.
The `"path"` property must be absolute, without a drive, and will be treated as relative to
the path to the repository. For example:

```json
{
  "kind": "git",
  "repository": "https://github.com/microsoft/vcpkg",
  "path": "/ports"
}
```

is the correct way to refer to the registry built in to vcpkg, at the latest version.

The following are all incorrect:

```json
{
  "$reason": "path can't be drive-absolute",
  "kind": "git",
  "repository": "https://github.com/microsoft/vcpkg",
  "path": "F:/ports"
}
```

```json
{
  "$reason": "path can't be relative",
  "kind": "git",
  "repository": "https://github.com/microsoft/vcpkg",
  "path": "ports"
}
```

```json
{
  "$reason": "path _really_ can't be relative like that",
  "kind": "git",
  "repository": "https://github.com/microsoft/vcpkg",
  "path": "../../meow/ports"
}
```

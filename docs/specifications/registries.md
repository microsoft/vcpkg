# Package Federation: Custom Registries

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

As background, let us look at our current project layout.
We currently have one file which a person using vcpkg to manage their dependencies must write the manifest,
or vcpkg.json. It contains the name of the project, the version of the project,
and the project's dependencies and feature list. An example file might look like:

```json
{
  "name": "example",
  "version-string": "1.3.2",
  "dependencies": [
    "fmt",
    "cppitertools"
  ]
}
```

We do wish to continue using this file,
and for simple cases one should be able to write everything they need into this file.
Therefore, we will add a new section, `"configuration"`,
which will be expanded in the future to contain other configuration and policies.
This `"configuration"` property will be an object,
and since this is the first RFC that adds anything to this field,
as of now the only properties that can live in that object will be `"registries"` and `"default-registry"`.
Additionally, we will allow the string value `"file"`,
which makes vcpkg look for a `vcpkg-configuration.json` file up the directory tree,
starting from the location of the `vcpkg.json` file.
This `vcpkg-configuration.json` file should be an object with the same shape as the `"configuration"` property.

The `"registries"` property should be an object, mapping `<identifier>`s to `<registry>` objects:
*	`"scopes"`: An array of `<package-name>`s (also defined in the manifests RFC: period-separated `<identifier>`s)
*	`"packages"`: An array of `<package-name>`s
*	Then, a `<registry>` is either a `<registry.path>`:
  *	`"path"`: A string denoting a path.
    Can be either relative (will be considered relative to the file containing the configuration), or absolute.
    Paths which are absolute without a drive on Windows will be considered to be
    on the drive containing the configuration.
*	Or, a `<registry.git>`:
  *	`"git"`: A URI denoting a git repository
  *	Optionally, `"ref"`: A git reference (a commit, a branch name, or a tag);
    defaults to the default branch of the repository.
* Or, a `<registry.none>`, which contains no more properties. `<identifier>`s may not map to a `<registry.none>`.

Additionally, the `"registries"` object may contain the property `"default"`, which must be a `<registry.none>`.

The `"default-registry"` property should be an `<identifier>`, the string `"default"`, or `null`.
The `"packages"` and `"scopes"` fields of distinct registries must be disjoint.
For example, a package which uses a different default registry, and a different registry for boost,
might look like the following:

```json
{
  "name": "example",
  "version-string": "1.3.2",
  "dependencies": [
    "fmt",
    "cppitertools"
  ],
  "configuration": {
    "registries": {
      "my-default": {
        "git": "https://github.com/meow/vcpkg-ports"
      },
      "boostorg": {
        "git": "https://github.com/boostorg/vcpkg-ports",
        "ref": "v1.73.0",
        "scopes": [ "boost" ]
      }
    ],
    "default-registry": "my-default"
  }
}
```

This will install `fmt` and `cppitertools` from `https://github.com/meow/vcpkg-ports`,
and since `cppitertools` depends on `boost.optional`, and we have replaced where `boost.*` comes from,
it will install `boost.optional` from `https://github.com/boostorg/vcpkg-ports`.

### Behavior

As background, it is important to understand that the current vcpkg has two "modes" of behavior –
classic mode, and manifest mode. Classic mode is closest to tools like apt or brew,
where you have a single installation directory per-system (although, for vcpkg,
it's a single installation directory per vcpkg installation,
and one can have as many vcpkg installations as one wants).
This mode is the way people have used vcpkg for the past four years,
but it is not the way we want future users to use vcpkg.
Recently, we have implemented a second mode – "manifest" mode – where a user writes this manifest,
called vcpkg.json, and there are separate installation directories for each manifest or even each build.
The registries RFC only supports this latter mode.

The way that vcpkg will do this is by searching from the current working directory
up towards the root for a file named `vcpkg.json`.
It will then look inside that file for the `"configuration"` property.
If that property is the literal string `"file"`, vcpkg will search
starting from the directory holding `vcpkg.json` upwards towards the root for a file named
`vcpkg-configuration.json`, which will then be treated as the configuration object.
Otherwise, the value of that property will be treated as the configuration object.
If the configuration object contains the `"default-registry"` field,
it replaces the default registry, which defaults to `"default"`.
If the configuration object contains the `"registries"` field,
it replaces the registry set, which defaults to the empty array.

The way that the registries actually work is as follows:
only the top-level manifest actually makes changes to the configuration of the project,
so configuration objects from dependencies will not modify which registries you use.
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

The special registry name `"default"` means the `ports` directory that is shipped with vcpkg.

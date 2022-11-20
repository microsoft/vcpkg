# Registries: Take 2 (including Git Registries)

**Note: this is the feature as it was initially specified and does not necessarily reflect the current behavior.**

**Up-to-date documentation is available at [Registries](../users/registries.md).**

Originally, the design of registries was decided upon and written up in the [Registries RFC](registries.md).
However, as we've gotten further into the design process of git registries and versioning,
and discussed the interaction of versioning with registries,
it's become clear that the existing design was lacking.
We need to have an on-disk port database that is not tied to the ports tree.

This RFC is a new design for registries, that includes this registry database.
It also includes the design for git registries,
which are likely to be the predominant form of registries in the wild.
They are also what we will start to treat the default registry as,
to allow for updating ports without updating the vcpkg executable
(likely necessary for binary releases).

## Design Considerations

After internal discussions of the relationship between versioning and registries,
it was clear that the existing design of registries does not play well with versioning.
It was also clear that it was necessary to have metadata about ports in a separate place from the ports tree;
in fact, after discussion, it was clear that the ports tree should be considered an implementation detail;
a backing store for build process information (e.g., `portfile.cmake` and the patches) and the manifest.

From this, it's clear that vcpkg needs to add a new set of metadata.
The versioning implementation has decided on `port_versions`, and thus that's what this RFC uses.

Since we're replacing the existing ports directory with a new method of describing ports,
this means that the ports directory is no longer anything but a data store.
This also means that the existing rules around locations of ports is no longer required;
however, it will still keep getting followed for the main repository,
and it's recommended that other registries follow the same pattern to make contributing easier.

## What does the registry database look like?

We don't wish to have the same problem as we do right now,
where there are nearly 1500 entries in a single directory.
We solve this by placing each database entry into `port_versions/<first character of port name>-/<port name>.json`.
For example, the database entry for 7zip is in `port_versions/7-/7zip.json`.

Each of these database entries contains all of the versions of the port throughout history,
along with versioning and feature metadata, so that we do not have to check out old manifests or CONTROL files
to get at that information.

Each database entry file must be a top-level array of port version objects, which contain the following entries:
* A version field: `"version-string"`, `"version"`, etc. Same as in the manifest.
* Optionally, `"port-version"`: Same as in the manifest.

And also contain a description of where to find the build files for this port; the possibilities include:

* `"git-tree"`: The [git object ID] of a tree object; this is only allowed for git registries.
  Note that this ID must be an ID from the repository where the registry is located.
* `"path"`: A path describing where to find the build files.
  The first entry in this path should be `$`, which means "this path starts at the root of the registry".
  No other kinds of paths are allowed.
  * For example: `$/foo/bar` gives you `foo/bar` underneath the folder containing the `port_versions` directory.
  * `/foo/bar` and `foo/bar` are both disallowed.

Using a `"git-tree"` as a backend in a non-git registry, and using a `"path"` in a git registry,
is not permitted. Future extensions may include things like remote archives or git repositories,
or may allow `"path"` in git registries.

Note that a registry entry should _always_ be additive;
deleting existing entries is unsupported and may result in bad behavior.
The only modification to existing entries that is allowable is moving the backing store
for the build files, assuming that the new build files are equivalent to the old build files.
(For example, a filesystem registry might have a new way of laying out where ports are).

Additionally, we'd like a new way of describing the set of ports that make up a "baseline".
This is currently done with the reference of the vcpkg git repository -
each reference has a set of versions that are tested against each other,
and this is a major feature of vcpkg.
We wish to have the same feature in the new versioning world,
and so we'll have a set of baseline versions in the registry database.

Baselines act differently between git registries or the builtin registry,
and in filesystem registries.
In git registries and the builtin registry,
since there's a history that one can access,
a baseline is the `"default"` entry in the baseline at the reference specified.
In filesystem registries, since there is no accessible history,
the baseline identifiers are mapped directly to entries in the baseline file,
without translation; by default, the `"default"` entry is used.

These baselines are placed in `port_versions/baseline.json`.
This is an object mapping baseline names to baseline objects,
where baseline objects map port names to version objects.
A version object contains `"baseline"`, which is un-schemed version,
and optionally `"port-version"`.

[git object ID]: https://git-scm.com/book/en/v2/Git-Internals-Git-Objects

### Example of a baseline file

The following is a reasonable baseline.json for a filesystem registry that only has two ports:

```json
{
  "default": {
    "abseil": { "baseline": "2020-03-03" },
    "zlib": { "baseline": "1.2.11", "port-version": 9 }
  },
  "old": {
    "abseil": { "baseline": "2019-02-11" },
    "zlib": { "baseline": "1.2.11", "port-version": 3 }
  },
  "really-old": {
    "zlib": { "baseline": "1.2.9" }
  }
}
```

### Example of a registry database entry file

Note: This file assumes that the versions RFC has been implemented,
and thus that minimum versions are required;
the syntax may change in the time between now and finishing the implementation.

This example is of `ogre`, since this port has both features and dependencies;
remember that this file would be `port_versions/o-/ogre.json`.

```json
[
  {
    "version-string": "1.12.7",
    "git-tree": "466e96fd2e17dd2453aa31dc0bc61bdcf53e7f61",
  },
  {
    "version-string": "1.12.1",
    "port-version": 1,
    "git-tree": "0de81b4f7e0ec24966e929c2ea64e16c15e71d5e",
  },
  ...
]
```

#### Filesystem Registry Databases

Filesystem registries are the simplest possible registry;
they have a `port_versions` directory at the top-level, which contains the registry database.
It's expected that the filesystem registry would have a filesystem backing store:
something like the existing `ports` directory, except with separate versions.
There won't be a specific way to lay the ports tree out as mandated by the tool,
as we are treating the ports tree as an implementation detail of the registry;
it's simply a way to get the files for a port.
As an example, let's assume that the registry is laid out something like this:

```
<registry>/
  port_versions/
    baseline.json
    a-/
      abseil.json
      asmjit.json
    o-/
      ogre.json
  ports/
    a-/
      abseil/
        2020-03-03_7/
          vcpkg.json
          portfile.cmake
          ...
        2020-03-03_8/
          vcpkg.json
          portfile.cmake
          ...
        ...
      asmjit/
        2020-05-08/
          CONTROL
          portfile.cmake
          ...
        2020-07-22/
          vcpkg.json
          portfile.cmake
          ...
    o-/
      ogre/
        1.12.7/
          ...
        1.12.1/
          ...
    ...
  ...
```

Then, let's look at updating `asmjit` to latest.

The current manifest file, in `asmjit/2020-07-22/vcpkg.json` looks like:

```json
{
  "name": "asmjit",
  "version-string": "2020-07-22",
  "description": "Complete x86/x64 JIT and Remote Assembler for C++",
  "homepage": "https://github.com/asmjit/asmjit",
  "supports": "!arm"
}
```

while the current `port_versions/a-/asmjit.json` looks like:

```json
[
  {
    "version-string": "2020-07-22",
    "path": "$/ports/a-/asmjit/2020-07-22"
  },
  {
    "version-string": "2020-05-08",
    "path": "$/ports/a-/asmjit/2020-05-08"
  }
]
```

with `port_versions/baseline.json` looking like:

```json
{
  "default": {
    ...,
    "asmjit": { "baseline": "2020-07-22" },
    ...
  }
}
```

and we'd like to update to `2020-10-08`.
We should first copy the existing implementation to a new folder:

```sh
$ cp -r ports/a-/asmjit/2020-07-22 ports/a-/asmjit/2020-10-08
```

then, we'll make the edits required to `ports/a-/asmjit/2020-10-08` to update to latest.
We should then update `port_versions/a-/asmjit.json`:

```json
[
  {
    "version-string": "2020-10-08",
    "path": "$/ports/a-/asmjit/2020-10-08"
  },
  {
    "version-string": "2020-07-22",
    "path": "$/ports/a-/asmjit/2020-07-22"
  },
  {
    "version-string": "2020-05-08",
    "path": "$/ports/a-/asmjit/2020-05-08"
  }
]
```

and update `port_versions/baseline.json`:

```json
{
  "default": {
    ...,
    "asmjit": { "baseline": "2020-10-08" },
    ...
  }
}
```

and we're done 😊.

#### Git Registry Databases

Git registries are not quite as simple as filesystem registries,
but they're still pretty simple, and are likely to be the most common:
the default registry is a git registry, for example.
There is not a specific way the tool requires one to lay out the backing store,
as long as it's possible to get an object hash that corresponds to a checked-in git tree
of the build information.
This allows, for example, the current vcpkg default registry way of laying out ports,
where the latest version of a port `<P>` is at `ports/<P>`,
and it also allows for any number of other designs.
One interesting design, for example,
is having an `old-ports` branch which is updated whenever someone want to backfill versions;
then, one could push the old version to the `old-ports` branch,
and then update the HEAD branch with the git tree of the old version in `port_versions/p-/<P>`.

As above, we want to update `asmjit` to latest; let's assume we're working in the default vcpkg registry
(the <https://github.com/microsoft/vcpkg> repository):

The current manifest file for `asmjit` looks like:

```json
{
  "name": "asmjit",
  "version-string": "2020-07-22",
  "description": "Complete x86/x64 JIT and Remote Assembler for C++",
  "homepage": "https://github.com/asmjit/asmjit",
  "supports": "!arm"
}
```

and the current `port_versions/a-/asmjit.json` looks like:

```json
[
  {
    "version-string": "2020-07-22",
    "git-tree": "fa0c36ba15b48959ab5a2df3463299e1d2473b6f"
  }
]
```

Now, let's update it to the latest version:

```json
{
  "name": "asmjit",
  "version-string": "2020-10-08",
  "description": "Complete x86/x64 JIT and Remote Assembler for C++",
  "homepage": "https://github.com/asmjit/asmjit",
  "supports": "!arm"
}
```

and make the proper edits to the portfile.cmake. Then, let's commit the changes:

```cmd
> git add ./ports/asmjit
> git commit -m "[asmjit] update asmjit to 2020-10-08"
```

In `git-tree` mode, one needs to commit the new version of the port to get the git tree hash;
we use `git rev-parse` to do so:

```cmd
> git rev-parse HEAD:ports/asmjit
2bb51d8ec8b43bb9b21032185ca8123da10ecc6c
```

and then modify `port_versions/a-/asmjit.json` as follows:

```json
[
  {
    "version-string": "2020-10-08",
    "git-tree": "2bb51d8ec8b43bb9b21032185ca8123da10ecc6c"
  },
  {
    "version-string": "2020-07-22",
    "git-tree": "fa0c36ba15b48959ab5a2df3463299e1d2473b6f"
  }
]
```

Then we can commit and push this new database with:

```sh
$ git add port_versions
$ git commit --amend --no-edit
$ git push
```

## Consuming Registries

The `vcpkg-configuration.json` file from the [first registries RFC](registries.md)
is still the same, except that the registries have a slightly different layout.
A `<configuration>` is still an object with the following fields:
* Optionally, `"default-registry"`: A `<registry-implementation>` or `null`
* Optionally, `"registries"`: An array of `<registry>`s

Additionally, `<registry>` is still the same;
a `<registry-implementation>` object, plus the following properties:
* Optionally, `"baseline"`: A named baseline. Defaults to `"default"`.
* Optionally, `"packages"`: An array of `<package-name>`s

however, `<registry-implementation>`s are now slightly different:
* `<registry-implementation.builtin>`:
  * `"kind"`: The string `"builtin"`
* `<registry-implementation.filesystem>`:
  * `"kind"`: The string `"filesystem"`
  * `"path"`: A path
* `<registry-implementation.git>`:
  * `"kind"`: The string `"git"`
  * `"repository"`: A URI

The `"packages"` field of distinct registries must be disjoint,
and each `<registry>` must have at the `"packages"` property,
since otherwise there's no point.

As an example, a package which uses a different default registry, and a different registry for boost,
might look like the following:

```json
{
  "default-registry": {
    "kind": "filesystem",
    "path": "vcpkg-ports"
  },
  "registries": [
    {
      "kind": "builtin",
      "packages": [ "cppitertools" ]
    }
  ]
}
```

This will install `fmt` from `<directory-of-vcpkg-configuration.json>/vcpkg-ports`,
and `cppitertools` and the `boost` ports from the registry that ships with vcpkg.
Notably, this does not replace behavior up the tree -- only the `vcpkg-configuration.json`s
for the current invocation do anything.

### Filesystem Registries

A filesystem registry takes on the form:

* `"kind"`: The string `"filesystem"`
* `"path"`: The path to the filesystem registry's root, i.e. the directory containing the `port_versions` directory.

```json
{
  "kind": "filesystem",
  "path": "vcpkg-registry"
}
```

Unlike git registries, where there's quite a bit of interesting stuff going on,
there isn't much stuff to do with filesystem registries.
We simply use the registry database at `<registry root>/port_versions` to get information about ports.

### Git Registries

A git registry takes on the form:

* `"kind"`: The string `"git"`
* `"repository"`: The URL at which the git repository lives. May be any kind of URL that git understands

```json
{
  "kind": "git",
  "repository": "https://github.com/microsoft/vcpkg"
}
```

Whenever the first vcpkg command is run with a git registry,
vcpkg notes down the exact commit that HEAD points to at the time of the run in the `vcpkg-lock.json` file.
This will be used as the commit which vcpkg takes the `"default"` baseline from,
and vcpkg will only update that commit when `vcpkg update` is run.

Since the `"versions"` field is strictly additive, we don't consider older refs than `HEAD`.
We update the repository on some reasonable clip.
Likely, whenever a command is run that will change the set of installed ports.

#### `vcpkg-lock.json`

This file will contain metadata that we need to save across runs,
to allow us to keep a "state-of-the-world" that doesn't change unless one explicitly asks for it to change.
This means that, even across different machines, the same registries will be used.
We will also be able to write down version resolution in this file as soon as that feature is added.

It is recommended that one adds this `vcpkg-lock.json` to one's version control.
This file is machine generated, and it is not specified how it's laid out;
however, for purposes of this RFC, we will define how it relates to git registries.

In `vcpkg-lock.json`, in the top level object,
there will be a `"registries"` property that is an object.
This object will contain a `"git"` field, which is an array of git-registry objects,
that contain:

* `"repository"`: The `"repository"` field from the git registry object
* `"baseline"`: The name of the baseline that we've used
* `"baseline-ref"`: The ref which we've gotten the specific baseline from.

For example, a `vcpkg-lock.json` might look like:

```json
{
  "registries": {
    "git": [
      {
        "repository": "https://github.com/microsoft/vcpkg",
        "baseline": "default",
        "baseline-ref": "6185aa76504a5025f36754324abf307cc776f3da"
      }
    ]
  }
}
```

#### `vcpkg update`

You'll notice that once the repository is added the first time,
there is only one way to update the repository to the tag at a later date - deleting the lock file.
We additionally want to add support for the user updating the registry by themselves -
they will be able to do this via the `vcpkg update` command.
The `vcpkg update` command will, for each git registry,
update the registry and repoint the `"commit"` field in `vcpkg-lock.json` to the latest `HEAD`.

There is no way to update only one git registry to a later date, since versions are strictly additive.

## Git Registries: Implementation on Disk

There are two implementations on disk to consider here: the implementation of the registry database,
and once we have the database entries for the ports, accessing the port data from the git tree object.

Both of these implementations are placed in the vcpkg cache home (shared by binary caching archives).
On unix, this is located at `$XDG_CACHE_HOME/vcpkg` if the environment variable exists,
otherwise `$HOME/.cache/vcpkg`; on Windows, it's located at `%LOCALAPPDATA%\vcpkg`.
In this document, we use the variable `$CACHE_ROOT` to refer to this folder.
We will add a new folder, `$CACHE_ROOT/registries`, which will contain all the data we need.

First, we'll discuss the registry database.

### Registry Database

At `$CACHE_ROOT/registries/git`,
we'll create a new git repository root which contains all information from all git registries,
since the hashes should be unique, and this allows for deduplication
across repositories which have the same commits (e.g., for mirrors).
In order to get the data from git registries, we simply `fetch` the URL of the git registry.

In order to grab a specific database entry from a git registry, `git show` is used to grab the
file from the right commit: `git show <commit id> -- port_versions/<first character>-/<portname>.json`.

One unfortunate thing about having one directory being used for all vcpkg instances on a machine is
that it's possible to have an issue with concurrency - for example, after `fetch`ing the latest HEAD
of `https://github.com/microsoft/vcpkg`, another vcpkg process might fetch the latest HEAD of
`https://github.com/meow/vcpkg` before the first vcpkg process has the chance to `git rev-parse FETCH_HEAD`.
Since the first vcpkg process will run `git rev-parse` after the second fetch is done,
instead of getting the `HEAD` of `microsoft/vcpkg`, they instead get the `HEAD` of `meow/vcpkg`.
We will solve this by having a mutex file in `$CACHE_ROOT/registries/git`
that vcpkg locks before any fetches (and unlocks after `rev-parse`ing).

### Accessing Port Data from `git-tree`s

Once we've done version resolution and everything with the database,
we then need to access the port data from the git history.
We will add a new folder, `$CACHE_ROOT/registries/git-trees`, into which we'll check out the port data.

In this `git-trees` directory, we will have all of the trees we check out, at their hashes.
For example, the asmjit port data from above will be located at
`git-trees/2bb51d8ec8b43bb9b21032185ca8123da10ecc6c`.
We will add a mutex file in this `git-trees` directory as well which is taken whenever
we are checking out a new git tree.
We wish to allow multiple vcpkg instances to read port data at a time,
and thus we do the check outs semi-atomically - if `git-trees/<hash>` exists,
then the `<hash>` must be completely checked out.
vcpkg does this by first checking out to a temporary directory,
and then renaming to the actual hash.

## Future Extensions

The way forward for this is to allow the `"builtin"` registry to be a git registry,
in order to support packaging and shipping vcpkg as a binary.
This is currently our plan, although it definitely is still a ways out.
Git registries _are_ an important step on that road,
but are also a good way to support both enterprise,
and experimentation by our users.
They allow us a lot more flexibility than we've had in the past.
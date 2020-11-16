# Binary Caching

Binary caching is vcpkg's method for reusing package builds between projects and between machines. Think of it as a "package restore accelerator" that gives you the same results as though you built from source. Each build is packaged independently, so changing one library only requires rebuilding consuming libraries.

If your CI provider offers a native "caching" function, we recommend using both methods for the most performant results.

In-tool help is available via `vcpkg help binarycaching` and a [detailed configuration reference is provided below](#Configuration).

## CI Examples

If your CI system of choice is not listed, we welcome PRs to add them!

### GitHub Packages

To use vcpkg with GitHub Packages, we recommend using the `NuGet` backend.

>**NOTE 2020-09-21**: GitHub's hosted agents come with an older, pre-installed copy of vcpkg on the path that does not support the latest binary caching. This means that direct calls to `bootstrap-vcpkg` or `vcpkg` without a path prefix may call an unintended vcpkg instance. We recommend taking the following two steps to avoid issues if you want to use your own copy of vcpkg:
> 1. Run the equivalent of `rm -rf "$VCPKG_INSTALLATION_ROOT"` using `shell: 'bash'`
> 2. Always call `vcpkg` and `bootstrap-vcpkg` with a path prefix, such as `./vcpkg`, `vcpkg/vcpkg`, `.\bootstrap-vcpkg.bat`, etc

```yaml
# actions.yaml
#
# In this example, vcpkg has been added as a submodule (`git submodule add https://github.com/Microsoft/vcpkg`).
env:
  VCPKG_BINARY_SOURCES: 'clear;nuget,GitHub,readwrite'

matrix:
  os: ['windows-2019', 'ubuntu-20.04']
  include:
    - os: 'windows-2019'
      triplet: 'x86-windows'
      mono: ''
    - os: 'ubuntu-20.04'
      triplet: 'x64-linux'
      # To run `nuget.exe` on non-Windows platforms, we must use `mono`.
      mono: 'mono'

steps:
  # This step assumes `vcpkg` has been bootstrapped (run `./vcpkg/bootstrap-vcpkg`)
  - name: 'Setup NuGet Credentials'
    shell: 'bash'
    # Replace <OWNER> with your organization name
    run: >
      ${{ matrix.mono }} `./vcpkg/vcpkg fetch nuget | tail -n 1`
      sources add
      -source "https://nuget.pkg.github.com/<OWNER>/index.json"
      -storepasswordincleartext
      -name "GitHub"
      -username "<OWNER>"
      -password "${{ secrets.GITHUB_TOKEN }}"

  # Omit this step if you're using manifests
  - name: 'vcpkg package restore'
    shell: 'bash'
    run: >
      ./vcpkg/vcpkg install sqlite3 cpprestsdk --triplet ${{ matrix.triplet }}
```

If you're using [manifests](../specifications/manifests.md), you can omit the `vcpkg package restore` step: it will be run automatically as part of your build.

More information about GitHub Packages' NuGet support is available on [GitHub Docs][github-nuget].

[github-nuget]: https://docs.github.com/en/packages/using-github-packages-with-your-projects-ecosystem/configuring-dotnet-cli-for-use-with-github-packages

### Azure DevOps Artifacts

To use vcpkg with Azure DevOps Artifacts, we recommend using the `NuGet` backend.

First, you need to ensure Artifacts has been enabled on your DevOps instance; this can be done by an Administrator through `Project Settings > General > Overview > Azure DevOps Services > Artifacts`.

Next, you will need to create a feed for your project; see the [Azure DevOps Artifacts Documentation][devops-nuget] for more information. Your feed URL will be an `https://` link ending with `/nuget/v3/index.json`.

```yaml
# azure-pipelines.yaml
variables:
- name: VCPKG_BINARY_SOURCES
  value: 'clear;nuget,<FEED_URL>,readwrite'
```

If you are using custom agents with a non-Windows OS, you will need to install Mono to run `nuget.exe` (`apt install mono-complete`, `brew install mono`, etc).

More information about Azure DevOps Artifacts' NuGet support is available in the [Azure DevOps Artifacts Documentation][devops-nuget].

[devops-nuget]: https://docs.microsoft.com/en-us/azure/devops/artifacts/get-started-nuget?view=azure-devops

## Configuration

Binary caching is configured via a combination of defaults, the environment variable `VCPKG_BINARY_SOURCES` (set to `<source>;<source>;...`), and the command line option `--binarysource=<source>`. Source options are evaluated in order of defaults, then environment, then command line.

By default, zip-based archives will be cached at the first valid location of:

**Windows**
1. `%VCPKG_DEFAULT_BINARY_CACHE%`
2. `%LOCALAPPDATA%\vcpkg\archives`
3. `%APPDATA%\vcpkg\archives`

**Non-Windows**
1. `$VCPKG_DEFAULT_BINARY_CACHE`
2. `$XDG_CACHE_HOME/vcpkg/archives`
3. `$HOME/.cache/vcpkg/archives`

### Valid source strings (`<source>`)

| form                        | description
|-----------------------------|---------------
| `clear`                     | Removes all previous sources (including the default)
| `default[,<rw>]`            | Adds the default file-based location
| `files,<path>[,<rw>]`       | Adds a custom file-based location
| `nuget,<uri>[,<rw>]`        | Adds a NuGet-based source; equivalent to the `-Source` parameter of the NuGet CLI
| `nugetconfig,<path>[,<rw>]` | Adds a NuGet-config-file-based source; equivalent to the `-Config` parameter <br>of the NuGet CLI. This config should specify `defaultPushSource` for uploads.
| `interactive`               | Enables interactive credential management for NuGet (for debugging; requires `--debug` on the command line)

The `<rw>` optional parameter for certain sources controls whether they will be consulted for
downloading binaries (`read`), whether on-demand builds will be uploaded to that remote (`write`), or both (`readwrite`).

The `nuget` and `nugetconfig` source providers additionally respect certain environment variables while generating nuget packages. The `metadata.repository` field of any packages will be generated as:
```
    <repository type="git" url="${VCPKG_NUGET_REPOSITORY}"/>
```
or
```
    <repository type="git"
                url="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}.git"
                branch="${GITHUB_REF}"
                commit="${GITHUB_SHA}"/>
```
if the appropriate environment variables are defined and non-empty. This is specifically used to associate packages in GitHub Packages with the _building_ project and not intended to associate with the original package sources.

Finally, binary caching can be completely disabled by passing `--no-binarycaching` on the command line.

## Implementation Notes (internal details subject to change without notice)

Binary caching relies on hashing everything that contributes to a particular package build. This includes:

- Every file in the port directory
- The triplet file and name
- The C++ compiler executable
- The C compiler executable
- The set of features selected
- Every dependency's package hash (note: this is that package's input hash, not contents)
- All helper scripts referenced by `portfile.cmake` (heuristic)
- The version of CMake used
- The contents of any environment variables listed in `VCPKG_ENV_PASSTHROUGH`
- The hash of the toolchain file (builtin or `VCPKG_CHAINLOAD_TOOLCHAIN_FILE`)

Despite this extensive list, it is possible to defeat the cache and introduce nondeterminism. If you have additional details that you'd like to be tracked, the easiest resolution is to generate a triplet file with your additional information in a comment. That additional information will be included in the package's input set and ensure a unique universe of binaries.

The hashes used are stored in the package and in the current installed directory at `/share/<port>/vcpkg_abi_info.txt`.

The original specification for binary caching is available [here](../specifications/binarycaching.md).

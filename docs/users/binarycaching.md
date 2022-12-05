# Binary Caching

**The latest version of this documentation is available on [GitHub](https://github.com/Microsoft/vcpkg/tree/master/docs/users/binarycaching.md).**

Libraries installed with vcpkg can always be built from source. However, that can duplicate work and waste time when working across multiple projects.

Binary caching is a vcpkg feature that saves copies of library binaries in a shared location that can be accessed by vcpkg for future installs. This means that, as a user, you should only need to build dependencies from source once. If vcpkg is asked to install the same library with the same build configuration in the future, it will just copy the built binaries from the cache and finish the operation in seconds.

Binary caching is especially effective when using Continuous Integration, since local developers can reuse the binaries produced during a CI run. It also greatly enhances the performance of "ephemeral" or "hosted" build agents, since all local changes are otherwise lost between runs. By using binary caching backed by a cloud service, such as GitHub, Azure, or many others, you can ensure your CI runs at maximum speed and only rebuilds your dependencies when they've changed.

Caches can be hosted in a variety of environments. The most basic examples are a folder on the local machine or a network file share. Caches can also be stored in any NuGet feed (such as GitHub or Azure DevOps Artifacts), Azure Blob Storage*, or Google Cloud Storage*.

\* (experimental)

If your CI provider offers a native "caching" function, we recommend using both vcpkg binary caching and the native method for the most performant results.

In-tool help is available via `vcpkg help binarycaching`.

Table of Contents
 - [Configuration](#configuration)
 - [CI Examples](#ci-examples)
   - [GitHub Packages](#github-packages)
   - [Azure DevOps Artifacts](#azure-devops-artifacts)
   - [Azure Blob Storage](#azure-blob-storage-experimental)
   - [Google Cloud Storage](#google-cloud-storage-experimental)
 - [NuGet Provider Configuration](#nuget-provider-configuration)
 - [Implementation Notes](#implementation-notes-internal-details-subject-to-change-without-notice)


## Configuration

Binary caching is configured via a combination of defaults, the environment variable `VCPKG_BINARY_SOURCES` (set to `<source>;<source>;...`), and the command line option `--binarysource=<source>`. Source options are evaluated in order of defaults, then environment, then command line. Binary caching can be completely disabled by passing `--binarysource=clear` as the last command line option.

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
| `clear`                     | Disable read all previous sources (including the default)
| `default[,<rw>]`            | Adds the default file-based location
| `files,<absolute path>[,<rw>]`       | Adds a custom file-based location
| `nuget,<uri>[,<rw>]`        | Adds a NuGet-based source; equivalent to the `-Source` parameter of the NuGet CLI
| `nugetconfig,<path>[,<rw>]` | Adds a NuGet-config-file-based source; equivalent to the `-Config` parameter of the NuGet CLI. This config should specify `defaultPushSource` for uploads.
| `nugettimeout,<seconds>`    | Specifies a timeout for NuGet network operations; equivalent to the `-Timeout` parameter of the NuGet CLI.
| `x-azblob,<baseuri>,<sas>[,<rw>]`    | **Experimental: will change or be removed without warning**<br> Adds an Azure Blob Storage source. Uses Shared Access Signature validation. URL should include the container path.
| `interactive`               | Enables interactive credential management for NuGet (for debugging; requires `--debug` on the command line)

The `<rw>` optional parameter for certain sources controls whether they will be consulted for
downloading binaries (`read`)(default), whether on-demand builds will be uploaded to that remote (`write`), or both (`readwrite`).

Additional configuration details for NuGet-based providers can be found below in [NuGet Provider Configuration](#nuget-provider-configuration).

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
    run: |
      ${{ matrix.mono }} `./vcpkg/vcpkg fetch nuget | tail -n 1` \
        sources add \
        -source "https://nuget.pkg.github.com/<OWNER>/index.json" \
        -storepasswordincleartext \
        -name "GitHub" \
        -username "<OWNER>" \
        -password "${{ secrets.GITHUB_TOKEN }}"
      ${{ matrix.mono }} `./vcpkg/vcpkg fetch nuget | tail -n 1` \
        setapikey "${{ secrets.GITHUB_TOKEN }}" \
        -source "https://nuget.pkg.github.com/<OWNER>/index.json"

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

steps:
# Remember to add this task to allow vcpkg to upload archives via NuGet
- task: NuGetAuthenticate@0
```

If you are using custom agents with a non-Windows OS, you will need to install Mono to run `nuget.exe` (`apt install mono-complete`, `brew install mono`, etc).

More information about Azure DevOps Artifacts' NuGet support is available in the [Azure DevOps Artifacts Documentation][devops-nuget].

[devops-nuget]: https://docs.microsoft.com/en-us/azure/devops/artifacts/get-started-nuget?view=azure-devops

### Azure Blob Storage (experimental)

> Note: This is an experimental feature and may change or be removed at any time

Vcpkg supports interfacing with Azure Blob Storage via the `x-azblob` source type.

```
x-azblob,<baseuri>,<sas>[,<rw>]
```

First, you need to create an Azure Storage Account as well as a container ([Quick Start Documentation](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-portal)].

Next, you will need to create a Shared Access Signature, which can be done from the storage account under Settings -> Shared access signature. This SAS will need:
- Allowed services: Blob
- Allowed resource types: Object
- Allowed permissions: Read, Create (if using `write` or `readwrite`)

The blob endpoint plus the container must be passed as the `<baseuri>` and the generated SAS without the `?` prefix must be passed as the `<sas>`.

Example:
```
x-azblob,https://<storagename>.blob.core.windows.net/<containername>,sv=2019-12-12&ss=b&srt=o&sp=rcx&se=2020-12-31T06:20:36Z&st=2020-12-30T22:20:36Z&spr=https&sig=abcd,readwrite
```

Vcpkg will attempt to avoid revealing the SAS during normal operations, however:
1. It will be printed in full if `--debug` is passed
2. It will be passed as a command line parameter to subprocesses, such as `curl.exe`

Azure Blob Storage includes a feature to remove cache entries that haven't been accessed in a given number of days which can be used to reduce the size of your cache. See [Data Lifecycle Management on Microsoft Docs](https://docs.microsoft.com/en-us/azure/storage/blobs/lifecycle-management-overview) for more information, or look for "Data management > Lifecycle management" in the Azure Portal for your storage account. If you wish to be able to be resilient to upstream libraries' servers but still want to remove entries from the binary cache, consider using [asset caching](assetcaching.md#x-azurl) in a different storage account without a lifecycle management policy.

### Google Cloud Storage (experimental)

> Note: This is an experimental feature and may change or be removed at any time

Vcpkg supports interfacing with Google Cloud Storage (GCS) via the `x-gcs` source type.

```
x-gcs,<prefix>[,<rw>]
```

First, you need to create an Google Cloud Platform Account as well as a storage bucket ([GCS Quick Start](https://cloud.google.com/storage/docs/quickstart-gsutil)].

As part of this quickstart you would have configured the `gsutil` command-line tool to authenticate with Google Cloud.
Vcpkg will use this command-line tool, make sure it is in your search path for executables.

Example 1 (using a bucket without a common prefix for the objects):

```
x-gcs,gs://<bucket-name>/,readwrite
```

Example 2 (using a bucket and a prefix for the objects):

```
x-gcs,gs://<bucket-name>/my-vcpkg-cache/maybe/with/many/slashes/,readwrite
x-gcs,gs://<bucket-name>/my-vcpkg-cache/maybe/with`,commas/too!/,readwrite
```

Commas (`,`) are valid as part of a object prefix in GCS, just remember to escape them in the vcpkg configuration, as
shown in the previous example. Note that GCS does not have folders (some of the GCS tools simulate folders), it is not
necessary to create or otherwise manipulate the prefix used by your vcpkg cache.

## NuGet Provider Configuration

### Credentials

Many NuGet servers require additional credentials to access. The most flexible way to supply credentials is via the `nugetconfig` provider with a custom `nuget.config` file. See https://docs.microsoft.com/en-us/nuget/consume-packages/consuming-packages-authenticated-feeds for more information on authenticating via `nuget.config`.

However, it is still possible to authenticate against many servers using NuGet's built-in credential providers or via customizing your environment's default `nuget.config`. The default config can be extended via nuget client calls such as
```
nuget sources add -Name MyRemote -Source https://... -Username $user -Password $pass
```
and then passed to vcpkg via `--binarysource=nuget,MyRemote,readwrite`. You can get a path to the precise copy of NuGet used by vcpkg by running `vcpkg fetch nuget`, which will report something like:
```
$ vcpkg fetch nuget
/vcpkg/downloads/tools/nuget-5.5.1-linux/nuget.exe
```
Non-Windows users will need to call this through mono via `mono /path/to/nuget.exe sources add ...`.

##### Credential Example for Azure Dev Ops
```bash
# On Linux or OSX
$ mono `vcpkg fetch nuget | tail -n1` sources add \
  -name ADO \
  -Source https://pkgs.dev.azure.com/$ORG/_packaging/$FEEDNAME/nuget/v3/index.json \
  -Username $USERNAME \
  -Password $PAT
$ export VCPKG_BINARY_SOURCES="nuget,ADO,readwrite"
```
```powershell
# On Windows Powershell
PS> & $(vcpkg fetch nuget | select -last 1) sources add `
  -name ADO `
  -Source https://pkgs.dev.azure.com/$ORG/_packaging/$FEEDNAME/nuget/v3/index.json `
  -Username $USERNAME `
  -Password $PAT
PS> $env:VCPKG_BINARY_SOURCES="nuget,ADO,readwrite"
```

We recommend using a Personal Access Token (PAT) as the password for maximum security. You can generate a PAT in User Settings -> Personal Access Tokens or `https://dev.azure.com/$ORG/_usersSettings/tokens`.

#### `metadata.repository`

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

#### NuGet's cache

NuGet's cache is not used by default. To use it for every nuget-based source, set the [environment variable](config-environment.md) `VCPKG_USE_NUGET_CACHE` to `true` (case-insensitive) or `1`.

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

## Environment and Configuration

### Environment Variables

#### VCPKG_DOWNLOADS

This environment variable can be set to an existing directory to use for storing downloads instead of the internal
`downloads/` directory. It should always be set to an absolute path.

#### VCPKG_FEATURE_FLAGS

This environment variable can be set to a comma-separated list of off-by-default features in vcpkg. These features are
subject to change without notice and should be considered highly unstable.

Non-exhaustive list of off-by-default features:

- `binarycaching`
- `manifest`

#### EDITOR

This environment variable can be set to the full path of an executable to be used for `vcpkg edit`. Please see
`vcpkg help edit` for command-specific help.

#### VCPKG_ROOT

This environment variable can be set to a directory to use as the root of the vcpkg instance. Note that mixing vcpkg
repo versions and executable versions can cause issues.

#### VCPKG_VISUAL_STUDIO_PATH

This environment variable can be set to the full path to a Visual Studio instance on the machine. This Visual Studio instance
will be used if the triplet does not override it via the [`VCPKG_VISUAL_STUDIO_PATH` triplet setting](triplets.md#VCPKG_VISUAL_STUDIO_PATH).

Example: `D:\2017`

#### VCPKG_DEFAULT_TRIPLET

This environment variable can be set to a triplet name which will be used for unqualified triplet references in command lines.

#### VCPKG_OVERLAY_PORTS

This environment variable allows users to override ports with alternate versions according to the
[ports overlay](../specifications/ports-overlay.md) specification. List paths to overlays using 
the platform dependent PATH seperator (Windows `;` | others `:`) 

Example (Windows): `C:\custom-ports\boost;C:\custom-ports\sqlite3`

#### VCPKG_OVERLAY_TRIPLETS

This environment variable allows users to add directories to search for triplets.
[Example: overlay triplets](../examples/overlay-triplets-linux-dynamic.md).
List paths to overlays using the platform dependent PATH seperator (Windows `;`, others `:`) 

#### VCPKG_FORCE_SYSTEM_BINARIES

This environment variable, if set, suppresses the downloading of CMake and Ninja and forces the use of the system binaries.

#### VCPKG_KEEP_ENV_VARS

This environment variable can be set to a list of environment variables, separated by `;`, which will be propagated to
the build environment.

Example: `FOO_SDK_DIR;BAR_SDK_DIR`

#### VCPKG_MAX_CONCURRENCY

This environment variables limits the amount of concurrency requested by underlying buildsystems. If unspecified, this defaults to logical cores + 1.

#### VCPKG_DEFAULT_BINARY_CACHE

This environment variable redirects the default location to store binary packages. See [Binary Caching](binarycaching.md#Configuration) for more details.

#### VCPKG_BINARY_SOURCES

This environment variable adds or removes binary sources. See [Binary Caching](binarycaching.md#Configuration) for more details.

#### VCPKG_NUGET_REPOSITORY

This environment variable changes the metadata of produced NuGet packages. See [Binary Caching](binarycaching.md#Configuration) for more details.

#### VCPKG_USE_NUGET_CACHE

This environment variable allows using NuGet's cache for every nuget-based binary source. See [Binary Caching](binarycaching.md#NuGets-cache) for more details.

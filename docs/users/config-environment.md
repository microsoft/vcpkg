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

#### VCPKG_FORCE_SYSTEM_BINARIES

This environment variable, if set, suppresses the downloading of CMake and Ninja and forces the use of the system binaries.

#### VCPKG_KEEP_ENV_VARS

This environment variable can be set to a list of environment variables, separated by `;`, which will be propagated to
the build environment.

Example: `FOO_SDK_DIR;BAR_SDK_DIR`

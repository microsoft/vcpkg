find_path(ZSTD_INCLUDE_DIR zstd.h)

find_library(ZSTD_LIBRARY_DEBUG NAMES zstd)
find_library(ZSTD_LIBRARY_RELEASE NAMES zstd)

include(SelectLibraryConfigurations)
select_library_configurations(ZSTD)

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(
    ZSTD DEFAULT_MSG
    ZSTD_LIBRARY ZSTD_INCLUDE_DIR
)

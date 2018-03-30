find_path(LZ4_INCLUDE_DIR lz4.h)

find_package(LZ4_LIBRARY_DEBUG NAMES lz4d)
find_package(LZ4_LIBRARY_RELEASE NAMES lz4)

select_library_configurations(LZ4_LIBRARY)

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(
    LZ4 DEFAULT_MSG
    LZ4_LIBRARY LZ4_INCLUDE_DIR
)

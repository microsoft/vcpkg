find_path(LZ4_INCLUDE_DIR NAMES lz4.h)

find_library(LZ4_LIBRARY_DEBUG NAMES lz4d)
find_library(LZ4_LIBRARY_RELEASE NAMES lz4)

include(SelectLibraryConfigurations)
select_library_configurations(LZ4)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    LZ4
    REQUIRED_VARS LZ4_LIBRARY LZ4_INCLUDE_DIR
)

if(LZ4_FOUND)
    set(LZ4_INCLUDE_DIRS ${LZ4_INCLUDE_DIR})
endif()

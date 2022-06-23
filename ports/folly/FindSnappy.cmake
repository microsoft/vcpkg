find_path(SNAPPY_INCLUDE_DIR snappy.h)

find_library(SNAPPY_LIBRARY_DEBUG NAMES snappyd)
find_library(SNAPPY_LIBRARY_RELEASE NAMES snappy)

include(SelectLibraryConfigurations)
select_library_configurations(SNAPPY)

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(
    SNAPPY DEFAULT_MSG
    SNAPPY_LIBRARY SNAPPY_INCLUDE_DIR
)

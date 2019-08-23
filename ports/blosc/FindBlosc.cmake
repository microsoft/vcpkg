include(FindPackageHandleStandardArgs)

find_path(
  BLOSC_INCLUDE_DIRS
  blosc.h
)

get_filename_component(_prefix_path ${BLOSC_INCLUDE_DIRS} PATH)

find_library(
    BLOSC_LIBRARY_DEBUG
    NAMES blosc
    PATHS ${_prefix_path}/debug/lib
    NO_DEFAULT_PATH
)

find_library(
    SNAPPY_LIBRARY_RELEASE
    NAMES blosc
    PATHS ${_prefix_path}/lib
    NO_DEFAULT_PATH
)

unset(_prefix_path)

include(SelectLibraryConfigurations)
select_library_configurations(blosc)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    blosc
    REQUIRED_VARS BLOSC_LIBRARIES BLOSC_INCLUDE_DIRS
)

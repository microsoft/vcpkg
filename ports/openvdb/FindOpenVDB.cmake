include(FindPackageHandleStandardArgs)

find_path(
  OPENVDB_INCLUDE_DIRS
  openvdb/version.h
)

get_filename_component(_prefix_path ${OPENVDB_INCLUDE_DIRS} PATH)

find_library(
    OPENVDB_LIBRARY_DEBUG
    NAMES openvdb
    PATHS ${_prefix_path}/debug/lib
    NO_DEFAULT_PATH
)

find_library(
    OPENVDB_LIBRARY_RELEASE
    NAMES openvdb
    PATHS ${_prefix_path}/lib
    NO_DEFAULT_PATH
)

unset(_prefix_path)

include(SelectLibraryConfigurations)
select_library_configurations(OPENVDB)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    OPENVDB
    REQUIRED_VARS OPENVDB_LIBRARIES OPENVDB_INCLUDE_DIRS
)

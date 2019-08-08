find_path(
    UUID_INCLUDE_DIRS
    NAMES uuid/uuid.h
)

get_filename_component(_prefix_path ${UUID_INCLUDE_DIRS} PATH)

find_library(
    UUID_LIBRARY_DEBUG
    NAMES uuid
    PATHS ${_prefix_path}/debug/lib
    NO_DEFAULT_PATH
)

find_library(
    UUID_LIBRARY_RELEASE
    NAMES uuid
    PATHS ${_prefix_path}/lib
    NO_DEFAULT_PATH
)

unset(_prefix_path)

include(SelectLibraryConfigurations)
select_library_configurations(UUID)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(
    UUID
    REQUIRED_VARS UUID_LIBRARIES UUID_INCLUDE_DIRS
)

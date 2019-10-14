find_path(GEOS_INCLUDE_DIR geos_c.h)

find_library(GEOS_LIBRARY_DEBUG NAMES geos_cd)
find_library(GEOS_LIBRARY_RELEASE NAMES geos_c)

include(SelectLibraryConfigurations)
select_library_configurations(GEOS)

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(
    GEOS DEFAULT_MSG
    GEOS_LIBRARY GEOS_INCLUDE_DIR
)

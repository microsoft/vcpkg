find_path(GEOTIFF_INCLUDE_DIR geotiff.h)

find_library(GEOTIFF_LIBRARY_DEBUG NAMES geotiff_d)
find_library(GEOTIFF_LIBRARY_RELEASE NAMES geotiff)

include(SelectLibraryConfigurations)
select_library_configurations(GEOTIFF)

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(
    GEOTIFF DEFAULT_MSG
    GEOTIFF_LIBRARY GEOTIFF_INCLUDE_DIR
)

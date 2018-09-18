find_path(GDAL_INCLUDE_DIR gdal.h)

find_library(GDAL_LIBRARY_DEBUG NAMES gdald)
find_library(GDAL_LIBRARY_RELEASE NAMES gdal)

include(SelectLibraryConfigurations)
select_library_configurations(GDAL)

include(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(
    GDAL DEFAULT_MSG
    GDAL_LIBRARY GDAL_INCLUDE_DIR
)

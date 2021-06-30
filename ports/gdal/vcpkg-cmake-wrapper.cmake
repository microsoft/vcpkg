include(SelectLibraryConfigurations)

find_path(GDAL_INCLUDE_DIR
    NAMES gdal.h
    PATHS "${CMAKE_CURRENT_LIST_DIR}/../../include"
    NO_DEFAULT_PATH
)
find_library(GDAL_LIBRARY_DEBUG
    NAMES gdal_d gdal_i_d gdal
    NAMES_PER_DIR
    PATHS "${CMAKE_CURRENT_LIST_DIR}/../../debug/lib"
    NO_DEFAULT_PATH
)
find_library(GDAL_LIBRARY_RELEASE
    NAMES gdal_i gdal
    NAMES_PER_DIR
    PATHS "${CMAKE_CURRENT_LIST_DIR}/../../lib"
    NO_DEFAULT_PATH
)
select_library_configurations(GDAL)

if(NOT GDAL_INCLUDE_DIR OR NOT GDAL_LIBRARY)
    message(FATAL_ERROR "Installation of vcpkg port gdal is broken.")
endif()

set(FindGDAL_SKIP_GDAL_CONFIG TRUE)

_find_package(${ARGS})

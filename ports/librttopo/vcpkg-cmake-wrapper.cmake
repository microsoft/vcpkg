include(FindPackageHandleStandardArgs)
include(SelectLibraryConfigurations)

find_path(RTTOPO_INCLUDE_DIR NAMES librttopo.h HINTS ${CURRENT_INSTALLED_DIR}/include)

find_library(RTTOPO_LIBRARY_DEBUG NAMES librttopo_d librttopo_i_d librttopo librttopo_i NAMES_PER_DIR PATH_SUFFIXES lib PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug" NO_DEFAULT_PATH REQUIRED)
find_library(RTTOPO_LIBRARY_RELEASE NAMES librttopo_i librttopo NAMES_PER_DIR PATH_SUFFIXES lib PATHS "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}" NO_DEFAULT_PATH REQUIRED)

select_library_configurations(RTTOPO)

set(RTTOPO_INCLUDE_DIRS ${RTTOPO_INCLUDE_DIR})
set(RTTOPO_LIBRARIES ${RTTOPO_LIBRARY})

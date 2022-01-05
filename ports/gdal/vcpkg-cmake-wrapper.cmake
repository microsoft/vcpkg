
cmake_policy(PUSH)
cmake_policy(SET CMP0012 NEW)
cmake_policy(SET CMP0054 NEW)

list(REMOVE_ITEM ARGS "NO_MODULE" "CONFIG" "MODULE")
list(APPEND ARGS "CONFIG")
# The current port version should satisfy GDAL 3.0 ... 3.5
list(GET ARGS 1 z_vcpkg_gdal_maybe_version)
if(z_vcpkg_gdal_maybe_version MATCHES "(^3\$|^3[.][0-5])")
    list(REMOVE_AT ARGS "1")
endif()
unset(z_vcpkg_gdal_maybe_version)
_find_package(${ARGS} CONFIG)
if(GDAL_FOUND)
    get_filename_component(GDAL_INCLUDE_DIR "${CMAKE_CURRENT_LIST_DIR}" DIRECTORY)
    get_filename_component(GDAL_INCLUDE_DIR "${GDAL_INCLUDE_DIR}" DIRECTORY)
    set(GDAL_INCLUDE_DIR "${GDAL_INCLUDE_DIR}/include" CACHE INTERNAL "")
    set(GDAL_INCLUDE_DIRS "${GDAL_INCLUDE_DIR}")
    set(GDAL_LIBRARY GDAL::GDAL CACHE INTERNAL "")
    set(GDAL_LIBRARIES "${GDAL_LIBRARY}")
endif()

cmake_policy(POP)

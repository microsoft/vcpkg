# Give the CMake module a little bit of help to find the debug libraries
find_library(PostgreSQL_LIBRARY_DEBUG
NAMES pq
PATHS
  "${_VCPKG_INSTALLED_DIR}/${VCPKG_TARGET_TRIPLET}/debug/lib"
NO_DEFAULT_PATH
)
_find_package(${ARGS})
if(PostgreSQL_FOUND AND @USE_DL@)
    find_library(PostgreSQL_DL_LIBRARY NAMES dl)
    if(PostgreSQL_DL_LIBRARY)
        list(APPEND PostgreSQL_LIBRARIES "dl")
        if(TARGET PostgreSQL::PostgreSQL)
            set_property(TARGET PostgreSQL::PostgreSQL APPEND PROPERTY INTERFACE_LINK_LIBRARIES "dl")
        endif()
    endif()
endif()

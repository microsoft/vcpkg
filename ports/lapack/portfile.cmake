SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(BLA_STATIC ON)
else()
    set(BLA_STATIC OFF)
endif()
set(BLA_VENDOR Generic)
if(VCPKG_TARGET_IS_WINDOWS) # The other wrapper is in lapack-reference
    if(NOT EXISTS "${CURRENT_INSTALLED_DIR}/share/lapack/vcpkg-cmake-wrapper.cmake")
        configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake.in" "${CURRENT_PACKAGES_DIR}/share/lapack/vcpkg-cmake-wrapper.cmake" @ONLY)
    endif()
endif()
# Make sure LAPACK can be found
vcpkg_configure_cmake(SOURCE_PATH ${CURRENT_PORT_DIR}
                      OPTIONS -DCMAKE_PREFIX_PATH="${CURRENT_PACKAGES_DIR}"
                              -DBLA_VENDOR=${BLA_VENDOR}
                              -DBLA_STATIC=${BLA_STATIC})


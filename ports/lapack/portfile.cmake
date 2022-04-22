SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(BLA_STATIC ON)
else()
    set(BLA_STATIC OFF)
endif()

set(BLA_VENDOR Generic)
if(VCPKG_TARGET_IS_OSX)
    set(BLA_VENDOR Apple)
    configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake.in" "${CURRENT_PACKAGES_DIR}/share/lapack/vcpkg-cmake-wrapper.cmake" @ONLY)
elseif((VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE MATCHES "arm") OR VCPKG_TARGET_IS_UWP)
    configure_file("${CURRENT_INSTALLED_DIR}/share/clapack/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/lapack/vcpkg-cmake-wrapper.cmake" COPYONLY)
    configure_file("${CURRENT_INSTALLED_DIR}/share/clapack/FindLAPACK.cmake" "${CURRENT_PACKAGES_DIR}/share/lapack/FindLAPACK.cmake" COPYONLY)
else()
    configure_file("${CURRENT_INSTALLED_DIR}/share/lapack-reference/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/lapack/vcpkg-cmake-wrapper.cmake" COPYONLY)
    configure_file("${CURRENT_INSTALLED_DIR}/share/lapack-reference/FindLAPACK.cmake" "${CURRENT_PACKAGES_DIR}/share/lapack/FindLAPACK.cmake" COPYONLY)
endif()

# Make sure LAPACK can be found
vcpkg_cmake_configure(SOURCE_PATH "${CURRENT_PORT_DIR}"
                      OPTIONS -DCMAKE_PREFIX_PATH="${CURRENT_PACKAGES_DIR}"
                              -DCMAKE_MODULE_PATH="${CURRENT_PACKAGES_DIR}/share/lapack"
                              -DBLA_VENDOR="${BLA_VENDOR}"
                              -DBLA_STATIC="${BLA_STATIC}")


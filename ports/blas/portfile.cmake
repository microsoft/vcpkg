SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)

# OpenBLAS
if(VCPKG_TARGET_IS_OSX)
    set(BLA_VENDOR Apple)
else()
    set(BLA_VENDOR OpenBLAS)
endif()

# For possible overlays:

#NETLIB reference implementation (contained in lapack-reference)
#set(BLA_VENDOR Generic)

# Intel MKL
#if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
#    set(BLA_VENDOR Intel10_64lp)
#elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL x86)
#    set(BLA_VENDOR Intel10_32)
#else()
#    message(FATAL_ERROR "Unsupported target architecture for Intel MKL!")
#endif()

# Apple Accelerate Framework
# set(BLA_VENDOR Apple)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    set(BLA_STATIC ON)
else()
    set(BLA_STATIC OFF)
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)
# Make sure BLAS can be found
vcpkg_cmake_configure(SOURCE_PATH "${CURRENT_PORT_DIR}"
                      OPTIONS -DCMAKE_PREFIX_PATH="${CURRENT_PACKAGES_DIR}"
                              -DBLA_VENDOR=${BLA_VENDOR}
                              -DBLA_STATIC=${BLA_STATIC})

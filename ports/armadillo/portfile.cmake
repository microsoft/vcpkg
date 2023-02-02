vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}
vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arma
    FILENAME "armadillo-${VERSION}.tar.xz"
    SHA512 3ca620e686487dd3392b30c184be6f7f89eb13a63668f54b3d39cd6d29c7e024423819e948aea01247935ca3bf7b0b0d5f0004dc60395195beb7d14feef484b1
    PATCHES
        cmake-config.patch
        dependencies.patch
        pkgconfig.patch
)

set(REQUIRES_PRIVATE "")
foreach(module IN ITEMS lapack blas)
    if(EXISTS "${CURRENT_INSTALLED_DIR}/lib/pkgconfig/${module}.pc")
        string(APPEND REQUIRES_PRIVATE " ${module}")
    endif()
endforeach()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DALLOW_FLEXIBLAS_LINUX=OFF
        -DDETECT_HDF5=OFF
        "-DREQUIRES_PRIVATE=${REQUIRES_PRIVATE}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/Armadillo/CMake)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/Armadillo/CMake"
)

file(GLOB SHARE_ARMADILLO_FILES "${CURRENT_PACKAGES_DIR}/share/Armadillo/*")
if(SHARE_ARMADILLO_FILES STREQUAL "")
    # On case sensitive file system there is an extra empty directory created that should be removed
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/Armadillo")
endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/armadillo_bits/config.hpp" "#define ARMA_AUX_LIBS " "#define ARMA_AUX_LIBS //")

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE.txt"  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arma
    FILENAME "armadillo-${VERSION}.tar.xz"
    SHA512 163e81e09d3cd13aa80833ce06d9c4f1889110efa99532adfb66ffac6abb067eedb81775f9a988377d3197f75bfd3cefda56c003cbfe4f2b8256bed680a028de
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
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

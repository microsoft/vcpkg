vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arma
    FILENAME "armadillo-11.2.3.tar.xz"
    SHA512 db3457adbc799c68c928aaf22714598b4b9df91ec83aff33bf2d0096b755bd316d4bae12ac973bf1821759a71f3a58a7dd8dc64cbcb1f53ea2646d8bb0bc9a3b
    PATCHES
        remove_custom_modules.patch
        fix-CMakePath.patch
        add-disable-find-package.patch
)

file(REMOVE "${SOURCE_PATH}/cmake_aux/Modules/ARMA_FindBLAS.cmake")
file(REMOVE "${SOURCE_PATH}/cmake_aux/Modules/ARMA_FindLAPACK.cmake")
file(REMOVE "${SOURCE_PATH}/cmake_aux/Modules/ARMA_FindOpenBLAS.cmake")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DDETECT_HDF5=false
        -DCMAKE_DISABLE_FIND_PACKAGE_SuperLU=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_ARPACK=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_ATLAS=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_MKL=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME Armadillo CONFIG_PATH share/Armadillo/CMake)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(GLOB SHARE_CONTENT "${CURRENT_PACKAGES_DIR}/share/Armadillo")
list(LENGTH SHARE_CONTENT SHARE_LEN)
if(SHARE_LEN EQUAL 0)
    # On case sensitive file system there is an extra empty directory created that should be removed
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/Armadillo")
endif()

set(filename "${CURRENT_PACKAGES_DIR}/include/armadillo_bits/config.hpp")
if(EXISTS "${filename}")
    file(READ "${filename}" contents)
    string(REGEX REPLACE "\n#define ARMA_AUX_LIBS [^\n]*\n" "\n" contents "${contents}")
    file(WRITE "${filename}" "${contents}")
endif()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${SOURCE_PATH}/LICENSE.txt"  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO arma
    FILENAME "armadillo-10.2.0.tar.xz"
    SHA512 c5d6f4bac0acba63fbd7681653d521249fd303ffbbc5b18df71500eb111514c1d09db600a580091d6a23c83748c109c30938bbcd80a3a0b2c25e2fdea932f2cd
    PATCHES
        remove_custom_modules.patch
        fix-CMakePath.patch
        add-disable-find-package.patch
)

file(REMOVE ${SOURCE_PATH}/cmake_aux/Modules/ARMA_FindBLAS.cmake)
file(REMOVE ${SOURCE_PATH}/cmake_aux/Modules/ARMA_FindLAPACK.cmake)
file(REMOVE ${SOURCE_PATH}/cmake_aux/Modules/ARMA_FindOpenBLAS.cmake)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    PREFER_NINJA
    OPTIONS
        -DDETECT_HDF5=false
        -DCMAKE_DISABLE_FIND_PACKAGE_SuperLU=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_ACML=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_ACMLMP=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_ARPACK=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_ATLAS=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_MKL=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/Armadillo/CMake TARGET_PATH share/Armadillo)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(GLOB SHARE_CONTENT ${CURRENT_PACKAGES_DIR}/share/Armadillo)
list(LENGTH SHARE_CONTENT SHARE_LEN)
if(SHARE_LEN EQUAL 0)
    # On case sensitive file system there is an extra empty directory created that should be removed
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/share/Armadillo)
endif()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/LICENSE.txt  DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

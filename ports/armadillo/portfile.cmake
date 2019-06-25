include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO conradsnicta/armadillo-code
    REF f00d3225b1c005775044369723f31cecc3cd6569
    SHA512 ca3574edf5de8c752867403c3856ed9569fbed2ce9729585cae59be5751493c2e71121319b0a812e2ea56baada6b6f62fbc84ce6f1efb362347e5fd4141ccf1b
    HEAD_REF 9.400.x
    PATCHES
        remove_custom_modules.patch
)

file(REMOVE ${SOURCE_PATH}/cmake_aux/Modules/ARMA_FindBLAS.cmake)
file(REMOVE ${SOURCE_PATH}/cmake_aux/Modules/ARMA_FindLAPACK.cmake)
file(REMOVE ${SOURCE_PATH}/cmake_aux/Modules/ARMA_FindOpenBLAS.cmake)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DDETECT_HDF5=false
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/armadillo/CMake)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt  DESTINATION ${CURRENT_PACKAGES_DIR}/share/armadillo RENAME copyright)

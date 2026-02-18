vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fast-pack/FastPFOR
    REF "v${VERSION}"
    SHA512 63eae397540e901e6b60420a92a165bbc16f35d97238221dac5d9d8819f40886a12edc17087d0aa2eeef706b8f411d1d19b77d6833d8bf34ad8340fa59f4cccf
    HEAD_REF master
    PATCHES
        remove-cpm.patch
        fix-arm-checker.patch
)

file(REMOVE
    ${SOURCE_PATH}/cmake_modules/CPM.cmake
    ${SOURCE_PATH}/cmake_modules/Findsnappy.cmake
    ${SOURCE_PATH}/cmake_modules/simde.cmake
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFASTPFOR_WITH_TEST=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/FastPFOR")

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/doc"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

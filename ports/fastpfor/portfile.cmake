vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO fast-pack/FastPFOR
    REF "v${VERSION}"
    SHA512 2e899ad43c128cab16846fd09c11bb794d25b26f4c89df57d85ceb97239a44426ee607f2769e58bc3283d77bfdd35d455f2142900ae73e961387bb8074f4062a
    HEAD_REF master
    PATCHES
        remove-cpm.patch
        fix-arm-checker.patch
        check-sse4.patch
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

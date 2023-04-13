vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jll63/yomm2
    REF "v${VERSION}"
    SHA512  456422f829293339d1d29eda8a00ad1bf5a2b7adcf0eb3727729b25208e1e67bff8187e21d49b64817ebb3a2274cef5504e22d612b1c68de20c8fe458daa81ba
    HEAD_REF master
    PATCHES "fix_find_boost.patch"
)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS -DYOMM2_ENABLE_EXAMPLES=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/YOMM2)
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

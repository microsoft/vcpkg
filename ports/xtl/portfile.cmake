# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xtensor-stack/xtl
    REF e0f00666d90086bb245ae73abb6123d0e2c1b30b # 0.7.2
    SHA512 d7a552dc4e43a3270a56c57fde8fdc48a108909d4fa1e3fdd7ab12b178b3e271ed4d89aac9fd184e2739ddacfb3b5cb248538ed50a0ba56e740875c0faf5aa62
    HEAD_REF master
    PATCHES
        fix-fixup-cmake.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS=OFF
        -DDOWNLOAD_GTEST=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

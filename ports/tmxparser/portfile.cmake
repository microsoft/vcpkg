vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sainteos/tmxparser
    REF d314b3115c7ed86a939eefcb6009a495f043a346 # 2019-10-14
    HEAD_REF master
    SHA512 b4c087ae46b02b632427d8e4af1b5b8c43ab4f1efba21d2d705e1501aa8f33b97e03bf4e621ad4d4e14c19b1c890416332a56a2305c81930facfb8954bedee26
    PATCHES
        fix_dependencies.patch
        disable_werror.patch # https://github.com/microsoft/vcpkg/pull/28139#issuecomment-1336119855
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_REQUIRE_FIND_PACKAGE_ZLIB=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kuba--/zip
    REF a0fcdbf0fae4ebba741cc41cd1b286e52f3e3424
    SHA512 23db0c92893a07de786c6520425de8373f4642f8438248cb1e8ffca6668b73032e666cbb5175cf0f2cc06dd913cc1a76a6eac6bd7b0be355a146f4a865cd7568
    HEAD_REF master
    PATCHES
        c89-support-and-rename-zip-kubazip.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DISABLE_TESTING=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

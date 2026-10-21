vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO p-ranav/tabulate
    REF "v${VERSION}"
    SHA512 50508ac58fdb7542a095b02e04da32f87ae6595b5c0de143b5071878ea819db01b71b21d8aed1a99c6fd22342bbd5fa531d9a354723ba2e5513a8e858233ee09
    HEAD_REF master
    PATCHES
        fix-version.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -Dtabulate_BUILD_TESTS=OFF
        -DSAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/LICENSE.termcolor"
)

set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO taocpp/json
    REF "${VERSION}"
    SHA512 07909e824c8c0a3c4568a50e941dde2507ddffbd1456816e3a85d5ec9e119655604011554be8b05c0c94d19a16abd3f030d2bbebe96d65d639184aad0c720bc9
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DTAOCPP_JSON_BUILD_TESTS=OFF
        -DTAOCPP_JSON_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/taocpp-json/cmake)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/share/doc"
)

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/LICENSE.double-conversion"
        "${SOURCE_PATH}/LICENSE.itoa"
        "${SOURCE_PATH}/LICENSE.ryu"
)

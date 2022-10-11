vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gazebosim/gz-utils
    REF ignition-utils1_1.4.0
    SHA512 f7c841391b0f523ed631c00d8053c52c3a52f409fb76faf68565ae2db96424c79e91a4bdcab650acfc35c17fe7f1df6881de4b59d5210539ebe8e9cfef991461
    HEAD_REF ign-utils1
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

# Fix cmake targets and pkg-config file location
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/ignition-utils1")
vcpkg_fixup_pkgconfig()

# Remove debug files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/lib/cmake"
                    "${CURRENT_PACKAGES_DIR}/debug/share"
                    "${CURRENT_PACKAGES_DIR}/include/ignition/utils1/ignition/utils/cli"
)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

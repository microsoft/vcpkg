vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO martinmoene/optional-lite
    REF "v${VERSION}"
    SHA512 6ec7dbd11947376cc46502cdab866e171fca7123b317887889022d22b003e4fd96d26816046e8e24b1b83fb5190ae6232cbbacfcb20fcb78200878bd73d7adc4
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DOPTIONAL_LITE_OPT_BUILD_TESTS=OFF
        -DOPTIONAL_LITE_OPT_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH "lib/cmake/${PORT}"
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

file(INSTALL
    "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright
)

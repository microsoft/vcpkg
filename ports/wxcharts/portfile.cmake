vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wxIshiko/wxCharts
    REF 2d5998fedf23e5d3472258f6bde44087ec828680
    SHA512 0
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_RELEASE
        -DwxBUILD_DEBUG_LEVEL=0
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
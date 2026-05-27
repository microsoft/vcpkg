vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Kalina20/NeuralFramework
    REF v0.1.1
    SHA512 8ed4bbaf7cf8aff1a69ad5912e991e4bbb1117cae71920a315bbdb1adc3578caab3d19f8b98762e1b29f7289ecf3ad1797e63bc5376b103e07142f8db63e1961
    HEAD_REF main
)

vcpkg_configure_cmake(
    SOURCE_PATH "${SOURCE_PATH}/NeuralFramework"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(
    CONFIG_PATH lib/cmake/NeuralFramework
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL
    "${SOURCE_PATH}/NeuralFramework/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)

file(INSTALL
    "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

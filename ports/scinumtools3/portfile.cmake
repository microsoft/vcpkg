vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vrtulka23/scinumtools3
    REF v0.5.9
    SHA512 b5164dbb80517e9827a3588556357dd2dbf9b952ad4131379408c070b21bfcef6b7c2cecf5504aa6d3a4f2d35c7064abe0601fb31ae7512b231cadd2a579c9ec
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DENABLE_UNIT_TESTS=OFF
        -DENABLE_BINDING_PYTHON=OFF

        -DENABLE_SNT=ON
        -DENABLE_EXS=ON
        -DENABLE_VAL=ON
        -DENABLE_PUQ=ON
        -DENABLE_DIP=ON
        -DENABLE_MAT=OFF
        -DENABLE_API=ON

        -DENABLE_EXEC_APPS_DMAP=OFF
        -DENABLE_EXEC_EXAMPLES=OFF
        -DENABLE_EXEC_BENCHMARKS=OFF
)

vcpkg_cmake_install()

# Copy executables to tools
vcpkg_copy_tools(
    TOOL_NAMES snt
    AUTO_CLEAN
)

vcpkg_cmake_config_fixup(
    PACKAGE_NAME snt
    CONFIG_PATH lib/cmake/snt
)

# Headers should only be installed once.
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
)

file(INSTALL
    "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)

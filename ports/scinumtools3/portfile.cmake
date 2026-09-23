vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vrtulka23/scinumtools3
    REF v0.8.0
    SHA512 185745f10fd603671c054d41e0351f4d8b16994955dfbe5fb35f4b25c34820fbacbf0e430d74701c5bf99f94eae1b7aedbff3e2fba3b1082bc9c8f83718fa396
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DENABLE_UNIT_TESTS=OFF
        -DENABLE_BINDING_PYTHON=OFF

        -DENABLE_CORE=ON
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
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL
    "${SOURCE_PATH}/LICENSE"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)

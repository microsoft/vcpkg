vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vrtulka23/scinumtools3
    REF v0.5.11
    SHA512 301484eb60e70baf703b97291f5ca668a0c74f7986641aa0ae09e57489e195cfa1e49c85d03bc37b566bfec849bb3f247a285b49a680f4a4a28e5133ac2f76d5
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

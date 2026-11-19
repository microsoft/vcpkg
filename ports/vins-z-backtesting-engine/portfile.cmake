vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Vins-z/Backtesting-Engine
    REF "v${VERSION}"
    SHA512 126fa41f74dcd7d7cd8e2718a45e4249aab21f42d7ac52031cc2d81b53b8a9f68c08d3f659ed728f44258ad18f71ac3355a143c54365a1e08dc958edbcee1734
    HEAD_REF master
)

set(PROJECT_SUBDIR "${SOURCE_PATH}/cpp-backtesting-engine")

vcpkg_cmake_configure(
    SOURCE_PATH "${PROJECT_SUBDIR}"
    OPTIONS
        -DBACKTESTINGENGINE_BUILD_EXAMPLES=OFF
        -DBACKTESTINGENGINE_BUILD_TESTS=OFF
        -DBACKTESTINGENGINE_ENABLE_TALIB=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME BacktestingEngine CONFIG_PATH lib/cmake/BacktestingEngine)

vcpkg_copy_tools(TOOL_NAMES backtest_engine backtest_server AUTO_CLEAN)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Vins-z/Backtesting-Engine
    REF "v${VERSION}"
    SHA512 141f697b347c9bfc41a1834b51893b04a31cc880d4333dcaa7679cb9c538bc46aa8c6befea11f29041a92a237147a7b07c82d75ff059ebaaa7e7c76c6a7449de
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

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

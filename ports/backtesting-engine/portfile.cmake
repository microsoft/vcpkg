vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Vins-z/Backtesting-Engine
    REF v1.0.1
    SHA512 bb4f684f7866dc5e4e3afe1fdb44602cb3026a6f5ea396babc438a0bf585518fbda5ee1446c6de5341106b39074e32031889a9447a522770d1334012726fb7bf
    HEAD_REF master
)

set(PROJECT_SUBDIR "${SOURCE_PATH}/cpp-backtesting-engine")

# Make the build toolchain-friendly for vcpkg:
# - Upstream uses `-march=native`, which fails on some compilers/arch settings (ex: x64-osx build on non-native host)
# - Upstream also hardcodes Homebrew paths on macOS; in vcpkg builds we must not mix those libs.
set(_be_cmake_file "${PROJECT_SUBDIR}/CMakeLists.txt")
if(EXISTS "${_be_cmake_file}")
    file(READ "${_be_cmake_file}" _be_cmake_contents)

    # Remove `-march=native` occurrences (leave other optimization flags intact).
    string(REPLACE "-march=native" "" _be_cmake_contents "${_be_cmake_contents}")

    # Avoid Homebrew prefix overrides when building under vcpkg.
    string(REPLACE "if(APPLE)" "if(APPLE AND NOT DEFINED VCPKG_TARGET_TRIPLET)" _be_cmake_contents "${_be_cmake_contents}")

    file(WRITE "${_be_cmake_file}" "${_be_cmake_contents}")
endif()

if(EXISTS "${CMAKE_CURRENT_LIST_DIR}/usage")
    file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
        DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${PROJECT_SUBDIR}"
    OPTIONS
        -DBACKTESTINGENGINE_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/BacktestingEngine PACKAGE_NAME BacktestingEngine)

# Installed CMake config references tools/${PORT}/ (post-fixup); copy from bin so imported targets resolve.
vcpkg_copy_tools(TOOL_NAMES backtest_engine backtest_server AUTO_CLEAN)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(EXISTS "${PROJECT_SUBDIR}/LICENSE")
    vcpkg_install_copyright(FILE_LIST "${PROJECT_SUBDIR}/LICENSE")
elseif(EXISTS "${SOURCE_PATH}/LICENSE")
    vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
endif()


vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO aistemsplitter/aistemsplitter-cpp
    REF v0.1.0
    SHA512 17279384bd6b993b669778b3034d2fb7266d718e62e053f372e5c326ee02bccde8c3c011ef0755b92eb74005822ef64742121893fc5440a46d116d05dcc1c5c9
    HEAD_REF main
    PATCHES
        fix-windows-nominmax.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DAISTEMSPLITTER_BUILD_TESTS=OFF
        -DAISTEMSPLITTER_BUILD_EXAMPLES=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/aistemsplitter)

file(WRITE "${CURRENT_PACKAGES_DIR}/share/aistemsplitter/aistemsplitterConfig.cmake" [[
include(CMakeFindDependencyMacro)
find_dependency(CURL)
include("${CMAKE_CURRENT_LIST_DIR}/aistemsplitterTargets.cmake")
]])

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

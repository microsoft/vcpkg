vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO electronicarts/EABase
    REF 0699a15efdfd20b6cecf02153bfa5663decb653c
    SHA512 6852fcef08002c503d7ca23a22ef25d4b3136787c505d9b7ad55e821a6369d1dcc1773ff8042d7a9c306a52f33dd8da35b2f3fdbd8ea0ff1ca0f765fbe7ac240
    HEAD_REF master
    PATCHES
    fix_cmake_install.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/EABaseConfig.cmake.in" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    -DEABASE_BUILD_TESTS:BOOL=OFF
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/EABase)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

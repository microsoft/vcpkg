vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO electronicarts/EABase
    REF d1be0a1d0fc01a9bf8f3f2cea75018df0d2410ee
    SHA512 84a11bea06aecbf9a659d92b1ac904b99b2b82023650f4f376b5e68a744f631c5dbdd53d25f746ffb01b428415ac86e4fb8ba758db844acf80560fabe4d77733
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
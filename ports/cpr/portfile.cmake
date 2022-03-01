vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libcpr/cpr
    REF 1.7.2
    SHA512 b2af6ab13a5dab435cc298c74ba79c365569c1e5ccfaffeea9dab0ad28cd918a198f83446761ac2e2101abb4be3a2f669f991e854e541851c1d250f34e16c414
    HEAD_REF master
    PATCHES
        001-cpr-config.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DCPR_BUILD_TESTS=OFF
        -DCPR_FORCE_USE_SYSTEM_CURL=ON
    OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()


vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cpr)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

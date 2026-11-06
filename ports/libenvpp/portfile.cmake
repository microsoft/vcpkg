vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

# No DLL export(yet)
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ph3at/libenvpp
    REF v${VERSION}
    SHA512 c4699bb5b19dd2c2cec2db443e4a5f185588e74bc7f1ef34bcb96c4b93cec6b50bc88394e8535bedc0fa7429a76ff5ab6fdd9a65789d0a8a98ce75fb66ef70cf
    HEAD_REF main
    PATCHES
        fix-dependencies.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBENVPP_EXAMPLES=OFF
        -DLIBENVPP_TESTS=OFF
        -DLIBENVPP_CHECKS=OFF
        -DLIBENVPP_INSTALL=ON
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

if(VCPKG_TARGET_IS_UWP)
    set(UWP_PATCH fix-uwp.patch)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libcpr/cpr
    REF 1.6.2
    SHA512 77afd1dc81274aa1d37bf17abaf2614b63802f17fc08bdf8453d96d8fa2bd4b025511db9fadbde51160d7dde31a0363694422d3407ca9cdac3cd79b744a82888
    HEAD_REF master
    PATCHES
        001-cpr-config.patch
        ${UWP_PATCH}
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS 
        -DCPR_BUILD_TESTS=OFF
        -DCPR_FORCE_USE_SYSTEM_CURL=ON
    OPTIONS_DEBUG
        -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/cprConfig.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/lib/cmake/cpr)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/cpr)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/SEAL
    REF e3ad13edf7e5b4dc8a59fd2cd6235ad9d7428cab
    SHA512 9d52a51bd1d3141e45fd1f92134433a9eb7458e125140501952535c67ea49e0c66ccd4a80f7473c31db1963afcd7e690c716ea32d195cb07ba6fa60847168a91
    HEAD_REF master
    PATCHES no-source-writes.patch
)

if("zlib" IN_LIST FEATURES)
    message("SEAL currently does not support non-vendored zlib -- ignoring feature 'zlib'")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DALLOW_COMMAND_LINE_BUILD=ON
        -DSEAL_BUILD_EXAMPLES=OFF 
        -DSEAL_BUILD_TESTS=OFF 
        -DSEAL_BUILD_SEAL_C=OFF
        -DSEAL_USE_MSGSL=OFF
        -DSEAL_USE_ZLIB=OFF
)

vcpkg_build_cmake(TARGET seal LOGFILE_ROOT build)
vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(GLOB CONFIG_PATH RELATIVE "${CURRENT_PACKAGES_DIR}" "${CURRENT_PACKAGES_DIR}/lib/cmake/SEAL-*")
if(NOT CONFIG_PATH)
    message(FATAL_ERROR "Could not find installed cmake config files.")
endif()

vcpkg_fixup_cmake_targets(CONFIG_PATH "${CONFIG_PATH}")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

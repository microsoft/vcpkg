vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO kubernetes-client/c
    REF ecc9efc23656e747e97f86fbe2810f7e8471990f
    SHA512 e9bb1b6f68aacd82df2b33fcb432fdfee5fb56e0426835f8480afff1c2545f483eb0f4edeafb2e866ea74918d748aa48655b5819909c13a88f693e371047e8b7
    HEAD_REF master
    PATCHES
        001-fix-destination.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}/kubernetes
)

vcpkg_cmake_install()

if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL debug)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
endif()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
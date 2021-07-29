vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO trailofbits/uthenticode
    REF fb9b05b5273af748f5075b7e82ac8be446570574 #v1.0.4
    SHA512 2e8ff1c0c40359102a999952f820d6c7fbd653bc084901b6d42ba95f3d50498219f6afddd837faa11fb23e11cfa6ac39b18bf1fa0491de6a2fdc37759bb78a30
    HEAD_REF master
    PATCHES
        fix-include-path-notfind.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/uthenticode)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

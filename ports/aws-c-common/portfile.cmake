vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-c-common
    REF fdd4a10243903260f412f587cc748f0ac79629b4 # v0.6.9
    SHA512 969c9b85af58fc144480f6548e78126cf3fe758951ecbdffb579163b9a505a7ea58c32430390102ff620e828bf241dd24c0167f205306949d36dcf4504efa09a
    HEAD_REF master
    PATCHES
        disable-internal-crt-option.patch # Disable internal crt option because vcpkg contains crt processing flow
        fix-cmake-target-path.patch # Shared libraries and static libraries are not built at the same time
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    PREFER_NINJA
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/aws-c-common/cmake)
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/lib/aws-c-common"
    "${CURRENT_PACKAGES_DIR}/lib/aws-c-common"
    )

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

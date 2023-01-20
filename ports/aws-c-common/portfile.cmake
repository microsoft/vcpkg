vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-c-common
    REF 3973e3c89bbb532f5c3d2327b602836a57bd4db6 # v0.8.6
    SHA512 42bd0a9b14e35c3657c03006b20aa5df60498020d9e8cc742762637a35b5d62c747c1fd6ac43bff7dfd4c725aab19791c08bfbe842de81efb3cd6210ab1affe5
    HEAD_REF master
    PATCHES
        disable-internal-crt-option.patch # Disable internal crt option because vcpkg contains crt processing flow
        fix-cmake-target-path.patch # Shared libraries and static libraries are not built at the same time
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=FALSE
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

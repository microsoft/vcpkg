vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-c-common
    REF 68f28f8df258390744f3c5b460250f8809161041 # v0.6.20
    SHA512 a8be405e0e1586a06db038a0068df2c9277772ff7b8df2c542d18d2aae4b2bc0fd89de668ab10d84476446834390e4e27383b68d86c7d9f0d0749b57802866f1
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

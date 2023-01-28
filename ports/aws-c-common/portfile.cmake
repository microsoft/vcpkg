vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO awslabs/aws-c-common
    REF 5e64b039356c72d17fcf1fb0bfc7637f8c2270f7 # v0.8.9
    SHA512 b9e414cb2b87beb7b7b239e4a7e51a10555f0c154669c0fbeff2117683776734d83e70f4449f0e8d1eaec9c0e20c871cf2abd466850e84b4ec3c0cca84d4fcd5
    HEAD_REF master
    PATCHES
        disable-internal-crt-option.patch # Disable internal crt option because vcpkg contains crt processing flow
        fix-cmake-target-path.patch # Shared libraries and static libraries are not built at the same time
        fix-cmake-config-file.patch
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

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/nsync
    REF "${VERSION}"
    SHA512 8aa49997f100f161f0f32e99c9004ee845d7b16c1391e7eb62eea0897e2f91b7f9e5181055fdca637518751b6b26e16a1cd53e45adceda145285752c4b74f3bf
    HEAD_REF master
    PATCHES
        fix-install.patch
        export-targets.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNSYNC_ENABLE_TESTS=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-nsync CONFIG_PATH share/unofficial-nsync)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

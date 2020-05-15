vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO erincatto/Box2D
    REF 37e2dc25f8da158abda10324d75cb4d1db009adf
    SHA512 c9021b6bbc8ee405e38418bdadc136814fb66d5f4928ffd06d2ed016751613ecc3e82e7f60851fdc7a2e13594f68c21e7b7adb06d35a5a02314235132556d174
    HEAD_REF master
    PATCHES
        export-targets.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS=OFF
        -DBUILD_SAMPLES=OFF
)
vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-box2d TARGET_PATH share/unofficial-box2d)

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

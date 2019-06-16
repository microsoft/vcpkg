include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO graeme-hill/crossguid
    REF c4f8e9b21f779abe287c022e73eeac365d430337
    SHA512 38876f410d0014ad930b720312cecc99be1361b9810a21d5ffc1deba6221ea0e2aebd0da332adb18fd314d0477fd33410403120629b8df405bb64a9884e3d0b0
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCROSSGUID_TESTS:BOOL=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/crossguid/cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(RENAME ${CURRENT_PACKAGES_DIR}/share/crossguid/LICENSE ${CURRENT_PACKAGES_DIR}/share/crossguid/copyright)

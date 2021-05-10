vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO skypjack/entt
    REF 1e07b981f0b305400f854084c61c4efe2fd36206
    SHA512 0a61d293b8f6d9eec07711f9ac87c185e158b42da7ca1f91c1ab189a573686a79efa0d15cc76d8e7a2770c6b625df20b8bce1aa16147c0af07cd722a3d32d583
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    DISABLE_PARALLEL_CONFIGURE
    PREFER_NINJA
    OPTIONS
        -DENTT_BUILD_TESTING=OFF
)

vcpkg_install_cmake()

if(EXISTS ${CURRENT_PACKAGES_DIR}/cmake)
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)
else()
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/EnTT/cmake)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

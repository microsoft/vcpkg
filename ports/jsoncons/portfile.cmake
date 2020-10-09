vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO danielaparker/jsoncons
    REF 1d81dc242a0ad29123c4fff4470d5d5e5d461b4a # v0.158.0
    SHA512 f5efaa89263579f77560c1707ec6bcf1ca6a30cce70da144cadfa97301869480326ad5dff241df8b751d190e0d0177fea5de929f8b950f53c87c264332dfe6f4
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

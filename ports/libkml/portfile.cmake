vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libkml/libkml
    REF   1.3.0
    SHA512 aa48158103d3af764bf98c1fb4cf3e1356b9cc6c8e79d80b96850916f0a8ccb1dac3a46427735dd0bf20647daa047d10e722ac3da2a214d4c1559bf6d5d7c853
    HEAD_REF master
    PATCHES
        patch_empty_literal_on_vc.patch
)

file(REMOVE ${SOURCE_PATH}/cmake/External_boost.cmake)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)
elseif (VCPKG_TARGET_IS_LINUX)
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/libkml)
elseif (VCPKG_TARGET_IS_OSX)
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/libkml)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
vcpkg_fixup_pkgconfig()

vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO odygrd/quill
    REF v1.6.2
    SHA512 c1db04c96c70b6bced38ecc83b4bba9e60b02cf13ff48ab92132ceb828414fcf046cb2c41337a4ae321b0bad8598eb280a7edcc30e0720d7609898e15d514380
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DQUILL_FMT_EXTERNAL=ON
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/quill)

vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/quill/TweakMe.h "// #define QUILL_FMT_EXTERNAL" "#define QUILL_FMT_EXTERNAL")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

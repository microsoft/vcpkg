vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO odygrd/quill
    REF v1.6.3
    SHA512 e75aca827fe0833422da0d38df482cbc39db0e43dcc3cb791f3e2649f7022dcc448831a5ede85daf6feada60a2d5eaf312a3411abbba92fb9d76466336a7244d
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

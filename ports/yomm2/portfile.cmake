vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jll63/yomm2
    REF v1.1.2
    SHA512  f45c3f3d267dedaa3c76f9dab1a75be01941e3715e71b30b878be49157a5ba97f2188c9e635272be3ca396019b161bb21a30199ca504c94a18673685f5dbf06d
    HEAD_REF master
    PATCHES "fix_find_boost.patch" "fix_uwp_osx.patch"
)
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DYOMM2_ENABLE_EXAMPLES=OFF
)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/YOMM2)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

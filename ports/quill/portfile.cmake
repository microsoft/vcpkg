vcpkg_fail_port_install(ON_ARCH "arm" ON_TARGET "uwp")
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO odygrd/quill
    REF 94cecd870236410016db692a68114e547be6578c # v1.4.1
    SHA512 de13d62fa4fe1d68b5475df4d2e97ffb0c5028bedc6cd652fbe280ee4bf665ab01002928c55342f671997265a71018c88fd5150f97084d338b5d7adaa60a0361
    HEAD_REF master
)

# remove bundled fmt
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/quill/quill/include/quill/bundled/fmt)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/quill/quill/src/bundled/fmt)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
      -DQUILL_FMT_EXTERNAL=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/quill)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

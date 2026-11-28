vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bitdefender/bddisasm
    REF "v${VERSION}"
    SHA512 5cec6008230e908d9433de0433fed422e0f71081d35bcacd9fa8c286b01ef8298319246ea1282f33607d6456f74e3a9111f13415d2923f87ddf2dc4bd32f1125
    HEAD_REF master
)

# Cached packages must not target the build host's CPU.
vcpkg_replace_string("${SOURCE_PATH}/CMakeLists.txt" "-march=native" "")
# Let vcpkg_fixup_pkgconfig point Debug at the shared headers.
vcpkg_replace_string("${SOURCE_PATH}/bddisasm.pc.in"
    [[include_dir=${dir_prefix}/${include}]]
    [[include_dir=${prefix}/@BDDISASM_INSTALL_INCLUDE_DIR@]]
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBDD_INCLUDE_TOOL=OFF
        -DBDD_INCLUDE_ISAGENERATOR_X86=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/bddisasm)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/bin"
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/bin"
)

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

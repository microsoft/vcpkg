vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nodejs/llhttp
    REF refs/tags/release/v${VERSION}
    SHA512 725332e20aace7215c3cb7a4973e6fe72e6ed80c451c513c4caade0f8e5a276e0725733637fe30c6e3312a68fba3dcdad50ab2f17f52d4120dbecef970fa4e70
    PATCHES
)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LLHTTP_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LLHTTP_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
      -DLLHTTP_BUILD_SHARED_LIBS=${LLHTTP_BUILD_SHARED}
      -DLLHTTP_BUILD_STATIC_LIBS=${LLHTTP_BUILD_STATIC}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(
    CONFIG_PATH "/lib/cmake/${PORT}"
)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE-MIT")

vcpkg_fixup_pkgconfig()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO json-c/json-c
    REF "json-c-${VERSION}"

    SHA512 3be9058351acb3d9a66c7ae850391ebaa80472b42ee3f013f8b655743eb41b55513e0546c6798399af98ed049b80d11c93286ea3f5af26dc5f199905a28c4db1
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" JSON_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" JSON_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DBUILD_STATIC_LIBS=${JSON_BUILD_STATIC}
        -DBUILD_SHARED_LIBS=${JSON_BUILD_SHARED}
        -DDISABLE_EXTRA_LIBS=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

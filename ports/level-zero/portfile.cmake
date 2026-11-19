vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oneapi-src/level-zero
    REF "v${VERSION}"
    SHA512 67749e279d1a579d02af291734f9b5a2979d2906c72ce7973a78ffc189721de3e6756ff5a8251402d444a68020849e61b7ec25240f616cd20f63bf00967f26bc
    HEAD_REF master
)

vcpkg_list(SET options)
if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_list(APPEND options "-DBUILD_STATIC=1")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/third_party/xla/LICENSE"
)

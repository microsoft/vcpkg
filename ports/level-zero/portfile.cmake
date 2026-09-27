vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oneapi-src/level-zero
    REF "v${VERSION}"
    SHA512 9420b8dd115c6e509d5f9b381656615bfcda920ad589f184645f522e88352b380d27a15c8c148a02591221d6c57bff4fd90482a5c8b18e3a85227b454ba9a6ec
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

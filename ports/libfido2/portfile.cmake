vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Yubico/libfido2
    REF ${VERSION}
    SHA512 97932ca1a9f8d1bb3cb4b4a8d56ef70085d19ad2bd27c67944fa17ed033bfa45d28d7ad3fa318723e79b17ef5a882ac4f999ad8a6b9965c58665d99c4da7b5ee
    HEAD_REF main
    PATCHES
        "fix_cmakelists.patch"
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LIBFIDO2_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LIBFIDO2_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_MANPAGES=OFF
        -DBUILD_STATIC_LIBS=${LIBFIDO2_BUILD_STATIC}
        -DBUILD_SHARED_LIBS=${LIBFIDO2_BUILD_SHARED}
        -DBUILD_TOOLS=OFF
        -DBUILD_TESTS=OFF
 )

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

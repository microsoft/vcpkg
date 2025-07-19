# No DLL export(yet)
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO laurencelundblade/QCBOR
    REF v${VERSION}
    SHA512 3961cbcde2dde3565b68f92b53e92db31b649b71bc683a8439bada3aa6c44f4727747ca7b4ad35c4ca6f5bd0594abc2bf36a6ce0c7452eb412e8dcd55e946585
    HEAD_REF master
    PATCHES
        install.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_QCBOR_TEST=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO matajoh/libnpy
    REF "v${VERSION}"
    SHA512 88b39e5018fbe2ef8b8a40b01fb85beb5e9a25dccff6199924d6eb072f49972501c33a68e6af3e67bba34ae546c632176f86db7cc530e8314666cfee13297907
    HEAD_REF main
    PATCHES
        fix-install.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DLIBNPY_BUILD_TESTS=OFF
	-DLIBNPY_BUILD_SAMPLES=OFF
	-DLIBNPY_BUILD_DOCUMENTATION=OFF
	-DLIBNPY_INCLUDE_CSHARP=OFF # when swig is added, this can be added as a feature
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

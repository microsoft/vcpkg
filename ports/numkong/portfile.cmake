vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/NumKong
    REF "v${VERSION}"
    SHA512 fdb0d0190890fdf802c5ec9b3164d52b5721efcdff98e33eb1cf06558b6e3c00ecfba44d22492dd9619749b77237e0d94ba366c39ee543f9ae744552faf6e2bc
    HEAD_REF main
    PATCHES
        export-target.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNK_BUILD_TEST=OFF
        -DNK_BUILD_SHARED_TEST=OFF
        -DNK_BUILD_BENCHMARKS=OFF
        "-DNK_BUILD_SHARED=${BUILD_SHARED}"
)

vcpkg_cmake_install()

if(BUILD_SHARED)
    vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-numkong)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
else()
    # numkong is a header-only library when the library linkage is static.
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

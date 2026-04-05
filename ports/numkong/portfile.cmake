vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/NumKong
    REF "v${VERSION}"
    SHA512 e3514bd8520babdb47058c5693eb329d57053d45640f300db38a9704ecf427b40ac2f0c1f8f5c28a8feb5a8bdd38b5fb2a52577ca0ace56d47bdbbe4178b6fcf
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

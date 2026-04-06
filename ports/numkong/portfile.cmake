vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ashvardanian/NumKong
    REF "v${VERSION}"
    SHA512 5af620701996ea1ca7df4bcada0303d4560d0f50e5a48489c30990a3991a67f2a66f7a7683ac1b5c5d7f5153864b0349b9e85c117402ec4a9b72442021f917fe
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

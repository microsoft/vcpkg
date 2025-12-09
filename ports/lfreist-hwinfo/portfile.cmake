vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lfreist/hwinfo
    REF fff0ffb494aa8f8cb8537a35d0032235d6d5b5cc
    SHA512 9100d6a5e39096d1aa36b462499e3937fd6c829887c7cab23ebb4ac8798f9abc844111df0bc781190780f164e8e2df93b1f0dbbc2d6ac824601910b03009ed3e
    HEAD_REF main
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" HWINFO_BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" HWINFO_BUILD_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLES=OFF
        -DBUILD_TESTING=OFF
        -DHWINFO_SHARED=${HWINFO_BUILD_SHARED}
        -DHWINFO_STATIC=${HWINFO_BUILD_STATIC}
    )

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME lfreist-hwinfo
    CONFIG_PATH "lib/cmake/hwinfo"
)
vcpkg_copy_pdbs()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO lfreist/hwinfo
    REF 46690dd36727b868c5bb7a7316bb2ee52a898349
    SHA512 31ac0f2c405a817893146f4f8899ea05d831393bd1776c12257675385be25990cb77251d644fefb8ea0d179940ff782ede9036ea42a3f3050c36a66d978f0da6
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

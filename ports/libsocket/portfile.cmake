vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dermesser/libsocket
    REF fe5f78c997478a1915f44a494a50025bdc792698
    SHA512 c3563365f00021e9fa18e776765681268f52b9596b200f757661781bfb901360b42ad15beba02e39b0602edeac7904b061e46b6709c2023f9b624ceb81bf70ca
    HEAD_REF master
    PATCHES
        0001-fix-static-builds.patch
        0002-install-cmake-targets.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LIBSOCKET_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LIBSOCKET_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_STATIC_LIBS=${LIBSOCKET_BUILD_STATIC}
        -DBUILD_SHARED_LIBS=${LIBSOCKET_BUILD_SHARED}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

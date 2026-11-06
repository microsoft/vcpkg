vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bungee-audio-stretch/bungee
    REF "v${VERSION}"
    SHA512 b86e9373c47dd8de8d38bdf54b1281b59a6b695de2595dfc4ac9502546d82c6726acbbfb1396b6065317f574c32e6d74cd08c425b39490cf292df9c1aa04cd23
    HEAD_REF main
    PATCHES
        cmake-use-vcpkg-deps-and-install-layout.patch
        pffft-include-path.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUNGEE_BUILD_SHARED_LIBRARY)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUNGEE_SELF_TEST=0
        -DBUNGEE_BUILD_SHARED_LIBRARY=${BUNGEE_BUILD_SHARED_LIBRARY}
        -DBUNGEE_INSTALL_FRAMEWORK=OFF
        -DBUNGEE_VERSION=${VERSION}
        -DBUNGEE_PRESET=
)
vcpkg_cmake_install()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/unofficial-bungee-config.cmake"
     DESTINATION "${CURRENT_PACKAGES_DIR}/lib/cmake/unofficial-bungee")

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-bungee CONFIG_PATH lib/cmake/unofficial-bungee)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

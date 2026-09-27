vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bungee-audio-stretch/bungee
    REF "v${VERSION}"
    SHA512 ec5bf082385716d6246dbd31b7ef34620654cf4290dd1b9ff3279275bfdc1deb5f5636785ecf97e72ef637afdfe9c7761d13eeda736831da76ab273b87f5e789
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

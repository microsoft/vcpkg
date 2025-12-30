vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stlab/libraries
    REF "v${VERSION}"
    SHA512 9854b93b92dd9fdb468020660c91282a70304a8e99ef07b7c4a6ba348d07c06a4da17531c1162fde64f924ab9c6faadef2b55fc73e1b443e9f8b02838dc66630
    HEAD_REF main
    PATCHES
        cross-build.patch
        devendoring.patch
)

file(WRITE "${SOURCE_PATH}/cmake/CPM.cmake" "# disabled by vcpkg")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Qt6=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/stlab)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

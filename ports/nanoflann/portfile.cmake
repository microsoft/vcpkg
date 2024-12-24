vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jlblancoc/nanoflann
    REF "v${VERSION}"
    SHA512 9405970865cf5a7b5fe8316e3b528b29530eea5eac22419d602ef008a2e09dce78dbf66f3c10c1d22ce2c3d5e69a650b27818ee4eb9cee9a583488ce1c81ed2d
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNANOFLANN_BUILD_EXAMPLES=OFF
        -DNANOFLANN_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "share/cmake/${PORT}")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(READ "${CURRENT_PACKAGES_DIR}/share/nanoflann/nanoflannConfig.cmake" _contents)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/nanoflann/nanoflannConfig.cmake" "
include(CMakeFindDependencyMacro)
find_dependency(Threads)
${_contents}")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")


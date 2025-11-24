vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jlblancoc/nanoflann
    REF "v${VERSION}"
    SHA512 4e775d58a5d5a53df75f7d808ff4a9984dcf621e0246c1a7c3155ae51c53506140ee55eac9c25f7159e77ed0926a170e5a34a197697fa2a72ff8920f955e3bb6
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


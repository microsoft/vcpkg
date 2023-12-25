vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jlblancoc/nanoflann
    REF "v${VERSION}"
    SHA512 bc4cdb285708f605ac202af41a66140d49b0fb54a96ce19642ab18e22ee0ffea6374ad1de08988ad4cef6aae8a65aad2a824b95b1c03fc0d762ccc783732b2ee
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNANOFLANN_BUILD_EXAMPLES=OFF
        -DNANOFLANN_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "share/${PORT}/cmake")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(READ "${CURRENT_PACKAGES_DIR}/share/nanoflann/nanoflannConfig.cmake" _contents)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/nanoflann/nanoflannConfig.cmake" "
include(CMakeFindDependencyMacro)
find_dependency(Threads)
${_contents}")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")


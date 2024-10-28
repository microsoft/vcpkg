vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice/libimobiledevice-glue
    REF 214bafdde6a1434ead87357afe6cb41b32318495 # commits on 2023-05-13
    SHA512 a12ace7690ebab0ac6372f61e1a6722d506bc20a89130f39441af4da74e8fe9cdae45d947eb3e864a5f043b621432b59418f8e4660857e25b648a9476c552ac6
    HEAD_REF master
    PATCHES
        001_fix_win32_defs.patch
        002_fix_msvc.patch
        003_fix_static_build.patch
        004_fix_api.patch
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/exports.def" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-${PORT})
vcpkg_fixup_pkgconfig()

file(READ "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-${PORT}-config.cmake" cmake_config)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-${PORT}-config.cmake"
"include(CMakeFindDependencyMacro)
find_dependency(unofficial-libplist CONFIG)
${cmake_config}
")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

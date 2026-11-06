vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenBluetoothToolbox/SimpleBLE
    HEAD_REF main
    REF "v${VERSION}"
    SHA512 609bc49c625b5b85b360ccbf09589c752c820685f2108d978daaa3eb5f8ce8d23f4edd02ab03853ae3e313911ad84537a02643af9c81f7f17b9a1ee2b762d930
    PATCHES
        devendor.diff
        use-std-localtime.patch
        use-cpp20-on-windows.diff
)

file(REMOVE_RECURSE
    "${SOURCE_PATH}/cmake/find/Findfmt.cmake"
    "${SOURCE_PATH}/dependencies/internal/include/fmt"
    "${SOURCE_PATH}/dependencies/internal/include/nanopb"
    "${SOURCE_PATH}/dependencies/internal/src/nanopb"
)

vcpkg_find_acquire_program(PKGCONFIG)
set(ENV{PKG_CONFIG} "${PKGCONFIG}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/simpleble"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/simpleble")
file(READ "${CURRENT_PACKAGES_DIR}/share/simpleble/simpleble-config.cmake" simpleble-config)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/simpleble/simpleble-config.cmake"
"include(CMakeFindDependencyMacro)
find_dependency(nanopb CONFIG)
${simpleble-config}"
)

vcpkg_fixup_pkgconfig()
if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/simpleble.pc" " -lsimpleble" " -lsimpleble-debug")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

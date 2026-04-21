vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenBluetoothToolbox/SimpleBLE
    HEAD_REF main
    REF "v${VERSION}"
    SHA512 c53c435c53f4829bfe1f1db94a94693958a23174689b798ae32d9518725efbb3173540e150c5a630ee53752d3e49f80f9e412c1c21e9f7a326369592d47cab46
    PATCHES
        devendor.diff
        use-std-localtime.patch
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
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/simpleble")

file(READ "${CURRENT_PACKAGES_DIR}/share/simpleble/simpleble-config.cmake" simpleble-config)
file(WRITE "${CURRENT_PACKAGES_DIR}/share/simpleble/simpleble-config.cmake"
"include(CMakeFindDependencyMacro)
find_dependency(nanopb CONFIG)
${simpleble-config}"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ARM-software/kleidiai
    REF "v${VERSION}"
    SHA512 bdb2fa30025d7cd885ab143df98f70c454e2ff7a5d94be6ac99cfa66dafa4a8dcd83f07652b285ef61ed8523bdb0d4c313b506cd1c71347d5400e935783fc459
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    WINDOWS_USE_MSBUILD
    OPTIONS
        -DKLEIDIAI_BUILD_TESTS=OFF
        -DKLEIDIAI_BUILD_BENCHMARK=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    CONFIG_PATH "lib/cmake/KleidiAI"
)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share") # Avoids empty debug folder in the zip.

file(GLOB LICENSE_FILES
    "${SOURCE_PATH}/LICENSES/*"
)
vcpkg_install_copyright(
    FILE_LIST ${LICENSE_FILES}
)

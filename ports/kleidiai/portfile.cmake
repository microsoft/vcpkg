vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ARM-software/kleidiai
    REF "v${VERSION}"
    SHA512 280bab1c123dec04d85da6a5fe4d1fc6a6698a6f1f664df635771e80de3de37cb837e7a970cc24b6478c6fb95dafb550b1e70033a7edf2ad28aa4fdbc82c918b
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

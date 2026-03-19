vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ARM-software/kleidiai
    REF "v${VERSION}"
    SHA512 46de1f0cdd04ce1e8de5d1bdb2499d07eb377e616eb3a8596fbcd296b7887e413be5470f383b5790cef73dc370bead3db36ef2ed116513b95924ae71d87ef123
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

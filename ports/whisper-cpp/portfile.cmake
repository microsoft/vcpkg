vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ggml-org/whisper.cpp
    REF v${VERSION}
    SHA512 7e0ec9d6afe234afaaa83d7d69051504252c27ecdacbedf3d70992429801bcd1078794a0bb76cf4dafb74131dd0f506bd24c3f3100815c35b8ac2b12336492ef
    HEAD_REF master
    PATCHES
        cmake-config.diff
)
file(REMOVE_RECURSE "${SOURCE_PATH}/ggml")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE # updating bindings/javascript/package.json
    OPTIONS
        -DWHISPER_CCACHE=OFF
        -DWHISPER_ALL_WARNINGS=OFF
        -DWHISPER_BUILD_EXAMPLES=OFF
        -DWHISPER_BUILD_TESTS=OFF
        -DWHISPER_USE_SYSTEM_GGML=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/whisper")
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(INSTALL "${SOURCE_PATH}/models/convert-pt-to-ggml.py" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

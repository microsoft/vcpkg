vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ggml-org/whisper.cpp
    REF "v${VERSION}"
    SHA512 5d2b4b962362e5e2336fcc507314bf1bc054cc79290357bc90b26744ad56fad47320a890e0571d7e495f0854172526d09567f0e56247b3eb84d37f9dde8cfb10
    HEAD_REF master
    PATCHES
        cmake-config.diff
        pkgconfig.diff
)
file(REMOVE_RECURSE "${SOURCE_PATH}/ggml")
vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE # updating bindings/javascript/package.json
    OPTIONS
        -DWHISPER_ALL_WARNINGS=OFF
        -DWHISPER_BUILD_EXAMPLES=OFF
        -DWHISPER_BUILD_SERVER=OFF
        -DWHISPER_BUILD_TESTS=OFF
        -DWHISPER_CCACHE=OFF
        -DWHISPER_USE_SYSTEM_GGML=ON
        -DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}
    MAYBE_UNUSED_VARIABLES
        PKG_CONFIG_EXECUTABLE
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/whisper")
vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/models/convert-pt-to-ggml.py" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

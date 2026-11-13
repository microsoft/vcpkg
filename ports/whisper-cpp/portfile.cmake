vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ggml-org/whisper.cpp
    REF "v${VERSION}"
    SHA512 5e01ca94a49438b71e38c3cab710cf75a7aa76a1ae03fe8f81b1a5beb794becb1ae1c6e078e3eea5526e4ad89ae4cc0306d17974541050afb3a7ac1d09f94768
    HEAD_REF master
    PATCHES
        pkgconfig-static.diff
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
vcpkg_cmake_config_fixup(PACKAGE_NAME parakeet CONFIG_PATH "lib/cmake/parakeet" DO_NOT_DELETE_PARENT_CONFIG_PATH)
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/whisper")
vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/models/convert-pt-to-ggml.py" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

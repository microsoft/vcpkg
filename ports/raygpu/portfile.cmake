vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO manuel5975p/raygpu
    REF "v${VERSION}"
    SHA512 4dba98afd534db4ba519a623b6f3af953da444ce8aa442c28fed15cbd5bf16424971fac9f7880224d53a92f709ce112e45f8e9ed22e23fbfc98e5dcbd25db91a
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        sdl3            SUPPORT_SDL3
        glfw            SUPPORT_GLFW
        vulkan-backend  SUPPORT_VULKAN_BACKEND
        wgpu-backend    SUPPORT_WGPU_BACKEND
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DRAYGPU_BUILD_TESTS=OFF
        -DRAYGPU_ENABLE_INSTALL=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME raygpu)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

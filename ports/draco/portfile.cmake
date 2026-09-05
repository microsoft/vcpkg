vcpkg_download_distfile(ALGORITHM_INCLUDE_PATCH
    URLS "https://github.com/google/draco/commit/b283ba36eea52dc525ab4c9324ae6de2055d1191.patch?full_index=1"
    FILENAME "draco-b283ba36eea52dc525ab4c9324ae6de2055d1191.patch"
    SHA512 8dab3a74ec52b6628955c68e79cca70383ec283f0624c054ec3a29baf6455029b38aeded4ed819978f891a0192472116e7c57d3100e1bc714ec96f7e3d4be778
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/draco
    REF "${VERSION}"
    SHA512 8b444744cdf12fb9d276916eb2ff0735cd1a6497b65b88813ec457fe2169db987db62e3db253a7d0f3ae7d45ae6502e8a9f8c0b81abde73e07b3bec69f9dc170
    HEAD_REF master
    PATCHES
        fix-compile-error-uwp.patch
        fix-uwperror.patch
        fix-pkgconfig.patch
        disable-symlinks.patch
        install-linkage.diff
        "${ALGORITHM_INCLUDE_PATCH}"
)

if(VCPKG_TARGET_IS_EMSCRIPTEN)
    set(ENV{EMSCRIPTEN} "${EMSCRIPTEN_ROOT}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPYTHON_EXECUTABLE=: # unused with DRACO_JS_GLUE off
        -DDRACO_JS_GLUE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/draco)
vcpkg_fixup_pkgconfig()

# Install tools and plugins
if(NOT VCPKG_TARGET_IS_EMSCRIPTEN)
    vcpkg_copy_tools(TOOL_NAMES draco_encoder draco_decoder AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

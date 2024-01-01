vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/draco
    REF "${VERSION}"
    SHA512 d4bc48aeac23aba377d1770a46e6676cb01596a436493385fb0c4ef9ba3f0fae42027232131a3d438250909aff4311353e114925753d045cc585af42660be0b1
    HEAD_REF master
    PATCHES
        fix-compile-error-uwp.patch
        fix-uwperror.patch
        fix-pkgconfig.patch
        disable-symlinks.patch
        install-linkage.diff
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

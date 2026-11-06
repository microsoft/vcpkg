vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vsg-dev/VulkanSceneGraph
    REF "v${VERSION}"
    SHA512 95a15e44171f44fa0fbefea790f4f8b2aa606dbf599b6ebf4acf34b65e00e61ad0099de98d3a96dfcc6132500b7062b33cbf2c16de9478dab79984776f617c52
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS options
    FEATURES
        shader-optimizer    VSG_SUPPORTS_ShaderOptimizer
        windowing           VSG_SUPPORTS_Windowing
)

if("windowing" IN_LIST FEATURES AND NOT (VCPKG_TARGET_IS_ANDROID OR VCPKG_TARGET_IS_IOS OR VCPKG_TARGET_IS_OSX OR VCPKG_TARGET_IS_WINDOWS))
    vcpkg_find_acquire_program(PKGCONFIG)
    set(ENV{PKG_CONFIG} "${PKGCONFIG}")
endif()

# added -DGLSLANG_MIN_VERSION=15 to sync with vcpkg version of glslang
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
        -DGLSLANG_MIN_VERSION=
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/vsg")
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

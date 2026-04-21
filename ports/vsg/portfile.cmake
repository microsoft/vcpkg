vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vsg-dev/VulkanSceneGraph
    REF "v${VERSION}"
    SHA512 6b7e400d066cfe5ea26a5739ba0e0cce4eaf34d66e9d5144b9cf4e9909305ac6294af6d25255ece7733bae699ad43f8048a9a5914b4a16253b1ae73d43f3ae51
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

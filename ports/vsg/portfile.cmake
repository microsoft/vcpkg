vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vsg-dev/VulkanSceneGraph
    REF "v${VERSION}"
    SHA512 d74d5cc889fc9faaac54992e482898fedd2f13a0f136b0ec2b2044ab7b5d3e7f6a26a81dc875fd1cd3eb926031ddf3f428008429bcc8d5cb22cd16f4eb21a5a9
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

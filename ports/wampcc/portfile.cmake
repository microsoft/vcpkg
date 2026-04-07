if (VCPKG_TARGET_IS_WINDOWS)
    message("Shared build is broken under Windows. See https://github.com/darrenjs/wampcc/issues/57")
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()


vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO darrenjs/wampcc
    REF 2963fd47b6775122aa45f83ed50a58ce2444ec64
    SHA512 19883f1dffb1967e6da9f613bb1aff93693e66c2617e8ff53eabe7965a2a9ac83d6da67e1629666cbc8f349eba0466f54edd22fc3c0fe0b4bf7e6a6f33c9e25b
    HEAD_REF master
    PATCHES
        add-include-chrono.patch #https://github.com/darrenjs/wampcc/pull/85
        fix-dependencies.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        examples    BUILD_EXAMPLES
        utils       BUILD_UTILS
)


vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS:BOOL=OFF # Tests build is broken
        ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()

if("utils" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES admin AUTO_CLEAN)
endif()

vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/wampcc")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

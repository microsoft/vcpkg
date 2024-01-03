vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO NVlabs/flip
    REF 5d8b86c205a6a675976b1ba1a82f578ef944e038 # HEAD as of 20231108
    SHA512 6ab1acd11b7e817cb031ea86d357a0c523b23a637376653267daf67759e779c0fd166dc7e1100d4dc728e9e7305c61341ae509fed81af5344b9f89689b26bfb1
    HEAD_REF main
    PATCHES
        001-vcpkg-dependencies.patch
        002-fix-installation-rules.patch
        003-option-build-tools.patch
        004-remove-cmake-variable-set.patch
)

file(REMOVE
    "${SOURCE_PATH}/cpp/common/stb_image.h"
    "${SOURCE_PATH}/cpp/common/stb_image_write.h"
    "${SOURCE_PATH}/cpp/common/tinyexr.h"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools FLIP_BUILD_TOOLS
        cuda FLIP_ENABLE_CUDA
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-flip)

if(VCPKG_HOST_IS_WINDOWS)
    vcpkg_fixup_pkgconfig(SKIP_CHECK)
else()
    vcpkg_fixup_pkgconfig()
endif()

if(FLIP_BUILD_TOOLS)
    vcpkg_copy_tools(AUTO_CLEAN TOOL_NAMES flip)
endif()

# Cleanup
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/include"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/README.md")

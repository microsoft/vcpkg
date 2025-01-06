vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LLNL/zfp
    REF "${VERSION}"
    SHA512 5bbd98ed2f98e75c654afa863cab3023abb2eeb8f203f9049c75d5dbdf4b364cfb5c8378e10e6aaeaf13242315ad4949b06619810a67b3adaed095b7e8a48d5a
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        all     BUILD_ALL
        cfp     BUILD_CFP
        utility BUILD_UTILITIES
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
      -DBUILD_TESTING=OFF
      -DBUILD_ALL=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

# Rename problematic root include "bitstream.h"; conflicts with x265's private headers
vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/zfp.h "\"bitstream.h\"" "\"zfp/bitstream.h\"" IGNORE_UNCHANGED)

if("utility" IN_LIST FEATURES)
    if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/zfp")
        vcpkg_copy_tools(TOOL_NAMES zfp AUTO_CLEAN)
    else()
        vcpkg_copy_tools(TOOL_NAMES zfpcmd AUTO_CLEAN)
    endif()
endif()

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

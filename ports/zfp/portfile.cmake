vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LLNL/zfp
    REF f39af72648a2aeb88e9b2cca8c64f51b493ad5f4 #1.0.0
    SHA512 943c147a5170defe8e40c6b5ffc736dcc5a4fd33ab5b3e71aab9194821d68e4b6d093f11c76532ae011cbee44c861b04feb01e36789a9858b10ebfa808416e92
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
vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/zfp.h "\"bitstream.h\"" "\"zfp/bitstream.h\"")

if("utility" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES zfpcmd AUTO_CLEAN)
endif()

vcpkg_copy_pdbs()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Chlumsky/msdfgen
    REF "v${VERSION}"
    SHA512 ad02b8b18b4c3329d1c3e9468dedb6ea45b1691817a970f84c4c6dbfd47e2b3483710810256a2714dece6f000931125fdef9fc6bad12f40667a623f7a5f06c9a
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openmp MSDFGEN_USE_OPENMP
        geometry-preprocessing MSDFGEN_USE_SKIA
        tools MSDFGEN_BUILD_STANDALONE
    INVERTED_FEATURES
        extensions MSDFGEN_CORE_ONLY
)

if (VCPKG_CRT_LINKAGE STREQUAL dynamic)
    set(MSDFGEN_DYNAMIC_RUNTIME ON)
else()
    set(MSDFGEN_DYNAMIC_RUNTIME OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMSDFGEN_USE_VCPKG=ON
        -DMSDFGEN_VCPKG_FEATURES_SET=ON
        -DMSDFGEN_INSTALL=ON
        -DMSDFGEN_DYNAMIC_RUNTIME="${MSDFGEN_DYNAMIC_RUNTIME}"
        ${FEATURE_OPTIONS}
    MAYBE_UNUSED_VARIABLES
        MSDFGEN_VCPKG_FEATURES_SET
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/msdfgen)

# move exe to tools
if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES msdfgen AUTO_CLEAN)
endif()

# cleanup
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

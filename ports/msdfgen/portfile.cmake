
if ("tools" IN_LIST FEATURES AND VCPKG_TARGET_IS_UWP)
    message(FATAL_ERROR "Tools cannot be built on UWP.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Chlumsky/msdfgen
    REF a811ef8935354d3f6d767cff6c4eebeb683777f2 # accessed on 2023-01-20
    SHA512 6c7fb9e9a4f4dee2502e1dca2c4612aae005697476e30664cc263f09e336b1cd0b529d75af667cdd9063ac1dd183867ce9f5bb88731e3071687c87937dab29d9
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
file(INSTALL "${SOURCE_PATH}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Chlumsky/msdfgen
    REF "v${VERSION}"
    SHA512 610e74675f5997a10e32eeed70cefa34f25649b56fed556e9c3ef4de9526633d0cda6dc156bfcd8f7b420b153f1e8cd1bf1633ac1f9c3afc9586bc63964a4089
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
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/msdfgen/msdfgenConfig.cmake"
        "\${VCPKG_IMPORT_PREFIX}/bin/msdfgen"
        "\${VCPKG_IMPORT_PREFIX}/tools/${PORT}/msdfgen")
endif()

# cleanup
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

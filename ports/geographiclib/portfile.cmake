vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO geographiclib
    REF distrib-C++
    FILENAME "GeographicLib-${VERSION}.tar.gz"
    SHA512 afa44e65f1d58c14b527ac2df6f0ccd647bce76736f012970b3913dfe611ea796a9ea1c1d3c5c9887f7737160034319b74042b1edb31a1d77717cde6d20f7418
    )

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        "tools" TOOLS
)

# GeographicLib's CMakeLists.txt allows the installation directories for
# all the components to be set independently.  A "false" value, e.g., an
# empty string or OFF (-DBINDIR=OFF), indicates that the corresponding
# component should not be installed.
if(TOOLS)
    set(TOOL_OPTION "-DBINDIR=tools/${PORT}")
else()
    set(TOOL_OPTION -DBINDIR=OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${TOOL_OPTION}
    "-DCMAKEDIR=share/${PORT}"
    -DDOCDIR=OFF
    -DEXAMPLEDIR=OFF
    -DMANDIR=OFF
    -DSBINDIR=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()
vcpkg_copy_pdbs()

vcpkg_fixup_pkgconfig()

if(tools IN_LIST FEATURES)
    vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/${PORT}")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/tools")

file(INSTALL "${SOURCE_PATH}/LICENSE.txt"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright)

# Install usage
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage"
    "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)

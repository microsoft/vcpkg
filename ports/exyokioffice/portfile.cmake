vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO JakubMelka/ExyokiOffice
    REF "v${VERSION}"
    SHA512 079d90326e104d4ba4a3e4449b7fcea5cd972bc79b1dd661ec25d51e5d5af7cea601bec4b44c87628971f74a1e12adb2241c1c6937411a38ef69c1c7a100c4fc
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tools   EXYOKIOFFICE_BUILD_TOOL
        mcp     EXYOKIOFFICE_BUILD_MCP
)

# EXYOKIOFFICE_RUN_GENERATOR reruns the OpenXML source generator and writes the
# result back into the source tree. The generated sources are committed upstream,
# so a package build takes them as they are: it keeps the extracted source clean
# and it is what makes cross compilation possible, since the generator would
# otherwise be built for the target and then run on the host.
#
# BUILD_SHARED_LIBS is supplied by vcpkg_cmake_configure from the triplet.
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DEXYOKIOFFICE_RUN_GENERATOR=OFF
        -DEXYOKIOFFICE_WARNINGS_AS_ERRORS=OFF
        -DEXYOKIOFFICE_BUILD_UNIT_TESTS=OFF
        -DEXYOKIOFFICE_BUILD_MCP_PYTHON_TESTS=OFF
        -DEXYOKIOFFICE_BUILD_FUZZERS=OFF
        -DEXYOKIOFFICE_DUMP_EXPORTS=OFF
        -DEXYOKIOFFICE_BUILD_EXAMPLE_WORD=OFF
        -DEXYOKIOFFICE_BUILD_EXAMPLE_WORD_EDITOR=OFF
        -DEXYOKIOFFICE_BUILD_EXAMPLE_WORD_EDIT=OFF
        -DEXYOKIOFFICE_BUILD_EXAMPLE_EXCEL_EDITOR=OFF
        -DEXYOKIOFFICE_BUILD_EXAMPLE_POWERPOINT_EDITOR=OFF
)

vcpkg_cmake_install()

# The package name stays lowercase so that the config files land in the same
# share/exyokioffice as the copyright and usage files; find_package matches the
# directory case-insensitively, so ExyokiOfficeConfig.cmake is still found.
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ExyokiOffice)
vcpkg_copy_pdbs()

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES exyoki AUTO_CLEAN)
endif()

if("mcp" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES
            exyoki-mcp-word
            exyoki-mcp-excel
            exyoki-mcp-power-point
        AUTO_CLEAN
    )
endif()

# The upstream install ships its manual, changelog and contributor documentation
# under share/doc; vcpkg carries none of that.
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share/doc"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

# Every third-party component compiled into the installed binaries, under the
# name upstream's THIRD-PARTY-LICENSES.md gives it. They are all called LICENSE
# in the source tree, so they are staged under distinct names first. doctest is
# absent on purpose: it reaches the test executables only, and none are installed.
set(license_staging "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-licenses")
file(REMOVE_RECURSE "${license_staging}")
configure_file("${SOURCE_PATH}/3rdparty/CLI11/LICENSE" "${license_staging}/CLI11" COPYONLY)
configure_file("${SOURCE_PATH}/3rdparty/nlohmann/LICENSE.MIT" "${license_staging}/nlohmann-json" COPYONLY)
configure_file("${SOURCE_PATH}/3rdparty/json-schema-validator/LICENSE" "${license_staging}/json-schema-validator" COPYONLY)
configure_file("${SOURCE_PATH}/sources/pugixml/LICENSE" "${license_staging}/pugixml" COPYONLY)
configure_file("${SOURCE_PATH}/sources/zip/LICENSE" "${license_staging}/zip-miniz" COPYONLY)
configure_file("${SOURCE_PATH}/data/LICENSE" "${license_staging}/Open-XML-SDK-data" COPYONLY)

vcpkg_install_copyright(
    COMMENT "ExyokiOffice is distributed under the MIT license. It embeds the third-party components listed below."
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${license_staging}/CLI11"
        "${license_staging}/nlohmann-json"
        "${license_staging}/json-schema-validator"
        "${license_staging}/pugixml"
        "${license_staging}/zip-miniz"
        "${license_staging}/Open-XML-SDK-data"
)

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)

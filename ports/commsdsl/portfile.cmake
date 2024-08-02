vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO commschamp/commsdsl
    REF "v${VERSION}"
    SHA512 21a1fd4a3a66f2c9389c19ab8ad0aadf09bc97db39492921385534de6d819b1cd5a1e65798abc71de8f8f6c436191fd199e8e77dc8b5c979b07d313a2b825fde
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCOMMSDSL_INSTALL_APPS=ON
        -DCOMMSDSL_INSTALL_LIBRARY=ON
        -DCOMMSDSL_INSTALL_LIBRARY_HEADERS=ON
        -DCOMMSDSL_BUILD_UNIT_TESTS=OFF
        -DCOMMSDSL_WARN_AS_ERR=OFF
        -DCOMMSDSL_WIN_ALLOW_LIBXML_BUILD=OFF
        -DBUILD_TESTING=OFF
)
vcpkg_cmake_install()

vcpkg_copy_tools(
    TOOL_NAMES commsdsl2comms
    AUTO_CLEAN
)

vcpkg_cmake_config_fixup(PACKAGE_NAME LibCommsdsl CONFIG_PATH lib/LibCommsdsl/cmake)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/share/LibCommsdsl/LibCommsdslConfig.cmake"
"if (TARGET cc::commsdsl)"
[[include(CMakeFindDependencyMacro)
find_dependency(LibXml2)
if (TARGET cc::commsdsl)]])

# after fixing the following dirs are empty
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib/LibCommsdsl")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/LibCommsdsl")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")

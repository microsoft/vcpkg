vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-source-parsers/jsoncpp
    REF "${VERSION}"
    SHA512 1d06e044759b1e1a4cc4960189dd7e001a0a4389d7239a6d59295af995a553518e4e0337b4b4b817e70da5d9731a4c98655af90791b6287870b5ff8d73ad8873
    HEAD_REF master
    PATCHES
        cmake-target.diff
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" JSONCPP_STATIC)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_CRT)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DJSONCPP_WITH_CMAKE_PACKAGE=ON
        -DBUILD_STATIC_LIBS=${JSONCPP_STATIC}
        -DJSONCPP_STATIC_WINDOWS_RUNTIME=${STATIC_CRT}
        -DJSONCPP_WITH_PKGCONFIG_SUPPORT=ON
        -DJSONCPP_WITH_POST_BUILD_UNITTEST=OFF
        -DJSONCPP_WITH_TESTS=OFF
        -DJSONCPP_WITH_EXAMPLE=OFF
        -DBUILD_OBJECT_LIBS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/jsoncpp)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

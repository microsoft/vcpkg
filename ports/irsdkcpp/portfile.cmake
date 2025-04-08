vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vrkit-platform/irsdk-cpp
    REF "v${VERSION}"
    SHA512 c702479259d77b3eeec85f5fbe177b040c598f2c0b3812139f4c95a1d3c292eff96cc84baa2c620bbfb2c507c61b4425f2cbeb4cb143235b8b25098ab816796a
    HEAD_REF develop
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" IRSDKCPP_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_CXX_STANDARD=23
        -DIRSDKCPP_BUILD_TESTS=OFF
        -DIRSDKCPP_BUILD_DOCS=OFF
        -DIRSDKCPP_BUILD_EXAMPLES=OFF
        -DIRSDKCPP_BUILD_SHARED=${IRSDKCPP_BUILD_SHARED}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

if (EXISTS "${CURRENT_PACKAGES_DIR}/debug/include")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
endif()

if (EXISTS "${CURRENT_PACKAGES_DIR}/include/include")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/include")
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vrkit-platform/irsdk-cpp
    REF "v${VERSION}"
    SHA512 efdaafc2badcce7ba88fb943882aa301fa3c9959c8de86a99269ade05f188828c485e16f21241d558b108d48e566702e961a1c5b0bda42e523abcc783bdde5c6
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

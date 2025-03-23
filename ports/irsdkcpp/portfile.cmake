vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vrkit-platform/irsdk-cpp
    REF "v${VERSION}"
    SHA512 97775a282430f8ab5c80b489761c6d28a62dad3fff85a430419f8f47843d7da58e97afa5fc52fe41941be1711e2352dd493f0feeef6c1ca0e96871399f8c7efa
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

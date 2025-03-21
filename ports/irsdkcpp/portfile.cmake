vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vrkit-platform/irsdk-cpp
    REF "v${VERSION}"
    SHA512 cf991d4a519c24f481b124aec139e4f6a07c8b0aa5458e156f056129ee5dd258c7b4e1a44f4aee8daf5008df2388b3788c47cc492e2dd2fb2e8d1fc1d57e74d1
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" IRSDKCPP_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" IRSDKCPP_BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_CXX_STANDARD=23
        -DBUILD_TESTS=OFF
        -DBUILD_DOCS=OFF
        -DBUILD_EXAMPLES=OFF
        -DIRSDKCPP_BUILD_SHARED=${IRSDKCPP_BUILD_SHARED}
        -DIRSDKCPP_BUILD_STATIC=${IRSDKCPP_BUILD_STATIC}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/irsdkcpp)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

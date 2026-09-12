# Only the standalone tool
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
set(VCPKG_BUILD_TYPE release)
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO introlab/rtabmap
    REF "${VERSION}"
    SHA512 b18515a1215d76592f748c6d18c4c7cd6311739be411dfbc787d11d69729b1193265d5970816cef2b5b5dc9f4418547896d7749fd76137c0888e1dcb7de66fca
    HEAD_REF master
)
file(COPY "${CURRENT_PORT_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DINSTALL_INCLUDE_DIR=include
        -DINSTALL_CMAKE_DIR=lib/cmake
        -DRTABMAP_VERSION=${VERSION}
)
vcpkg_cmake_install()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/include"
    "${CURRENT_PACKAGES_DIR}/lib"
)

# We don't use vcpkg_copy_tools here, as some platforms need rtabmap-res_tool-${UTILITE_VERSION}, aside from rtabmap-res_tool
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/utilite/resource_generator/main.cpp"
)

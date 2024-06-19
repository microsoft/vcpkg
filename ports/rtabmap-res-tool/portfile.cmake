# Only the standalone tool
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
set(VCPKG_BUILD_TYPE release)
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO introlab/rtabmap
    REF ${VERSION}
    SHA512 2b424f5b6458cf0f976e711985708f104b56d11921c9c43c6a837f9d3dc9e9e802308f1aa2b6d0e7e6ddf13623ff1ad2922b5f54254d16ee5811e786d27b9f98
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

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

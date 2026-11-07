# Only the standalone tool
set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
set(VCPKG_BUILD_TYPE release)
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO introlab/rtabmap
    REF "${VERSION}"
    SHA512 b630896016a5cbec700d5199c7c4cb1ef4ded33af081bedfe4cdbfdff0bc560053052afd8f4a1b27f6e2f28df9ce6d7bc06fcefc3c724c667f512b281c41224c
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

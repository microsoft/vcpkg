vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO g-truc/glm
    REF "${VERSION}"
    SHA512 62e22002a6369a54e1f0ee2885a65f2780af7d2a446573e5387b81518f5dc7e8076053837cb99ae850a0166ce8b0f077bed009e8986d9884d01c456ce467553f
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGLM_ENABLE_CXX_17=ON
        -DGLM_BUILD_LIBRARY=ON
        -DGLM_BUILD_TESTS=OFF
        -DGLM_BUILD_INSTALL=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/copying.txt")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

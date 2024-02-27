vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO g-truc/glm
    REF "${VERSION}"
    SHA512 0296a9bac8a114f50aa719b402d66524a4028aeec72649da1964faa80116f3f1ae5fa13d741dbaf9f4bcdb0722c0e44a4e85e8fc16dda641f4ba03f4a2c755d3
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

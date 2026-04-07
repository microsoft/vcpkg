vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO g-truc/glm
    REF "${VERSION}"
    SHA512 0a490f0c79cd4a8ba54f37358f8917cef961dab9e61417c84ae0959c61bc860e5b83f4fb7f27169fb3d08eef1d84131bddde23d60876922310205c901b1273aa
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGLM_BUILD_LIBRARY=ON
        -DGLM_BUILD_TESTS=OFF
        -DGLM_BUILD_INSTALL=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/copying.txt")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

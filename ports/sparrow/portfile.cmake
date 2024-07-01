# sparrow is header only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO man-group/sparrow
    REF 0.0.2
    SHA512 388c7401c9168cb389f619f196a02f69e54934a66d06828d9d3cc5ea64c858f6512ccaca94309eebbeefbc57a9e864f0f203a187413e4d8ce688791e00d39757
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DBUILD_TESTS=OFF
        -DUSE_DATE_POLYFILL=ON
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

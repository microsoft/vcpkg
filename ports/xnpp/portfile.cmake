vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO borgesdan/xnpp
    REF v0.1.0
    SHA512 399fc3189e8fb40ab9c66ffe4417840ef08e5cae22085585ad55bd3e38409b030b00e95a5569c37cee0f56dd35ae824d1bdc9e80dc9a9dec2b1a9418b7c9166e
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DXNPP_BUILD_LIB=ON
        -DXNPP_BUILD_CONTENTPIPELINE=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/xnpp
)

vcpkg_install_copyright(
    FILE_LIST "${SOURCE_PATH}/LICENSE.md"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

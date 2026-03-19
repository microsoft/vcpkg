vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LTLA/CppKmeans
    REF "v${VERSION}"
    SHA512 d9ea94ee5e1d2e124828f6c123f0136477cc78f1652aac24df2d90b06cd164e708557aab10b638ec8b1df8080d40980b416084719545dc47bcfc96a8a45d18b3
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE "release") # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DKMEANS_FETCH_EXTERN=OFF
        -DKMEANS_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME ltla_kmeans
    CONFIG_PATH lib/cmake/ltla_kmeans
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LTLA/CppKmeans
    REF "v${VERSION}"
    SHA512 3218751179960fdd3f1a226a21a4ea97abf35dabf78d4ab875054f1f209d5ba2ce918764a8ea2cd6eec84e95b719b8370b645fa79d8a150976f6ba4ac9eb008a
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

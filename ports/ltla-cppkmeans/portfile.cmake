vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LTLA/CppKmeans
    REF "v${VERSION}"
    SHA512 f1798873ee0bd15fcb8ba9c02d9dc6ecbc3cce0b8cd6f38d23aff27b37fdd68069d64aa16fbdfa63515906c51ce811093f3f0a4dc92081072f21c41d08e98d31
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

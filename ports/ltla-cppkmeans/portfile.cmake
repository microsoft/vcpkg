vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LTLA/CppKmeans
    REF "v${VERSION}"
    SHA512 17ea2822ccf35adc18a5162ac5bb469bbd46fba32072e524fda4e3baa12bc04f9666c69ccb8fe71b02e471197acc392958bf5d6036ba9e7829d7a8d4522471d5
    HEAD_REF master
    PATCHES
        0001-fix-dependencies.patch # https://github.com/LTLA/CppKmeans/pull/15
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

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO LTLA/CppKmeans
    REF 4c5aca44bffd8ed7d7243b2451105b572028e9d4
    SHA512 c56147bc89ab50aa4d738c1392dffcf32771ad4995cbb206a83af05294dbfe640a1da265d46e108816486374fe0e6fa45c1b1da770cdc4367a69195c3510ecd4
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

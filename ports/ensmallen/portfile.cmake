vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mlpack/ensmallen
    REF "${VERSION}"
    SHA512 1e86fc28a58694057262a8d036af8080be084c889f7b659b77a08fd4e0957d0f03d8866e47b682a1868b5ac2198cca85c591a334b284096659a123196de95a66
    HEAD_REF master
    PATCHES
        dependencies.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ensmallen)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL "${SOURCE_PATH}/COPYRIGHT.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

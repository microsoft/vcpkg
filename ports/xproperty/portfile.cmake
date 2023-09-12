# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO QuantStack/xproperty
    REF 0.8.1
    SHA512 70fcce3a3cc84be98d844aa59c14686945907db3c8fa1c9a916f0bab811ef96512464031e53f00d29cba7db750a0032f4b59d6ca524f52bc7cfe8de5cebad5e5
    HEAD_REF master
    PATCHES
        fix-target.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DDOWNLOAD_GTEST=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
configure_file("${SOURCE_PATH}/LICENSE" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)

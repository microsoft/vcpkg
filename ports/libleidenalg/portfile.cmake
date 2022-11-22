vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO theAeon/libleidenalg
    REF "v${VERSION}"
    SHA512 eeb718457dd9eebbf429c83e9b4512225917432074829b34f1bedf49d2179f73cc687fada99250d633ad1b6d06d6865e0b7c40ac94d1c0c944a5bcd781c66e18
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "${CONFIG_CMAKE_DIR}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

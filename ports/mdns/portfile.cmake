#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mjansson/mdns
    REF "${VERSION}"
    SHA512 0bbfeefdd3f324a8e5aa85227bfa45c2b5cd88c12a9f77df2a1c48cb2661ba8b283dd53541e39d20ed2705646dc8d8724a0287c58f9efa91d2b1b796a0ca9a7a
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMDNS_BUILD_EXAMPLE=OFF
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

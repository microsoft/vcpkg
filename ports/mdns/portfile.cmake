#header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mjansson/mdns
    REF 1.4.2
    SHA512 fa3fcf130721ee6f7012225c1e7952bd41703c2488b1d0ffe2b8c73ed06744d1cd9f03b6ab19aa0b8074fbfaafe46f8e102d6a648756725a60dc076e896cfbf6
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DMDNS_BUILD_EXAMPLE=OFF
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

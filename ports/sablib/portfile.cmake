vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Izadori/sablib
    REF v0.3.1
    SHA512 812be6129b7a09b20883ad1ac4d970a09e5853b37ac9dbe4950a14a2e6d4269c85183f10d5642728a26bf673cfa4902bd15848eb367210ba01c521432447dc59
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    -DBUILD_SHARED_LIBS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/sablib
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

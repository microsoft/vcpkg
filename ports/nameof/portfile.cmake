vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Neargye/nameof
    REF "v${VERSION}"
    SHA512 e7df7fd1e4210080b59df91860901757f8ef8db47a7e81d57395313bc93eedf977e4812f49bfd0ac3af7a85f3e45c22d5c21015bb9e3062c07b889cceb2ef55d
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNAMEOF_OPT_BUILD_EXAMPLES=OFF
        -DNAMEOF_OPT_BUILD_TESTS=OFF
        -DNAMEOF_OPT_INSTALL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

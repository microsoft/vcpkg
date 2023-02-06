vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO open-dis/open-dis-cpp
    REF a17466dabb2944ee608330d0c0ea8d69e3defde8
    SHA512 d0578fed46deb9422a5d4f0c95fc0367e844d4f77911dbb9597ccf1e9550c7a9627e4bf2c7148bafa424c12f8a8be54ee8b0629d734a926443f350a155518080
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME OpenDIS CONFIG_PATH lib/cmake/OpenDIS)

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO taocpp/pegtl
    REF 697aaa06564c6ea9d13f95de081a2d2d46b39160
    SHA512 453821966526569a2d1842ec0bebe6f65dee0241d6ab7d38255726243326356b6a972bf5ca58168e94f51dd87c74ce17fdefffd19fe67570fe9dc52f1f6a4f16
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPEGTL_BUILD_TESTS=OFF
        -DPEGTL_BUILD_EXAMPLES=OFF
        -DPEGTL_INSTALL_DOC_DIR=share/pegtl
        -DPEGTL_INSTALL_CMAKE_DIR=share/pegtl/cmake
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/pegtl/cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)

# Handle copyright
file(RENAME ${CURRENT_PACKAGES_DIR}/share/pegtl/LICENSE ${CURRENT_PACKAGES_DIR}/share/pegtl/copyright)

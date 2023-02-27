vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO nemequ/portable-snippets
    REF 26496acb37ab46ee249ea19d45381da6955d89c4
    SHA512 6213b22e4358b06f92396731d94fd27d4cf3568a47c56c057174c1839929c6a569ad5b1e1302fe0d092c4f393c570607b96e9e977223f86a9e3c2862010f3af0
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG
        -DPSNIP_INSTALL_HEADERS=OFF
    OPTIONS_RELEASE
        -DPSNIP_INSTALL_HEADERS=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-${PORT})

# Handle copyright
configure_file("${SOURCE_PATH}/COPYING.md" "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" COPYONLY)

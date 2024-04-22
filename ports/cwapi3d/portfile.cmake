vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cwapi3d/cwapi3dcpp
    REF 4e83a5c07f2a4b3c766a9b4a950e98ae1a80b2de
    SHA512 c5b9872659c6e390dfe39a568e9ee036e52d56f6d19ac87cdda1cfd94ab394fdd2aece37c393c6061d464dc0ab6af32fd2716fbbb5f843210b97356eea2e1b6f
    HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/CwAPI3D)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

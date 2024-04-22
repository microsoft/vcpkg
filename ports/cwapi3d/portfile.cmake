vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cwapi3d/cwapi3dcpp
    REF 76fcd3acc99c33a65c9aa27d3e95151168afdb6f
    SHA512 e9ab2db1a8f7ea548e4b3f8072b921ed33bb1092663abe24273e1b7098f3d9e496879afc65dd89c318956eb9192692e5f2a119713afca621f81bd82168d58264
    HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/CwAPI3D)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

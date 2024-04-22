vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cwapi3d/cwapi3dcpp
    REF 44c2d55fe31b89c76ed69bae72f9cb40acae38d3
    SHA512 4aaee6c2eb4cb2bfff3617781ca6ee10c8959cb82cbac1d704ec14b684bedf8c1f2b35bbf064a15edc569646e5db7b99ca61553acb5a6ad7a113e1faae7dac5f
    HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/CwAPI3D)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

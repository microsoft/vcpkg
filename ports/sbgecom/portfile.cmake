vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SBG-Systems/sbgECom
    REF "${VERSION}-stable"
    SHA512 d2d9aa2751f96fe87590aad71c276d2ab7a7a9e230887f8f83355b55fc25b57046dc84a8c5d2cfc8d4fd58e6c92210d3527937fe923cea660785d12db74997c3
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME "sbgECom"
    CONFIG_PATH lib/cmake/sbgECom
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")

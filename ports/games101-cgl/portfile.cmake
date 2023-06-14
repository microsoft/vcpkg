vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO endingly/games101-cgl
    REF v${VERSION}
    SHA512  59b0d0aea7629f7c07e4815408ee96dee3c62c128a57420fb9d7c395f28eae1d6fedb6193ff844ed2d84df632fda2a0f2f3ad5e471a03fa7543d21da10ca3af5
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/license")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
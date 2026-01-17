vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bbalouki/itchcpp
    REF "v${VERSION}"
    SHA512 ce66984be3c70f83486e9b3f46227bff4d5456d73b58e70fe7f7d08c5fa5fe92a7222ee3c2ad81fda80a1c8e9f745f410d5ccc792bb40d52ef67422532355f65
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DITCH_BUILD_TESTS=OFF
        -DITCH_BUILD_BENCHMARKS=OFF
        -DITCH_BUILD_EXAMPLES=OFF
        -DITCH_PROJECT_ENV=PROD
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME "itch"
    CONFIG_PATH "lib/cmake/itch"
   
)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

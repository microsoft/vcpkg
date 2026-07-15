vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sdcb/libnsfemu
    REF v1.0.0
    SHA512 25944afe3ea19cf5783457c2d67d1ae34d3195305a0d81164efe59bb433c83a6562fde697cf1c5fa9769fe985d272880077707275772af0423002f1a91eb7cca
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DNSFEMU_BUILD_TOOLS=OFF
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/libnsfemu")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

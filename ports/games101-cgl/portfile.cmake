vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
set(GAMMA_RELEASE_TAG "993c0c0b173ed45a6f5e546c162d17effa885971")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO endingly/games101-cgl
    REF ${GAMMA_RELEASE_TAG}
    SHA512  2b7beed7b235d9adde5816f30e9d0757caab83c07a34b3de5f6241fba3b803658fc500249318611f2928adf4b54d6575e272e5027f0a61bd94d4dc5a27c29a4b
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(
    INSTALL "${SOURCE_PATH}/license"
    DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
    RENAME copyright
)


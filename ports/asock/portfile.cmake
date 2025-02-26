set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jeremyko/ASockLib
    REF "${VERSION}"
    SHA512 4b39f7332975488e58e3885845f3a89fca71b9f69e61715e7068c8002008a1ce8e34d568e4189f3332b571f923246297085cd17c60e1686fb9e43bf7c8b66e89
    HEAD_REF master
)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DJEREMYKO_ASOCK_BUILD_TESTS=OFF
        -DJEREMYKO_ASOCK_BUILD_SAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "share/cmake/asock")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE "${CURRENT_PACKAGES_DIR}/share/asock/LICENSE" "${CURRENT_PACKAGES_DIR}/share/asock/README.md")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")


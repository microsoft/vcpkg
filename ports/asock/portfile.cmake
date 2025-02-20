set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jeremyko/ASockLib
    REF "${VERSION}"
    SHA512 81965153c557021c168a85ab0ff4a40916bd597192496642fa1d79128d1db0d3b1431326c453c8296289b39754f8a1d9cc61af65fba45b6f6596c07f8bf86534
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


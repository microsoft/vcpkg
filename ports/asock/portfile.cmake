set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jeremyko/ASockLib
    REF "${VERSION}"
    SHA512 61ce6ba52cc83c2a66912bef5662757465ee33ea460d2a2d5364a972f163b3d4771d4a7bc5935a56d2b6566a581998a83ca8c786ea8d79e2907a7238d528ef69
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


set(VCPKG_BUILD_TYPE release) # header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jeremyko/ASockLib
    REF "${VERSION}"
    SHA512 97422003d596c23520e7dce4929891ab73607ef75137d261928227100a40150074faa5703c228fd0dd803d68304b30e2e35a574f848011071915cff1e8aaaf6a
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


#Get release from GitHub
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eclipse-ecal/fineftp-server
    REF "v${VERSION}"
    SHA512 dcced2cf743434a55314ad661ca729efc1c4883ae0c0883335f43a12ed47568ebcb50d233dab8a1410bb526587b24f1cf19938241bf649cfe54b11ffe264124b
    HEAD_REF master
    PATCHES
        asio.patch
)

# Configure
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME fineftp
    CONFIG_PATH lib/cmake/fineftp
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Header + compiled library. Downloads the tagged release from GitHub, builds it
# with the project's CMake, and installs headers + the apibrasil::apibrasil target.

# The library does not export symbols for a Windows DLL, so build it static on
# every triplet (avoids empty-DLL/link errors on dynamic triplets).
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO APIBrasil/apigratis-sdk-cpp
    REF "v${VERSION}"
    # Placeholder: rode 'vcpkg install apibrasil' uma vez e cole o "Actual hash"
    # que o vcpkg imprime. Assim o hash e do tarball real da tag (independente
    # deste arquivo, evitando dependencia circular).
    SHA512 df371bc33cfb8970d2376e70660fc1f803055edc3e85f182bf2b3f5ef551d29943ab2c59cfc9f5cc6f46bab881ff1aad60460bade7f82c3447fb38f29d914c18
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DAPIBRASIL_BUILD_EXAMPLES=OFF
        -DAPIBRASIL_BUILD_TESTS=OFF
        -DAPIBRASIL_INSTALL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME apibrasil CONFIG_PATH lib/cmake/apibrasil)

# Headers only live in the release tree.
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

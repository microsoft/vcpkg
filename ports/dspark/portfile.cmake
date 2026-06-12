# DSPark vcpkg port — submit to microsoft/vcpkg once a release tag exists.
# Update REF and SHA512 for the published release archive
# (vcpkg hashes the GitHub source tarball of the tag).

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CristianMoresi/DSPark
    REF v1.4.1
    SHA512 b9fd5b6d7428a2a82589661d65f73e91a72aeeb243572ad5c88aaa6974b8ad6a5282a01b6c3623872f2b2241e97070555864be243af8de2b1a29807a64684bfd
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DDSPARK_BUILD_CONFORMANCE=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME dspark CONFIG_PATH lib/cmake/dspark)

# Header-only: no compiled libraries, and config_fixup moved the cmake files
# from lib/cmake to share/, so lib/ is left empty (vcpkg rejects empty
# installed directories).
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

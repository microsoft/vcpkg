set(VCPKG_BUILD_TYPE release) # header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Arnime/givp
    REF v${VERSION}
    SHA512 e305c166ab1a3d570ba2cb117c399e3013fc6305c8dd95954b51c08e9c17083eaac736266c4c773c96828d06ca5571769901dec4d7c71a2535ee0c2a7406fd7f
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/cpp"
    OPTIONS
        -DGIVP_BUILD_TESTS=OFF
        -DGIVP_BUILD_BENCHMARKS=OFF
        -DGIVP_BUILD_FUZZ=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME givp
    CONFIG_PATH lib/cmake/givp
)

# Header-only, no need to keep debug or empty lib directories
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

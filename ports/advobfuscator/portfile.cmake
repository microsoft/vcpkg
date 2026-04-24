vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO andrivet/ADVobfuscator
    REF "v${VERSION}"
    SHA512 3c8ca3b921b3167804d121cdafd8684cc18429d9ecd6978f6a3affa81216e0a9c8b8fbcc0f557e996483f0863b097fe54b6ba25ec4ccf2e66dbb09652ec0333f
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS 
        -DBUILD_TESTING=OFF
        -DBUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wiiuse/wiiuse
    REF "${VERSION}"
    SHA512 b8cbc585f68b62b6bd3faac993130d616c6479f673ccfdc508497fb11a3afca7c86fa5bdf3780c757ef8846d993984dacede1b0365dea4123136bbc393f0d05e
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_EXAMPLE=OFF
	-DBUILD_EXAMPLE_SDL=OFF
	-DINSTALL_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

file(REMOVE "${CURRENT_PACKAGES_DIR}/CHANGELOG.mkd")
file(REMOVE "${CURRENT_PACKAGES_DIR}/LICENSE")
file(REMOVE "${CURRENT_PACKAGES_DIR}/README.mkd")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/CHANGELOG.mkd")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/LICENSE")
file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/README.mkd")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

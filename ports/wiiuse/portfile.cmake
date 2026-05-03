vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO wiiuse/wiiuse
    REF "${VERSION}"
    SHA512 dcd65bc8c5890de85683c7689e55b56204127e78947cf1fbb6ce29ea5b4b0bda20ed721439297cb53163e9f94a7fad0579d90edb172fc4ceacc367fe9fbae742
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

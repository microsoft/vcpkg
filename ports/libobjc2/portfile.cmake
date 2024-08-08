vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gnustep/libobjc2
    REF "v${VERSION}"
    SHA512 294db277da1ad929813cbb6c7ae1b5b9dfd9dcb6ceec157b9ec59bca85202c6f344ad8ba8ab3731b83abc5f72c2ab1cb88a79947e56eb92e87dcf62584169af9
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${OPTIONS}
        "-DGNUSTEP_INSTALL_TYPE=NONE"
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")

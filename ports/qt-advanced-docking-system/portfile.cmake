vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO githubuser0xFFFF/Qt-Advanced-Docking-System
    REF 487e23e190b8130de3b60e6e801f404edbedbf2f #v3.7.2
    SHA512 da6d813267f242d4460d77808588f3bf11a8ea91183e2d8aa1040228cf5176556153d3c741c2f1c22f0a098de15ecc6c336f0b078fd0365c81cc27aa54868572 
    HEAD_REF master
    PATCHES
        hardcode_version.patch
        config_changes.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS 
        -DBUILD_EXAMPLES=OFF
        -DVERSION_SHORT=3.7.2
)

vcpkg_cmake_install()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/gnu-lgpl-v2.1.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/license)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
vcpkg_cmake_config_fixup(PACKAGE_NAME qtadvanceddocking CONFIG_PATH lib/cmake/qtadvanceddocking)

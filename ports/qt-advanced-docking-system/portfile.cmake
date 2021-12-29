vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO githubuser0xFFFF/Qt-Advanced-Docking-System
    REF ab4869a0e1c97fec1dfca29eeb84be67af182864 #v3.8.0
    SHA512 220ec4604eda8a39cd7ba8839cee2ab420e8c5a0b247749afb85a7b4ec3286f6debd53c910637e84023af79319f0600eb48a6c037c3e4877708677fee3c62ce7 
    HEAD_REF master
    PATCHES
        hardcode_version.patch
        config_changes.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS 
        -DBUILD_EXAMPLES=OFF
        -DVERSION_SHORT=3.8.0
)

vcpkg_cmake_install()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/gnu-lgpl-v2.1.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/license)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
vcpkg_cmake_config_fixup(PACKAGE_NAME qtadvanceddocking CONFIG_PATH lib/cmake/qtadvanceddocking)

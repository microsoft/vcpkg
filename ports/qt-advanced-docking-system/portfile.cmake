vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO githubuser0xFFFF/Qt-Advanced-Docking-System
    REF 6846c9614602f21c51057a32d759a51eba1fc4d9
    SHA512 35d27002a678a2117fdd9e46e0cc94b9d8435f9b43149fb7a3b6f6389e04b1e7f3a94b64e3077d8f80c408f861e335d9f5d4facda08b47d25b60bf6ba7ceda01
    HEAD_REF master
    PATCHES
        hardcode_version.patch
        config_changes.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -DBUILD_EXAMPLES=OFF
        -DVERSION_SHORT=3.6.1
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/gnu-lgpl-v2.1.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/license)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/qtadvanceddocking TARGET_PATH share/qtadvanceddocking)

message(STATUS "${PORT} will only build with Visual Studio 2019 Version 16.3 and above. So you probably need to manually set VCPKG_VISUAL_STUDIO_PATH to the preview installation!")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/STL
    REF 92508bed6387cbdae433fc86279bc446af6f1b1a
    SHA512 85df2e5b1ed8e30449459b773d51e92e8027daf5b74e1276950e413583cf47093f7024d10412e520be1e907e4e105391c07f4dfadbb6a27414416ff487cf4d9a
    HEAD_REF master
    PATCHES
        install_targets.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA )

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)


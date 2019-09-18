message(STATUS "${PORT} will only build with Visual Studio 2019 Version 16.3 and above. So you probably need to manually set VCPKG_VISUAL_STUDIO_PATH to the preview installation!")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO microsoft/STL
    REF 7f65140761947af4ed7f9dfc11adee8c86c9e4c2
    SHA512 c94fed807129bdd488b4a23334179b48d46136f2611e5714f1c0a7f9abf2f2aa947b3d539a51bb6188e17730165e084ca22d6c3078cf9ceca2bce6d829159039
    HEAD_REF master
    PATCHES
        first.patch     # removes setting of build flags so that vcpkg can inject its own flags
        second.patch    # removes building of all flavours and only build one flavour depending on configuration options
                        # you can pass ITERATOR_DEBUG_LEVEL[_DEBUG|_RELEASE] via configure to set the appropiate iterator debug level. 
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA )

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)


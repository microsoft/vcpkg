vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO OpenEtherCATsociety/SOEM
    REF abbf0d42e38d6cfbaa4c1e9e8e07ace651c386fd #v1.4.0
    SHA512 2967775c6746bb63becea5eb12f136c184bbf874e1e5e8753374bfc212ec9cefbf1159350e79627b978af3562d261b61c50f38936a425c4d9c70598a1d136817
    HEAD_REF master
    PATCHES
        winpcap.patch
        disable-werror.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/bin
    ${CURRENT_PACKAGES_DIR}/debug/bin
    ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

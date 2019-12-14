include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oliora/ppconsul
    REF a3285a630ff46423701da28c6029c8d097e7430c
    SHA512 9910d802c3cc296680274b3aad78f68885b7e0b30d0f196f31a3e5f056a9ddab2a03c7cc28028050922a2463155ea326b8531c69f2a4e286ca70ea1f9a9f6971
    HEAD_REF master
    PATCHES "cmake_build.patch"
)

# Force the use of the vcpkg installed versions
file(REMOVE_RECURSE ${SOURCE_PATH}/ext/json11)
file(REMOVE_RECURSE ${SOURCE_PATH}/ext/catch)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)
vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)


file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/ppconsul RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)


vcpkg_copy_pdbs()

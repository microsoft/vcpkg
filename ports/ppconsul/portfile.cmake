include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO oliora/ppconsul
    REF fd3a22eba03a49623832a8f8c990fee499e3f8fb
    SHA512 098f2fa0fdc3f219f5958d0d5b2a620231e3cd94dc3110cfbedb87e787e8402a7b0294f7ffa4fcb4169b0428b4f65376b621e5840706ff7cc8f02ac7fc1d7757
    HEAD_REF master
    PATCHES "cmake_build.patch"
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)
vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)


file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/ppconsul RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)


vcpkg_copy_pdbs()

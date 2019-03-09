include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO svi-opensource/libics
    REF 8d8d2dbe72450cbaf88080b6c0e24a7a4a58009e 
    SHA512 739668b4d51ddb67d50ed1d41bd6965b90b5e4eafc7ec19e2f1d668f48af6e237f6a1872673e3fec5888efe94c2b321295c4de9502aba1f677fc6d0e0399c141
    HEAD_REF master
    PATCHES
        cmakelists.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH cmake)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(COPY ${SOURCE_PATH}/GNU_LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libics)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libics/GNU_LICENSE ${CURRENT_PACKAGES_DIR}/share/libics/copyright)
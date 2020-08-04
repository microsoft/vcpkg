include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO svi-opensource/libics
    REF 807193979650ab3d474e9a4bf907cf046eb0f3f0 # 1.6.4
    SHA512 9fcbc14d4b62a8f5c6c114123a5cd3102c3398dd25f44caf07d033dbfc8304fc22dcde35e545ed984047a6009a0e7d7e30cbb6075fb10b9ceda0311cabc56ecb
    HEAD_REF master
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
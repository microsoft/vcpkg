include(vcpkg_common_functions)

vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Milerius/imgui-sfml-shared
    REF 1.1
    SHA512 191184f7b302f643bd7c241b69d9f9edc0d03c6f5a0b3a49f57ac84f3828202f8065291fb17993073a2c07f1237ba491de677c47e2f8160dc70ea77f20eb1946
    HEAD_REF master
    PATCHES FixFindPackageIssue.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/milerius-sfml-imgui)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/milerius-sfml-imgui)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/milerius-sfml-imgui/LICENSE ${CURRENT_PACKAGES_DIR}/share/milerius-sfml-imgui/copyright)
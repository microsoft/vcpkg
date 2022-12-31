vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Milerius/imgui-sfml-shared
    REF 1.1
    SHA512 191184f7b302f643bd7c241b69d9f9edc0d03c6f5a0b3a49f57ac84f3828202f8065291fb17993073a2c07f1237ba491de677c47e2f8160dc70ea77f20eb1946
    HEAD_REF master
    PATCHES
        FixFindPackageIssue.patch
        cpp11.patch
        fix-imgui-dependency.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/milerius-sfml-imgui)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

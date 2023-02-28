vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO eliasdaler/imgui-sfml
    REF 004efd85a590343e8c9d166dc9d2524c199c9450 #v2.5
    SHA512 feb11f0a52f89eedc5af4c686b71290a48d69e7bc371f29536eb51752d00b6879d642625f494035d2ccc0500878757709afa2a3810ac17496506db754a3a4ed6
    HEAD_REF master
    PATCHES
        0001-fix_find_package.patch
        0002-fix-imgui-dependency.patch
        004-fix-find-sfml.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_CXX_STANDARD=11
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(PACKAGE_NAME ImGui-SFML CONFIG_PATH lib/cmake/ImGui-SFML)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

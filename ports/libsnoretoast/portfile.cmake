vcpkg_fail_port_install(ON_TARGET "osx" "linux")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO KDE/snoretoast
    REF v0.7.0
    SHA512 580d069baf0bdd4a7bca670cbb61baab5afe2f891ea2faad1303e5b75e6ed7462f9b6864628041cbe8a6f6038e8c9ca3c67110fd8f8558cad749f57b8ce058c5
    HEAD_REF master
    PATCHES
        install_location.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS 
        -DBUILD_EXAMPLES=OFF
        -DBUILD_STATIC_RUNTIME=OFF
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/libsnoretoast)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/etc)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib)
file(INSTALL ${SOURCE_PATH}/COPYING.LGPL-3 DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

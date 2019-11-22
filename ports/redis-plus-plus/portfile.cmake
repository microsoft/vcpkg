vcpkg_fail_port_install(ON_TARGET "Windows")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sewenew/redis-plus-plus
    REF d35267580568517f09bdf70cb582e5284c25401a 
    SHA512 f065b97d438772300e30485a7550bc0fff00005f1056cf9c23216ea388fa088303869ccf2eaa70ee8b06cc0fc2406c9c6faddd5ad08759ee2d0665ac91761914
    HEAD_REF master
    PATCHES disable-build-test.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJIA
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright )
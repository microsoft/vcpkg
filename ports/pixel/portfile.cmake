include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO dascandy/pixel
    REF v0.2
    SHA512 53485d298e34f8fda6c14dc07687e21281e4ef9d0567a654e5ded0589e1ac8e6bd84adbef922f0a12806f508c887299a6fc99c2415313029b8f7a6efc1cc3f59
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

vcpkg_copy_pdbs()

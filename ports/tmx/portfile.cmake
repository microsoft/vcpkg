vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO baylej/tmx
    REF tmx_1.1.0
    HEAD_REF master
    SHA512 4f57cea30cf01518812cb7279e4d09fd3524e02a29950c2a40aed07ed0f5bd44601517d8a6216a3ca878e1d6bfa15651e92b9e8024e0325baae1dadc7a79acd1
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(RENAME ${CURRENT_PACKAGES_DIR}/lib/cmake/tmx/tmxExports.cmake ${CURRENT_PACKAGES_DIR}/lib/cmake/tmx/tmxTargets.cmake)
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/tmx)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/tmx/tmxTargets.cmake ${CURRENT_PACKAGES_DIR}/share/tmx/tmxExports.cmake)

file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)

# Handle copyright
configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)

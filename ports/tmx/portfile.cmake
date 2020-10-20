vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO baylej/tmx
    REF tmx_1.0.0
    HEAD_REF master
    SHA512 d045c45efd03f91a81dae471cb9ddc80d222b3ac52e13b729deeaf3e07d0a03b8e0956b30336ef410c72ddbbf33bea6811da5454b88d44b1db75683ef2a9383a
    PATCHES fix-build-error.patch
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
configure_file(${SOURCE_PATH}/COPYING ${CURRENT_PACKAGES_DIR}/share/tmx/copyright COPYONLY)

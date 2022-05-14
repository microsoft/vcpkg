vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO P-H-C/phc-winner-argon2
    REF f57e61e19229e23c4445b85494dbf7c07de721cb
    SHA512 5a964b31613141424c65eef57f9e26ac5279b72d9c2f2b8cba9bb1fbf484e177183e7fe66700f10dc290e6f55f0a5dfff40235a9714d8d84d807cf5fa07cf7d4

    # REPO matlo607/phc-winner-argon2
    # REF aa165d6b545024b1719ee4ea33cf4f1bb1a4d1fa
    # SHA512 2eef06783d135399df56b5fb6b9b45a735e53349e86699ba83c8fb31ec50410e183b913441b960a72331eb3a4cacd8673acc7a1111b821880afd6520537c43c0
    HEAD_REF master
)

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION  "${SOURCE_PATH}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
#    PREFER_NINJA
)

vcpkg_install_cmake()

# file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
# file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# vcpkg_fixup_cmake_targets()
# vcpkg_copy_pdbs()

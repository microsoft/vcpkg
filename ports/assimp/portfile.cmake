vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO assimp/assimp
    REF 8f0c6b04b2257a520aaab38421b2e090204b69df # v5.0.1
    SHA512 59b213428e2f7494cb5da423e6b2d51556318f948b00cea420090d74d4f5f0f8970d38dba70cd47b2ef35a1f57f9e15df8597411b6cd8732b233395080147c0f
    HEAD_REF master
    PATCHES
        uninitialized-variable.patch
        fix-static-build-error.patch
        cmake-policy.patch
        fix_minizip.patch
        config.patch
)

file(REMOVE ${SOURCE_PATH}/cmake-modules/FindZLIB.cmake)
file(REMOVE_RECURSE ${SOURCE_PATH}/contrib/zlib ${SOURCE_PATH}/contrib/gtest ${SOURCE_PATH}/contrib/rapidjson)

set(VCPKG_C_FLAGS "${VCPKG_C_FLAGS} -D_CRT_SECURE_NO_WARNINGS")
set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} -D_CRT_SECURE_NO_WARNINGS")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DASSIMP_BUILD_TESTS=OFF
            -DASSIMP_BUILD_ASSIMP_VIEW=OFF
            -DASSIMP_BUILD_ZLIB=OFF
            -DASSIMP_BUILD_ASSIMP_TOOLS=OFF
            -DASSIMP_INSTALL_PDB=OFF
            -DIGNORE_GIT_HASH=ON
            -DCMAKE_DISABLE_FIND_PACKAGE_RT=ON
            -DHUNTER_ENABLED=OFF
            #-DSYSTEM_IRRXML=ON # Assimp is not compatible with the latest irrlicht
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Assimp)
# The pkgconfig files have hardcoded library names that do not match cmake's output
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
file(READ ${CURRENT_PACKAGES_DIR}/share/assimp/AssimpConfig.cmake _contents)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/assimp/AssimpConfig.cmake "${_contents}
add_library (assimp::assimp INTERFACE IMPORTED)
set_target_properties(assimp::assimp PROPERTIES INTERFACE_LINK_LIBRARIES Assimp::assimp)
set(ASSIMP_LIBRARIES Assimp::assimp)
")

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

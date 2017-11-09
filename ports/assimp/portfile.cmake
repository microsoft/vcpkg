include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO assimp/assimp
    REF v4.0.1
    SHA512 260b4c7e738f857d8364c4878ea4e789ca676180821943f6d9bff8f56e5f9377ea29660dca4e130c681a8aa12fc32f155adb1d78ca260ba242e68b8afa6cc1bb
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        "${CMAKE_CURRENT_LIST_DIR}/const-compare-worditerator.patch"
        "${CMAKE_CURRENT_LIST_DIR}/dont-overwrite-prefix-path.patch"
)

file(REMOVE ${SOURCE_PATH}/cmake-modules/FindZLIB.cmake)
set(VCPKG_C_FLAGS "${VCPKG_C_FLAGS} -D_CRT_SECURE_NO_WARNINGS")
set(VCPKG_CXX_FLAGS "${VCPKG_CXX_FLAGS} -D_CRT_SECURE_NO_WARNINGS")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DASSIMP_BUILD_TESTS=OFF
            -DASSIMP_BUILD_ASSIMP_VIEW=OFF
            -DASSIMP_BUILD_ZLIB=OFF
            -DASSIMP_BUILD_ASSIMP_TOOLS=OFF
            -DASSIMP_INSTALL_PDB=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/assimp-4.0")

vcpkg_copy_pdbs()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(READ ${CURRENT_PACKAGES_DIR}/share/assimp/assimp-config.cmake ASSIMP_CONFIG)
string(REPLACE "get_filename_component(ASSIMP_ROOT_DIR \"\${_PREFIX}\" PATH)"
               "set(ASSIMP_ROOT_DIR \${_PREFIX})" ASSIMP_CONFIG ${ASSIMP_CONFIG})
string(REPLACE "assimp\${ASSIMP_LIBRARY_SUFFIX}"
               "assimp\${ASSIMP_LIBRARY_SUFFIX}.lib" ASSIMP_CONFIG ${ASSIMP_CONFIG})
string(REPLACE "set( ASSIMP_LIBRARIES \${ASSIMP_LIBRARIES})"
               "set( ASSIMP_LIBRARIES \${ASSIMP_LIBRARY_DIRS}/\${ASSIMP_LIBRARIES})" ASSIMP_CONFIG ${ASSIMP_CONFIG})
file(WRITE ${CURRENT_PACKAGES_DIR}/share/assimp/assimp-config.cmake "${ASSIMP_CONFIG}")

# Handle copyright
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/assimp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/assimp/LICENSE ${CURRENT_PACKAGES_DIR}/share/assimp/copyright)

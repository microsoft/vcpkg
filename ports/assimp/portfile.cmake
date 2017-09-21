include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO assimp/assimp
    REF v4.0.0
    SHA512 ab2b376c6323fc8579fe3a4b3dbe92c44d753747464a14d6e2be70d2a855c208df882ad84487a7b96f364afb175938b5f6a1111d767450b01e0b8b7f0f36ba62
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES ${CMAKE_CURRENT_LIST_DIR}/const-compare-worditerator.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DASSIMP_BUILD_TESTS=False
            -DASSIMP_BUILD_ASSIMP_VIEW=False
            -DASSIMP_BUILD_ZLIB=False
            -DASSIMP_BUILD_ASSIMP_TOOLS=False
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/assimp-4.0")

vcpkg_copy_pdbs()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/cmake)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake)
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

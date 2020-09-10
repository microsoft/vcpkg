vcpkg_from_sourceforge(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO irrlicht/irrXML%20SDK
    REF 1.2
    FILENAME irrxml-1.2.zip
    SHA512 b6a7f76305c6d1e74a66bc182bd260428b9aa0b1db444f79de56095a7d39e320429756329202b44d3159f6b4d9ff13b7ebb6b88ca3d087f09c3a4a3a0ce08995
    PATCHES
        disable_asm_calls.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL ${SOURCE_PATH}/readme.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

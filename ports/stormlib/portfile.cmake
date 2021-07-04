vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ladislav-zezula/StormLib
    REF 2f0e0e69e6b3739d7c450ac3d38816aee45ac3c2
    SHA512 54cbe4270963944edf3d75b845047add2b004e0d95b20b75a4c4790c2a12a41bf19cc4f55aaeaec697a0a913827e11cfabde2123b2b13730556310dd89eef1e9
    HEAD_REF master
)

file(COPY 
    ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt
    DESTINATION ${SOURCE_PATH}
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/stormlib RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
vcpkg_fixup_cmake_targets()
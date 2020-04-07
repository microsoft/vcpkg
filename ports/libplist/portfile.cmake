vcpkg_check_linkage(ONLY_DYNAMIC_CRT ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libimobiledevice-win32/libplist
    REF efeba335a63110d9ce2b3cd2481743cb0028d9c7 # v1.2.185
    SHA512 c2f742a60c7a6e0601d33eae03d934f2cdb01fdd121be33212955f261a6756c14753ff3c8e173375b228f44f007d7a96ff6833ae66b5a8a6c7c245017cdc9b07
    HEAD_REF msvc-master
    PATCHES dllexport.patch
)

configure_file(${CURRENT_PORT_DIR}/CMakeLists.txt ${SOURCE_PATH}/CMakeLists.txt COPYONLY)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

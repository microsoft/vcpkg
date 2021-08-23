vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO faaxm/spix
    REF v0.3
    SHA512 14eb742b7861d510466341f90f8d5b9d519aeaf27a032a8be8ab15743c7dd20d0584aa1f815a82dd54e73cb747612975f4a52db23c57390e9b5cd4a102a789c6
    HEAD_REF master
    PATCHES
        export-header.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" ANYRPC_LIB_BUILD_SHARED)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
    -DSPIX_BUILD_EXAMPLES=OFF
    -DBUILD_TESTS=OFF
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/spix RENAME copyright)

vcpkg_copy_pdbs()

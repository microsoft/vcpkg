include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hyperrealm/libconfig
    REF v1.6
    SHA512 6222110851970fda11d21e73bc322be95fb1ce62c513e2f4cc7875d7b32d1d211860971692db679edf8ac46151033a132fc669bd16590fec56360ef3a6e584f8
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
    "${CMAKE_CURRENT_LIST_DIR}/fix-scanner-source-msvc-patch.patch"
    "${CMAKE_CURRENT_LIST_DIR}/fix-scanner-header-msvc-patch.patch"
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})
file(COPY ${CMAKE_CURRENT_LIST_DIR}/scandir.c DESTINATION ${SOURCE_PATH}/lib/win32)


vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libconfig RENAME copyright)

vcpkg_copy_pdbs()

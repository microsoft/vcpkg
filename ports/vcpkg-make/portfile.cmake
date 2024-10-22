set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)

vcpkg_download_distfile(ARCHIVE
    URLS https://ftp.gnu.org/gnu/automake/automake-1.17.tar.gz
    FILENAME automake.tar.gz
    SHA512 11357dfab8cbf4b5d94d9d06e475732ca01df82bef1284888a34bd558afc37b1a239bed1b5eb18a9dbcc326344fb7b1b301f77bb8385131eb8e1e118b677883a
)

vcpkg_extract_source_archive(
    automake_source
    ARCHIVE "${ARCHIVE}"
)

file(INSTALL 
        "${CMAKE_CURRENT_LIST_DIR}/vcpkg_make_configure.cmake"
        "${CMAKE_CURRENT_LIST_DIR}/vcpkg_make_install.cmake"
        "${CMAKE_CURRENT_LIST_DIR}/vcpkg_make_common.cmake"
        "${CMAKE_CURRENT_LIST_DIR}/vcpkg_make.cmake"
        "${CMAKE_CURRENT_LIST_DIR}/vcpkg_scripts.cmake" 
        "${CMAKE_CURRENT_LIST_DIR}/vcpkg-port-config.cmake"
    DESTINATION 
        "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

file(INSTALL 
        "${automake_source}/lib/ar-lib"
        "${automake_source}/lib/compile"
    DESTINATION 
        "${CURRENT_PACKAGES_DIR}/share/${PORT}/wrappers"
)

vcpkg_install_copyright(FILE_LIST "${VCPKG_ROOT_DIR}/LICENSE.txt")

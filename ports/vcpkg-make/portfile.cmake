set(VCPKG_POLICY_CMAKE_HELPER_PORT enabled)

vcpkg_download_distfile(ARCHIVE
    URLS https://ftp.gnu.org/gnu/automake/automake-1.16.tar.gz
    FILENAME automake.tar.gz
    SHA512 640a008fee3099f5afbb1fb12d0d3e3d802fda43d44f7ef7985d5dd952b9fe384c03dc4a9693d782531bd851d4fe1bf4e3718beabc29ca061212bad70f8af6ee
)

vcpkg_extract_source_archive(
    automake_source
    ARCHIVE ${ARCHIVE}
    PATCHES
       "consider_clang_cl.patch"
       "consider_clang_cl_ar_lib.patch"
)

file(COPY 
        "${CMAKE_CURRENT_LIST_DIR}/" 
    DESTINATION 
        "${CURRENT_PACKAGES_DIR}/share/${PORT}"
)

file(COPY 
        "${automake_source}/lib/ar-lib"
        "${automake_source}/lib/compile"
    DESTINATION 
        "${CURRENT_PACKAGES_DIR}/share/${PORT}/wrappers"
)

file(REMOVE 
        "${CURRENT_PACKAGES_DIR}/share/${PORT}/portfile.cmake"
        "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg.json"
)

vcpkg_install_copyright(FILE_LIST "${VCPKG_ROOT_DIR}/LICENSE.txt")

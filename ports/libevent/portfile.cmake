include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/libevent-release-2.1.8-stable)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libevent/libevent/archive/release-2.1.8-stable.tar.gz"
    FILENAME "libevent-2.1.8-stable.tar.gz"
    SHA512 0d5c872dc797b69ab8ea4b83aebcbac20735b8c6f5adfcc2950aa4d6013d240f5fac3376e817da75ae0ccead50cec0d931619e135a050add438777457b086549
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share)
file(RENAME ${CURRENT_PACKAGES_DIR}/cmake ${CURRENT_PACKAGES_DIR}/share/libevent)

file(READ ${CURRENT_PACKAGES_DIR}/debug/cmake/LibeventTargets-debug.cmake DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" DEBUG_MODULE "${DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/libevent/LibeventTargets-debug.cmake "${DEBUG_MODULE}")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/cmake)

file(COPY ${CURRENT_BUILDTREES_DIR}/src/libevent-release-2.1.8-stable/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libevent)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libevent/LICENSE ${CURRENT_PACKAGES_DIR}/share/libevent/copyright)
vcpkg_copy_pdbs()

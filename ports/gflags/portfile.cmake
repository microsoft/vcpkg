include(vcpkg_common_functions)
find_program(GIT git)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/gflags/gflags/archive/v2.2.0.zip"
    FILENAME "gflags-v2.2.0.zip"
    SHA512 638d094cdcc759a35ebd0e57900216deec6113242d2dcc964beff7b88cf56e3dbab3dce6e10a055bfd94cb5daebb8632382219a5ef40a689e14c76b263d3eca5)

vcpkg_extract_source_archive(${ARCHIVE})

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/gflags-2.2.0)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DGFLAGS_REGISTER_BUILD_DIR:BOOL=OFF
        -DGFLAGS_REGISTER_INSTALL_PREFIX:BOOL=OFF
        -DBUILD_gflags_nothreads_LIB:BOOL=OFF
)

vcpkg_install_cmake()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gflags.dll ${CURRENT_PACKAGES_DIR}/bin/gflags.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gflags.dll ${CURRENT_PACKAGES_DIR}/debug/bin/gflags.dll)
endif()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share)
file(RENAME ${CURRENT_PACKAGES_DIR}/cmake ${CURRENT_PACKAGES_DIR}/share/gflags)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(READ ${CURRENT_PACKAGES_DIR}/debug/cmake/gflags-targets-debug.cmake GFLAGS_DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" GFLAGS_DEBUG_MODULE "${GFLAGS_DEBUG_MODULE}")
string(REPLACE "/Lib/gflags.dll" "/bin/gflags.dll" GFLAGS_DEBUG_MODULE "${GFLAGS_DEBUG_MODULE}")
string(REPLACE "/Lib/gflags_nothreads.dll" "/bin/gflags_nothreads.dll" GFLAGS_DEBUG_MODULE "${GFLAGS_DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/gflags/gflags-targets-debug.cmake "${GFLAGS_DEBUG_MODULE}")

file(READ ${CURRENT_PACKAGES_DIR}/share/gflags/gflags-targets-release.cmake GFLAGS_RELEASE_MODULE)
string(REPLACE "/Lib/gflags.dll" "/bin/gflags.dll" GFLAGS_RELEASE_MODULE "${GFLAGS_RELEASE_MODULE}")
string(REPLACE "/Lib/gflags_nothreads.dll" "/bin/gflags_nothreads.dll" GFLAGS_RELEASE_MODULE "${GFLAGS_RELEASE_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/gflags/gflags-targets-release.cmake "${GFLAGS_RELEASE_MODULE}")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/cmake)

file(READ ${CURRENT_PACKAGES_DIR}/share/gflags/gflags-targets.cmake GFLAGS_CONFIG_MODULE)
string(REPLACE "get_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)"
               "get_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)"
               GFLAGS_CONFIG_MODULE "${GFLAGS_CONFIG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/gflags/gflags-targets.cmake ${GFLAGS_CONFIG_MODULE})

file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/COPYING.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/gflags RENAME copyright)


vcpkg_copy_pdbs()

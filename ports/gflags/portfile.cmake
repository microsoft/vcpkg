include(vcpkg_common_functions)
find_program(GIT git)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gflags/gflags
    REF v2.2.0
    SHA512 e2106ca70ff539024f888bca12487b3bf7f4f51928acf5ae3e1022f6bbd5e3b7882196ec50b609fd52f739e1f7b13eec7d4b3535d8216ec019a3577de6b4228d
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/fix-static-linking.patch"
)

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
file(WRITE ${CURRENT_PACKAGES_DIR}/share/gflags/gflags-targets.cmake "${GFLAGS_CONFIG_MODULE}")

file(INSTALL ${SOURCE_PATH}/COPYING.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/gflags RENAME copyright)

file(RENAME ${CURRENT_PACKAGES_DIR}/Include ${CURRENT_PACKAGES_DIR}/include)
file(RENAME ${CURRENT_PACKAGES_DIR}/Lib ${CURRENT_PACKAGES_DIR}/lib)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/Lib ${CURRENT_PACKAGES_DIR}/debug/lib)

vcpkg_copy_pdbs()

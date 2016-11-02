include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
find_program(GIT git)

set(GIT_URL "https://github.com/gflags/gflags.git")
set(GIT_TAG "v2.1.2")

if(NOT EXISTS "${DOWNLOADS}/gflags.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${GIT_URL} ${DOWNLOADS}/gflags.git
        WORKING_DIRECTORY ${DOWNLOADS}
        LOGNAME clone
    )
endif()
message(STATUS "Cloning done")

if(NOT EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
    message(STATUS "Adding worktree and patching")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR})
    vcpkg_execute_required_process(
        COMMAND ${GIT} worktree add -f --detach ${CURRENT_BUILDTREES_DIR}/src ${GIT_TAG}
        WORKING_DIRECTORY ${DOWNLOADS}/gflags.git
        LOGNAME worktree
    )
    message(STATUS "Patching")
    vcpkg_execute_required_process(
        COMMAND ${GIT} apply ${CMAKE_CURRENT_LIST_DIR}/0001-Fix-some-compilation-warnings-with-MSVC-2015.patch --ignore-whitespace --whitespace=fix
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/src
        LOGNAME patch
    )
endif()
message(STATUS "Adding worktree and patching done")

vcpkg_configure_cmake(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src
)

vcpkg_install_cmake()

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gflags.dll ${CURRENT_PACKAGES_DIR}/bin/gflags.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/gflags_nothreads.dll ${CURRENT_PACKAGES_DIR}/bin/gflags_nothreads.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gflags.dll ${CURRENT_PACKAGES_DIR}/debug/bin/gflags.dll)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/gflags_nothreads.dll ${CURRENT_PACKAGES_DIR}/debug/bin/gflags_nothreads.dll)
endif()

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/share)
file(RENAME ${CURRENT_PACKAGES_DIR}/cmake ${CURRENT_PACKAGES_DIR}/share/gflags)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(READ ${CURRENT_PACKAGES_DIR}/debug/cmake/gflags-export-debug.cmake GFLAGS_DEBUG_MODULE)
string(REPLACE "\${_IMPORT_PREFIX}" "\${_IMPORT_PREFIX}/debug" GFLAGS_DEBUG_MODULE "${GFLAGS_DEBUG_MODULE}")
string(REPLACE "/Lib/gflags.dll" "/bin/gflags.dll" GFLAGS_DEBUG_MODULE "${GFLAGS_DEBUG_MODULE}")
string(REPLACE "/Lib/gflags_nothreads.dll" "/bin/gflags_nothreads.dll" GFLAGS_DEBUG_MODULE "${GFLAGS_DEBUG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/gflags/gflags-export-debug.cmake "${GFLAGS_DEBUG_MODULE}")

file(READ ${CURRENT_PACKAGES_DIR}/share/gflags/gflags-export-release.cmake GFLAGS_RELEASE_MODULE)
string(REPLACE "/Lib/gflags.dll" "/bin/gflags.dll" GFLAGS_RELEASE_MODULE "${GFLAGS_RELEASE_MODULE}")
string(REPLACE "/Lib/gflags_nothreads.dll" "/bin/gflags_nothreads.dll" GFLAGS_RELEASE_MODULE "${GFLAGS_RELEASE_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/gflags/gflags-export-release.cmake "${GFLAGS_RELEASE_MODULE}")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/cmake)

file(READ ${CURRENT_PACKAGES_DIR}/share/gflags/gflags-export.cmake GFLAGS_CONFIG_MODULE)
string(REPLACE "get_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)" 
               "get_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)\nget_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)" 
               GFLAGS_CONFIG_MODULE "${GFLAGS_CONFIG_MODULE}")
file(WRITE ${CURRENT_PACKAGES_DIR}/share/gflags/gflags-export.cmake ${GFLAGS_CONFIG_MODULE})

file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/COPYING.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/gflags RENAME copyright)


vcpkg_copy_pdbs()

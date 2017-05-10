if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported yet. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

include(vcpkg_common_functions)

set(GIT_URL "https://github.com/jemalloc/jemalloc-cmake.git")
set(GIT_REF "jemalloc-cmake.4.3.1")

if(NOT EXISTS "${DOWNLOADS}/jemalloc-cmake.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${GIT_URL} ${DOWNLOADS}/jemalloc-cmake.git
        WORKING_DIRECTORY ${DOWNLOADS}
        LOGNAME clone
    )
endif()

set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src)

if(NOT EXISTS "${SOURCE_PATH}/.git")
    message(STATUS "Adding worktree")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR})
    vcpkg_execute_required_process(
        COMMAND ${GIT} worktree add -f --detach ${SOURCE_PATH} ${GIT_REF}
        WORKING_DIRECTORY ${DOWNLOADS}/jemalloc-cmake.git
        LOGNAME worktree
    )
    message(STATUS "Patching")
    vcpkg_apply_patches(
        SOURCE_PATH ${SOURCE_PATH}
        PATCHES "${CMAKE_CURRENT_LIST_DIR}/fix-cmakelists.patch"
        PATCHES "${CMAKE_CURRENT_LIST_DIR}/fix-utilities.patch"
    )
endif()

# jemalloc uses git to get it version
find_program(GIT NAMES git git.cmd)
get_filename_component(GIT_EXE_PATH ${GIT} DIRECTORY)
set(ENV{PATH} "${GIT_EXE_PATH};$ENV{PATH}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/jemalloc)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/jemalloc/COPYING ${CURRENT_PACKAGES_DIR}/share/jemalloc/copyright)

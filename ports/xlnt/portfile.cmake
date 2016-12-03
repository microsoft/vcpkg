if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(STATIC "OFF")
else()
    set(STATIC "ON")
endif()

include(vcpkg_common_functions)
find_program(GIT git)

set(GIT_URL "https://github.com/tfussell/xlnt.git")
set(GIT_REV "f33e8870123042b8420f87b82673c11014f6babd")

if(NOT EXISTS "${DOWNLOADS}/xlnt.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${GIT_URL} ${DOWNLOADS}/xlnt.git
        WORKING_DIRECTORY ${DOWNLOADS}
        LOGNAME clone
    )
endif()
message(STATUS "Cloning done")

if(NOT EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
    message(STATUS "Adding worktree")
    vcpkg_execute_required_process(
        COMMAND ${GIT} worktree add -f --detach ${CURRENT_BUILDTREES_DIR}/src ${GIT_REV}
        WORKING_DIRECTORY ${DOWNLOADS}/xlnt.git
        LOGNAME worktree
    )
    message(STATUS "Updating sumbodules")
    vcpkg_execute_required_process(
        COMMAND ${GIT} submodule update --init --remote
        WORKING_DIRECTORY ${CURRENT_BUILDTREES_DIR}/src
        LOGNAME submodule
    )
endif()
message(STATUS "Adding worktree and updating sumbodules done")

vcpkg_configure_cmake(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src
    OPTIONS -DTESTS=OFF -DSAMPLES=OFF -DBENCHMARKS=OFF -DSTATIC=${STATIC}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/LICENCE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/xlnt RENAME copyright)

vcpkg_copy_pdbs()

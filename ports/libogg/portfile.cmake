# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

include(${CMAKE_TRIPLET_FILE})
include(vcpkg_common_functions)
find_program(GIT git)

set(GIT_URL "https://git.xiph.org/ogg.git")
set(GIT_REF "cab46b19847eb1d38aeda73ab4708716e5776366")

if(NOT EXISTS "${DOWNLOADS}/ogg.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${GIT_URL} ${DOWNLOADS}/ogg.git
        WORKING_DIRECTORY ${DOWNLOADS}
        LOGNAME clone
    )
endif()

if(NOT EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
    message(STATUS "Adding worktree")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR})
    vcpkg_execute_required_process(
        COMMAND ${GIT} worktree add -f --detach ${CURRENT_BUILDTREES_DIR}/src ${GIT_REF}
        WORKING_DIRECTORY ${DOWNLOADS}/ogg.git
        LOGNAME worktree
    )
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src
)

vcpkg_install_cmake()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
# Handle copyright
file(COPY ${CURRENT_BUILDTREES_DIR}/src/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libogg)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libogg/COPYING ${CURRENT_PACKAGES_DIR}/share/libogg/copyright)

vcpkg_copy_pdbs()

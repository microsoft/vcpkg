# Common Ambient Variables:
#   VCPKG_ROOT_DIR = <C:\path\to\current\vcpkg>
#   TARGET_TRIPLET is the current triplet (x86-windows, etc)
#   PORT is the current port name (zlib, etc)
#   CURRENT_BUILDTREES_DIR = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR  = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported yet. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()
include(vcpkg_common_functions)
find_program(GIT git)

set(GIT_URL "https://git.xiph.org/vorbis.git")
set(GIT_REF "143caf4023a90c09a5eb685fdd46fb9b9c36b1ee")

if(NOT EXISTS "${DOWNLOADS}/vorbis.git")
    message(STATUS "Cloning")
    vcpkg_execute_required_process(
        COMMAND ${GIT} clone --bare ${GIT_URL} ${DOWNLOADS}/vorbis.git
        WORKING_DIRECTORY ${DOWNLOADS}
        LOGNAME clone
    )
endif()

if(NOT EXISTS "${CURRENT_BUILDTREES_DIR}/src/.git")
    message(STATUS "Adding worktree and patching")
    file(MAKE_DIRECTORY ${CURRENT_BUILDTREES_DIR})
    vcpkg_execute_required_process(
        COMMAND ${GIT} worktree add -f --detach ${CURRENT_BUILDTREES_DIR}/src ${GIT_REF}
        WORKING_DIRECTORY ${DOWNLOADS}/vorbis.git
        LOGNAME worktree
    )
endif()
vcpkg_apply_patches(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/0001-Add-vorbisenc.c-to-vorbis-library.patch
        ${CMAKE_CURRENT_LIST_DIR}/0002-Allow-deprecated-functions.patch
)

file(TO_NATIVE_PATH "${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/include" OGG_INCLUDE)
file(TO_NATIVE_PATH "${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/lib/ogg.lib" OGG_LIB_REL)
file(TO_NATIVE_PATH "${VCPKG_ROOT_DIR}/installed/${TARGET_TRIPLET}/debug/lib/ogg.lib" OGG_LIB_DBG)

vcpkg_configure_cmake(
    SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src
    OPTIONS -DOGG_INCLUDE_DIRS=${OGG_INCLUDE}
    OPTIONS_RELEASE -DOGG_LIBRARIES=${OGG_LIB_REL}
    OPTIONS_DEBUG -DOGG_LIBRARIES=${OGG_LIB_DBG}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(COPY ${CURRENT_BUILDTREES_DIR}/src/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libvorbis)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libvorbis/COPYING ${CURRENT_PACKAGES_DIR}/share/libvorbis/copyright)

vcpkg_copy_pdbs()

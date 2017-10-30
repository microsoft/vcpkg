# Common Ambient Variables:
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    message(STATUS "Warning: Static building not supported yet. Building dynamic.")
    set(VCPKG_LIBRARY_LINKAGE dynamic)
endif()

include(vcpkg_common_functions)

set(DEVIL_VERSION 1.8.0)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO DentonW/DevIL
    REF v${DEVIL_VERSION}
	SHA512 4aed5e50a730ece8b1eb6b2f6204374c6fb6f5334cf7c880d84c0f79645ea7c6b5118f57a7868a487510fc59c452f51472b272215d4c852f265f58b5857e17c7
    HEAD_REF master
)

set(DEVIL_SHARED OFF)
if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(DEVIL_SHARED ON)
else()
    set(DEVIL_SHARED OFF)
endif()

vcpkg_apply_patches(
	SOURCE_PATH ${SOURCE_PATH}/DevIL
	PATCHES
		${CMAKE_CURRENT_LIST_DIR}/0001_fix-encoding.patch
		${CMAKE_CURRENT_LIST_DIR}/0002_fix-missing-mfc-includes.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/DevIL
    PREFER_NINJA
    OPTIONS
        -DBUILD_SHARED_LIBS=${DEVIL_SHARED}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/devil RENAME copyright)

# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO malaterre/GDCM
    REF v2.8.6
    SHA512 c04c131afae6a326978d82ea7c6f42eaa5d8e0f9d9dc3b6ad531a2d6ef7261e603cef32f364609ae99ff33f144373fe7bdd62056e535b6d487b0a4b13919062e
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/socketxx.patch
)


if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    set(GDCM_BUILD_SHARED_LIBS ON)
else()
    set(GDCM_BUILD_SHARED_LIBS OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
	PREFER_NINJA # Disable this option if project cannot be built with Ninja
	OPTIONS
		-DGDCM_BUILD_DOCBOOK_MANPAGES=OFF
		-DGDCM_BUILD_SHARED_LIBS=${GDCM_BUILD_SHARED_LIBS}
		-DGDCM_INSTALL_INCLUDE_DIR=include
		-DGDCM_USE_SYSTEM_EXPAT=ON
		-DGDCM_USE_SYSTEM_ZLIB=ON
		${ADDITIONAL_OPTIONS}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE
	${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/Copyright.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/gdcm2 RENAME copyright)

vcpkg_copy_pdbs()

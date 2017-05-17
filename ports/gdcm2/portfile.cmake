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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/GDCM-2.6.8)
vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/malaterre/GDCM/archive/v2.6.8.zip"
    FILENAME "GDCM-2.6.8.zip"
    SHA512 52d3b0e8a3dab3077ee63e08f9ed727cb66fdc511935664b9d446e753905103543dabe9baa0b4c4264317b6f11deaf6869d0f9180df032589422de0dac7fc787
)

vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/gdcmSystem.patch
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

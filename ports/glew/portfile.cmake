include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/glew-1.13.0)
vcpkg_download_distfile(ARCHIVE_FILE
    URLS "http://downloads.sourceforge.net/project/glew/glew/1.13.0/glew-1.13.0.tgz"
    FILENAME "glew-1.13.0.tgz"
    SHA512 8fc8d7c0d2cd9235ea51db9972f492701827bff40642fdb3cc54c10b0737dba8e6d8d0dcd8c5aa5bfaaae39c6198ba3d4292cd1662fbe1977eb9a5d187ba635f
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

IF (TRIPLET_SYSTEM_ARCH MATCHES "x86")
	SET(BUILD_ARCH "Win32")
ELSEIF(TRIPLET_SYSTEM_ARCH MATCHES "arm")
	MESSAGE(FATAL_ERROR, " ARM is currently not supported.")
	RETURN()
ELSE()
	SET(BUILD_ARCH ${TRIPLET_SYSTEM_ARCH})
ENDIF()

if(NOT EXISTS ${SOURCE_PATH}/build/vc12/glew_shared14.vcxproj)
    message(STATUS "Upgrading projects")
    file(READ ${SOURCE_PATH}/build/vc12/glew_shared.vcxproj PROJ)
    string(REPLACE
        "<PlatformToolset>v120</PlatformToolset>"
        "<PlatformToolset>v140</PlatformToolset>"
        PROJ ${PROJ})
    string(REPLACE
        "opengl32.lib%"
        "opengl32.lib\;%"
        PROJ ${PROJ})
    file(WRITE ${SOURCE_PATH}/build/vc12/glew_shared14.vcxproj ${PROJ})
endif()
message(STATUS "Upgrading projects done")

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/build/vc12/glew_shared14.vcxproj
)

message(STATUS "Installing")

file(INSTALL
    ${SOURCE_PATH}/bin/Debug/${BUILD_ARCH}/glew32d.dll
    ${SOURCE_PATH}/bin/Debug/${BUILD_ARCH}/glew32d.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
)
file(INSTALL
    ${SOURCE_PATH}/bin/Release/${BUILD_ARCH}/glew32.dll
    ${SOURCE_PATH}/bin/Release/${BUILD_ARCH}/glew32.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin
)
file(INSTALL
    ${SOURCE_PATH}/lib/Debug/${BUILD_ARCH}/glew32d.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
)
file(INSTALL
    ${SOURCE_PATH}/lib/Release/${BUILD_ARCH}/glew32.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
)
file(INSTALL
    ${SOURCE_PATH}/include/GL
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/glew RENAME copyright)
vcpkg_copy_pdbs()
message(STATUS "Installing done")

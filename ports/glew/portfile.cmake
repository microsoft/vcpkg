include(vcpkg_common_functions)
vcpkg_download_distfile(ARCHIVE_FILE
    URL "http://downloads.sourceforge.net/project/glew/glew/1.13.0/glew-1.13.0.tgz"
    FILENAME "glew-1.13.0.tgz"
    SHA512 8fc8d7c0d2cd9235ea51db9972f492701827bff40642fdb3cc54c10b0737dba8e6d8d0dcd8c5aa5bfaaae39c6198ba3d4292cd1662fbe1977eb9a5d187ba635f
)
vcpkg_extract_source_archive(${ARCHIVE_FILE})

if(NOT EXISTS ${CURRENT_BUILDTREES_DIR}/src/glew-1.13.0/build/vc12/glew_shared14.vcxproj)
    message(STATUS "Upgrading projects")
    file(READ ${CURRENT_BUILDTREES_DIR}/src/glew-1.13.0/build/vc12/glew_shared.vcxproj PROJ)
    string(REPLACE
        "<PlatformToolset>v120</PlatformToolset>"
        "<PlatformToolset>v140</PlatformToolset>"
        PROJ ${PROJ})
    string(REPLACE
        "opengl32.lib%"
        "opengl32.lib\;%"
        PROJ ${PROJ})
    file(WRITE ${CURRENT_BUILDTREES_DIR}/src/glew-1.13.0/build/vc12/glew_shared14.vcxproj ${PROJ})
endif()
message(STATUS "Upgrading projects done")

vcpkg_build_msbuild(
    PROJECT_PATH ${CURRENT_BUILDTREES_DIR}/src/glew-1.13.0/build/vc12/glew_shared14.vcxproj
)

message(STATUS "Installing")
file(INSTALL
    ${CURRENT_BUILDTREES_DIR}/src/glew-1.13.0/bin/Debug/Win32/glew32d.dll
    ${CURRENT_BUILDTREES_DIR}/src/glew-1.13.0/bin/Debug/Win32/glew32d.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin
)
file(INSTALL
    ${CURRENT_BUILDTREES_DIR}/src/glew-1.13.0/bin/Release/Win32/glew32.dll
    ${CURRENT_BUILDTREES_DIR}/src/glew-1.13.0/bin/Release/Win32/glew32.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/bin
)
file(INSTALL
    ${CURRENT_BUILDTREES_DIR}/src/glew-1.13.0/lib/Debug/Win32/glew32d.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib
)
file(INSTALL
    ${CURRENT_BUILDTREES_DIR}/src/glew-1.13.0/lib/Release/Win32/glew32.lib
    DESTINATION ${CURRENT_PACKAGES_DIR}/lib
)
file(INSTALL
    ${CURRENT_BUILDTREES_DIR}/src/glew-1.13.0/include/GL
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
)
file(INSTALL ${CURRENT_BUILDTREES_DIR}/src/glew-1.13.0/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/glew RENAME copyright)
vcpkg_copy_pdbs()
message(STATUS "Installing done")

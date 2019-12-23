vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ArtifexSoftware/mupdf
    REF 75dbbd97826e7191ee539f9934e607eb93247a42 #1.16.1-epub-prerelease
    SHA512 6ef83cadd0fd0d681ffe7f377b795046da533cb4d2a33f0165a0c77d29cd764f8c68fc8ff69bab957bc599e72241f402cf8fbfc31c46bc5cfd2783c3511c414d
    HEAD_REF master
	PATCHES
        Fix-error-C2169.patch
        fix-win-build.patch
)

if (VCPKG_TARGET_IS_WINDOWS)
    if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
        set(BUILD_ARCH "Win32")
    elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(BUILD_ARCH "x64")
    else()
        message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
    endif()
    
    message(STATUS "Upgrading solution")
    vcpkg_execute_required_process(
        COMMAND "devenv.exe"
                "mupdf.sln"
                /Upgrade
        WORKING_DIRECTORY ${SOURCE_PATH}/platform/win32
        LOGNAME upgrade-Packet-${TARGET_TRIPLET}
    )
    vcpkg_install_msbuild(
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH platform/win32/mupdf.sln
        INCLUDES_SUBPATH include/mupdf
        TARGET libmupdf 
        PLATFORM ${BUILD_ARCH}
        USE_VCPKG_INTEGRATION
    )

else()
    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        SKIP_CONFIGURE
    )
    
    vcpkg_install_make()
endif()

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

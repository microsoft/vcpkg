vcpkg_fail_port_install(ON_TARGET "UWP")
vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_STATIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ArtifexSoftware/mupdf
    REF c35d29bf873744d2e74f20444eb6dbef6acfe21c # 1.16.1
    SHA512 e21780283666224f2e5b8e70ff9dee7f6a43468fa4ed295301d5a97f6ecbf56870a07a3fe509a816dc5c1453e6532d27d27a46a1c2381c30770d0ebf45222ee9
    HEAD_REF master
    PATCHES
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
    
    # Bakup libmupdf project file to include gdcmjpeg include path
    if (NOT EXISTS ${SOURCE_PATH}/platform/win32/libmupdf.vcxproj.bak)
        configure_file(${SOURCE_PATH}/platform/win32/libmupdf.vcxproj ${SOURCE_PATH}/platform/win32/libmupdf.vcxproj.bak COPYONLY)
        file(REMOVE ${SOURCE_PATH}/platform/win32/libmupdf.vcxproj)
    endif()
    configure_file(${SOURCE_PATH}/platform/win32/libmupdf.vcxproj.bak ${SOURCE_PATH}/platform/win32/libmupdf.vcxproj COPYONLY)
    # Add include/gdcmjpeg/8 to include path
    file(READ ${SOURCE_PATH}/platform/win32/libmupdf.vcxproj LIBMUPDF_CFG)
    file(TO_NATIVE_PATH "${CURRENT_INSTALLED_DIR}/include/gdcmjpeg/8" GDCMJPEG_INC_PATH)
    string(REPLACE "<AdditionalIncludeDirectories>"
                "<AdditionalIncludeDirectories>${GDCMJPEG_INC_PATH};" LIBMUPDF_CFG "${LIBMUPDF_CFG}")
    file(WRITE ${SOURCE_PATH}/platform/win32/libmupdf.vcxproj "${LIBMUPDF_CFG}")
    
    vcpkg_install_msbuild(
        SOURCE_PATH ${SOURCE_PATH}
        PROJECT_SUBPATH platform/win32/mupdf.sln
        PLATFORM ${BUILD_ARCH}
        USE_VCPKG_INTEGRATION
    )
    
    file(COPY ${SOURCE_PATH}/include/mupdf DESTINATION ${CURRENT_PACKAGES_DIR}/include)

else()
    vcpkg_configure_make(
        SOURCE_PATH ${SOURCE_PATH}
        SKIP_CONFIGURE
    )
    
    vcpkg_install_make()
endif()

vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

vcpkg_fail_port_install(ON_TARGET "UWP")
vcpkg_check_linkage(ONLY_STATIC_LIBRARY ONLY_STATIC_CRT)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ArtifexSoftware/mupdf
    REF bc5f2b43dfbf05ef560ec094149c868227f58496
    SHA512 a15af0dff1395edc683abcf12f770de95f55b7ccd276925cfb92ef5282dc94ab7d3a1da7276a90f33cdf44c4245f954d386ddd0a48f4330f17619db9eafe54b9
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

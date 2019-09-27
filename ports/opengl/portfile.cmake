include(vcpkg_common_functions)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_get_program_files_32_bit(PROGRAM_FILES_32_BIT)
    vcpkg_get_windows_sdk(WINDOWS_SDK)

    if (WINDOWS_SDK MATCHES "10.")
        set(LIBGLFILEPATH  "${PROGRAM_FILES_32_BIT}\\Windows Kits\\10\\Lib\\${WINDOWS_SDK}\\um\\${TRIPLET_SYSTEM_ARCH}\\OpenGL32.Lib")
        set(LIBGLUFILEPATH "${PROGRAM_FILES_32_BIT}\\Windows Kits\\10\\Lib\\${WINDOWS_SDK}\\um\\${TRIPLET_SYSTEM_ARCH}\\GlU32.Lib")
        set(HEADERSPATH    "${PROGRAM_FILES_32_BIT}\\Windows Kits\\10\\Include\\${WINDOWS_SDK}\\um")
    elseif(WINDOWS_SDK MATCHES "8.")
        set(LIBGLFILEPATH  "${PROGRAM_FILES_32_BIT}\\Windows Kits\\8.1\\Lib\\winv6.3\\um\\${TRIPLET_SYSTEM_ARCH}\\OpenGL32.Lib")
        set(LIBGLUFILEPATH "${PROGRAM_FILES_32_BIT}\\Windows Kits\\8.1\\Lib\\winv6.3\\um\\${TRIPLET_SYSTEM_ARCH}\\GlU32.Lib")
        set(HEADERSPATH    "${PROGRAM_FILES_32_BIT}\\Windows Kits\\8.1\\Include\\um")
    else()
        message(FATAL_ERROR "Portfile not yet configured for Windows SDK with version: ${WINDOWS_SDK}")
    endif()

    if (NOT EXISTS "${LIBGLFILEPATH}")
        message(FATAL_ERROR "Cannot find Windows ${WINDOWS_SDK} SDK. File does not exist: ${LIBGLFILEPATH}")
    endif()

    if (NOT EXISTS "${LIBGLUFILEPATH}")
        message(FATAL_ERROR "Cannot find Windows ${WINDOWS_SDK} SDK. File does not exist: ${LIBGLUFILEPATH}")
    endif()

    file(MAKE_DIRECTORY
        ${CURRENT_PACKAGES_DIR}/include/gl
        ${CURRENT_PACKAGES_DIR}/lib
        ${CURRENT_PACKAGES_DIR}/debug/lib
        ${CURRENT_PACKAGES_DIR}/share/opengl
    )

    file(COPY
        "${HEADERSPATH}\\gl\\GL.h"
        "${HEADERSPATH}\\gl\\GLU.h"
        DESTINATION ${CURRENT_PACKAGES_DIR}/include/gl
    )
    file(COPY ${LIBGLFILEPATH}  DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(COPY ${LIBGLUFILEPATH} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(COPY ${LIBGLFILEPATH}  DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    file(COPY ${LIBGLUFILEPATH} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    
    # Download opengl utility toolkit
    set(GLUT_VER 3.7.6)
    if ("glut" IN_LIST FEATURES)
        # glut only support x86 dynamic.
        set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    
        vcpkg_download_distfile(ARCHIVE
            URLS "https://user.xmission.com/~nate/glut/glut-${GLUT_VER}-src.zip"
            FILENAME "glut-${GLUT_VER}-src.zip"
            SHA512 9dea26d5dfce9c709056871c3e42ec87eeac4e920e26ff76cf5bcf8c0a53de5d160b9a4d45f26643b41944933cca89ee4b49dcb7f2488cd4d351dbd14b2e165c
        )
        
        vcpkg_extract_source_archive_ex(
            ARCHIVE ${ARCHIVE}
            OUT_SOURCE_PATH SOURCE_PATH
            PATCHES disable-postcmd.patch
        )
        
        if (VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
            set(BUILD_ARCH "Win32")
        elseif (VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
            set(BUILD_ARCH "Win32")
            message("glut only support x86.")
        else()
            message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
        endif()
        
        set(GLUT_SOURCE_PATH ${SOURCE_PATH}/lib/glut)   

        if (NOT EXISTS ${GLUT_SOURCE_PATH}/glut32.vcxproj)
            message(STATUS "Upgrade solution...")
            vcpkg_execute_required_process(
                COMMAND "devenv.exe"
                        "glut32.dsp"
                        /Upgrade
                WORKING_DIRECTORY ${GLUT_SOURCE_PATH}
                LOGNAME upgrade-glut
            )
            
            # Fix '/ZI' and '/Gy-' incompatibility issues
            file(READ ${GLUT_SOURCE_PATH}/glut32.vcxproj GLUT_PRJ_FILE)
            string(REPLACE "<FunctionLevelLinking>false</FunctionLevelLinking>" "<FunctionLevelLinking>true</FunctionLevelLinking>" GLUT_PRJ_FILE "${GLUT_PRJ_FILE}")
            file(WRITE ${GLUT_SOURCE_PATH}/glut32.vcxproj "${GLUT_PRJ_FILE}")
        endif()
        
        vcpkg_build_msbuild(
            USE_VCPKG_INTEGRATION
            PROJECT_PATH ${GLUT_SOURCE_PATH}/glut32.vcxproj
            PLATFORM ${BUILD_ARCH}
        )
        
        file(COPY "${SOURCE_PATH}/include/GL/glut.h" "${SOURCE_PATH}/lib/glut/glut.def" DESTINATION ${CURRENT_PACKAGES_DIR}/include/gl)
        if (NOT CMAKE_BUILD_TYPE OR CMAKE_BUILD_TYPE STREQUAL debug)
            file(COPY "${GLUT_SOURCE_PATH}/Debug/glut32.dll" "${GLUT_SOURCE_PATH}/Debug/glut32.pdb" DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
            file(COPY "${GLUT_SOURCE_PATH}/Debug/glut32.lib" DESTINATION ${CURRENT_PACKAGES_DIR}/release/lib)
        endif()
        if (NOT CMAKE_BUILD_TYPE OR CMAKE_BUILD_TYPE STREQUAL release)
            file(COPY "${GLUT_SOURCE_PATH}/Release/glut32.dll" "${GLUT_SOURCE_PATH}/Release/glut32.pdb" DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
            file(COPY "${GLUT_SOURCE_PATH}/Release/glut32.lib" DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
        endif()
    endif()

    if (WINDOWS_SDK MATCHES "10.")
        file(WRITE ${CURRENT_PACKAGES_DIR}/share/opengl/copyright "See https://developer.microsoft.com/windows/downloads/windows-10-sdk for the Windows 10 SDK license")
    elseif(WINDOWS_SDK MATCHES "8.")
        file(WRITE ${CURRENT_PACKAGES_DIR}/share/opengl/copyright "See https://developer.microsoft.com/windows/downloads/windows-8-1-sdk for the Windows 8.1 SDK license")
    endif()
else()
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
endif()

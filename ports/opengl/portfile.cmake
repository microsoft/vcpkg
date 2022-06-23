if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    vcpkg_get_windows_sdk(WINDOWS_SDK)

    if (WINDOWS_SDK MATCHES "10.")
        file(TO_NATIVE_PATH "$ENV{WindowsSdkDir}Lib/${WINDOWS_SDK}/um/${TRIPLET_SYSTEM_ARCH}/OpenGL32.Lib" LIBGLFILEPATH)
        file(TO_NATIVE_PATH "$ENV{WindowsSdkDir}Lib/${WINDOWS_SDK}/um/${TRIPLET_SYSTEM_ARCH}/GlU32.Lib" LIBGLUFILEPATH)
        file(TO_NATIVE_PATH "$ENV{WindowsSdkDir}Include/${WINDOWS_SDK}/um" HEADERSPATH)
    elseif(WINDOWS_SDK MATCHES "8.")
        file(TO_NATIVE_PATH "$ENV{WindowsSdkDir}Lib/winv6.3/um/${TRIPLET_SYSTEM_ARCH}/OpenGL32.Lib" LIBGLFILEPATH)
        file(TO_NATIVE_PATH "$ENV{WindowsSdkDir}Lib/winv6.3/um/${TRIPLET_SYSTEM_ARCH}/GlU32.Lib" LIBGLUFILEPATH)
        file(TO_NATIVE_PATH "$ENV{WindowsSdkDir}Include/um" HEADERSPATH)
    else()
        message(FATAL_ERROR "Portfile not yet configured for Windows SDK with version: ${WINDOWS_SDK}")
    endif()

    if (NOT EXISTS "${LIBGLFILEPATH}")
        message(FATAL_ERROR "Cannot find Windows ${WINDOWS_SDK} SDK. File does not exist: ${LIBGLFILEPATH}")
    endif()

    if (NOT EXISTS "${LIBGLUFILEPATH}")
        message(FATAL_ERROR "Cannot find Windows ${WINDOWS_SDK} SDK. File does not exist: ${LIBGLUFILEPATH}")
    endif()

    file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}/include/gl"   INCLUDEGLPATH)   
    file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}/share/opengl" SHAREOPENGLPATH)   
    file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}/lib"          RELEASELIBPATH)
    file(TO_NATIVE_PATH "${CURRENT_PACKAGES_DIR}/debug/lib"    DEBUGLIBPATH)
    file(TO_NATIVE_PATH "${HEADERSPATH}/gl/GL.h"               GLGLHPATH)
    file(TO_NATIVE_PATH "${HEADERSPATH}/gl/GLU.h"              GLGLUHPATH)

    file(MAKE_DIRECTORY
        "${INCLUDEGLPATH}"
        "${SHAREOPENGLPATH}"
    )
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(MAKE_DIRECTORY
            "${RELEASELIBPATH}"
        )
    endif()
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(MAKE_DIRECTORY
            "${DEBUGLIBPATH}"
        )
    endif()

    file(COPY
       "${GLGLHPATH}"
       "${GLGLUHPATH}"
        DESTINATION "${INCLUDEGLPATH}"
    )
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(COPY ${LIBGLFILEPATH}  DESTINATION "${RELEASELIBPATH}")
        file(COPY ${LIBGLUFILEPATH} DESTINATION "${RELEASELIBPATH}")
    endif()
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(COPY ${LIBGLFILEPATH}  DESTINATION "${DEBUGLIBPATH}")
        file(COPY ${LIBGLUFILEPATH} DESTINATION "${DEBUGLIBPATH}")
    endif()

    if (WINDOWS_SDK MATCHES "10.")
        file(WRITE ${CURRENT_PACKAGES_DIR}/share/opengl/copyright "See https://developer.microsoft.com/windows/downloads/windows-10-sdk for the Windows 10 SDK license")
    elseif(WINDOWS_SDK MATCHES "8.")
        file(WRITE ${CURRENT_PACKAGES_DIR}/share/opengl/copyright "See https://developer.microsoft.com/windows/downloads/windows-8-1-sdk for the Windows 8.1 SDK license")
    endif()
    
    string(REGEX MATCH "^([0-9]+)\\.([0-9]+)\\.([0-9]+)" WINDOWS_SDK_SEMVER "${WINDOWS_SDK}")
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        configure_file("${CMAKE_CURRENT_LIST_DIR}/opengl.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/opengl.pc" @ONLY)
        configure_file("${CMAKE_CURRENT_LIST_DIR}/glu.pc.in" "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/glu.pc" @ONLY)
    endif()
    if (NOT VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        configure_file("${CMAKE_CURRENT_LIST_DIR}/opengl.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/opengl.pc" @ONLY)
        configure_file("${CMAKE_CURRENT_LIST_DIR}/glu.pc.in" "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/glu.pc" @ONLY)
    endif()
    vcpkg_fixup_pkgconfig()

else()
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
endif()

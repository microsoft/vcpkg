if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_get_program_files_32_bit(PROGRAM_FILES_32_BIT)
    vcpkg_get_windows_sdk(WINDOWS_SDK)
    vcpkg_get_windows_sdk_path(WINDOWS_SDK_PATH)

    if (WINDOWS_SDK MATCHES "10.")
        set(LIBGLFILEPATH  "${WINDOWS_SDK_PATH}\\Lib\\${WINDOWS_SDK}\\um\\${TRIPLET_SYSTEM_ARCH}\\OpenGL32.Lib")
        set(LIBGLUFILEPATH "${WINDOWS_SDK_PATH}\\Lib\\${WINDOWS_SDK}\\um\\${TRIPLET_SYSTEM_ARCH}\\GlU32.Lib")
        set(HEADERSPATH    "${WINDOWS_SDK_PATH}\\Include\\${WINDOWS_SDK}\\um")
    elseif(WINDOWS_SDK MATCHES "8.")
        set(LIBGLFILEPATH  "${WINDOWS_SDK_PATH}\\Lib\\winv6.3\\um\\${TRIPLET_SYSTEM_ARCH}\\OpenGL32.Lib")
        set(LIBGLUFILEPATH "${WINDOWS_SDK_PATH}\\Lib\\winv6.3\\um\\${TRIPLET_SYSTEM_ARCH}\\GlU32.Lib")
        set(HEADERSPATH    "${WINDOWS_SDK_PATH}\\Include\\um")
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

    if (WINDOWS_SDK MATCHES "10.")
        file(WRITE ${CURRENT_PACKAGES_DIR}/share/opengl/copyright "See https://developer.microsoft.com/windows/downloads/windows-10-sdk for the Windows 10 SDK license")
    elseif(WINDOWS_SDK MATCHES "8.")
        file(WRITE ${CURRENT_PACKAGES_DIR}/share/opengl/copyright "See https://developer.microsoft.com/windows/downloads/windows-8-1-sdk for the Windows 8.1 SDK license")
    endif()
else()
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
endif()

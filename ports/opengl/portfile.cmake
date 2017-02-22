include(vcpkg_common_functions)

vcpkg_get_program_files_32_bit(PROGRAM_FILES_32_BIT)
vcpkg_get_windows_sdk(WINDOWS_SDK)

if (${WINDOWS_SDK} STREQUAL "10")
    set(OPENGLPATH "${PROGRAM_FILES_32_BIT}\\Windows Kits\\10\\Lib\\${WINDOWS_SDK}\\um\\${TRIPLET_SYSTEM_ARCH}\\OpenGL32.Lib")
    set(LICENSEPATH "${PROGRAM_FILES_32_BIT}\\Windows Kits\\10\\Licenses\\${WINDOWS_SDK}\\sdk_license.rtf")
    set(HEADERSPATH "${PROGRAM_FILES_32_BIT}\\Windows Kits\\10\\Include\\${WINDOWS_SDK}\\um")
else()
    message(FATAL_ERROR "Portfile not yet configured for Windows SDK with version: ${WINDOWS_SDK}")
endif()


if (NOT EXISTS "${OPENGLPATH}")
    message(FATAL_ERROR "Cannot find Windows ${WINDOWS_SDK} SDK. File does not exist: ${OPENGLPATH}")
endif()

file(MAKE_DIRECTORY
    ${CURRENT_PACKAGES_DIR}/include/gl
    ${CURRENT_PACKAGES_DIR}/lib
    ${CURRENT_PACKAGES_DIR}/debug/lib
    ${CURRENT_PACKAGES_DIR}/share/opengl
)

file(COPY ${LICENSEPATH} DESTINATION ${CURRENT_PACKAGES_DIR}/include/gl)
file(COPY
    "${HEADERSPATH}\\gl\\GL.h"
    "${HEADERSPATH}\\gl\\GLU.h"
    DESTINATION ${CURRENT_PACKAGES_DIR}/include
    )
file(COPY ${OPENGLPATH} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${OPENGLPATH} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(COPY ${LICENSEPATH} DESTINATION ${CURRENT_PACKAGES_DIR}/share/opengl)
file(WRITE ${CURRENT_PACKAGES_DIR}/share/opengl/copyright "See the accompanying sdk_license.rtf")

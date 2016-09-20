set(OPENGLPATH "C:\\Program Files (x86)\\Windows Kits\\10\\Lib\\10.0.10240.0\\um\\${TRIPLET_SYSTEM_ARCH}\\OpenGL32.Lib")
set(LICENSEPATH "C:\\Program Files (x86)\\Windows Kits\\10\\Licenses\\10.0.10240.0\\sdk_license.rtf")
set(HEADERSPATH "C:\\Program Files (x86)\\Windows Kits\\10\\Include\\10.0.10240.0\\um")

if (NOT EXISTS "${OPENGLPATH}")
    message(FATAL_ERROR "Cannot find Windows 10.0.10240.0 SDK. File does not exist: ${OPENGLPATH}")
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

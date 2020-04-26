vcpkg_fail_port_install(ON_TARGET "OSX" "Linux")
vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_get_program_files_32_bit(PROGRAM_FILES_32_BIT)
vcpkg_get_windows_sdk(WINDOWS_SDK)

if (WINDOWS_SDK MATCHES "10.")
    set(LIBFILEPATH "${PROGRAM_FILES_32_BIT}\\Windows Kits\\10\\Debuggers\\lib\\${TRIPLET_SYSTEM_ARCH}\\dbghelp.lib")
    set(DLLFILEPATH "${PROGRAM_FILES_32_BIT}\\Windows Kits\\10\\Debuggers\\${TRIPLET_SYSTEM_ARCH}\\dbghelp.dll")
    set(HEADERPATH "${PROGRAM_FILES_32_BIT}\\Windows Kits\\10\\Debuggers\\inc\\dbghelp.h")
else()
    message(FATAL_ERROR "Portfile not yet configured for Windows SDK with version: ${WINDOWS_SDK}")
endif()

if (NOT EXISTS "${LIBFILEPATH}")
    message(FATAL_ERROR "Cannot find Windows ${WINDOWS_SDK} SDK. File does not exist: ${LIBFILEPATH}")
endif()

if (NOT EXISTS "${DLLFILEPATH}")
    message(FATAL_ERROR "Cannot find Windows ${WINDOWS_SDK} SDK. File does not exist: ${DLLFILEPATH}")
endif()

if (NOT EXISTS "${HEADERPATH}")
    message(FATAL_ERROR "Cannot find Windows ${WINDOWS_SDK} SDK. File does not exist: ${HEADERPATH}")
endif()

file(INSTALL ${LIBFILEPATH} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${LIBFILEPATH} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(INSTALL ${DLLFILEPATH} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(INSTALL ${DLLFILEPATH} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
file(INSTALL ${HEADERPATH} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

if (WINDOWS_SDK MATCHES "10.")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright "See https://developer.microsoft.com/windows/downloads/windows-10-sdk for the Windows 10 SDK license")
endif()

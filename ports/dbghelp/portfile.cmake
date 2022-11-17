vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_get_windows_sdk(WINDOWS_SDK)

if (WINDOWS_SDK VERSION_GREATER "10")
    set(LIBFILEPATH "$ENV{WindowsSdkDir}Debuggers\\lib\\${TRIPLET_SYSTEM_ARCH}\\dbghelp.lib")
    message("LIBFILEPATH: ${LIBFILEPATH}")
    set(DLLFILEPATH "$ENV{WindowsSdkDir}Debuggers\\${TRIPLET_SYSTEM_ARCH}\\dbghelp.dll")
    message("DLLFILEPATH: ${DLLFILEPATH}")
    set(HEADERPATH "$ENV{WindowsSdkDir}Debuggers\\inc\\dbghelp.h")
    message("HEADERPATH: ${HEADERPATH}")
else()
    message(FATAL_ERROR "Portfile not yet configured for Windows SDK with version: ${WINDOWS_SDK}")
endif()

if (NOT EXISTS "${LIBFILEPATH}" OR NOT EXISTS "${DLLFILEPATH}" OR NOT EXISTS "${HEADERPATH}")
    message(FATAL_ERROR "Cannot find debugging tools in Windows SDK ${WINDOWS_SDK}. Please reinstall the Windows SDK and select \"Debugging Tools\".")
endif()

file(INSTALL ${LIBFILEPATH} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${LIBFILEPATH} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
file(INSTALL ${DLLFILEPATH} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
file(INSTALL ${DLLFILEPATH} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
file(INSTALL ${HEADERPATH} DESTINATION ${CURRENT_PACKAGES_DIR}/include)

file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright "See https://developer.microsoft.com/windows/downloads/windows-10-sdk for the Windows 10 SDK license")

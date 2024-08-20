if(VCPKG_TARGET_IS_MINGW)
    set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
    return()
endif()

vcpkg_get_windows_sdk(WINDOWS_SDK)

if (WINDOWS_SDK MATCHES "10.")
    set(LIBFILEPATH "$ENV{WindowsSdkDir}Lib\\${WINDOWS_SDK}\\um\\${TRIPLET_SYSTEM_ARCH}\\Ws2_32.Lib")
    set(HEADERSPATH "$ENV{WindowsSdkDir}Include\\${WINDOWS_SDK}\\um")
elseif(WINDOWS_SDK MATCHES "8.")
    set(LIBFILEPATH "$ENV{WindowsSdkDir}Lib\\winv6.3\\um\\${TRIPLET_SYSTEM_ARCH}\\Ws2_32.Lib")
    set(HEADERSPATH "$ENV{WindowsSdkDir}Include\\um")
else()
    message(FATAL_ERROR "Portfile not yet configured for Windows SDK with version: ${WINDOWS_SDK}")
endif()

if (NOT EXISTS "${LIBFILEPATH}")
    message(FATAL_ERROR "Cannot find Windows ${WINDOWS_SDK} SDK. File does not exist: ${LIBFILEPATH}")
endif()

file(COPY ${LIBFILEPATH} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${LIBFILEPATH} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

if (WINDOWS_SDK MATCHES "10.")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/winsock2/copyright "See https://developer.microsoft.com/windows/downloads/windows-10-sdk for the Windows 10 SDK license")
elseif(WINDOWS_SDK MATCHES "8.")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/winsock2/copyright "See https://developer.microsoft.com/windows/downloads/windows-8-1-sdk for the Windows 8.1 SDK license")
endif()

# Allow empty include directory
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

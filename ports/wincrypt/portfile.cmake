include(vcpkg_common_functions)

vcpkg_get_program_files_32_bit(PROGRAM_FILES_32_BIT)
vcpkg_get_windows_sdk(WINDOWS_SDK)

if (WINDOWS_SDK MATCHES "10.")
    set(LIBFILEPATH "${PROGRAM_FILES_32_BIT}\\Windows Kits\\10\\Lib\\${WINDOWS_SDK}\\um\\${TRIPLET_SYSTEM_ARCH}\\Crypt32.Lib")
    set(HEADERSPATH "${PROGRAM_FILES_32_BIT}\\Windows Kits\\10\\Include\\${WINDOWS_SDK}\\um")
elseif(WINDOWS_SDK MATCHES "8.")
    set(LIBFILEPATH "${PROGRAM_FILES_32_BIT}\\Windows Kits\\8.1\\Lib\\winv6.3\\um\\${TRIPLET_SYSTEM_ARCH}\\Crypt32.Lib")
    set(HEADERSPATH "${PROGRAM_FILES_32_BIT}\\Windows Kits\\8.1\\Include\\um")
else()
    message(FATAL_ERROR "Portfile not yet configured for Windows SDK with version: ${WINDOWS_SDK}")
endif()

if (NOT EXISTS "${LIBFILEPATH}")
    message(FATAL_ERROR "Cannot find Windows ${WINDOWS_SDK} SDK. File does not exist: ${LIBFILEPATH}")
endif()

file(COPY ${LIBFILEPATH} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
file(COPY ${LIBFILEPATH} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)

if (WINDOWS_SDK MATCHES "10.")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/wincrypt/copyright "See https://developer.microsoft.com/windows/downloads/windows-10-sdk for the Windows 10 SDK license")
elseif(WINDOWS_SDK MATCHES "8.")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/wincrypt/copyright "See https://developer.microsoft.com/windows/downloads/windows-8-1-sdk for the Windows 8.1 SDK license")
endif()

# Allow empty include directory
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)
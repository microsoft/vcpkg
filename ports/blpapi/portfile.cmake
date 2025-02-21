# According to Bloomberg Helpdesk on 2023-07-18, the last digit of the version string is just a build identifier,
# not an actual version identifier, and can be different between the latest Linux and Windows distfiles.

if (VCPKG_TARGET_IS_LINUX)
    vcpkg_download_distfile(ARCHIVE
        URLS "https://blpapi.bloomberg.com/download/releases/raw/files/blpapi_cpp_3.24.6.1-linux.tar.gz"
        FILENAME "blpapi_cpp_3.24.6.1-linux.tar.gz"
        SHA512 a70b43614a7c3414ca391b4b1a9499a545d6ec98779caafed4317b2bc5cdce3e493bcd600196b340c657ce23287ce6f85833ec270b5301e074884f4640cb19f4
    )
elseif (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_download_distfile(ARCHIVE
        URLS "https://blpapi.bloomberg.com/download/releases/raw/files/blpapi_cpp_3.24.6.1-windows.zip"
        FILENAME "blpapi_cpp_3.24.6.1-windows.zip"
        SHA512 1e1dba172767c9fcd0d015f2e8eaa16ef25f643a241144bf4a38ed35c8d8cce9f7fa9f4275636abd8a7307c21def17e50cda0a28bdb3f233d1e7a5affd87d3a5
    )
endif()

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    PATCHES update-blpapi-lib-include-dir.patch
)

if ("${VCPKG_TARGET_ARCHITECTURE}" MATCHES "x86")
    set(BITS_SUFFIX 32)
elseif ("${VCPKG_TARGET_ARCHITECTURE}" MATCHES "x64")
    set(BITS_SUFFIX 64)
else()
    message(FATAL_ERROR "Unrecognized architecture.")
endif()

if (VCPKG_TARGET_IS_LINUX)
    file(GLOB SO_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/Linux/*${BITS_SUFFIX}.so")
else()
    file(GLOB DLL_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/lib/*${BITS_SUFFIX}.dll")
    file(GLOB LIB_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/lib/*${BITS_SUFFIX}.lib")
endif()

if (VCPKG_TARGET_IS_LINUX)
    file(COPY ${SO_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    if (NOT VCPKG_BUILD_TYPE)
        file(COPY ${SO_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    endif()
else()
    file(COPY ${DLL_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(COPY ${LIB_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    if (NOT VCPKG_BUILD_TYPE)
        file(COPY ${DLL_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
        file(COPY ${LIB_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    endif()
endif()

file(COPY "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}")

file(GLOB CMAKE_FILES LIST_DIRECTORIES false "${SOURCE_PATH}/cmake/*.cmake")
file(COPY ${CMAKE_FILES} DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" @ONLY)

file(INSTALL "${SOURCE_PATH}/License.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/vslavik/winsparkle/releases/download/v${VERSION}/WinSparkle-${VERSION}.zip"
    FILENAME "winsparkle-v${VERSION}.zip"
    SHA512 48306b9ca09e00dff6384767aed6e15f07dbb5463b6430cb18076195eea40c128cf952e68a300c920964276351c893aed93d3f81ac1d01db6caa0727885b2ef1
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    NO_REMOVE_ONE_LEVEL
)

# WinSparkle 0.9.4's binary ZIP retains this top-level directory when
# NO_REMOVE_ONE_LEVEL is used.
set(WINSPARKLE_ROOT "${SOURCE_PATH}/WinSparkle-${VERSION}")

if(NOT EXISTS "${WINSPARKLE_ROOT}/include/winsparkle.h")
    message(FATAL_ERROR "Unexpected WinSparkle archive layout under: ${SOURCE_PATH}")
endif()

file(GLOB HEADER_LIST "${WINSPARKLE_ROOT}/include/*.h")
file(INSTALL ${HEADER_LIST} DESTINATION "${CURRENT_PACKAGES_DIR}/include/${PORT}")

file(GLOB TOOLS_LIST "${WINSPARKLE_ROOT}/bin/*.bat")
file(INSTALL ${TOOLS_LIST} DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

# WinSparkle is distributed as a self-contained DLL even for static triplets.
set(VCPKG_POLICY_DLLS_IN_STATIC_LIBRARY enabled)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(WINSPARKLE_ARCH_DIR "Win32/Release")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(WINSPARKLE_ARCH_DIR "x64/Release")
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64")
    set(WINSPARKLE_ARCH_DIR "ARM64/Release")
else()
    message(FATAL_ERROR "Unsupported architecture: ${VCPKG_TARGET_ARCHITECTURE}")
endif()

set(WINSPARKLE_BINARY_DIR "${WINSPARKLE_ROOT}/${WINSPARKLE_ARCH_DIR}")

foreach(FILE_NAME IN ITEMS WinSparkle.dll WinSparkle.pdb)
    file(INSTALL
        "${WINSPARKLE_BINARY_DIR}/${FILE_NAME}"
        DESTINATION "${CURRENT_PACKAGES_DIR}/bin"
    )
    file(INSTALL
        "${WINSPARKLE_BINARY_DIR}/${FILE_NAME}"
        DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin"
    )
endforeach()

file(INSTALL
    "${WINSPARKLE_BINARY_DIR}/WinSparkle.lib"
    DESTINATION "${CURRENT_PACKAGES_DIR}/lib"
)
file(INSTALL
    "${WINSPARKLE_BINARY_DIR}/WinSparkle.lib"
    DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib"
)

vcpkg_install_copyright(FILE_LIST "${WINSPARKLE_ROOT}/COPYING")

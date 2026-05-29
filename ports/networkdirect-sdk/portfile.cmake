vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.nuget.org/api/v2/package/NetworkDirect/2.0.1"
    FILENAME "networkDirect-2.0.1.zip"
    SHA512 97e48ab293c164a80a3ed9e51f1f9f5ae85c07ee91c49950a76b486567d2e50346a2379b8284ffcb9d7d2fe70f76eff9455dce740cf9d3e0c1b83100e25168a8
)

vcpkg_download_distfile(LICENSE
    URLS "https://raw.githubusercontent.com/microsoft/NetworkDirect/master/LICENSE.txt"
    FILENAME "networkingDirect_license.txt"
    SHA512 7d79aae4c9beb85811a3e122a2b12aad231f519dd12a461ac49d52864a735a6b05a263d433c11ede1406d2e49b6dc62dd38487eb7bd8c079d7198a20cf85fc4d
)

vcpkg_extract_source_archive(
    SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    NO_REMOVE_ONE_LEVEL
)

file(COPY ${SOURCE_PATH}/include DESTINATION ${CURRENT_PACKAGES_DIR}/ )

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
  file(COPY ${SOURCE_PATH}/lib/x64/ndutil.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
  file(COPY ${SOURCE_PATH}/lib/x64/ndutil.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
  file(COPY ${SOURCE_PATH}/lib/Win32/ndutil.lib DESTINATION ${CURRENT_PACKAGES_DIR}/lib/)
  file(COPY ${SOURCE_PATH}/lib/Win32/ndutil.lib DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib/)
endif()

file(INSTALL ${LICENSE} DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

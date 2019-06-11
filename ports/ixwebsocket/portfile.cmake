include(vcpkg_common_functions)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/machinezone/IXWebSocket/archive/v4.0.3.tar.gz"
    FILENAME "v4.0.3.tar.gz"
    SHA512 41cda81ef28ae2a51d77bf09158f4c07350f22b17ed4b6645a87c7defd2a901b7656de260bc785c42990ddbea0ab23ad6e099694d2712537de0ca328aee8e229
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE} 
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS -DUSE_TLS=1
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/ixwebsocket RENAME copyright)

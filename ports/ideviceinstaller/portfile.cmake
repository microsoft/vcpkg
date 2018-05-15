# Common Ambient Variables:
#   CURRENT_BUILDTREES_DIR    = ${VCPKG_ROOT_DIR}\buildtrees\${PORT}
#   CURRENT_PACKAGES_DIR      = ${VCPKG_ROOT_DIR}\packages\${PORT}_${TARGET_TRIPLET}
#   CURRENT_PORT_DIR          = ${VCPKG_ROOT_DIR}\ports\${PORT}
#   PORT                      = current port name (zlib, etc)
#   TARGET_TRIPLET            = current triplet (x86-windows, x64-windows-static, etc)
#   VCPKG_CRT_LINKAGE         = C runtime linkage type (static, dynamic)
#   VCPKG_LIBRARY_LINKAGE     = target library linkage type (static, dynamic)
#   VCPKG_ROOT_DIR            = <C:\path\to\current\vcpkg>
#   VCPKG_TARGET_ARCHITECTURE = target architecture (x64, x86, arm)
#

include(vcpkg_common_functions)
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/ideviceinstaller-1.1.2.23)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL x64)
    set(MSBUILD_PLATFORM  x64)
else()
    set(MSBUILD_PLATFORM  Win32)
endif()

set(DEBUG_CONFIG Debug)
set(RELEASE_CONFIG Release)

vcpkg_download_distfile(ARCHIVE
    URLS "https://github.com/libimobiledevice-win32/ideviceinstaller/archive/1.1.2.23.zip"
    FILENAME "ideviceinstaller-1.1.2.23.zip"
    SHA512 fadfa831203599c7fede1317d920d281c1e0f2c56c5a89cb50bd6c3f976dafa4d144dc4fca62a6a09792118428bfcdedefd9241bcf7302f484adfb64e69df68c
)
vcpkg_extract_source_archive(${ARCHIVE})

vcpkg_build_msbuild(
    PROJECT_PATH ${SOURCE_PATH}/ideviceinstaller.vcxproj
    DEBUG_CONFIGURATION ${DEBUG_CONFIG}
    RELEASE_CONFIGURATION ${RELEASE_CONFIG}
    USE_VCPKG_INTEGRATION
)

# No headers
set(VCPKG_POLICY_EMPTY_INCLUDE_FOLDER enabled)

# Copy binary files
file (MAKE_DIRECTORY
    ${CURRENT_PACKAGES_DIR}/tools
    ${CURRENT_PACKAGES_DIR}/debug/tools)

file(COPY       ${SOURCE_PATH}/${MSBUILD_PLATFORM}/${DEBUG_CONFIG}/ideviceinstaller.exe
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools)
file(COPY       ${SOURCE_PATH}/${MSBUILD_PLATFORM}/${RELEASE_CONFIG}/ideviceinstaller.exe
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools)
file(COPY       ${SOURCE_PATH}/${MSBUILD_PLATFORM}/${DEBUG_CONFIG}/ideviceinstaller.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/debug/tools)
file(COPY       ${SOURCE_PATH}/${MSBUILD_PLATFORM}/${RELEASE_CONFIG}/ideviceinstaller.pdb
    DESTINATION ${CURRENT_PACKAGES_DIR}/tools)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/ideviceinstaller RENAME copyright)

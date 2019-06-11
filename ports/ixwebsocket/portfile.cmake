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

# ws exe
set(USE_WS OFF)
if("tool" IN_LIST FEATURES)
    set(USE_WS ON)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA # Disable this option if project cannot be built with Ninja
    OPTIONS
    	-DUSE_TLS=1
	-DUSE_WS=1
)

vcpkg_install_cmake()

# the native CMAKE_EXECUTABLE_SUFFIX does not work in portfiles, so emulate it
if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore") # Windows
    set(EXECUTABLE_SUFFIX ".exe")
else()
    set(EXECUTABLE_SUFFIX "")
endif()

if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/ws${EXECUTABLE_SUFFIX}")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/ixwebsocket")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/ws${EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/ixwebsocket/ws${EXECUTABLE_SUFFIX}")
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/ixwebsocket)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/ixwebsocket RENAME copyright)

# Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME ixwebsocket)

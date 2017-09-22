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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/winpcap)
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.winpcap.org/install/bin/WpcapSrc_4_1_3.zip"
    FILENAME "WpcapSrc_4_1_3.zip"
    SHA512 89a5109ed17f8069f7a43497f6fec817c58620dbc5fa506e52069b9113c5bc13f69c307affe611281cb727cfa0f8529d07044d41427e350b24468ccc89a87f33
)
vcpkg_extract_source_archive(${ARCHIVE})

if(VCPKG_CRT_LINKAGE STREQUAL "static")
    set(CRT_LINKAGE "MT")
elseif(VCPKG_CRT_LINKAGE STREQUAL "dynamic")
    set(CRT_LINKAGE "MD")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
set(LIBRARY_LINKAGE "4")
elseif(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
set(LIBRARY_LINKAGE "2")
endif()

configure_file("${CMAKE_CURRENT_LIST_DIR}/packetNtx.patch.in" "${CMAKE_CURRENT_LIST_DIR}/packetNtx.patch" @ONLY)
configure_file("${CMAKE_CURRENT_LIST_DIR}/wpcap.patch.in" "${CMAKE_CURRENT_LIST_DIR}/wpcap.patch" @ONLY)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES "${CMAKE_CURRENT_LIST_DIR}/packetNtx.patch"
            "${CMAKE_CURRENT_LIST_DIR}/wpcap.patch"
            "${CMAKE_CURRENT_LIST_DIR}/create_lib.patch"
)

file(
    COPY
        "${CURRENT_PORT_DIR}/create_bin.bat"
    DESTINATION
        ${SOURCE_PATH}
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(PLATFORM Win32)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(PLATFORM x64)
endif()

vcpkg_execute_required_process(
    COMMAND "devenv.exe"
            "Packet.sln"
            /Upgrade
    WORKING_DIRECTORY ${SOURCE_PATH}/packetNtx/Dll/Project
    LOGNAME upgrade-Packet-${TARGET_TRIPLET}
)

vcpkg_build_msbuild(
    PROJECT_PATH "${SOURCE_PATH}/packetNtx/Dll/Project/Packet.sln"
    PLATFORM ${PLATFORM}
)

vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(FLEX)

vcpkg_execute_required_process(
    COMMAND ${SOURCE_PATH}/wpcap/PRJ/build_scanner_parser.bat
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME build_scanner_parser-${TARGET_TRIPLET}
)

vcpkg_execute_required_process(
    COMMAND "devenv.exe"
            "wpcap.sln"
            /Upgrade
    WORKING_DIRECTORY ${SOURCE_PATH}/wpcap/PRJ
    LOGNAME upgrade-wpcap-${TARGET_TRIPLET}
)

vcpkg_build_msbuild(
    PROJECT_PATH "${SOURCE_PATH}/wpcap/PRJ/wpcap.sln"
    RELEASE_CONFIGURATION "Release - No AirPcap"
    DEBUG_CONFIGURATION "Debug - No AirPcap"
    PLATFORM ${PLATFORM}
)

vcpkg_execute_required_process(
    COMMAND ${SOURCE_PATH}/create_include.bat
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME create_include-${TARGET_TRIPLET}
)

file(
    INSTALL
        "${SOURCE_PATH}/WpdPack/Include/bittypes.h"
        "${SOURCE_PATH}/WpdPack/Include/ip6_misc.h"
        "${SOURCE_PATH}/WpdPack/Include/Packet32.h"
        "${SOURCE_PATH}/WpdPack/Include/pcap.h"
        "${SOURCE_PATH}/WpdPack/Include/pcap-bpf.h"
        "${SOURCE_PATH}/WpdPack/Include/pcap-namedb.h"
        "${SOURCE_PATH}/WpdPack/Include/pcap-stdinc.h"
        "${SOURCE_PATH}/WpdPack/Include/remote-ext.h"
        "${SOURCE_PATH}/WpdPack/Include/Win32-Extensions.h"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/include
)

file(
    INSTALL
        "${SOURCE_PATH}/WpdPack/Include/pcap/bluetooth.h"
        "${SOURCE_PATH}/WpdPack/Include/pcap/bpf.h"
        "${SOURCE_PATH}/WpdPack/Include/pcap/namedb.h"
        "${SOURCE_PATH}/WpdPack/Include/pcap/pcap.h"
        "${SOURCE_PATH}/WpdPack/Include/pcap/sll.h"
        "${SOURCE_PATH}/WpdPack/Include/pcap/usb.h"
        "${SOURCE_PATH}/WpdPack/Include/pcap/vlan.h"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/include/pcap
)

vcpkg_execute_required_process(
    COMMAND ${SOURCE_PATH}/create_lib.bat
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME create_lib-${TARGET_TRIPLET}
)

set(PCAP_LIBRARY_PATH "${SOURCE_PATH}/WpdPack/Lib")
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(PCAP_LIBRARY_PATH "${PCAP_LIBRARY_PATH}/x64")
endif()

file(
    INSTALL
        "${PCAP_LIBRARY_PATH}/Packet.lib"
        "${PCAP_LIBRARY_PATH}/wpcap.lib"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/lib
)

file(
    INSTALL
        "${PCAP_LIBRARY_PATH}/Packet.lib"
        "${PCAP_LIBRARY_PATH}/wpcap.lib"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/debug/lib
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_execute_required_process(
        COMMAND ${SOURCE_PATH}/create_bin.bat
        WORKING_DIRECTORY ${SOURCE_PATH}
        LOGNAME create_bin-${TARGET_TRIPLET}
    )

    set(PCAP_BINARY_PATH "${SOURCE_PATH}/WpdPack/Bin")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(PCAP_BINARY_PATH "${PCAP_BINARY_PATH}/x64")
    endif()

    file(
        INSTALL
            "${PCAP_BINARY_PATH}/Packet.dll"
            "${PCAP_BINARY_PATH}/wpcap.dll"
        DESTINATION
            ${CURRENT_PACKAGES_DIR}/bin
    )

    file(
        INSTALL
            "${PCAP_BINARY_PATH}/Packet.dll"
            "${PCAP_BINARY_PATH}/wpcap.dll"
        DESTINATION
            ${CURRENT_PACKAGES_DIR}/debug/bin
    )
endif()

# Handle copyright
file(DOWNLOAD "https://www.winpcap.org/misc/copyright.htm" ${SOURCE_PATH}/copyright.htm)
file(INSTALL ${SOURCE_PATH}/copyright.htm DESTINATION ${CURRENT_PACKAGES_DIR}/share/winpcap RENAME copyright)

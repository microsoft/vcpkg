if(EXISTS "${CURRENT_INSTALLED_DIR}/share/libpcap")
    message(FATAL_ERROR "FATAL ERROR: libpcap and winpcap are incompatible.")
endif()

set(WINPCAP_VERSION 4_1_3)

vcpkg_download_distfile(ARCHIVE
    URLS "https://www.winpcap.org/install/bin/WpcapSrc_${WINPCAP_VERSION}.zip"
    FILENAME "WpcapSrc_${WINPCAP_VERSION}.zip"
    SHA512 89a5109ed17f8069f7a43497f6fec817c58620dbc5fa506e52069b9113c5bc13f69c307affe611281cb727cfa0f8529d07044d41427e350b24468ccc89a87f33
)

# MSBuild performs in-source builds, so to ensure reliability we must clear them each time
file(REMOVE_RECURSE ${CURRENT_BUILDTREES_DIR}/src)

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

configure_file("${CMAKE_CURRENT_LIST_DIR}/packetNtx.patch.in" "${CURRENT_BUILDTREES_DIR}/src/packetNtx.patch" @ONLY)
configure_file("${CMAKE_CURRENT_LIST_DIR}/wpcap.patch.in" "${CURRENT_BUILDTREES_DIR}/src/wpcap.patch" @ONLY)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${WINPCAP_VERSION}
    PATCHES
        "${CURRENT_BUILDTREES_DIR}/src/packetNtx.patch"
        "${CURRENT_BUILDTREES_DIR}/src/wpcap.patch"
        "${CMAKE_CURRENT_LIST_DIR}/create_lib.patch"
        "${CMAKE_CURRENT_LIST_DIR}/fix-create-lib-batch.patch"
)

file(COPY "${CURRENT_PORT_DIR}/create_bin.bat" DESTINATION "${SOURCE_PATH}")

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
    set(PLATFORM Win32)
elseif(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(PLATFORM x64)
endif()

vcpkg_execute_required_process(
    COMMAND "devenv.exe"
            "Packet.sln"
            /Upgrade
    WORKING_DIRECTORY "${SOURCE_PATH}/packetNtx/Dll/Project"
    LOGNAME upgrade-Packet-${TARGET_TRIPLET}
)

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(COPY "${CURRENT_PORT_DIR}/Packet.vcxproj" DESTINATION "${SOURCE_PATH}/packetNtx/Dll/Project/")
endif()

vcpkg_build_msbuild(
    PROJECT_PATH "${SOURCE_PATH}/packetNtx/Dll/Project/Packet.sln"
    RELEASE_CONFIGURATION "Release"
    DEBUG_CONFIGURATION "Debug"
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

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" AND VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(COPY "${CURRENT_PORT_DIR}/wpcap.vcxproj" DESTINATION "${SOURCE_PATH}/wpcap/PRJ/")
endif()

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

file(INSTALL
        "${SOURCE_PATH}/WpdPack/Include/bittypes.h"
        "${SOURCE_PATH}/WpdPack/Include/ip6_misc.h"
        "${SOURCE_PATH}/WpdPack/Include/Packet32.h"
        "${SOURCE_PATH}/WpdPack/Include/pcap.h"
        "${SOURCE_PATH}/WpdPack/Include/pcap-bpf.h"
        "${SOURCE_PATH}/WpdPack/Include/pcap-namedb.h"
        "${SOURCE_PATH}/WpdPack/Include/pcap-stdinc.h"
        "${SOURCE_PATH}/WpdPack/Include/remote-ext.h"
        "${SOURCE_PATH}/WpdPack/Include/Win32-Extensions.h"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL
        "${SOURCE_PATH}/WpdPack/Include/pcap/bluetooth.h"
        "${SOURCE_PATH}/WpdPack/Include/pcap/bpf.h"
        "${SOURCE_PATH}/WpdPack/Include/pcap/namedb.h"
        "${SOURCE_PATH}/WpdPack/Include/pcap/pcap.h"
        "${SOURCE_PATH}/WpdPack/Include/pcap/sll.h"
        "${SOURCE_PATH}/WpdPack/Include/pcap/usb.h"
        "${SOURCE_PATH}/WpdPack/Include/pcap/vlan.h"
    DESTINATION "${CURRENT_PACKAGES_DIR}/include/pcap")

vcpkg_execute_required_process(
    COMMAND ${SOURCE_PATH}/create_lib.bat
    WORKING_DIRECTORY ${SOURCE_PATH}
    LOGNAME create_lib-${TARGET_TRIPLET}
)

set(PCAP_LIBRARY_PATH "${SOURCE_PATH}/WpdPack/Lib")
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(PCAP_LIBRARY_PATH "${PCAP_LIBRARY_PATH}/x64")
endif()

file(INSTALL
        "${PCAP_LIBRARY_PATH}/Packet.lib"
        "${PCAP_LIBRARY_PATH}/wpcap.lib"
    DESTINATION "${CURRENT_PACKAGES_DIR}/lib")

file(INSTALL
        "${PCAP_LIBRARY_PATH}/debug/Packet.lib"
        "${PCAP_LIBRARY_PATH}/debug/wpcap.lib"
    DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_execute_required_process(
        COMMAND "${SOURCE_PATH}/create_bin.bat"
        WORKING_DIRECTORY "${SOURCE_PATH}"
        LOGNAME create_bin-${TARGET_TRIPLET}
    )

    set(PCAP_BINARY_PATH "${SOURCE_PATH}/WpdPack/Bin")
    if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
        set(PCAP_BINARY_PATH "${PCAP_BINARY_PATH}/x64")
    endif()

    file(INSTALL
            "${PCAP_BINARY_PATH}/Packet.dll"
            "${PCAP_BINARY_PATH}/wpcap.dll"
        DESTINATION "${CURRENT_PACKAGES_DIR}/bin")

    file(INSTALL
            "${PCAP_BINARY_PATH}/Packet.dll"
            "${PCAP_BINARY_PATH}/wpcap.dll"
        DESTINATION  "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/pcap-stdinc.h" "#define inline __inline" "#ifndef __cplusplus\n#define inline __inline\n#endif")

file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "The latest license is available in https://www.winpcap.org/misc/copyright.htm and in the header files.
")

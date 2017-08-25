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
set(SOURCE_PATH ${CURRENT_BUILDTREES_DIR}/src/WpdPack)
vcpkg_download_distfile(ARCHIVE
    URLS "https://www.winpcap.org/install/bin/WpdPack_4_1_2.zip"
    FILENAME "WpdPack_4_1_2.zip"
    SHA512 7a319dfcda779eb881eca43c83c5570c0e359da30464f981010d31615222b84f758c3a8ea96605e02dc3f0a294c4c36be447d22beb1e58cd40a73deb1ad128f0
)
vcpkg_extract_source_archive(${ARCHIVE})

file(
    INSTALL
        "${SOURCE_PATH}/Include/bittypes.h"
        "${SOURCE_PATH}/Include/ip6_misc.h"
        "${SOURCE_PATH}/Include/Packet32.h"
        "${SOURCE_PATH}/Include/pcap.h"
        "${SOURCE_PATH}/Include/pcap-bpf.h"
        "${SOURCE_PATH}/Include/pcap-namedb.h"
        "${SOURCE_PATH}/Include/remote-ext.h"
        "${SOURCE_PATH}/Include/Win32-Extensions.h"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/include
)

file(
    INSTALL
        "${SOURCE_PATH}/Include/pcap/bluetooth.h"
        "${SOURCE_PATH}/Include/pcap/bpf.h"
        "${SOURCE_PATH}/Include/pcap/namedb.h"
        "${SOURCE_PATH}/Include/pcap/pcap.h"
        "${SOURCE_PATH}/Include/pcap/sll.h"
        "${SOURCE_PATH}/Include/pcap/usb.h"
        "${SOURCE_PATH}/Include/pcap/vlan.h"
    DESTINATION
        ${CURRENT_PACKAGES_DIR}/include/pcap
)

set(PCAP_LIBRARY_PATH "${SOURCE_PATH}/Lib")
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

# Handle copyright
file(DOWNLOAD "https://www.winpcap.org/misc/copyright.htm" ${SOURCE_PATH}/copyright.htm)
file(INSTALL ${SOURCE_PATH}/copyright.htm DESTINATION ${CURRENT_PACKAGES_DIR}/share/winpcap RENAME copyright)

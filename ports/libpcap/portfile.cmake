vcpkg_fail_port_install(MESSAGE "${PORT} currently only supports Linux platform" ON_TARGET "Windows" "OSX")

message(
"libpcap currently requires the following libraries from the system package manager:
    flex
    libbison-dev
These can be installed on Ubuntu systems via sudo apt install flex libbison-dev"
)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
include(vcpkg_fixup_pkgconfig)

vcpkg_download_distfile(
    SOURCE_ARCHIVE_PATH
    URLS http://www.tcpdump.org/release/libpcap-1.9.1.tar.gz
    FILENAME libpcap-1.9.1.tar.gz
    SHA512 ae0d6b0ad8253e7e059336c0f4ed3850d20d7d2f4dc1d942c2951f99a5443a690f0cc42c6f8fdc4a0ccb19e9e985192ba6f399c4bde2c7076e420f547fddfb08
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${SOURCE_ARCHIVE_PATH}
    REF 1.9.1
    PATCHES 0001-fix-package-name.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DDISABLE_USB=ON
        -DDISABLE_NETMAP=ON
        -DDISABLE_BLUETOOTH=ON
        -DDISABLE_DBUS=ON
        -DDISABLE_RDMA=ON
)

vcpkg_install_cmake()
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libpcap RENAME copyright)

vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share ${CURRENT_PACKAGES_DIR}/share/man)

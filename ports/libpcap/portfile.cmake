vcpkg_fail_port_install(MESSAGE "${PORT} currently only supports x64-windows, x86-windows and Linux" ON_TARGET "UWP" "OSX" ON_ARCH "arm64")

if(EXISTS "${CURRENT_INSTALLED_DIR}/share/winpcap")
    message(FATAL_ERROR "FATAL ERROR: winpcap and libpcap are incompatible.")
endif()

if(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
    message(
"libpcap currently requires the following libraries from the system package manager:
    flex
    libbison-dev
These can be installed on Ubuntu systems via sudo apt install flex libbison-dev"
    )
endif()

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})

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
    PATCHES 
        0001-fix-package-name.patch
        install-pc-on-msvc.patch
        add-disable-packet-option.patch
)

# Only dynamic builds are currently supported on Windows
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)
endif()

vcpkg_find_acquire_program(BISON)
get_filename_component(BISON_PATH ${BISON} DIRECTORY)
vcpkg_add_to_path(${BISON_PATH})
vcpkg_find_acquire_program(FLEX)
get_filename_component(FLEX_PATH ${FLEX} DIRECTORY)
vcpkg_add_to_path(${FLEX_PATH})

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DDISABLE_USB=ON
        -DDISABLE_NETMAP=ON
        -DDISABLE_BLUETOOTH=ON
        -DDISABLE_DBUS=ON
        -DDISABLE_RDMA=ON
        -DDISABLE_DAG=ON
        -DDISABLE_SEPTEL=ON
        -DDISABLE_SNF=ON
        -DDISABLE_TC=ON
        -DDISABLE_PACKET=ON
        -DENABLE_REMOTE=OFF
)

vcpkg_install_cmake()
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

# On Windows 64-bit, libpcap 1.9.1 installs the libraries in a amd64 subdirectory of the usual directories
if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(libsubdir "amd64")
    file(GLOB_RECURSE FILES_TO_MOVE ${CURRENT_PACKAGES_DIR}/lib/${libsubdir}/*)
    file(COPY ${FILES_TO_MOVE} DESTINATION ${CURRENT_PACKAGES_DIR}/lib)
    file(GLOB_RECURSE FILES_TO_MOVE ${CURRENT_PACKAGES_DIR}/debug/lib/${libsubdir}/*)
    file(COPY ${FILES_TO_MOVE} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/lib)
    file(GLOB_RECURSE FILES_TO_MOVE ${CURRENT_PACKAGES_DIR}/bin/${libsubdir}/*)
    file(COPY ${FILES_TO_MOVE} DESTINATION ${CURRENT_PACKAGES_DIR}/bin)
    file(GLOB_RECURSE FILES_TO_MOVE ${CURRENT_PACKAGES_DIR}/debug/bin/${libsubdir}/*)
    file(COPY ${FILES_TO_MOVE} DESTINATION ${CURRENT_PACKAGES_DIR}/debug/bin)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/${libsubdir}
                        ${CURRENT_PACKAGES_DIR}/debug/lib/${libsubdir}
                        ${CURRENT_PACKAGES_DIR}/bin/${libsubdir}
                        ${CURRENT_PACKAGES_DIR}/debug/bin/${libsubdir})
endif()

# Even if compiled with BUILD_SHARED_LIBS=ON, pcap also install a pcap_static library
if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    file(REMOVE ${CURRENT_PACKAGES_DIR}/lib/pcap_static.lib ${CURRENT_PACKAGES_DIR}/debug/lib/pcap_static.lib)
endif()

vcpkg_fixup_pkgconfig(SYSTEM_LIBRARIES ws2_32)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share ${CURRENT_PACKAGES_DIR}/share/man)


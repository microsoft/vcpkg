if(EXISTS "${CURRENT_INSTALLED_DIR}/share/winpcap")
    message(FATAL_ERROR "FATAL ERROR: winpcap and libpcap are incompatible.")
endif()

if(VCPKG_TARGET_IS_LINUX)
    message(
"libpcap currently requires the following libraries from the system package manager:
    flex
    libbison-dev
These can be installed on Ubuntu systems via sudo apt install flex libbison-dev"
    )
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO the-tcpdump-group/libpcap
    REF "libpcap-${VERSION}"
    SHA512 7352ff4d5bded916c0802e4a846fcb6b26e3ea8025dbbf58543abd9d9f6e8f7f5d60e03bcadb222d20434b7e052f663a560d7487af4b81fba74cf5aea040d733
    HEAD_REF master
    PATCHES 
        install-pc-on-msvc.patch
        add-disable-packet-option.patch
)

vcpkg_find_acquire_program(BISON)
get_filename_component(BISON_PATH ${BISON} DIRECTORY)
vcpkg_add_to_path(${BISON_PATH})
vcpkg_find_acquire_program(FLEX)
get_filename_component(FLEX_PATH ${FLEX} DIRECTORY)
vcpkg_add_to_path(${FLEX_PATH})

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" USE_STATIC_RT)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
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
        -DUSE_STATIC_RT=${USE_STATIC_RT}
)

vcpkg_cmake_install()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# On Windows 64-bit, libpcap 1.10.1 installs the libraries in a x64 subdirectory of the usual directories
if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(libsubdir "x64")
    file(GLOB_RECURSE FILES_TO_MOVE "${CURRENT_PACKAGES_DIR}/lib/${libsubdir}/*")
    file(COPY ${FILES_TO_MOVE} DESTINATION "${CURRENT_PACKAGES_DIR}/lib")
    file(GLOB_RECURSE FILES_TO_MOVE "${CURRENT_PACKAGES_DIR}/debug/lib/${libsubdir}/*")
    file(COPY ${FILES_TO_MOVE} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/lib")
    file(GLOB_RECURSE FILES_TO_MOVE "${CURRENT_PACKAGES_DIR}/bin/${libsubdir}/*")
    file(COPY ${FILES_TO_MOVE} DESTINATION "${CURRENT_PACKAGES_DIR}/bin")
    file(GLOB_RECURSE FILES_TO_MOVE "${CURRENT_PACKAGES_DIR}/debug/bin/${libsubdir}/*")
    file(COPY ${FILES_TO_MOVE} DESTINATION "${CURRENT_PACKAGES_DIR}/debug/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/${libsubdir}"
                        "${CURRENT_PACKAGES_DIR}/debug/lib/${libsubdir}"
                        "${CURRENT_PACKAGES_DIR}/bin/${libsubdir}"
                        "${CURRENT_PACKAGES_DIR}/debug/bin/${libsubdir}")
endif()

# Even if compiled with BUILD_SHARED_LIBS=ON, pcap also install a pcap_static library
if(VCPKG_TARGET_IS_WINDOWS AND VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/lib/pcap_static.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/pcap_static.lib")
endif()

vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/share/man")

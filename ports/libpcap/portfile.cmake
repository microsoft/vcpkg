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
    REF c7642e2cc0c5bd65754685b160d25dc23c76c6bd #1.10.1
    SHA512 ed46095863aaee79ca2833d26438f6c837cc3e64acb73efd5a388a11ff7d0d1245d23e5404070a9f2c2c77840c93c09328746761e4481e9a530593a5cbf2ad6f
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
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

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

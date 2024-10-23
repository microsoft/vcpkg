if(EXISTS "${CURRENT_INSTALLED_DIR}/share/winpcap")
    message(FATAL_ERROR "FATAL ERROR: winpcap and libpcap are incompatible.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO the-tcpdump-group/libpcap
    REF "libpcap-${VERSION}"
    SHA512 bb8ba3a589425d71531312285a3c7ded4abdff5ea157b88195e06a2b4f8c93b4db0bca122e9ac853cff14cd16e9519dca30b6bdf0311e7749038fdce57325726
    HEAD_REF master
    PATCHES
        install.diff
        mingw-dynamic-libname.diff
)

vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(FLEX)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" USE_STATIC_RT)

SET(options "")
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_CMAKE_CONFIGURE_OPTIONS MATCHES "Packet_ROOT")
        list(APPEND options "-DPCAP_TYPE=null")
        message(STATUS [[Attention:

This build does not include packet capture capabilities.
In order to enable such capabilities, install the Npcap SDK or the WinPcap SDK,
and pass '-DPacket_ROOT=<path of SDK>' via VCPKG_CMAKE_CONFIGURE_OPTIONS
in a custom triplet file.
]])
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${options}
        -DBUILD_WITH_LIBNL=OFF
        -DDISABLE_AIRPCAP=ON
        -DDISABLE_BLUETOOTH=ON
        -DDISABLE_DAG=ON
        -DDISABLE_DBUS=ON
        -DDISABLE_DPDK=ON
        -DDISABLE_NETMAP=ON
        -DDISABLE_RDMA=ON
        -DDISABLE_SEPTEL=ON
        -DDISABLE_SNF=ON
        -DDISABLE_TC=ON
        -DENABLE_REMOTE=OFF
        "-DLEX_EXECUTABLE=${FLEX}"
        "-DYACC_EXECUTABLE=${BISON}"
        -DUSE_STATIC_RT=${USE_STATIC_RT}
    MAYBE_UNUSED_VARIABLES
        BUILD_WITH_LIBNL  # linux only
        CMAKE_DISABLE_FIND_PACKAGE_Packet # windows only
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

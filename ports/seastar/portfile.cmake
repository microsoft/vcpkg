vcpkg_from_github(OUT_SOURCE_PATH SOURCE_PATH
    REPO scylladb/seastar
    REF seastar-20.05.0
    SHA512 6ff8306e0c7d12faea210853cce27ef465e38ded6069a1f009fd6b586e814f2d32182a66a688aa9bc6e6224c2b1c54f4893ee7617d2bea2e868b6e6d38cf4b8c
    HEAD_REF master
    PATCHES
        libvers.patch
        cmake_dest.patch
)

if(VCPKG_TARGET_IS_LINUX)
    message(STATUS "Seastar currently requires the following libraries from the system package manager:\n    libpciaccess\n    xfslibs\n    libgnutls28\n    libsctp\n    systemtap-sdt\n    libtool\n    valgrind \n\nThese can be installed on Ubuntu systems via apt-get install libpciaccess-dev xfslibs-dev libgnutls28-dev libsctp-dev systemtap-sdt-dev libtool valgrind")
endif()

if("dpdk" IN_LIST FEATURES)
    set(USE_DPDK ON)
else()
    set(USE_DPDK OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSeastar_APPS=OFF
        -DSeastar_DEMOS=OFF
        -DSeastar_DOCS=OFF
        -DSeastar_TESTING=OFF
        -DSeastar_DPDK=${USE_DPDK}
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}  RENAME copyright)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ntop/PF_RING
    REF "${VERSION}"
    SHA512 8b7c0d5532a6f69cee1153594903a115d3262f6a1988a46449bafb29da8ace3fc7437ff46bfc9f73804fa4c8c76bed0df3fd07b9ad1ced05b311bfaf5bf990ad
    HEAD_REF dev
    PATCHES
        use-external-libpcap.patch
)

file(REMOVE_RECURSE "${CURRENT_BUILDTREES_DIR}/kernel")
file(COPY "${SOURCE_PATH}/kernel/linux/pf_ring.h" DESTINATION "${CURRENT_BUILDTREES_DIR}/kernel/linux")

vcpkg_find_acquire_program(BISON)
vcpkg_find_acquire_program(FLEX)

vcpkg_configure_make(
    SOURCE_PATH "${SOURCE_PATH}"
    PROJECT_SUBPATH "userland"
    COPY_SOURCE
    OPTIONS
        --disable-archopt
        --disable-redis
        --disable-zmq
        --disable-ndpi
        --disable-xdp
        ac_cv_header_hiredis_h=no
        ac_cv_lib_nl_nl_handle_alloc=no
        ac_cv_lib_nl_3_nl_socket_alloc=no
        "BPF_INCLUDE=-I${CURRENT_INSTALLED_DIR}/include"
)
string(REPLACE "dynamic" "shared" install_target "install-${VCPKG_LIBRARY_LINKAGE}")
vcpkg_install_make(
    SUBPATH "lib"
    INSTALL_TARGET "${install_target}"
    OPTIONS
        "LEX=${FLEX}"
        "YACC=${BISON}"
)

file(INSTALL "${CURRENT_BUILDTREES_DIR}/kernel/linux/pf_ring.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/linux")

vcpkg_install_copyright(
    COMMENT [[
The user-space PF_RING library source code is distributed under the LGPLv2.1.
The library is built using binary objects from the userland/lib/libs directory
which adds an NTOP END USER LICENSE AGREEMENT.
]]
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/userland/lib/libs/EULA.txt"
        "${SOURCE_PATH}/userland/lib/third_party/uthash.h"
)
